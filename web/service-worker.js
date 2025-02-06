importScripts("https://www.gstatic.com/firebasejs/9.23.0/firebase-app-compat.js");
importScripts("https://www.gstatic.com/firebasejs/9.23.0/firebase-messaging-compat.js");

const CACHE_NAME = "weather-matter-v1";
const OFFLINE_URL = "/offline.html";
const STATIC_RESOURCES = [
  "/",
  "/index.html",
  "/main.dart.js",
  "/flutter.js",
  "/manifest.json",
  "/icons/Icon-192.png",
  "/icons/Icon-512.png",
  "/offline.html",
  "/favicon.png"
];

// APIs that should trigger offline mode when failed
const API_PATTERNS = [
  "dataservice.accuweather.com",
  "firestore.googleapis.com",
  "locations/v1/cities"
];

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
  console.log('[SW] Installing...');
  event.waitUntil(
    caches.open(CACHE_NAME)
      .then(cache => {
        console.log('[SW] Pre-caching offline page and static assets');
        return cache.addAll(STATIC_RESOURCES);
      })
  );
  self.skipWaiting();
});

self.addEventListener('activate', (event) => {
  console.log('[SW] Activating...');
  event.waitUntil(
    caches.keys().then(cacheNames => {
      return Promise.all(
        cacheNames.map(cacheName => {
          if (cacheName !== CACHE_NAME) {
            return caches.delete(cacheName);
          }
        })
      );
    }).then(() => {
      return clients.claim();
    })
  );
});

function isApiRequest(url) {
  return API_PATTERNS.some(pattern => url.includes(pattern));
}

async function handleApiFailure() {
  const cache = await caches.open(CACHE_NAME);
  const offlinePage = await cache.match(OFFLINE_URL);
  if (offlinePage) {
    return new Response(await offlinePage.blob(), {
      headers: { 'Content-Type': 'text/html' }
    });
  }
  return new Response('Offline', { status: 503 });
}

self.addEventListener('fetch', (event) => {
  const url = event.request.url;
  console.log('[SW] Fetch event for:', url);

  // Handle API requests
  if (isApiRequest(url)) {
    event.respondWith(
      fetch(event.request).catch(async () => {
        console.log('[SW] API request failed, showing offline page');
        const response = await handleApiFailure();
        // Force reload the page to show offline state
        clients.matchAll().then(clients => {
          clients.forEach(client => client.navigate(client.url));
        });
        return response;
      })
    );
    return;
  }

  // Handle navigation requests
  if (event.request.mode === 'navigate') {
    event.respondWith(
      fetch(event.request).catch(() => {
        console.log('[SW] Navigation failed, serving offline page');
        return caches.match(OFFLINE_URL);
      })
    );
    return;
  }

  // Handle other requests
  event.respondWith(
    caches.match(event.request).then(cachedResponse => {
      if (cachedResponse) {
        console.log('[SW] Serving from cache:', url);
        return cachedResponse;
      }

      return fetch(event.request)
        .then(response => {
          if (!response || response.status !== 200 || response.type !== 'basic') {
            return response;
          }

          const responseToCache = response.clone();
          caches.open(CACHE_NAME).then(cache => {
            cache.put(event.request, responseToCache);
          });

          return response;
        })
        .catch(() => {
          if (event.request.destination === 'document') {
            return caches.match(OFFLINE_URL);
          }
          return new Response('Offline', { status: 503 });
        });
    })
  );
});

messaging.onBackgroundMessage((payload) => {
  console.log('[SW] Background message:', payload);
  const notificationTitle = payload.notification.title;
  const notificationOptions = {
    body: payload.notification.body,
    icon: '/icons/Icon-192.png',
    badge: '/icons/Icon-192.png',
    tag: 'weather-notification',
    requireInteraction: true,
    vibrate: [200, 100, 200]
  };

  return self.registration.showNotification(notificationTitle, notificationOptions);
});