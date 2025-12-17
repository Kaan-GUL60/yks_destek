import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gap/gap.dart';
import 'package:shared_preferences/shared_preferences.dart';
// YENİ KÜTÜPHANE
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';
import 'package:kgsyks_destek/pages/bilgi_karti/bilgi_karti_ekle.dart';
import 'package:kgsyks_destek/pages/dashboard_provider.dart';
import 'package:kgsyks_destek/pages/grafikler/deneme_analiz_page.dart';
import 'package:kgsyks_destek/pages/grafikler/deneme_ekle_page.dart';
import 'package:kgsyks_destek/pages/soru_ekle/soru_ekle.dart';
import 'package:kgsyks_destek/sign/bilgi_ekle_provider.dart';

class AnaEkran extends ConsumerStatefulWidget {
  const AnaEkran({super.key});

  @override
  ConsumerState<AnaEkran> createState() => _AnaEkranState();
}

class _AnaEkranState extends ConsumerState<AnaEkran> {
  // --- TUTORIAL KEYS ---
  bool _isTutorialChecked = false;
  final GlobalKey _keyStatsRow = GlobalKey(); // Üstteki 4'lü istatistik
  final GlobalKey _keyTytRow = GlobalKey(); // TYT/AYT Max Hedefler
  final GlobalKey _keyAytRow = GlobalKey(); // Ortalamalar

  final GlobalKey _keySoruEkle = GlobalKey();
  final GlobalKey _keyDenemeEkle = GlobalKey();
  final GlobalKey _keyNotEkle = GlobalKey();
  final GlobalKey _keyAnaliz = GlobalKey();

  late TutorialCoachMark tutorialCoachMark;

  @override
  void initState() {
    super.initState();
    _logKaydiOlustur();

    // Ekran çizildikten sonra tutorial'ı kontrol et
    //Future.delayed(Duration.zero, _checkAndShowTutorial);
  }

  // --- TUTORIAL MANTIĞI ---
  Future<void> _checkAndShowTutorial() async {
    final prefs = await SharedPreferences.getInstance();
    // Test için 'tutorial_coach_v1' anahtarını kullandım.
    bool isShown = prefs.getBool('tutorial_coach_v3') ?? false;

    //print("Tutorial daha önce gösterildi mi? $isShown");
    if (!isShown && mounted) {
      //print("Tutorial daha önce gösterildi mi---? $isShown");
      _createTutorial(); // Hedefleri hazırla
      tutorialCoachMark.show(context: context); // Göster
    }
  }

  void _createTutorial() {
    tutorialCoachMark = TutorialCoachMark(
      targets: _createTargets(),
      colorShadow: const Color(
        0xFF0F172A,
      ), // Arka plan kararma rengi (Koyu Lacivert)
      textSkip: "ATLA",
      paddingFocus: 10,
      opacityShadow: 0.85,
      imageFilter:
          null, // Arka plan bulanıklığı istenirse ImageFilter.blur(...)
      onFinish: () {
        _markTutorialAsSeen();
      },
      onSkip: () {
        _markTutorialAsSeen();
        return true;
      },
    );
  }

  Future<void> _markTutorialAsSeen() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('tutorial_coach_v3', true);
  }

  // Hedeflerin Listesi
  List<TargetFocus> _createTargets() {
    return [
      // 1. İSTATİSTİK KARTLARI (Yeni key: _keyStatsRow)
      _buildTarget(
        identify: "stats_row",
        keyTarget: _keyStatsRow, // <--- Doğru Key atandı
        title: "Durum Özeti",
        description:
            "Çözülen soru, bekleyen testler ve notlarını buradan takip et.",
        align: ContentAlign.bottom,
        shape: ShapeLightFocus.RRect,
      ),
      // 2. EN YÜKSEK NETLER (Yeni key: _keyTytRow)
      _buildTarget(
        identify: "tyt_status",
        keyTarget: _keyTytRow, // <--- Doğru Key atandı
        title: "En Yüksek Netler",
        description: "Şimdiye kadar ulaştığın en yüksek TYT ve AYT netlerin.",
        align: ContentAlign.bottom,
        shape: ShapeLightFocus.RRect,
      ),
      // 3. ORTALAMALAR (Yeni key: _keyAytRow)
      _buildTarget(
        identify: "ayt_status",
        keyTarget: _keyAytRow, // <--- Doğru Key atandı
        title: "Son Denemeler",
        description: "Son 3 denemendeki ortalama net durumun.",
        align: ContentAlign.bottom,
        shape: ShapeLightFocus.RRect,
      ),
      _buildTarget(
        identify: "soru_ekle_btn",
        keyTarget: _keySoruEkle, // Soru Ekle Key'i
        title: "Soru Ekle",
        description:
            "Yapamadığın veya önemli gördüğün soruları fotoğrafıyla birlikte buraya kaydet.",
        align: ContentAlign.top,
      ),

      // 5. DENEME EKLE (YENİ EKLENDİ)
      _buildTarget(
        identify: "deneme_ekle_btn",
        keyTarget: _keyDenemeEkle, // Deneme Ekle Key'i
        title: "Deneme Ekle",
        description:
            "Girdiğin TYT ve AYT deneme sonuçlarını buradan sisteme gir.",
        align: ContentAlign.top,
      ),

      // 6. NOT EKLE (YENİ EKLENDİ)
      _buildTarget(
        identify: "not_ekle_btn",
        keyTarget: _keyNotEkle, // Not Ekle Key'i
        title: "Not Ekle",
        description:
            "Unutmamak istediğin formülleri veya kısa bilgileri not al.",
        align: ContentAlign.top,
      ),

      // 7. ANALİZ BUTONU
      _buildTarget(
        identify: "analiz_btn",
        keyTarget: _keyAnaliz,
        title: "Detaylı Analiz",
        description: "Grafiklerle gelişimini izlemek için buraya tıkla.",
        align: ContentAlign.top,
      ),
    ];
  }

  // --- HEDEF OLUŞTURUCU (GÜNCELLENDİ - PADDING EKLENDİ) ---
  TargetFocus _buildTarget({
    required String identify,
    required GlobalKey keyTarget,
    required String title,
    required String description,
    required ContentAlign align,
    ShapeLightFocus shape = ShapeLightFocus.RRect,
  }) {
    return TargetFocus(
      identify: identify,
      keyTarget: keyTarget,
      alignSkip: Alignment.topRight,
      enableOverlayTab: true,
      shape: shape,
      radius: 15,
      contents: [
        TargetContent(
          align: align,
          builder: (context, controller) {
            return Padding(
              padding: align == ContentAlign.top
                  ? const EdgeInsets.only(bottom: 20)
                  : const EdgeInsets.only(top: 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.montserrat(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontSize: 24,
                    ),
                  ),
                  const Gap(10),
                  Text(
                    description,
                    style: GoogleFonts.montserrat(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  Future<void> _logKaydiOlustur() async {
    try {
      final connectivityResult = await Connectivity().checkConnectivity();
      bool internetVar = connectivityResult.any(
        (r) => r != ConnectivityResult.none,
      );

      if (internetVar) {
        final user = FirebaseAuth.instance.currentUser;
        if (user != null) {
          await FirebaseFirestore.instance
              .collection("users")
              .doc(user.uid)
              .set({
                "sonGirisDate": FieldValue.serverTimestamp(),
              }, SetOptions(merge: true));
          await FirebaseFirestore.instance
              .collection("users")
              .doc(user.uid)
              .update({"intliGirisSayisi": FieldValue.increment(1)});
        }
      }
    } catch (e) {
      debugPrint("Log hatası: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final mainTextColor = isDarkMode ? Colors.white : const Color(0xFF1C1E21);

    final kullaniciAsyncValue = ref.watch(kullaniciProvider);
    final dashboardAsyncValue = ref.watch(dashboardProvider);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        centerTitle: false,
        titleSpacing: 20,
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
        /*actions: [
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
        ],*/
      ),
      body: dashboardAsyncValue.when(
        loading: () => Center(
          child: Platform.isIOS
              ? const CupertinoActivityIndicator()
              : const CircularProgressIndicator(),
        ),
        error: (err, stack) =>
            Center(child: Text("Veri yüklenirken hata oluştu: $err")),
        data: (stats) {
          // --- DÜZELTME BURADA ---
          // Veri geldi. Ekran çizildikten hemen sonra tutorial kontrolü yap:
          if (!_isTutorialChecked) {
            // addPostFrameCallback: "Bu frame çizildikten hemen sonra çalıştır" demektir.
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _checkAndShowTutorial();
            });
            _isTutorialChecked = true; // Bir daha bu blok çalışmasın
          }
          // -----------------------
          return SafeArea(
            top: false, // AppBar olduğu için üst güvenli alana gerek yok
            bottom: true, // Alt kısım önemli
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20.0,
                  vertical: 10,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // --- İSTATİSTİK KARTLARI ---
                    // --- 1. İSTATİSTİK KARTLARI ---
                    // Key'i buradaki IntrinsicHeight'a veriyoruz ki tüm satırı vurgulasın
                    IntrinsicHeight(
                      key: _keyStatsRow, // <--- KEY EKLENDİ
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Expanded(
                            child: _buildStatCard(
                              context,
                              title: "Çözülen",
                              count: stats.cozulenSoru.toString(),
                              icon: Platform.isIOS
                                  ? CupertinoIcons.check_mark_circled
                                  : Icons.check_circle_outline,
                              baseColor: Colors.green,
                              isDarkMode: isDarkMode,
                            ),
                          ),
                          const Gap(10),
                          Expanded(
                            child: _buildStatCard(
                              context,
                              title: "Bekleyen",
                              count: stats.bekleyenSoru.toString(),
                              icon: Platform.isIOS
                                  ? CupertinoIcons.timer
                                  : Icons.timer_outlined,
                              baseColor: Colors.orange,
                              isDarkMode: isDarkMode,
                            ),
                          ),
                          const Gap(10),
                          Expanded(
                            child: _buildStatCard(
                              context,
                              title: "Yanlış",
                              count: stats.yanlisSoru.toString(),
                              icon: Platform.isIOS
                                  ? CupertinoIcons.xmark_circle
                                  : Icons.cancel_outlined,
                              baseColor: Colors.red,
                              isDarkMode: isDarkMode,
                            ),
                          ),
                          const Gap(10),
                          Expanded(
                            child: _buildStatCard(
                              context,
                              title: "Notlar",
                              count: stats.notSayisi.toString(),
                              icon: Platform.isIOS
                                  ? CupertinoIcons.doc_text
                                  : Icons.description_outlined,
                              baseColor: Colors.yellow[700]!,
                              isDarkMode: isDarkMode,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const Gap(25),
                    Text(
                      "Sınav İstatistikleri",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: mainTextColor,
                        fontFamily: GoogleFonts.montserrat().fontFamily,
                      ),
                    ),
                    const Gap(15),

                    // --- 2. HEDEFLER (MAX TYT/AYT) ---
                    IntrinsicHeight(
                      key: _keyTytRow, // <--- KEY EKLENDİ
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Expanded(
                            child: _buildGoalCard(
                              context,
                              label: "En Yüksek TYT",
                              value: stats.maxTytNet.toStringAsFixed(1),
                              baseColor: Colors.blue,
                              isDarkMode: isDarkMode,
                            ),
                          ),
                          const Gap(15),
                          Expanded(
                            child: _buildGoalCard(
                              context,
                              label: "En Yüksek AYT",
                              value: stats.maxAytNet.toStringAsFixed(1),
                              baseColor: Colors.deepPurple,
                              isDarkMode: isDarkMode,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Gap(15),
                    // --- 3. ORTALAMALAR (SON 3) ---
                    IntrinsicHeight(
                      key: _keyAytRow, // <--- KEY EKLENDİ
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Expanded(
                            child: _buildGoalCard(
                              context,
                              label: "Son 3 TYT Ort.",
                              value: stats.son3TytOrt.toStringAsFixed(1),
                              baseColor: Colors.green,
                              isDarkMode: isDarkMode,
                            ),
                          ),
                          const Gap(15),
                          Expanded(
                            child: _buildGoalCard(
                              context,
                              label: "Son 3 AYT Ort.",
                              value: stats.son3AytOrt.toStringAsFixed(1),
                              baseColor: Colors.orange[800]!,
                              isDarkMode: isDarkMode,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Gap(30),

                    // --- 4. AKSİYON BUTONLARI ---
                    // Keyler _buildActionCard içine parametre olarak zaten gönderiliyor.
                    // --- 4. AKSİYON BUTONLARI KISMI ---
                    IntrinsicHeight(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // SORU EKLE BUTONU
                          Expanded(
                            child: _buildActionCard(
                              context,
                              key: _keySoruEkle, // <--- BURASI TAMAM
                              label: "Soru Ekle",
                              icon: Platform.isIOS
                                  ? CupertinoIcons.add_circled
                                  : Icons.add_circle,
                              baseColor: Colors.blue,
                              isDarkMode: isDarkMode,
                              onTap: () =>
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => const SoruEkle(),
                                    ),
                                  ).then((_) {
                                    if (mounted) {
                                      // <--- KONTROL EKLENDİ
                                      ref.invalidate(dashboardProvider);
                                    }
                                  }),
                            ),
                          ),
                          const Gap(15),

                          // DENEME EKLE BUTONU
                          Expanded(
                            child: _buildActionCard(
                              context,
                              key: _keyDenemeEkle, // <--- BURASI EKLİ OLMALI
                              label: "Deneme Ekle",
                              icon: Platform.isIOS
                                  ? CupertinoIcons.doc_append
                                  : Icons.note_add,
                              baseColor: Colors.purpleAccent,
                              isDarkMode: isDarkMode,
                              onTap: () =>
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => const DenemeEklePage(),
                                    ),
                                  ).then((_) {
                                    if (mounted) {
                                      // <--- KONTROL EKLENDİ
                                      ref.invalidate(dashboardProvider);
                                    }
                                  }),
                            ),
                          ),
                          const Gap(15),

                          // NOT EKLE BUTONU
                          Expanded(
                            child: _buildActionCard(
                              context,
                              key: _keyNotEkle, // <--- BURASI EKLİ OLMALI
                              label: "Not Ekle",
                              icon: Platform.isIOS
                                  ? CupertinoIcons.pencil_outline
                                  : Icons.post_add,
                              baseColor: Colors.amber[700]!,
                              isDarkMode: isDarkMode,
                              onTap: () =>
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => const BilgiNotuEklePage(),
                                    ),
                                  ).then((_) {
                                    if (mounted) {
                                      // <--- KONTROL EKLENDİ
                                      ref.invalidate(dashboardProvider);
                                    }
                                  }),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const Gap(25),

                    // --- 5. ANALİZ BUTONU ---
                    GestureDetector(
                      key: _keyAnaliz, // <--- KEY MEVCUT VE DOĞRU YERDE
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const DenemeAnalizPage(),
                        ),
                      ),
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
                                // Platforma göre ikon
                                Platform.isIOS
                                    ? CupertinoIcons.chart_bar_alt_fill
                                    : Icons.bar_chart,
                                color: isDarkMode
                                    ? Colors.white
                                    : Colors.green[800],
                              ),
                            ),
                            const Gap(10),
                            Text(
                              "İstatistikleri Gör",
                              style: TextStyle(
                                color: isDarkMode
                                    ? Colors.white
                                    : Colors.green[800],
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
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
        },
      ),
    );
  }

  // --- YARDIMCI WIDGET'LAR ---

  // _buildActionCard GÜNCELLENDİ (Key alabiliyor)
  Widget _buildActionCard(
    BuildContext context, {
    GlobalKey? key, // Yeni parametre
    required String label,
    required IconData icon,
    required Color baseColor,
    required bool isDarkMode,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      key: key, // Key buraya atandı
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

  // Diğer widgetlar aynen kalabilir
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
}
