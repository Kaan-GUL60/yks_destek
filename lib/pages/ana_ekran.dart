import 'package:cloud_firestore/cloud_firestore.dart'; // Firestore için
import 'package:connectivity_plus/connectivity_plus.dart'; // İnternet kontrolü için
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gap/gap.dart';
import 'package:kgsyks_destek/pages/bilgi_karti/bilgi_karti_ekle.dart';
import 'package:kgsyks_destek/pages/grafikler/deneme_analiz_page.dart';
import 'package:kgsyks_destek/pages/grafikler/deneme_ekle_page.dart';

// Mevcut sayfalarınızın importları
import 'package:kgsyks_destek/pages/soru_ekle/soru_ekle.dart';
import 'package:kgsyks_destek/pages/video_cozum.dart';
import 'package:kgsyks_destek/sign/bilgi_ekle_provider.dart';

// DEĞİŞİKLİK 1: ConsumerWidget yerine ConsumerStatefulWidget kullanıyoruz.
class AnaEkran extends ConsumerStatefulWidget {
  const AnaEkran({super.key});

  @override
  ConsumerState<AnaEkran> createState() => _AnaEkranState();
}

class _AnaEkranState extends ConsumerState<AnaEkran> {
  // DEĞİŞİKLİK 2: initState metodu sayfa ilk oluşturulduğunda 1 kez çalışır.
  @override
  void initState() {
    super.initState();
    // Sayfa açılır açılmaz bu fonksiyonu tetikliyoruz.
    _logKaydiOlustur();
  }

  // DEĞİŞİKLİK 3: İnternet kontrolü yapıp veri yazan asenkron fonksiyon.
  Future<void> _logKaydiOlustur() async {
    try {
      // 1. İnternet Kontrolü
      final connectivityResult = await Connectivity().checkConnectivity();
      bool internetVar = !connectivityResult.contains(ConnectivityResult.none);

      if (internetVar) {
        // 2. Doğrudan FirebaseAuth'dan UID alıyoruz
        final user = FirebaseAuth.instance.currentUser;

        // 3. Firestore'a Yazma
        await FirebaseFirestore.instance.collection("users").doc(user!.uid).set(
          {"sonGirisDate": FieldValue.serverTimestamp()},
          SetOptions(merge: true),
        );
        await FirebaseFirestore.instance
            .collection("users")
            .doc(user.uid)
            .update({"intliGirisSayisi": FieldValue.increment(1)});

        debugPrint("Log başarıyla gönderildi. UserID: ${user.uid}");
      }
    } catch (e) {
      debugPrint("Log hatası: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    // Tema kontrolü
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final mainTextColor = isDarkMode ? Colors.white : const Color(0xFF1C1E21);

    // Dinamik veri: Kullanıcı bilgisi
    final kullaniciAsyncValue = ref.watch(kullaniciProvider);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        centerTitle: false,
        titleSpacing: 20,

        // --- BAŞLIK (SOL ÜST) ---
        title: kullaniciAsyncValue.when(
          data: (kullanici) {
            final userName = kullanici?.userName ?? 'Öğrenci';
            return Text(
              "Hoş geldin, $userName!",
              style: TextStyle(
                color: mainTextColor,
                fontSize: 22,
                fontWeight: FontWeight.bold,
                fontFamily: GoogleFonts.montserrat().fontFamily,
              ),
            );
          },
          loading: () => Text(
            "Hoş geldin...",
            style: TextStyle(
              color: mainTextColor,
              fontSize: 22,
              fontWeight: FontWeight.bold,
              fontFamily: GoogleFonts.montserrat().fontFamily,
            ),
          ),
          error: (_, _) => Text(
            "Hoş geldin!",
            style: TextStyle(
              color: mainTextColor,
              fontSize: 22,
              fontWeight: FontWeight.bold,
              fontFamily: GoogleFonts.montserrat().fontFamily,
            ),
          ),
        ),

        // --- SAĞ ÜST BUTON (VIDEO ÇÖZÜM) ---
        actions: [
          IconButton(
            icon: Icon(
              Icons.play_circle_fill,
              color: isDarkMode ? Colors.white : const Color(0xFF1C1E21),
              size: 28,
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => YayinevleriListesi()),
              );
            },
          ),
          const Gap(10),
        ],
      ),

      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- 1. SATIR: İSTATİSTİK KARTLARI ---
              IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(
                      child: _buildStatCard(
                        context,
                        title: "Çözülen",
                        count: "128",
                        icon: Icons.check_circle_outline,
                        baseColor: Colors.blue,
                        isDarkMode: isDarkMode,
                      ),
                    ),
                    const Gap(10),
                    Expanded(
                      child: _buildStatCard(
                        context,
                        title: "Bekleyen",
                        count: "12",
                        icon: Icons.more_horiz,
                        baseColor: Colors.orange,
                        isDarkMode: isDarkMode,
                      ),
                    ),
                    const Gap(10),
                    Expanded(
                      child: _buildStatCard(
                        context,
                        title: "Yanlış",
                        count: "45",
                        icon: Icons.cancel_outlined,
                        baseColor: Colors.red,
                        isDarkMode: isDarkMode,
                      ),
                    ),
                    const Gap(10),
                    Expanded(
                      child: _buildStatCard(
                        context,
                        title: "Notlar",
                        count: "8",
                        icon: Icons.description_outlined,
                        baseColor: Colors.yellow[700]!,
                        isDarkMode: isDarkMode,
                      ),
                    ),
                  ],
                ),
              ),

              const Gap(25),

              // --- BAŞLIK: SINAV HEDEFLERİ ---
              Text(
                "Sınav Hedefleri ve Ortalamalar",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: mainTextColor,
                  fontFamily: GoogleFonts.montserrat().fontFamily,
                ),
              ),

              const Gap(15),

              // --- 2. BÖLÜM: HEDEFLER GRID (SATIR 1) ---
              IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(
                      child: _buildGoalCard(
                        context,
                        label: "TYT Net Hedefi",
                        value: "90.0",
                        baseColor: Colors.blue,
                        isDarkMode: isDarkMode,
                      ),
                    ),
                    const Gap(15),
                    Expanded(
                      child: _buildGoalCard(
                        context,
                        label: "AYT Net Hedefi",
                        value: "65.0",
                        baseColor: Colors.deepPurple,
                        isDarkMode: isDarkMode,
                      ),
                    ),
                  ],
                ),
              ),

              const Gap(15),

              // --- 2. BÖLÜM: HEDEFLER GRID (SATIR 2) ---
              IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(
                      child: _buildGoalCard(
                        context,
                        label: "Son 3 TYT Ortalaması",
                        value: "85.5",
                        baseColor: Colors.green,
                        isDarkMode: isDarkMode,
                      ),
                    ),
                    const Gap(15),
                    Expanded(
                      child: _buildGoalCard(
                        context,
                        label: "Son 3 AYT Ortalaması",
                        value: "60.25",
                        baseColor: Colors.orange[800]!,
                        isDarkMode: isDarkMode,
                      ),
                    ),
                  ],
                ),
              ),

              const Gap(30),

              // --- 3. BÖLÜM: AKSİYON BUTONLARI ---
              IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(
                      child: _buildActionCard(
                        context,
                        label: "Soru Ekle",
                        icon: Icons.add_circle,
                        baseColor: Colors.blue,
                        isDarkMode: isDarkMode,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const SoruEkle()),
                          );
                        },
                      ),
                    ),
                    const Gap(15),
                    Expanded(
                      child: _buildActionCard(
                        context,
                        label: "Deneme Ekle",
                        icon: Icons.note_add,
                        baseColor: Colors.purpleAccent,
                        isDarkMode: isDarkMode,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const DenemeEklePage(),
                            ),
                          );
                          /*ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                "Deneme ekleme sayfası yakında eklenecek!",
                                style: TextStyle(
                                  fontFamily:
                                      GoogleFonts.montserrat().fontFamily,
                                ),
                              ),
                            ),
                          );*/
                        },
                      ),
                    ),
                    const Gap(15),
                    Expanded(
                      child: _buildActionCard(
                        context,
                        label: "Not Ekle",
                        icon: Icons.post_add,
                        baseColor: Colors.amber[700]!,
                        isDarkMode: isDarkMode,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const BilgiNotuEklePage(),
                            ),
                          );

                          /*ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                "Not ekleme sayfası yakında eklenecek!",
                                style: TextStyle(
                                  fontFamily:
                                      GoogleFonts.montserrat().fontFamily,
                                ),
                              ),
                            ),
                          );*/
                        },
                      ),
                    ),
                  ],
                ),
              ),

              const Gap(25),

              // --- 4. BÖLÜM: İSTATİSTİKLERİ GÖR BUTONU ---
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const DenemeAnalizPage()),
                  );
                  /*ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        "İstatistikler sayfası yakında eklenecek!",
                        style: TextStyle(
                          fontFamily: GoogleFonts.montserrat().fontFamily,
                        ),
                      ),
                    ),
                  );*/
                },
                child: Container(
                  width: double.infinity,
                  height: 60,
                  decoration: BoxDecoration(
                    color: isDarkMode
                        ? const Color(0xFF2E5C46)
                        : const Color(0xFFE0F2E9),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: isDarkMode
                              ? Colors.green[800]
                              : Colors.green[200],
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.bar_chart,
                          color: isDarkMode ? Colors.white : Colors.green[800],
                        ),
                      ),
                      const Gap(10),
                      Text(
                        "İstatistikleri Gör",
                        style: TextStyle(
                          color: isDarkMode ? Colors.white : Colors.green[800],
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          fontFamily: GoogleFonts.montserrat().fontFamily,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const Gap(30),
            ],
          ),
        ),
      ),
    );
  }

  // --- YARDIMCI WIDGET'LAR (Aynı şekilde kopyalanabilir, değişiklik yok) ---

  Widget _buildStatCard(
    BuildContext context, {
    required String title,
    required String count,
    required IconData icon,
    required Color baseColor,
    required bool isDarkMode,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 2),
      decoration: BoxDecoration(
        color: isDarkMode
            ? const Color(0xFF1F2937)
            : baseColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: baseColor, size: 24),
          const Gap(5),
          Text(
            title,
            textAlign: TextAlign.center,
            maxLines: 1,
            style: TextStyle(
              fontSize: 11,
              color: isDarkMode ? Colors.grey[400] : Colors.grey[700],
              fontFamily: GoogleFonts.montserrat().fontFamily,
            ),
          ),
          const Gap(2),
          Text(
            count,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isDarkMode ? Colors.white : Colors.black,
              fontFamily: GoogleFonts.montserrat().fontFamily,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGoalCard(
    BuildContext context, {
    required String label,
    required String value,
    required Color baseColor,
    required bool isDarkMode,
  }) {
    return Container(
      constraints: const BoxConstraints(minHeight: 100),
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
      decoration: BoxDecoration(
        color: isDarkMode
            ? const Color(0xFF1A2332)
            : baseColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            label,
            maxLines: 2,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: isDarkMode ? Colors.grey[400] : Colors.grey[700],
              fontFamily: GoogleFonts.montserrat().fontFamily,
            ),
          ),
          const Gap(5),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: baseColor,
              fontFamily: GoogleFonts.montserrat().fontFamily,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionCard(
    BuildContext context, {
    required String label,
    required IconData icon,
    required Color baseColor,
    required bool isDarkMode,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        constraints: const BoxConstraints(minHeight: 110),
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 5),
        decoration: BoxDecoration(
          color: isDarkMode
              ? const Color(0xFF1A2332)
              : baseColor.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: baseColor.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: baseColor, size: 24),
            ),
            const Gap(10),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: baseColor,
                fontFamily: GoogleFonts.montserrat().fontFamily,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
