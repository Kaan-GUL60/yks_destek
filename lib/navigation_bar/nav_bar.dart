import 'dart:io'; // Platform kontrolü için
import 'package:flutter/cupertino.dart'; // iOS ikonları ve widget'ları
import 'package:flutter/material.dart'; // Android ikonları ve widget'ları
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kgsyks_destek/ana_ekran/home_controller.dart';
import 'package:kgsyks_destek/ana_ekran/home_state.dart';

class CustomBottomNavigationBar extends ConsumerWidget {
  const CustomBottomNavigationBar({super.key});

  // İkon haritasını genişlettik: Hem Android hem iOS ikonlarını tanımlıyoruz.
  static const List<Map<String, dynamic>> _navItems = [
    {
      'label': "Analiz",
      // Android İkonları (Material)
      'icon': Icons.auto_graph_outlined,
      'activeIcon': Icons.auto_graph,
      // iOS İkonları (Cupertino)
      'iosIcon': CupertinoIcons.graph_square,
      'iosActiveIcon': CupertinoIcons.graph_square_fill,
    },
    {
      'label': "Kartlar",
      'icon': Icons.library_books_outlined,
      'activeIcon': Icons.library_books,
      // iOS için 'rectangle_stack' (Kartlar/Kütüphane metaforu için uygundur)
      'iosIcon': CupertinoIcons.rectangle_stack,
      'iosActiveIcon': CupertinoIcons.rectangle_stack_fill,
    },
    {
      'label': "Ana Ekran",
      'icon': Icons.home_outlined,
      'activeIcon': Icons.home,
      // iOS Ev ikonu
      'iosIcon': CupertinoIcons.house,
      'iosActiveIcon': CupertinoIcons.house_fill,
    },
    {
      'label': "Sorular",
      'icon': Icons.quiz_outlined,
      'activeIcon': Icons.quiz,
      // iOS Soru işareti / Liste ikonu
      'iosIcon': CupertinoIcons.question_circle,
      'iosActiveIcon': CupertinoIcons.question_circle_fill,
    },
    {
      'label': "Profil",
      'icon': Icons.person_outline,
      'activeIcon': Icons.person,
      // iOS Profil ikonu
      'iosIcon': CupertinoIcons.person,
      'iosActiveIcon': CupertinoIcons.person_fill,
    },
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedIndex = ref.watch(bottomNavIndexProvider);
    final controller = ref.read(homeControllerProvider);

    final primaryColor = Theme.of(context).colorScheme.primary;
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    // --- 1. iOS TASARIMI (Cupertino) ---
    if (Platform.isIOS) {
      return CupertinoTabBar(
        currentIndex: selectedIndex,
        onTap: (index) => controller.changeTab(index),
        activeColor: primaryColor,
        inactiveColor: Colors.grey,
        // iOS standartlarına uygun hafif şeffaf arka plan
        backgroundColor: isDarkMode
            ? const Color(0xCC1E252F)
            : const Color(0xCCFFFFFF),
        iconSize: 28, // iOS ikonları genelde bir tık daha büyüktür
        border: Border(
          top: BorderSide(
            color: isDarkMode ? Colors.white12 : Colors.black12,
            width: 0.5,
          ),
        ),
        items: _navItems.map((item) {
          return BottomNavigationBarItem(
            // iOS ikonlarını kullanıyoruz
            icon: Icon(item['iosIcon']),
            activeIcon: Icon(item['iosActiveIcon']),
            label: item['label'],
          );
        }).toList(),
      );
    }
    // --- 2. ANDROID TASARIMI (Material 3) ---
    else {
      return NavigationBar(
        selectedIndex: selectedIndex,
        onDestinationSelected: (index) => controller.changeTab(index),
        indicatorColor: primaryColor.withValues(alpha: 0.15),
        destinations: _navItems.map((item) {
          return NavigationDestination(
            // Android ikonlarını kullanıyoruz
            icon: Icon(item['icon']),
            selectedIcon: Icon(item['activeIcon']),
            label: item['label'],
          );
        }).toList(),
      );
    }
  }
}
