import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kgsyks_destek/ana_ekran/home_state.dart';
import 'package:kgsyks_destek/navigation_bar/nav_bar.dart';
import 'package:kgsyks_destek/pages/ana_ekran.dart';
import 'package:kgsyks_destek/pages/analiz_page.dart';
import 'package:kgsyks_destek/pages/favoriler_page/favoriler_page.dart';
import 'package:kgsyks_destek/pages/profil_page.dart';
import 'package:kgsyks_destek/pages/soru_ekle/soru_ekle.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedIndex = ref.watch(bottomNavIndexProvider);

    Widget getPage(int index) {
      switch (index) {
        case 0:
          return AnalizPage(key: UniqueKey());
        case 1:
          return SoruEkle(key: UniqueKey());
        case 2:
          return AnaEkran(key: UniqueKey());
        case 3:
          return FavorilerPage(key: UniqueKey());
        case 4:
          return ProfilePage(key: UniqueKey());
        default:
          return AnaEkran(key: UniqueKey());
      }
    }

    return Scaffold(
      body: ProviderScope(
        // ← ➊
        key: UniqueKey(), //     Her build’de yeni bir scope
        child: getPage(selectedIndex),
      ),
      bottomNavigationBar: const CustomBottomNavigationBar(),
    );
  }
}
