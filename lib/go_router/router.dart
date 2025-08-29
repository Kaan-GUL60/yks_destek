import 'package:go_router/go_router.dart';
import 'package:kgsyks_destek/ana_ekran/home.dart';
import 'package:kgsyks_destek/sign/bilgi_al.dart';
import 'package:kgsyks_destek/sign/sign_in.dart';
import 'package:kgsyks_destek/sign/sign_up.dart';
import 'package:kgsyks_destek/splash_screen/splash_screen.dart';

// Route names as enum
enum AppRoute { home, signIn, bilgiAl, signUp, anaekran, profile, settings }

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
    }
  }
}

// GoRouter configuration
final GoRouter router = GoRouter(
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
  ],
);
