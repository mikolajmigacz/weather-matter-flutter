import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

class PushNotificationService {
  static final PushNotificationService _instance =
      PushNotificationService._internal();
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  factory PushNotificationService() {
    return _instance;
  }

  PushNotificationService._internal();

  Future<void> initialize() async {
    if (kIsWeb) {
      try {
        NotificationSettings settings =
            await _firebaseMessaging.requestPermission(
          alert: true,
          badge: true,
          sound: true,
        );

        debugPrint('User granted permission: ${settings.authorizationStatus}');

        // Get FCM token
        String? token = await _firebaseMessaging.getToken();
        debugPrint('FCM Token: $token');

        // Handle token refresh
        FirebaseMessaging.instance.onTokenRefresh.listen((token) {
          debugPrint('FCM Token refreshed: $token');
        });

        // Handle foreground messages
        FirebaseMessaging.onMessage.listen((RemoteMessage message) {
          debugPrint('Received foreground message: ${message.messageId}');
          debugPrint('Message data: ${message.data}');
          debugPrint('Message notification: ${message.notification?.title}');
          debugPrint('Message notification: ${message.notification?.body}');
        });

        // Handle background/terminated messages
        FirebaseMessaging.onBackgroundMessage(
            _firebaseMessagingBackgroundHandler);
      } catch (e) {
        debugPrint('Error initializing push notifications: $e');
      }
    }
  }

  Future<void> showNotification({
    required String title,
    required String body,
  }) async {
    if (kIsWeb) {
      try {
        await _firebaseMessaging.sendMessage(
          data: {
            'title': title,
            'body': body,
          },
        );
        debugPrint('Notification sent successfully');
      } catch (e) {
        debugPrint('Error sending notification: $e');
      }
    }
  }
}

// Top-level function for handling background messages
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  debugPrint('Handling background message: ${message.messageId}');
}
