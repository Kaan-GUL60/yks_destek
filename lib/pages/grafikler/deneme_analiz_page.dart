import 'dart:io';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:kgsyks_destek/pages/grafikler/deneme_analiz_provider.dart';
import 'package:kgsyks_destek/pages/grafikler/deneme_ekle_page.dart';

// --- ANA SAYFA ---
class DenemeAnalizPage extends ConsumerWidget {
  const DenemeAnalizPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedTab = ref.watch(analizTabProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = Theme.of(context).scaffoldBackgroundColor;
    final primaryColor = const Color(0xFF0099FF);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        title: Text(
          "Deneme Analizi",
          style: GoogleFonts.montserrat(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: bgColor,
        elevation: 0,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: IconButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const DenemeEklePage()),
                ).then((_) {
                  if (context.mounted) {
                    ref.invalidate(tytListProvider);
                    ref.invalidate(aytListProvider);
                  }
                });
              },
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: primaryColor,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Platform.isIOS ? CupertinoIcons.add : Icons.add,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            const Gap(10),
            _buildCustomToggle(ref, selectedTab, primaryColor, isDark),
            const Gap(20),
            Expanded(
              child: selectedTab == 0
                  ? const _TytAnalizView()
                  : const _AytAnalizView(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCustomToggle(
    WidgetRef ref,
    int selectedTab,
    Color primaryColor,
    bool isDark,
  ) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      height: 50,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1F2937) : Colors.grey[200],
        borderRadius: BorderRadius.circular(25),
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => ref.read(analizTabProvider.notifier).state = 0,
              child: Container(
                decoration: BoxDecoration(
                  color: selectedTab == 0 ? primaryColor : Colors.transparent,
                  borderRadius: BorderRadius.circular(25),
                ),
                alignment: Alignment.center,
                child: Text(
                  "TYT",
                  style: TextStyle(
                    color: selectedTab == 0
                        ? Colors.white
                        : (isDark ? Colors.white54 : Colors.black54),
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () => ref.read(analizTabProvider.notifier).state = 1,
              child: Container(
                decoration: BoxDecoration(
                  color: selectedTab == 1 ? primaryColor : Colors.transparent,
                  borderRadius: BorderRadius.circular(25),
                ),
                alignment: Alignment.center,
                child: Text(
                  "AYT",
                  style: TextStyle(
                    color: selectedTab == 1
                        ? Colors.white
                        : (isDark ? Colors.white54 : Colors.black54),
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// --- TYT GÖRÜNÜMÜ ---
class _TytAnalizView extends ConsumerWidget {
  const _TytAnalizView();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tytListAsync = ref.watch(tytListProvider);

    return tytListAsync.when(
      loading: () => Center(
        child: Platform.isIOS
            ? const CupertinoActivityIndicator()
            : const CircularProgressIndicator(),
      ),
      error: (err, stack) => Center(child: Text("Hata: $err")),
      data: (denemeler) {
        if (denemeler.isEmpty) {
          return const Center(child: Text("Henüz TYT denemesi eklenmedi."));
        }

        // --- Veri Hazırlama ---
        final overallSpots = denemeler
            .asMap()
            .entries
            .map((e) => FlSpot(e.key.toDouble(), hesaplaTytNet(e.value)))
            .toList();
        final trSpots = denemeler
            .asMap()
            .entries
            .map(
              (e) => FlSpot(
                e.key.toDouble(),
                e.value.turkceD - (e.value.turkceY / 4.0),
              ),
            )
            .toList();
        final matSpots = denemeler
            .asMap()
            .entries
            .map(
              (e) =>
                  FlSpot(e.key.toDouble(), e.value.matD - (e.value.matY / 4.0)),
            )
            .toList();
        final sosSpots = denemeler
            .asMap()
            .entries
            .map(
              (e) => FlSpot(
                e.key.toDouble(),
                e.value.sosyalD - (e.value.sosyalY / 4.0),
              ),
            )
            .toList();
        final fenSpots = denemeler
            .asMap()
            .entries
            .map(
              (e) =>
                  FlSpot(e.key.toDouble(), e.value.fenD - (e.value.fenY / 4.0)),
            )
            .toList();

        final chartDataList = [
          _ChartData(
            title: "TYT Genel Net",
            spots: overallSpots,
            color: const Color(0xFF8B5CF6),
          ),
          _ChartData(
            title: "Türkçe Net",
            spots: trSpots,
            color: Colors.redAccent,
          ),
          _ChartData(
            title: "Matematik Net",
            spots: matSpots,
            color: Colors.blueAccent,
          ),
          _ChartData(
            title: "Sosyal Net",
            spots: sosSpots,
            color: Colors.orangeAccent,
          ),
          _ChartData(
            title: "Fen Net",
            spots: fenSpots,
            color: Colors.greenAccent,
          ),
        ];

        return ListView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20),
          children: [
            // Grafik Alanı (Yüksekliği Artırıldı)
            SizedBox(
              height: 380, // 320'den 380'e çıkarıldı
              child: _SwipeableCharts(chartDataList: chartDataList),
            ),

            const Gap(24),
            Text(
              "Son Denemeler",
              style: GoogleFonts.montserrat(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Gap(12),
            ...denemeler.reversed.map((deneme) {
              final net = hesaplaTytNet(deneme);
              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          _DenemeDetailPage(deneme: deneme, isTyt: true),
                    ),
                  );
                },
                child: _DenemeListItem(
                  ad: deneme.denemeAdi,
                  tarih: deneme.tarih,
                  net: net,
                  detay: "",
                ),
              );
            }),
            const Gap(30),
          ],
        );
      },
    );
  }
}

// --- AYT GÖRÜNÜMÜ ---
// --- AYT GÖRÜNÜMÜ (GÜNCELLENDİ: Tüm Dersler Ayrı Ayrı) ---
class _AytAnalizView extends ConsumerWidget {
  const _AytAnalizView();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final aytListAsync = ref.watch(aytListProvider);

    return aytListAsync.when(
      loading: () => Center(
        child: Platform.isIOS
            ? const CupertinoActivityIndicator()
            : const CircularProgressIndicator(),
      ),
      error: (err, stack) => Center(child: Text("Hata: $err")),
      data: (denemeler) {
        if (denemeler.isEmpty) {
          return const Center(child: Text("Henüz AYT denemesi eklenmedi."));
        }

        // --- Veri Hazırlama (Her Ders Ayrı Ayrı) ---

        // 1. Genel Net
        final overallSpots = denemeler
            .asMap()
            .entries
            .map((e) => FlSpot(e.key.toDouble(), hesaplaAytNet(e.value)))
            .toList();

        // 2. Matematik
        final matSpots = denemeler
            .asMap()
            .entries
            .map(
              (e) =>
                  FlSpot(e.key.toDouble(), e.value.matD - (e.value.matY / 4.0)),
            )
            .toList();

        // 3. Fen Dersleri (Ayrı Ayrı)
        final fizSpots = denemeler
            .asMap()
            .entries
            .map(
              (e) =>
                  FlSpot(e.key.toDouble(), e.value.fizD - (e.value.fizY / 4.0)),
            )
            .toList();
        final kimSpots = denemeler
            .asMap()
            .entries
            .map(
              (e) =>
                  FlSpot(e.key.toDouble(), e.value.kimD - (e.value.kimY / 4.0)),
            )
            .toList();
        final biySpots = denemeler
            .asMap()
            .entries
            .map(
              (e) =>
                  FlSpot(e.key.toDouble(), e.value.biyD - (e.value.biyY / 4.0)),
            )
            .toList();

        // 4. Eşit Ağırlık / Sözel Ortak Dersleri (Ayrı Ayrı)
        final edbSpots = denemeler
            .asMap()
            .entries
            .map(
              (e) =>
                  FlSpot(e.key.toDouble(), e.value.edbD - (e.value.edbY / 4.0)),
            )
            .toList();
        final tar1Spots = denemeler
            .asMap()
            .entries
            .map(
              (e) => FlSpot(
                e.key.toDouble(),
                e.value.tar1D - (e.value.tar1Y / 4.0),
              ),
            )
            .toList();
        final cog1Spots = denemeler
            .asMap()
            .entries
            .map(
              (e) => FlSpot(
                e.key.toDouble(),
                e.value.cog1D - (e.value.cog1Y / 4.0),
              ),
            )
            .toList();

        // 5. Sözel Dersleri (Ayrı Ayrı)
        final tar2Spots = denemeler
            .asMap()
            .entries
            .map(
              (e) => FlSpot(
                e.key.toDouble(),
                e.value.tar2D - (e.value.tar2Y / 4.0),
              ),
            )
            .toList();
        final cog2Spots = denemeler
            .asMap()
            .entries
            .map(
              (e) => FlSpot(
                e.key.toDouble(),
                e.value.cog2D - (e.value.cog2Y / 4.0),
              ),
            )
            .toList();
        final felSpots = denemeler
            .asMap()
            .entries
            .map(
              (e) =>
                  FlSpot(e.key.toDouble(), e.value.felD - (e.value.felY / 4.0)),
            )
            .toList();
        final dinSpots = denemeler
            .asMap()
            .entries
            .map(
              (e) =>
                  FlSpot(e.key.toDouble(), e.value.dinD - (e.value.dinY / 4.0)),
            )
            .toList();

        // Grafik Listesini Oluşturma
        final chartDataList = [
          // Ana Grafikler
          _ChartData(
            title: "AYT Genel Net",
            spots: overallSpots,
            color: const Color(0xFF8B5CF6),
          ),
          _ChartData(
            title: "Matematik Net",
            spots: matSpots,
            color: Colors.blueAccent,
          ),

          // Fen Bilimleri
          _ChartData(title: "Fizik Net", spots: fizSpots, color: Colors.cyan),
          _ChartData(
            title: "Kimya Net",
            spots: kimSpots,
            color: Colors.purpleAccent,
          ),
          _ChartData(
            title: "Biyoloji Net",
            spots: biySpots,
            color: Colors.green,
          ),

          // Eşit Ağırlık & Sözel
          _ChartData(
            title: "Edebiyat Net",
            spots: edbSpots,
            color: Colors.orange,
          ),
          _ChartData(
            title: "Tarih-1 Net",
            spots: tar1Spots,
            color: Colors.brown,
          ),
          _ChartData(
            title: "Coğrafya-1 Net",
            spots: cog1Spots,
            color: Colors.teal,
          ),

          // Sözel Ekstra
          _ChartData(
            title: "Tarih-2 Net",
            spots: tar2Spots,
            color: Colors.brown.shade300,
          ),
          _ChartData(
            title: "Coğrafya-2 Net",
            spots: cog2Spots,
            color: Colors.teal.shade300,
          ),
          _ChartData(
            title: "Felsefe Net",
            spots: felSpots,
            color: Colors.indigo,
          ),
          _ChartData(
            title: "Din Kültürü Net",
            spots: dinSpots,
            color: Colors.amber,
          ),
        ];

        // Sadece verisi olan (en az bir denemede 0'dan farklı neti olan) grafikleri filtrelemek isterseniz:
        // chartDataList.removeWhere((chart) => chart.maxNet == 0 && chart.currentNet == 0);
        // Şimdilik isteğiniz üzerine hepsini gösteriyorum.

        return ListView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20),
          children: [
            // Grafik Alanı
            SizedBox(
              height: 380,
              child: _SwipeableCharts(chartDataList: chartDataList),
            ),

            const Gap(24),
            Text(
              "Son Denemeler",
              style: GoogleFonts.montserrat(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Gap(12),
            ...denemeler.reversed.map((deneme) {
              final net = hesaplaAytNet(deneme);
              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          _DenemeDetailPage(deneme: deneme, isTyt: false),
                    ),
                  );
                },
                child: _DenemeListItem(
                  ad: deneme.denemeAdi,
                  tarih: deneme.tarih,
                  net: net,
                  detay: deneme.alan,
                ),
              );
            }),
            const Gap(30),
          ],
        );
      },
    );
  }
}
// --- YARDIMCI SINIFLAR & WIDGETLAR ---

class _ChartData {
  final String title;
  final List<FlSpot> spots;
  final Color color;
  // Max Net Hesaplama
  double get maxNet =>
      spots.isEmpty ? 0 : spots.map((e) => e.y).reduce((a, b) => a > b ? a : b);
  // Ortalama Net Hesaplama
  double get average => spots.isEmpty
      ? 0
      : spots.map((e) => e.y).reduce((a, b) => a + b) / spots.length;
  // Son (Güncel) Net
  double get currentNet => spots.isNotEmpty ? spots.last.y : 0.0;

  _ChartData({required this.title, required this.spots, required this.color});
}

// Kaydırılabilir Grafik Widget'ı
class _SwipeableCharts extends StatefulWidget {
  final List<_ChartData> chartDataList;
  const _SwipeableCharts({required this.chartDataList});

  @override
  State<_SwipeableCharts> createState() => _SwipeableChartsState();
}

class _SwipeableChartsState extends State<_SwipeableCharts> {
  final PageController _pageController = PageController(
    viewportFraction: 0.95,
  ); // Kartları biraz daha genişlettim
  int _currentPage = 0;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: PageView.builder(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() => _currentPage = index);
            },
            itemCount: widget.chartDataList.length,
            itemBuilder: (context, index) {
              final data = widget.chartDataList[index];
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4.0),
                child: _ChartCard(
                  title: data.title,
                  currentNet: data.currentNet,
                  average: data.average,
                  maxNet: data.maxNet, // Max Net eklendi
                  spots: data.spots,
                  lineColor: data.color,
                ),
              );
            },
          ),
        ),
        const Gap(10),
        // Sayfa Göstergeleri (Dots)
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(widget.chartDataList.length, (index) {
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 3),
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _currentPage == index
                    ? const Color(0xFF0099FF)
                    : Colors.grey.withValues(alpha: 0.3),
              ),
            );
          }),
        ),
      ],
    );
  }
}

class _ChartCard extends StatelessWidget {
  final String title;
  final double currentNet;
  final double average;
  final double maxNet;
  final List<FlSpot> spots;
  final Color lineColor;

  const _ChartCard({
    required this.title,
    required this.currentNet,
    required this.average,
    required this.maxNet,
    required this.spots,
    required this.lineColor,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark ? const Color(0xFF1F2937) : Colors.white;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Başlık (Ders Adı)
          Text(
            title,
            style: GoogleFonts.montserrat(
              fontSize: 16, // Font büyütüldü
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white70 : Colors.black87,
            ),
          ),
          const Gap(12),

          // Net Bilgileri Satırı
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              // Sol Taraf: Güncel Net
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "${currentNet.toStringAsFixed(1)} Net",
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: lineColor, // Rengi dersin rengiyle aynı yaptım
                    ),
                  ),
                  const Text(
                    "Son Deneme",
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),

              // Sağ Taraf: Ortalama ve Max
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  // Ortalama
                  Row(
                    children: [
                      const Icon(
                        Icons.show_chart,
                        size: 16,
                        color: Colors.grey,
                      ),
                      const Gap(4),
                      Text(
                        "Ort: ${average.toStringAsFixed(2)}",
                        style: TextStyle(
                          color: isDark ? Colors.white70 : Colors.black87,
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                  const Gap(4),
                  // En Yüksek (Max)
                  Row(
                    children: [
                      const Icon(
                        Icons.emoji_events_outlined,
                        size: 16,
                        color: Colors.amber,
                      ),
                      const Gap(4),
                      Text(
                        "Max: ${maxNet.toStringAsFixed(2)}",
                        style: TextStyle(
                          color: isDark ? Colors.white70 : Colors.black87,
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
          const Gap(24),

          // --- GRAFİK ALANI ---
          Expanded(
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: 5, // Izgara çizgileri
                  getDrawingHorizontalLine: (value) {
                    return FlLine(
                      color: Colors.grey.withValues(alpha: 0.1),
                      strokeWidth: 1,
                    );
                  },
                ),
                titlesData: const FlTitlesData(
                  show: false,
                ), // Eksen yazılarını gizledim, temiz görünüm için
                borderData: FlBorderData(show: false),
                minX: 0,
                maxX: (spots.length - 1).toDouble(),
                minY: 0,
                // Grafiğin üstünde biraz boşluk bırak
                maxY:
                    (spots.isEmpty
                        ? 0
                        : spots
                              .map((e) => e.y)
                              .reduce((a, b) => a > b ? a : b)) +
                    5,
                lineBarsData: [
                  LineChartBarData(
                    spots: spots,
                    isCurved: true,
                    curveSmoothness: 0.35,
                    color: lineColor,
                    barWidth: 4,
                    isStrokeCapRound: true,
                    dotData: FlDotData(
                      show: true,
                      getDotPainter: (spot, percent, barData, index) {
                        return FlDotCirclePainter(
                          radius: 4,
                          color: cardColor, // Nokta içi kart rengi
                          strokeWidth: 2,
                          strokeColor: lineColor, // Çerçevesi çizgi rengi
                        );
                      },
                    ),
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        colors: [
                          lineColor.withValues(alpha: 0.3),
                          lineColor.withValues(alpha: 0.0),
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DenemeListItem extends StatelessWidget {
  final String ad;
  final DateTime tarih;
  final double net;
  final String detay;

  const _DenemeListItem({
    required this.ad,
    required this.tarih,
    required this.net,
    required this.detay,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark ? const Color(0xFF1F2937) : Colors.white;
    final textColor = isDark ? Colors.white : Colors.black;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  ad,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: textColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const Gap(4),
                Text(
                  DateFormat('dd MMMM yyyy', 'tr_TR').format(tarih),
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
                const Gap(4),
                Text(
                  detay,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
              ],
            ),
          ),
          const Gap(10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                net.toStringAsFixed(2),
                style: const TextStyle(
                  color: Color(0xFF8B5CF6),
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              const Text(
                "Net",
                style: TextStyle(color: Colors.grey, fontSize: 10),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// --- DETAY SAYFASI ---
// --- DETAY SAYFASI (GÜNCELLENDİ: Alana Göre Filtreleme) ---
class _DenemeDetailPage extends StatelessWidget {
  final dynamic deneme; // TytDenemeModel veya AytDenemeModel
  final bool isTyt;

  const _DenemeDetailPage({required this.deneme, required this.isTyt});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = Theme.of(context).scaffoldBackgroundColor;
    final cardColor = isDark ? const Color(0xFF1F2937) : Colors.white;
    final textColor = isDark ? Colors.white : Colors.black87;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        title: Text(
          deneme.denemeAdi,
          style: GoogleFonts.montserrat(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: bgColor,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          physics: const BouncingScrollPhysics(),
          child: Column(
            children: [
              // --- Özet Başlık Kartı ---
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFF0099FF),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF0099FF).withValues(alpha: 0.3),
                      blurRadius: 15,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Text(
                      "Toplam Net",
                      style: GoogleFonts.montserrat(
                        color: Colors.white.withValues(alpha: 0.9),
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const Gap(5),
                    Text(
                      (isTyt ? hesaplaTytNet(deneme) : hesaplaAytNet(deneme))
                          .toStringAsFixed(2),
                      style: GoogleFonts.montserrat(
                        color: Colors.white,
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Gap(10),
                    // Tarih ve Alan Bilgisi
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            DateFormat(
                              'dd MMMM yyyy',
                              'tr_TR',
                            ).format(deneme.tarih),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                            ),
                          ),
                        ),
                        if (!isTyt) ...[
                          const Gap(8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              _getAlanAdi(
                                deneme.alan,
                              ), // Kısaltma yerine uzun ad
                              style: const TextStyle(
                                color: Color(0xFF0099FF),
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              const Gap(24),

              // --- Ders Detayları Listesi ---
              if (isTyt) ...[
                // TYT İse Standart
                _buildDetailRow(
                  "Türkçe",
                  deneme.turkceD,
                  deneme.turkceY,
                  cardColor,
                  textColor,
                ),
                _buildDetailRow(
                  "Sosyal",
                  deneme.sosyalD,
                  deneme.sosyalY,
                  cardColor,
                  textColor,
                ),
                _buildDetailRow(
                  "Matematik",
                  deneme.matD,
                  deneme.matY,
                  cardColor,
                  textColor,
                ),
                _buildDetailRow(
                  "Fen",
                  deneme.fenD,
                  deneme.fenY,
                  cardColor,
                  textColor,
                ),
              ] else ...[
                // AYT İse ALANA GÖRE FİLTRELEME
                if (deneme.alan == "SAY") ...[
                  _buildDetailRow(
                    "Matematik",
                    deneme.matD,
                    deneme.matY,
                    cardColor,
                    textColor,
                  ),
                  _buildDetailRow(
                    "Fizik",
                    deneme.fizD,
                    deneme.fizY,
                    cardColor,
                    textColor,
                  ),
                  _buildDetailRow(
                    "Kimya",
                    deneme.kimD,
                    deneme.kimY,
                    cardColor,
                    textColor,
                  ),
                  _buildDetailRow(
                    "Biyoloji",
                    deneme.biyD,
                    deneme.biyY,
                    cardColor,
                    textColor,
                  ),
                ] else if (deneme.alan == "EA") ...[
                  _buildDetailRow(
                    "Matematik",
                    deneme.matD,
                    deneme.matY,
                    cardColor,
                    textColor,
                  ),
                  _buildDetailRow(
                    "Edebiyat",
                    deneme.edbD,
                    deneme.edbY,
                    cardColor,
                    textColor,
                  ),
                  _buildDetailRow(
                    "Tarih-1",
                    deneme.tar1D,
                    deneme.tar1Y,
                    cardColor,
                    textColor,
                  ),
                  _buildDetailRow(
                    "Coğrafya-1",
                    deneme.cog1D,
                    deneme.cog1Y,
                    cardColor,
                    textColor,
                  ),
                ] else if (deneme.alan == "SOZ") ...[
                  _buildDetailRow(
                    "Edebiyat",
                    deneme.edbD,
                    deneme.edbY,
                    cardColor,
                    textColor,
                  ),
                  _buildDetailRow(
                    "Tarih-1",
                    deneme.tar1D,
                    deneme.tar1Y,
                    cardColor,
                    textColor,
                  ),
                  _buildDetailRow(
                    "Coğrafya-1",
                    deneme.cog1D,
                    deneme.cog1Y,
                    cardColor,
                    textColor,
                  ),
                  _buildDetailRow(
                    "Tarih-2",
                    deneme.tar2D,
                    deneme.tar2Y,
                    cardColor,
                    textColor,
                  ),
                  _buildDetailRow(
                    "Coğrafya-2",
                    deneme.cog2D,
                    deneme.cog2Y,
                    cardColor,
                    textColor,
                  ),
                  _buildDetailRow(
                    "Felsefe",
                    deneme.felD,
                    deneme.felY,
                    cardColor,
                    textColor,
                  ),
                  _buildDetailRow(
                    "Din Kültürü",
                    deneme.dinD,
                    deneme.dinY,
                    cardColor,
                    textColor,
                  ),
                ] else ...[
                  // Hata durumunda veya alan boşsa varsayılan olarak temel dersleri göster
                  _buildDetailRow(
                    "Matematik",
                    deneme.matD,
                    deneme.matY,
                    cardColor,
                    textColor,
                  ),
                  _buildDetailRow(
                    "Edebiyat",
                    deneme.edbD,
                    deneme.edbY,
                    cardColor,
                    textColor,
                  ),
                ],
              ],
            ],
          ),
        ),
      ),
    );
  }

  String _getAlanAdi(String kisaKod) {
    switch (kisaKod) {
      case 'SAY':
        return 'Sayısal';
      case 'EA':
        return 'Eşit Ağırlık';
      case 'SOZ':
        return 'Sözel';
      default:
        return kisaKod;
    }
  }

  Widget _buildDetailRow(
    String title,
    int d,
    int y,
    Color cardColor,
    Color textColor,
  ) {
    final net = d - (y / 4.0);
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Text(
              title,
              style: GoogleFonts.montserrat(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: textColor,
              ),
            ),
          ),
          // İstatistik Sütunları
          Row(
            children: [
              _buildStatBadge("D", "$d", Colors.green),
              const Gap(12),
              _buildStatBadge("Y", "$y", Colors.redAccent),
              const Gap(16),
              SizedBox(
                width: 60,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      net.toStringAsFixed(2),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18, // Net yazısını biraz büyüttüm
                        color: Color(0xFF8B5CF6),
                      ),
                    ),
                    const Text(
                      "Net",
                      style: TextStyle(fontSize: 10, color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatBadge(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: color,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.bold,
            color: color.withValues(alpha: 0.6),
          ),
        ),
      ],
    );
  }
}
