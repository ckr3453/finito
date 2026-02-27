const { onSchedule } = require("firebase-functions/v2/scheduler");
const { initializeApp } = require("firebase-admin/app");
const { getFirestore, Timestamp } = require("firebase-admin/firestore");
const { getMessaging } = require("firebase-admin/messaging");

initializeApp();

/**
 * Scheduled function: runs every 5 minutes.
 * Checks all users' tasks for reminders that are due and sends FCM push.
 */
exports.sendReminderPush = onSchedule(
  {
    schedule: "every 5 minutes",
    timeZone: "Asia/Seoul",
  },
  async () => {
    const db = getFirestore();
    const messaging = getMessaging();
    const now = Timestamp.now();

    // Get all users
    const usersSnapshot = await db.collection("users").listDocuments();

    for (const userDoc of usersSnapshot) {
      const userId = userDoc.id;

      // Get tasks with reminder due and not yet sent
      const tasksSnapshot = await db
        .collection(`users/${userId}/tasks`)
        .where("reminderTime", "<=", now)
        .where("status", "==", "pending")
        .where("reminderPushSent", "==", false)
        .get();

      if (tasksSnapshot.empty) continue;

      // Get user's FCM tokens
      const tokensSnapshot = await db
        .collection(`users/${userId}/fcmTokens`)
        .get();

      if (tokensSnapshot.empty) {
        console.log(`User ${userId} has no FCM tokens, skipping.`);
        continue;
      }

      const tokens = tokensSnapshot.docs.map((doc) => doc.data().token);

      // Send push for each task
      for (const taskDoc of tasksSnapshot.docs) {
        const task = taskDoc.data();

        const priorityLabel = {
          high: "HIGH",
          medium: "MED",
          low: "LOW",
        }[task.priority] || task.priority;

        const dueDateStr = task.dueDate
          ? new Date(task.dueDate.seconds * 1000).toLocaleString("ko-KR", {
              timeZone: "Asia/Seoul",
            })
          : "";

        const body = [
          task.description || "",
          dueDateStr ? `마감: ${dueDateStr}` : "",
          `우선순위: ${priorityLabel}`,
        ]
          .filter(Boolean)
          .join(" | ");

        const message = {
          notification: {
            title: task.title,
            body: body,
          },
          data: {
            taskId: taskDoc.id,
          },
          tokens: tokens,
        };

        try {
          const response = await messaging.sendEachForMulticast(message);
          console.log(
            `Push sent for task "${task.title}" to ${userId}: ${response.successCount} success, ${response.failureCount} failure`
          );

          // Clean up invalid tokens
          const tokensToDelete = [];
          response.responses.forEach((resp, idx) => {
            if (
              resp.error &&
              (resp.error.code === "messaging/registration-token-not-registered" ||
                resp.error.code === "messaging/invalid-registration-token")
            ) {
              tokensToDelete.push(tokensSnapshot.docs[idx].ref);
            }
          });

          if (tokensToDelete.length > 0) {
            const batch = db.batch();
            tokensToDelete.forEach((ref) => batch.delete(ref));
            await batch.commit();
            console.log(
              `Cleaned up ${tokensToDelete.length} invalid tokens for user ${userId}`
            );
          }

          // Mark as sent
          await taskDoc.ref.update({ reminderPushSent: true });
        } catch (error) {
          console.error(
            `Failed to send push for task "${task.title}" to ${userId}: ${error.message}`
          );
        }
      }
    }
  }
);
