importScripts('https://www.gstatic.com/firebasejs/10.12.2/firebase-app-compat.js');
importScripts('https://www.gstatic.com/firebasejs/10.12.2/firebase-messaging-compat.js');

firebase.initializeApp({
  apiKey: "AIzaSyBc_PBSq6g-dxacKjyxtonRVpjOG-V2aiI",
  authDomain: "finito-f95ea.firebaseapp.com",
  projectId: "finito-f95ea",
  storageBucket: "finito-f95ea.firebasestorage.app",
  messagingSenderId: "1014105605136",
  appId: "1:1014105605136:web:6cb0adf050e97a2974b695",
});

const messaging = firebase.messaging();

messaging.onBackgroundMessage((payload) => {
  const title = payload.notification?.title ?? 'Finito';
  const body = payload.notification?.body ?? '';
  const taskId = payload.data?.taskId;

  return self.registration.showNotification(title, {
    body: body,
    icon: '/icons/Icon-192.png',
    data: { taskId: taskId },
  });
});

self.addEventListener('notificationclick', (event) => {
  event.notification.close();

  const taskId = event.notification.data?.taskId;
  const url = taskId ? `/#/task/${taskId}` : '/';

  event.waitUntil(
    clients.matchAll({ type: 'window', includeUncontrolled: true }).then((windowClients) => {
      for (const client of windowClients) {
        if (client.url.includes(self.location.origin)) {
          client.focus();
          client.postMessage({ type: 'notification_tap', taskId: taskId });
          return;
        }
      }
      return clients.openWindow(url);
    })
  );
});
