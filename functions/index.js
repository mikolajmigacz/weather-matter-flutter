const { onDocumentCreated } = require("firebase-functions/v2/firestore");
const { initializeApp } = require("firebase-admin/app");
const { getMessaging } = require("firebase-admin/messaging");
const { getFirestore } = require("firebase-admin/firestore");
const logger = require("firebase-functions/logger");

initializeApp();

exports.onNewNotification = onDocumentCreated("notifications/{notificationId}", async (event) => {
  logger.info("Push notification function triggered", { 
    notificationId: event.params.notificationId,
    data: event.data.data()
  });

  const notification = event.data.data();

  try {
    const message = {
      token: notification.fcmToken,
      data: {
        notificationId: event.params.notificationId,
        timestamp: Date.now().toString(),
      },
      notification: {
        title: notification.title,
        body: notification.body,
      },
      webpush: {
        headers: {
          Urgency: "high",
          TTL: "86400"
        },
        notification: {
          title: notification.title,
          body: notification.body,
          icon: "/icons/Icon-192.png",
          requireInteraction: true,
          vibrate: [200, 100, 200],
          actions: [
            {
              action: 'open',
              title: 'Open App'
            }
          ],
          data: {
            notificationId: event.params.notificationId,
            url: '/'
          }
        },
        fcmOptions: {
          link: "/"
        }
      }
    };

    logger.info("Sending message:", message);

    const response = await getMessaging().send(message);
    logger.info("Notification sent successfully", { 
      messageId: response,
      token: notification.fcmToken 
    });

    return response;
  } catch (error) {
    logger.error("Error sending notification:", { 
      error: error.message,
      stack: error.stack
    });
    throw error;
  }
});