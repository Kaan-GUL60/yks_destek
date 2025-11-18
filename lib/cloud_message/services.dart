import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

final FlutterLocalNotificationsPlugin fln = FlutterLocalNotificationsPlugin();

void initLocalNotifications(void Function(String?) onNotificationTap) {
  // 🎯 1. Parametreyi al
  const androidSettings = AndroidInitializationSettings(
    '@mipmap/launcher_icon',
  );

  // 🎯 2. iOS ayarlarını tanımla
  // (Bildirime tıklandığında uygulamanın açılması için bu ayarlar GEREKLİDİR)
  const DarwinInitializationSettings iosSettings = DarwinInitializationSettings(
    requestAlertPermission: true,
    requestBadgePermission: true,
    requestSoundPermission: true,
    // (Uygulama ön plandayken bildirim gelirse ne olacağını belirler)
    defaultPresentAlert: true,
    defaultPresentBadge: true,
    defaultPresentSound: true,
  );

  tz.initializeTimeZones(); // Zaman dilimi desteği

  fln.initialize(
    const InitializationSettings(
      android: androidSettings,
      iOS: iosSettings, // 🎯 3. iOS ayarlarını buraya ver
    ),

    // ==========================================================
    // 🎯 4. EKSİK OLAN KISIM (En Önemlisi)
    // ==========================================================
    // Uygulama AÇIKKEN veya ARKA PLANDA iken
    // bildirime tıklandığında bu fonksiyon tetiklenir.
    onDidReceiveNotificationResponse: (NotificationResponse response) {
      debugPrint(
        "onDidReceiveNotificationResponse tetiklendi! Payload: ${response.payload}",
      );

      // main.dart'tan gelen yönlendirme fonksiyonunu çağır
      onNotificationTap(response.payload);
    },
  );
}

// ==========================================================
// 🔹 BU FONKSİYON DEĞİŞMEDİ (FCM BİLDİRİMLERİ İÇİN)
// ==========================================================
void showNotification(RemoteMessage message) {
  fln.show(
    0,
    message.notification?.title ?? 'Başlık',
    message.notification?.body ?? 'Mesaj',
    NotificationDetails(
      android: AndroidNotificationDetails(
        'channel_id',
        'channel_name',
        importance: Importance.max,
        priority: Priority.high,
        icon: '@mipmap/launcher_icon',
      ),
    ),
  );
}

// ==========================================================
// 🔹 BU FONKSİYON GÜNCELLENDİ (HATA DÜZELTİLDİ)
// ==========================================================
Future<void> scheduleLocalNotification({
  required int
  notificationId, // 🎯 DEĞİŞİKLİK 1: Adı 'id' -> 'notificationId' oldu
  required int soruId,
  required String title,
  required String body,
  required DateTime scheduledTime,
  String? imagePath,
}) async {
  // --- 1. Resim var mı diye kontrol et ---
  final bool hasImage = imagePath != null && imagePath.isNotEmpty;

  // --- 2. Android Detaylarını Dinamik Oluştur ---
  AndroidNotificationDetails androidDetails;

  if (hasImage) {
    final BigPictureStyleInformation bigPictureStyle =
        BigPictureStyleInformation(
          FilePathAndroidBitmap(imagePath),
          largeIcon: FilePathAndroidBitmap(imagePath),
          contentTitle: title,
          summaryText: body,
        );

    androidDetails = AndroidNotificationDetails(
      'hatirlatma_kanali_resimli',
      'Hatırlatmalar (Resimli)',
      channelDescription: 'Resim içeren hatırlatma bildirimleri',
      importance: Importance.max,
      priority: Priority.high,
      styleInformation: bigPictureStyle,
      icon: '@mipmap/launcher_icon',
    );
  } else {
    androidDetails = const AndroidNotificationDetails(
      'hatirlatma_kanali',
      'Hatırlatmalar',
      channelDescription:
          'Kullanıcının seçtiği tarihlerde hatırlatma bildirimi',
      importance: Importance.max,
      priority: Priority.high,
      icon: '@mipmap/launcher_icon',
    );
  }

  // --- 3. iOS Detaylarını Dinamik Oluştur ---
  DarwinNotificationDetails iosDetails;

  if (hasImage) {
    iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
      attachments: [DarwinNotificationAttachment(imagePath)],
      // 🎯 HATA DÜZELTMESİ: Parametre buradan kaldırıldı.
    );
  } else {
    iosDetails = const DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
      // 🎯 HATA DÜZELTMESİ: Parametre buradan kaldırıldı.
    );
  }

  // --- 4. Platforma özel detayları birleştir ---
  final NotificationDetails notificationDetails = NotificationDetails(
    android: androidDetails,
    iOS: iosDetails,
  );
  AndroidScheduleMode scheduleMode =
      AndroidScheduleMode.inexact; // Varsayılan (Güvenli)

  // İzin verilmiş mi diye kontrol et
  if (await Permission.scheduleExactAlarm.isGranted) {
    scheduleMode =
        AndroidScheduleMode.exactAllowWhileIdle; // İzin varsa 'exact' kullan
  }

  // --- 5. Bildirimi planla ---
  await fln.zonedSchedule(
    notificationId,
    title,
    body,
    tz.TZDateTime.from(scheduledTime, tz.local),
    notificationDetails,
    payload: soruId.toString(),
    androidScheduleMode: scheduleMode, // exact alarm izni istemiyorsan
  );
}

// ==========================================================
// 🔹 BU FONKSİYON DEĞİŞMEDİ
// ==========================================================
Future<void> subscribeToTopic(String topic) async {
  await FirebaseMessaging.instance.subscribeToTopic(topic);
  //print("Subscribed to $topic");
}

// ==========================================================
// 🔹 BU FONKSİYON DEĞİŞMEDİ
// ==========================================================
void setupFCM() {
  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    showNotification(message);
  });
}
