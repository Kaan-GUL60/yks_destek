import 'package:go_router/go_router.dart';
import 'package:kgsyks_destek/ana_ekran/home.dart';
import 'package:kgsyks_destek/pages/analiz_page/analiz_add.dart';
import 'package:kgsyks_destek/pages/favoriler_page/favoriler_page.dart';
import 'package:kgsyks_destek/sign/bilgi_al.dart';
import 'package:kgsyks_destek/sign/sign_in.dart';
import 'package:kgsyks_destek/sign/sign_up.dart';
import 'package:kgsyks_destek/soru_viewer/soru_viewer.dart';
import 'package:kgsyks_destek/splash_screen/splash_screen.dart';

// Route names as enum
enum AppRoute {
  home,
  signIn,
  bilgiAl,
  signUp,
  anaekran,
  profile,
  settings,
  soruViewer,
  favorilerPage,
  analizAddPage,
}

// Route paths as extension
extension AppRouteExtension on AppRoute {
  String get path {
    switch (this) {
      case AppRoute.home:
        return '/';
      case AppRoute.signIn:
        return '/signIn';
      case AppRoute.bilgiAl:
        return '/bilgiAl';
      case AppRoute.signUp:
        return '/signUp';
      case AppRoute.anaekran:
        return '/anaekran';
      case AppRoute.profile:
        return '/profile';
      case AppRoute.settings:
        return '/settings';
      case AppRoute.soruViewer:
        return '/soruViewer/:id';
      case AppRoute.favorilerPage:
        return '/favorilerPage';
      case AppRoute.analizAddPage:
        return '/analizAddPage/:id';
    }
  }
}

// ==========================================================
// 🎯 1. DEĞİŞİKLİK: router'ı 'late final' yap
// ==========================================================
late final GoRouter router;

// ==========================================================
// 🎯 2. DEĞİŞİKLİK: GoRouter'ı bir fonksiyona taşı
// ==========================================================
/// Bu fonksiyon main.dart'tan çağrılacak
GoRouter createRouter(String? notificationPayload) {
  // 3. Başlangıç konumunu belirle
  String initialLocation = AppRoute.home.path; // Varsayılan: '/' (SplashScreen)

  if (notificationPayload != null) {
    try {
      // Eğer bildirimden geldiysek, başlangıç konumunu SoruViewer yap
      final int soruId = int.parse(notificationPayload);
      initialLocation = AppRoute.soruViewer.path.replaceAll(
        ':id',
        soruId.toString(),
      );
      // Sonuç: '/soruViewer/123'
    } catch (e) {
      // Payload bozuksa, güvenli olarak ana sayfadan başlat
      initialLocation = AppRoute.home.path;
    }
  }

  // 4. Router'ı bu başlangıç konumuyla oluştur
  return GoRouter(
    initialLocation: initialLocation, // 🎯 EN ÖNEMLİ KISIM
    routes: [
      GoRoute(
        path: AppRoute.home.path,
        name: AppRoute.home.name,
        builder: (context, state) => SplashScreen(),
      ),
      GoRoute(
        path: AppRoute.signIn.path,
        name: AppRoute.signIn.name,
        builder: (context, state) => SignIn(),
      ),
      GoRoute(
        path: AppRoute.bilgiAl.path,
        name: AppRoute.bilgiAl.name,
        builder: (context, state) => BilgiAl(),
      ),
      GoRoute(
        path: AppRoute.signUp.path,
        name: AppRoute.signUp.name,
        builder: (context, state) => SignUp(),
      ),
      GoRoute(
        path: AppRoute.anaekran.path,
        name: AppRoute.anaekran.name,
        builder: (context, state) => HomePage(),
      ),
      GoRoute(
        path: AppRoute.soruViewer.path,
        name: AppRoute.soruViewer.name,
        builder: (context, state) {
          final int soruId = int.parse(state.pathParameters['id']!);
          return SoruViewer(soruId: soruId);
        },
      ),
      GoRoute(
        path: AppRoute.favorilerPage.path,
        name: AppRoute.favorilerPage.name,
        builder: (context, state) => FavorilerPage(),
      ),
      GoRoute(
        path: AppRoute.analizAddPage.path,
        name: AppRoute.analizAddPage.name,
        builder: (context, state) {
          final int durumId = int.parse(state.pathParameters['id']!);
          return AnalizAddPage(durumId: durumId);
        },
      ),
    ],
  );
}
