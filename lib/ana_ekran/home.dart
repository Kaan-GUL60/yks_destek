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

  final List<Widget> pages = const [
    AnalizPage(),
    SoruEkle(),
    AnaEkran(),
    FavorilerPage(),
    ProfilePage(),
  ];
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedIndex = ref.watch(bottomNavIndexProvider);

    return Scaffold(
      body: pages[selectedIndex],
      bottomNavigationBar: const CustomBottomNavigationBar(),
    );
  }
}
