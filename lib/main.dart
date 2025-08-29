import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:kgsyks_destek/firebase_options.dart';
import 'package:kgsyks_destek/go_router/router.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await FirebaseAuth.instance.setLanguageCode('tr');
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
