importScripts("https://www.gstatic.com/firebasejs/9.23.0/firebase-app-compat.js");
importScripts("https://www.gstatic.com/firebasejs/9.23.0/firebase-messaging-compat.js");

firebase.initializeApp({
  apiKey: dotenv.env['F_API_KEY'],
  authDomain: dotenv.env['F_AUTH_DOMAIN'],
  projectId: dotenv.env['F_PROJECT_ID'],
  storageBucket: dotenv.env['F_STORAGE_BUCKET'],
  messagingSenderId: dotenv.env['F_MESSAGING_SENDER_ID'],
  appId: dotenv.env['F_APP_ID']
});

const messaging = firebase.messaging();

self.addEventListener('install', (event) => {
  console.log('[Service Worker] Installing Service Worker...', event);
  self.skipWaiting();
});

self.addEventListener('activate', (event) => {
  console.log('[Service Worker] Activating Service Worker...', event);
  return self.clients.claim();
});

self.addEventListener('push', function(event) {
  console.log('[Service Worker] Push received:', event);
  
  if (event.data) {
    try {
      const data = event.data.json();
      console.log('[Service Worker] Push data:', data);

      const notificationTitle = data.notification.title || 'Weather Matter';
      const notificationOptions = {
        body: data.notification.body || 'New notification',
        icon: '/icons/Icon-192.png',
        badge: '/icons/Icon-192.png',
        tag: 'weather-notification',
        requireInteraction: true,
        vibrate: [200, 100, 200],
        data: data.data || {}
      };

      event.waitUntil(
        self.registration.showNotification(notificationTitle, notificationOptions)
      );
    } catch (error) {
      console.error('[Service Worker] Error processing push data:', error);
    }
  } else {
    console.log('[Service Worker] Push event but no data');
  }
});

messaging.onBackgroundMessage((payload) => {
  console.log('[Service Worker] Received background message:', payload);

  const notificationTitle = payload.notification.title;
  const notificationOptions = {
    body: payload.notification.body,
    icon: '/icons/Icon-192.png',
    badge: '/icons/Icon-192.png',
    tag: 'weather-notification',
    requireInteraction: true,
    vibrate: [200, 100, 200],
    data: payload.data || {}
  };

  return self.registration.showNotification(notificationTitle, notificationOptions);
});

self.addEventListener('notificationclick', (event) => {
  console.log('[Service Worker] Notification clicked:', event);
  event.notification.close();

  event.waitUntil(
    clients.openWindow('/')
  );
});