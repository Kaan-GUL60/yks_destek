import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kgsyks_destek/ana_ekran/home_state.dart';
import 'package:kgsyks_destek/navigation_bar/nav_bar.dart';
import 'package:kgsyks_destek/pages/ana_ekran.dart';
import 'package:kgsyks_destek/pages/bilgi_karti/bilgi_karti_ogrenme_view.dart';
import 'package:kgsyks_destek/pages/grafikler/deneme_analiz_page.dart';
import 'package:kgsyks_destek/pages/profil_page.dart';
// ignore: unused_import
import 'package:kgsyks_destek/pages/soru_ekle/soru_ekle.dart';
import 'package:kgsyks_destek/pages/tabbar/main_tabs_page.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedIndex = ref.watch(bottomNavIndexProvider);

    Widget getPage(int index) {
      switch (index) {
        case 0:
          return DenemeAnalizPage(key: UniqueKey());
        case 1:
          return BilgiKartiOgrenmePage(key: UniqueKey());
        case 2:
          return AnaEkran(key: UniqueKey());
        case 3:
          return MainTabsPage(key: UniqueKey());
        case 4:
          return ProfilePage(key: UniqueKey());
        default:
          return AnaEkran(key: UniqueKey());
      }
    }

    return Scaffold(
      body: ProviderScope(
        key: UniqueKey(), //     Her build’de yeni bir scope
        child: getPage(selectedIndex),
      ),
      bottomNavigationBar: const CustomBottomNavigationBar(),
    );
  }
}
