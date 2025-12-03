import 'dart:io'; // Platform kontrolü
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/cupertino.dart'; // iOS widget'ları
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:kgsyks_destek/pages/grafikler/deneme_analiz_provider.dart';
import 'package:kgsyks_destek/pages/grafikler/deneme_ekle_page.dart';

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
          // Ekleme Butonu (Sağ Üst)
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: IconButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const DenemeEklePage()),
                ).then((_) {
                  // Geri dönüldüğünde verileri yenile
                  // DÜZELTME: Sayfa hala açık mı kontrol et
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
                // İYİLEŞTİRME 1: Platforma Duyarlı İkon
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
      // İYİLEŞTİRME 2: SafeArea
      body: SafeArea(
        child: Column(
          children: [
            const Gap(10),
            // 1. TOGGLE BUTONU (TYT / AYT)
            _buildCustomToggle(ref, selectedTab, primaryColor, isDark),

            const Gap(20),

            // 2. İÇERİK (GRAFİK + LİSTE)
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

  // Özel Toggle Tasarımı (Korundu)
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
      // İYİLEŞTİRME 3: Platforma Duyarlı Loading
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

        // Netleri hesapla ve listeye ekle
        final List<double> netler = denemeler
            .map((d) => hesaplaTytNet(d))
            .toList();
        final double sonNet = netler.last;
        final double ortalama = netler.reduce((a, b) => a + b) / netler.length;

        // Grafik için veri hazırla
        final List<FlSpot> spots = [];
        for (int i = 0; i < netler.length; i++) {
          spots.add(FlSpot(i.toDouble(), netler[i]));
        }

        return ListView(
          // İYİLEŞTİRME 4: iOS Esneme Efekti
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20),
          children: [
            // GRAFİK KARTI
            _ChartCard(
              title: "TYT Net Grafiği",
              currentNet: sonNet,
              average: ortalama,
              spots: spots,
              isTyt: true,
            ),
            const Gap(24),

            // SON DENEMELER BAŞLIĞI
            Text(
              "Son Denemeler",
              style: GoogleFonts.montserrat(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Gap(12),

            // LİSTE
            ...denemeler.reversed.map((deneme) {
              final net = hesaplaTytNet(deneme);
              return _DenemeListItem(
                ad: deneme.denemeAdi,
                tarih: deneme.tarih,
                net: net,
                detay:
                    "TR: ${deneme.turkceD}-${deneme.turkceY} | Mat: ${deneme.matD}-${deneme.matY}",
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
class _AytAnalizView extends ConsumerWidget {
  const _AytAnalizView();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final aytListAsync = ref.watch(aytListProvider);

    return aytListAsync.when(
      // İYİLEŞTİRME 3: Platforma Duyarlı Loading
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

        final List<double> netler = denemeler
            .map((d) => hesaplaAytNet(d))
            .toList();
        final double sonNet = netler.last;
        final double ortalama = netler.reduce((a, b) => a + b) / netler.length;

        final List<FlSpot> spots = [];
        for (int i = 0; i < netler.length; i++) {
          spots.add(FlSpot(i.toDouble(), netler[i]));
        }

        return ListView(
          // İYİLEŞTİRME 4: iOS Esneme Efekti
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20),
          children: [
            _ChartCard(
              title: "AYT Net Grafiği",
              currentNet: sonNet,
              average: ortalama,
              spots: spots,
              isTyt: false,
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
              return _DenemeListItem(
                ad: deneme.denemeAdi,
                tarih: deneme.tarih,
                net: net,
                detay: "${deneme.alan} | Mat: ${deneme.matD}-${deneme.matY}",
              );
            }),
            const Gap(30),
          ],
        );
      },
    );
  }
}

// --- WIDGETLAR (Aynı kaldı) ---

class _ChartCard extends StatelessWidget {
  final String title;
  final double currentNet;
  final double average;
  final List<FlSpot> spots;
  final bool isTyt;

  const _ChartCard({
    required this.title,
    required this.currentNet,
    required this.average,
    required this.spots,
    required this.isTyt,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark ? const Color(0xFF1F2937) : Colors.white;
    final lineColor = const Color(0xFF8B5CF6);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.05),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
          const Gap(8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                "${currentNet.toStringAsFixed(1)} Net",
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.black,
                ),
              ),
            ],
          ),
          Text(
            "Ortalama: ${average.toStringAsFixed(2)}",
            style: const TextStyle(
              color: Colors.green,
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
          ),
          const Gap(24),

          // --- GRAFİK ALANI ---
          SizedBox(
            height: 150,
            child: LineChart(
              LineChartData(
                gridData: const FlGridData(show: false),
                titlesData: const FlTitlesData(show: false),
                borderData: FlBorderData(show: false),
                minX: 0,
                maxX: (spots.length - 1).toDouble(),
                minY: 0,
                maxY:
                    (spots.map((e) => e.y).reduce((a, b) => a > b ? a : b)) +
                    10,
                lineBarsData: [
                  LineChartBarData(
                    spots: spots,
                    isCurved: true,
                    color: lineColor,
                    barWidth: 4,
                    isStrokeCapRound: true,
                    dotData: const FlDotData(show: false),
                    belowBarData: BarAreaData(
                      show: true,
                      color: lineColor.withValues(alpha: 0.1),
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
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                ad,
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
                style: TextStyle(color: Colors.grey[600], fontSize: 12),
              ),
            ],
          ),
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
