import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kgsyks_destek/pages/bilgi_karti/bilgi_karti_view.dart';
import 'package:kgsyks_destek/pages/favoriler_page/favoriler_page.dart';

// Mevcut sayfanı import etmeyi unutma
// import 'package:kgsyks_destek/pages/favoriler_page.dart';

class MainTabsPage extends StatelessWidget {
  const MainTabsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    // Resimdeki mor renk (Örnek kod)
    final purpleColor = Theme.of(context).colorScheme.primary;
    final unselectedColor = isDarkMode ? Colors.grey[400] : Colors.grey[600];

    return DefaultTabController(
      length: 2, // İki sekmemiz var: Bilgi Notlarım ve Sorularım
      initialIndex:
          0, // "Sorularım" sayfası (2. sekme) varsayılan açılsın istiyorsan 1 yap, yoksa 0.
      child: Scaffold(
        // Arka plan rengi
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: AppBar(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          elevation: 1, // Hafif bir gölge (resimdeki çizgi efekti için)
          //shadowColor: Colors.black12,
          toolbarHeight:
              0, // Standart AppBar başlığını gizle, sadece TabBar kalsın
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(50), // TabBar yüksekliği
            child: TabBar(
              indicatorColor:
                  purpleColor, // Seçili olanın altındaki çizgi rengi
              indicatorWeight: 3, // Çizgi kalınlığı
              labelColor: purpleColor, // Seçili yazı rengi
              unselectedLabelColor:
                  unselectedColor, // Seçili olmayan yazı rengi
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
          children: [
            // 1. Sekme: Bilgi Notlarım (Şimdilik boş bir sayfa koydum)
            FavorilerPage(),

            // 2. Sekme: Senin verdiğin Sorularım sayfası
            BilgiKartlariPage(),
          ],
        ),
      ),
    );
  }
}
