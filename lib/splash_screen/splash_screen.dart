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

  // Yönlendirme mantığını içeren ana asenkron fonksiyon
  Future<void> _navigateToNextScreen(BuildContext context) async {
    // Tüm kontrolleri yapmadan önce bekleyin
    await Future.delayed(const Duration(milliseconds: 500));

    final online = await _hasConnection();
    final isRegisteredLocally = await _isUserRegisteredLocally();

    if (!online) {
      // 1. İnternet Yok: Sadece Local Sayaç + Ana Ekran
      final count = await localCounter.increment();
      debugPrint("Offline açılma sayısı: $count");
      router.goNamed(AppRoute.anaekran.name);
      return;
    }

    // 2. İnternet Var

    // YEREL KULLANICI KAYDI KONTROLÜ
    if (isRegisteredLocally) {
      // KULLANICI DETAY BİLGİLERİ KONTROLÜ (getKullanici metodu ile)
      final kullaniciDetay = await dbHelper
          .getKullanici(); // dbHelper direkt çağırıldı

      if (kullaniciDetay != null) {
        // A) HEM BOOL TRUE HEM DETAY BİLGİSİ VARSA -> ANA EKRAN
        //print("******************************$kullaniciDetay");

        // Online açılma analytics
        AnalyticsService().trackCount("uyg_acilma_sayisi", "splash_screen");

        // Offline sayacı Firebase'e gönder ve sıfırla
        final offlineCount = await localCounter.getCount();
        if (offlineCount > 0) {
          AnalyticsService().trackCount(
            "offline_acilma_toplam",
            "splash_screen:$offlineCount",
          );
          await localCounter.reset();
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
      body: Center(
        child: Stack(
          alignment: Alignment.center,
          children: [
            const SizedBox(height: double.infinity, width: double.infinity),
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

/*


*/
