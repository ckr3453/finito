const { onSchedule } = require("firebase-functions/v2/scheduler");
const { defineSecret } = require("firebase-functions/params");
const { initializeApp } = require("firebase-admin/app");
const { getFirestore, Timestamp } = require("firebase-admin/firestore");
const { getAuth } = require("firebase-admin/auth");
const nodemailer = require("nodemailer");

initializeApp();

const gmailUser = defineSecret("GMAIL_USER");
const gmailAppPassword = defineSecret("GMAIL_APP_PASSWORD");

/**
 * Scheduled function: runs every 5 minutes.
 * Checks all users' tasks for reminders that are due and sends email.
 */
exports.sendReminderEmails = onSchedule(
  {
    schedule: "every 5 minutes",
    timeZone: "Asia/Seoul",
    secrets: [gmailUser, gmailAppPassword],
  },
  async () => {
    const db = getFirestore();
    const auth = getAuth();
    const now = Timestamp.now();

    const transporter = nodemailer.createTransport({
      service: "gmail",
      auth: {
        user: gmailUser.value(),
        pass: gmailAppPassword.value(),
      },
    });

    // Get all users
    const usersSnapshot = await db.collection("users").listDocuments();

    for (const userDoc of usersSnapshot) {
      const userId = userDoc.id;

      // Get tasks with reminder due and not yet sent
      const tasksSnapshot = await db
        .collection(`users/${userId}/tasks`)
        .where("reminderTime", "<=", now)
        .where("status", "==", "pending")
        .where("reminderEmailSent", "==", false)
        .get();

      if (tasksSnapshot.empty) continue;

      // Get user email from Firebase Auth
      let userEmail;
      try {
        const userRecord = await auth.getUser(userId);
        userEmail = userRecord.email;
      } catch {
        console.log(`User ${userId} not found in Auth, skipping.`);
        continue;
      }

      if (!userEmail) {
        console.log(`User ${userId} has no email, skipping.`);
        continue;
      }

      // Send email for each task
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
          : "없음";

        const mailOptions = {
          from: `Finito <${gmailUser.value()}>`,
          to: userEmail,
          subject: `[Finito] ${task.title}`,
          html: `
            <div style="font-family: sans-serif; max-width: 480px; margin: 0 auto;">
              <h2 style="color: #1976D2;">Finito - 리마인더</h2>
              <div style="background: #f5f5f5; padding: 16px; border-radius: 8px;">
                <h3 style="margin: 0 0 8px;">${task.title}</h3>
                ${task.description ? `<p style="color: #666; margin: 0 0 8px;">${task.description}</p>` : ""}
                <p style="margin: 4px 0; font-size: 14px;">
                  <strong>우선순위:</strong> ${priorityLabel}
                </p>
                <p style="margin: 4px 0; font-size: 14px;">
                  <strong>마감일:</strong> ${dueDateStr}
                </p>
              </div>
              <p style="color: #999; font-size: 12px; margin-top: 16px;">
                이 이메일은 Finito 앱에서 설정한 리마인더입니다.
              </p>
            </div>
          `,
        };

        try {
          await transporter.sendMail(mailOptions);
          // Mark as sent
          await taskDoc.ref.update({ reminderEmailSent: true });
          console.log(`Reminder sent to ${userEmail} for task: ${task.title}`);
        } catch (error) {
          console.error(
            `Failed to send email to ${userEmail}: ${error.message}`
          );
        }
      }
    }
  }
);
