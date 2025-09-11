import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:kgsyks_destek/firebase_options.dart';
import 'package:kgsyks_destek/go_router/router.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await FirebaseAuth.instance.setLanguageCode('tr');
  // Flutter framework’te yakalanmamış fatal hataları Crashlytics’e gönder
  FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;
  PlatformDispatcher.instance.onError = (error, stack) {
    FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
    return true;
  };
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'KGS YKS Destek',
      theme: ThemeData(
        useMaterial3: true,
        fontFamily: GoogleFonts.montserrat(
          fontWeight: FontWeight.w600,
        ).fontFamily,
      ),
      debugShowCheckedModeBanner: false,
      routerConfig: router,
    );
  }
}
