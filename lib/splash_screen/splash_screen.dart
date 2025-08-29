import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kgsyks_destek/go_router/router.dart';
import 'package:kgsyks_destek/provider.dart';

class SplashScreen extends ConsumerWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen<AsyncValue<User?>>(authStateChangesProvider, (prev, next) {
      next.whenData((user) {
        Future.microtask(() {
          if (user == null) {
            router.goNamed(AppRoute.signIn.name);
          } else {
            router.goNamed(AppRoute.anaekran.name);
          }
        });
      });
    });

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
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
