import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gemini/flutter_gemini.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kgsyks_destek/cloud_message/services.dart';
import 'package:kgsyks_destek/const.dart';
import 'package:kgsyks_destek/firebase_options.dart';
import 'package:kgsyks_destek/go_router/router.dart';
import 'package:kgsyks_destek/sign/kontrol_db.dart';
import 'package:kgsyks_destek/theme_section/custom_theme.dart';
import 'package:permission_handler/permission_handler.dart';

Future<bool> _hasConnection() async {
  final result = await Connectivity().checkConnectivity();
  return result.any((r) => r != ConnectivityResult.none);
}

final settingStorage = BooleanSettingStorage();
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
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

    initLocalNotifications();
    setupFCM();
    await subscribeToTopic('all');

    if (Platform.isAndroid) {
      await Permission.notification.request();
    }

    Gemini.init(apiKey: geminiApiKey);
  } else {
    // offline modda sadece lokal işleyiş
    debugPrint('Başlangıç: internet yok, Firebase başlatılmadı');
  }
  await settingStorage.initializeDatabase();

  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
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
