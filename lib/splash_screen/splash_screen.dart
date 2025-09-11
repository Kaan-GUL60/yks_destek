import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kgsyks_destek/analytics_helper/analytics_helper.dart';
import 'package:kgsyks_destek/go_router/router.dart';
import 'package:kgsyks_destek/provider.dart';
import 'package:kgsyks_destek/sign/bilgi_database_helper.dart';
import 'package:kgsyks_destek/sign/save_data.dart';

class SplashScreen extends ConsumerWidget {
  SplashScreen({super.key});

  final UserAuth authered = UserAuth();
  final KullaniciDatabaseHelper dbHelper = KullaniciDatabaseHelper.instance;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen<AsyncValue<User?>>(authStateChangesProvider, (prev, next) {
      next.whenData((user) {
        Future.microtask(() async {
          if (user == null) {
            router.goNamed(AppRoute.signUp.name);
          } else {
            final kullanici = await dbHelper.getKullanici();

            if (kullanici == null) {
              router.goNamed(AppRoute.signUp.name);
              return;
            } else {
              AnalyticsService().trackCount(
                "uyg_acilma_sayisi",
                "splash_screen",
              );
              router.goNamed(AppRoute.anaekran.name);
            }
          }
        });
      });
    });

    return Scaffold(
      backgroundColor: Color.fromARGB(255, 11, 21, 31),
      body: Center(
        child: Stack(
          alignment: Alignment.center,
          children: [
            SizedBox(height: double.infinity, width: double.infinity),
            Center(child: Image.asset('assets/logo/logo.png', width: 150)),
            Positioned(
              bottom: 50,
              child: Image.asset('assets/logo/branding.png', width: 200),
            ),
          ],
        ),
      ),
    );
  }
}
