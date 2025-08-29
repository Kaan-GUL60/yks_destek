import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kgsyks_destek/ana_ekran/home_state.dart';

class HomeController {
  final Ref ref; // WidgetRef değil, Ref olmalı

  HomeController(this.ref);

  void changeTab(int index) {
    ref.read(bottomNavIndexProvider.notifier).state = index;
  }
}

final homeControllerProvider = Provider<HomeController>((ref) {
  return HomeController(ref);
});
