import 'dart:io';

import 'package:app_tracking_transparency/app_tracking_transparency.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kgsyks_destek/analytics_helper/analytics_helper.dart';
import 'package:kgsyks_destek/go_router/router.dart';
import 'package:kgsyks_destek/main.dart';
import 'package:kgsyks_destek/sign/bilgi_database_helper.dart';
import 'package:kgsyks_destek/splash_screen/local_counter_helper.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

class SplashScreen extends ConsumerWidget {
  SplashScreen({super.key});

  //final UserAuth authered = UserAuth();
  final KullaniciDatabaseHelper dbHelper = KullaniciDatabaseHelper.instance;
  final LocalCounterHelper localCounter = LocalCounterHelper.instance;

  Future<bool> _hasConnection() async {
    final results = await Connectivity().checkConnectivity();
    return results.any((r) => r != ConnectivityResult.none);
  }

  Future<bool> _isUserRegisteredLocally() async {
    final bool isUserRegistered = await settingStorage.getSetting();
    return isUserRegistered;
  }

  Future<void> _initAppTracking() async {
    if (Platform.isIOS) {
      try {
        final status =
            await AppTrackingTransparency.trackingAuthorizationStatus;
        if (status == TrackingStatus.notDetermined) {
          // Kullanıcıya izni sor
          await Future.delayed(const Duration(milliseconds: 200));
          await AppTrackingTransparency.requestTrackingAuthorization();
        }
      } catch (e) {
        debugPrint("ATT Hatası: $e");
      }
    }
  }

  // Yönlendirme mantığını içeren ana asenkron fonksiyon
  Future<void> _navigateToNextScreen(BuildContext context) async {
    // Tüm kontrolleri yapmadan önce bekleyin
    await _initAppTracking();

    // Bekleme süresi
    await Future.delayed(const Duration(milliseconds: 400));

    final online = await _hasConnection();
    final isRegisteredLocally = await _isUserRegisteredLocally();

    if (!online) {
      // 1. İnternet Yok: Sadece Local Sayaç + Ana Ekran
      if (!isRegisteredLocally) {
        // İnternet yok ve kullanıcı kayıtlı değilse, kayıt/giriş ekranına yönlendir
        router.goNamed(AppRoute.signUp.name);
        return;
      } else {
        final count = await localCounter.increment();
        debugPrint("Offline açılma sayısı: $count");
        router.goNamed(AppRoute.anaekran.name);
        return;
      }
    }

    // 2. İnternet Var

    // YEREL KULLANICI KAYDI KONTROLÜ

    if (isRegisteredLocally) {
      // KULLANICI DETAY BİLGİLERİ KONTROLÜ (getKullanici metodu ile)
      final kullaniciDetay = await dbHelper
          .getKullanici(); // dbHelper direkt çağırıldı

      if (kullaniciDetay != null) {
        //print(kullaniciDetay.userName);
        // A) HEM BOOL TRUE HEM DETAY BİLGİSİ VARSA -> ANA EKRAN
        //print("******************************$kullaniciDetay");

        // Online açılma analytics
        AnalyticsService().trackCount("uyg_acilma_sayisi", "splash_screen");

        final doc = await FirebaseFirestore.instance
            .collection('users')
            .doc(kullaniciDetay.uid)
            .get();
        if (doc.exists || doc.data() == null || doc.data()!.isEmpty) {
          // Kullanıcı belgesi yoksa veya boşsa, Firestore'a kaydet
          await FirebaseFirestore.instance
              .collection('users')
              .doc(kullaniciDetay.uid)
              .set({
                'userName': kullaniciDetay.userName,
                'email': kullaniciDetay.email,
                'uid': kullaniciDetay.uid,
                'profilePhotos': kullaniciDetay.profilePhotos,
                'sinif': kullaniciDetay.sinif,
                'sinav': kullaniciDetay.sinav,
                'alan': kullaniciDetay.alan,
                'kurumKodu': kullaniciDetay.kurumKodu,
                'isPro': kullaniciDetay.isPro,
                'createdAt': FieldValue.serverTimestamp(),
              });
        }
        // Offline sayacı Firebase'e gönder ve sıfırla
        final offlineCount = await localCounter.getCount();
        if (offlineCount > 0) {
          AnalyticsService().trackCount(
            "offline_acilma_toplam",
            "splash_screen:$offlineCount",
          );
        }

        router.goNamed(AppRoute.anaekran.name);
      } else {
        // B) BOOL TRUE FAKAT DETAY BİLGİSİ YOKSA -> BİLGİ GİRİŞ EKRANI
        // Not: Bilgi Giriş ekranınızın adını (route name) AppRoute içinde varsayılan olarak 'bilgiGiris' kabul ettim.
        router.goNamed(AppRoute.bilgiAl.name);
      }
    } else {
      // C) BOOL FALSE İSE -> KAYIT/GİRİŞ EKRANI
      router.goNamed(AppRoute.signUp.name);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // auth state dinleme SENKRON
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _navigateToNextScreen(context);
    });
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 11, 21, 31),
      body: Center(child: Image.asset('assets/logo/logo.png', width: 150)),
    );
  }
}

/*


*/
