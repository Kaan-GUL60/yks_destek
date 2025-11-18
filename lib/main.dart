import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gemini/flutter_gemini.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kgsyks_destek/cloud_message/services.dart';
import 'package:kgsyks_destek/const.dart';
import 'package:kgsyks_destek/firebase_options.dart';
import 'package:kgsyks_destek/go_router/router.dart';
import 'package:kgsyks_destek/sign/kontrol_db.dart';
import 'package:kgsyks_destek/theme_section/custom_theme.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:kgsyks_destek/pages/soru_ekle/database_helper.dart';

//final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
void handleNotificationTap(String? payload) {
  debugPrint("=============== NOTIFICATION TAP HANDLER ===============");
  debugPrint("Payload alındı: $payload");

  if (payload != null && payload.isNotEmpty) {
    try {
      final int soruId = int.parse(payload);
      debugPrint("Payload '$soruId' tamsayısına (int) çevrildi.");

      router.goNamed(
        AppRoute.soruViewer.name,
        pathParameters: {'id': soruId.toString()},
      );
      debugPrint(
        "router.goNamed çağrıldı: ${AppRoute.soruViewer.name} / $soruId",
      );
    } catch (e) {
      debugPrint(
        "Payload (soruId) parse edilirken VEYA yönlendirilirken HATA: $e",
      );
    }
  } else {
    debugPrint("Payload boş veya null. Yönlendirme yapılmadı.");
  }
  debugPrint("==========================================================");
}

Future<bool> _hasConnection() async {
  final result = await Connectivity().checkConnectivity();
  return result.any((r) => r != ConnectivityResult.none);
}

final settingStorage = BooleanSettingStorage();
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  String? notificationLaunchPayload;
  final online = await _hasConnection();
  if (online) {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    await FirebaseAuth.instance.setLanguageCode('tr');

    FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;
    PlatformDispatcher.instance.onError = (error, stack) {
      FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
      return true;
    };

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      showNotification(message);
    });

    initLocalNotifications(handleNotificationTap);

    final NotificationAppLaunchDetails? launchDetails = await fln
        .getNotificationAppLaunchDetails();
    if (launchDetails?.didNotificationLaunchApp ?? false) {
      notificationLaunchPayload = launchDetails!.notificationResponse?.payload;
      debugPrint("Payload (terminated) kaydedildi: $notificationLaunchPayload");
    }
    setupFCM();
    await subscribeToTopic('all');

    if (Platform.isAndroid) {
      await Permission.notification.request();
      await fln
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >()
          ?.requestExactAlarmsPermission();
    }

    Gemini.init(apiKey: geminiApiKey);
  } else {
    // offline modda sadece lokal işleyiş
    debugPrint('Başlangıç: internet yok, Firebase başlatılmadı');
    initLocalNotifications(handleNotificationTap);

    final NotificationAppLaunchDetails? launchDetails = await fln
        .getNotificationAppLaunchDetails();
    if (launchDetails?.didNotificationLaunchApp ?? false) {
      notificationLaunchPayload = launchDetails!.notificationResponse?.payload;
      debugPrint(
        "Payload (offline-terminated) kaydedildi: $notificationLaunchPayload",
      );
    }
    if (Platform.isAndroid) {
      await Permission.notification.request();
      await fln
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >()
          ?.requestExactAlarmsPermission();
    }
  }
  await settingStorage.initializeDatabase();
  await DatabaseHelper.instance.database;

  debugPrint("Tüm veritabanları başlatıldı.");

  router = createRouter(notificationLaunchPayload);

  // ==========================================================
  // 🎯 2. DEĞİŞİKLİK: MyApp'e artık payload göndermeye gerek yok
  // ==========================================================
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'KGS YKS Destek',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,

      // Cihazın sistem temasına göre otomatik geçiş
      themeMode: ThemeMode.system,
      debugShowCheckedModeBanner: false,
      routerConfig: router,
    );
  }
}
