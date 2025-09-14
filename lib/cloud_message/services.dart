import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

final FlutterLocalNotificationsPlugin fln = FlutterLocalNotificationsPlugin();

void initLocalNotifications() {
  const androidSettings = AndroidInitializationSettings(
    '@mipmap/launcher_icon',
  );
  fln.initialize(const InitializationSettings(android: androidSettings));
}

void showNotification(RemoteMessage message) {
  fln.show(
    0,
    message.notification?.title ?? 'Başlık',
    message.notification?.body ?? 'Mesaj',
    NotificationDetails(
      android: AndroidNotificationDetails(
        'channel_id',
        'channel_name',
        importance:
            Importance.max, // 🔑 FlutterLocalNotifications importu ile enum
        priority: Priority.high,
      ),
    ),
  );
}

Future<void> subscribeToTopic(String topic) async {
  await FirebaseMessaging.instance.subscribeToTopic(topic);
  //print("Subscribed to $topic");
}

void setupFCM() {
  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    showNotification(message);
  });
}
