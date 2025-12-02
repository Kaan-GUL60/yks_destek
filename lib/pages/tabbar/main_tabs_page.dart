import 'dart:io'; // Platform kontrolü
import 'package:flutter/cupertino.dart'; // iOS widget'ları
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kgsyks_destek/pages/bilgi_karti/bilgi_karti_view.dart';
import 'package:kgsyks_destek/pages/favoriler_page/favoriler_page.dart';

class MainTabsPage extends StatefulWidget {
  const MainTabsPage({super.key});

  @override
  State<MainTabsPage> createState() => _MainTabsPageState();
}

class _MainTabsPageState extends State<MainTabsPage> {
  // iOS Segment Kontrolü için index takibi
  int _cupertinoGroupValue = 0;

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final purpleColor = Theme.of(context).colorScheme.primary;
    final unselectedColor = isDarkMode ? Colors.grey[400] : Colors.grey[600];

    // --- 1. iOS TASARIMI (Cupertino) ---
    if (Platform.isIOS) {
      return CupertinoPageScaffold(
        navigationBar: CupertinoNavigationBar(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          middle: CupertinoSlidingSegmentedControl<int>(
            groupValue: _cupertinoGroupValue,
            children: const {
              0: Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Text("Sorularım", style: TextStyle(fontSize: 14)),
              ),
              1: Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Text("Bilgi Notlarım", style: TextStyle(fontSize: 14)),
              ),
            },
            onValueChanged: (int? value) {
              if (value != null) {
                setState(() {
                  _cupertinoGroupValue = value;
                });
              }
            },
            thumbColor: purpleColor, // Seçili olanın rengi
            backgroundColor: isDarkMode
                ? Colors.white.withValues(alpha: 0.1)
                : Colors.black.withValues(alpha: 0.05),
          ),
          border: null, // Alt çizgiyi kaldırmak için
        ),
        child: SafeArea(
          child: _cupertinoGroupValue == 0
              ? const FavorilerPage()
              : const BilgiKartlariPage(),
        ),
      );
    }
    // --- 2. ANDROID TASARIMI (Mevcut Kod) ---
    else {
      return DefaultTabController(
        length: 2,
        initialIndex: 0,
        child: Scaffold(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          appBar: AppBar(
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            elevation: 1,
            toolbarHeight: 0, // Başlığı gizle, sadece TabBar kalsın
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(50),
              child: TabBar(
                indicatorColor: purpleColor,
                indicatorWeight: 3,
                labelColor: purpleColor,
                unselectedLabelColor: unselectedColor,
                labelStyle: TextStyle(
                  fontFamily: GoogleFonts.montserrat().fontFamily,
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
                tabs: const [
                  Tab(text: "Sorularım"),
                  Tab(text: "Bilgi Notlarım"),
                ],
              ),
            ),
          ),
          body: const TabBarView(
            children: [FavorilerPage(), BilgiKartlariPage()],
          ),
        ),
      );
    }
  }
}
