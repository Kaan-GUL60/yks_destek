import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kgsyks_destek/ana_ekran/home_controller.dart';
import 'package:kgsyks_destek/ana_ekran/home_state.dart';

class CustomBottomNavigationBar extends ConsumerWidget {
  const CustomBottomNavigationBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedIndex = ref.watch(bottomNavIndexProvider);
    final controller = ref.read(homeControllerProvider);

    return NavigationBar(
      selectedIndex: selectedIndex,
      onDestinationSelected: (index) => controller.changeTab(index),

      // Temadaki NavigationBarTheme çalışsın diye backgroundColor KALDIRILDI
      indicatorColor: Theme.of(
        context,
      ).colorScheme.primary.withValues(alpha: 0.15),

      destinations: const [
        NavigationDestination(
          icon: Icon(Icons.auto_graph_outlined),
          selectedIcon: Icon(Icons.auto_graph),
          label: "Analiz",
        ),
        NavigationDestination(
          icon: Icon(Icons.library_books_outlined),
          selectedIcon: Icon(Icons.library_books),
          label: "Kartlar",
        ),
        NavigationDestination(
          icon: Icon(Icons.home_outlined),
          selectedIcon: Icon(Icons.home),
          label: "Ana Ekran",
        ),
        NavigationDestination(
          icon: Icon(Icons.quiz_outlined),
          selectedIcon: Icon(Icons.quiz),
          label: "Sorular",
        ),
        NavigationDestination(
          icon: Icon(Icons.person_outline),
          selectedIcon: Icon(Icons.person),
          label: "Profil",
        ),
      ],
    );
  }
}
