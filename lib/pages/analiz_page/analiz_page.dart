import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'; // ConsumerWidget ve WidgetRef için eklendi
import 'package:kgsyks_destek/go_router/router.dart';
import 'package:kgsyks_destek/pages/analiz_page/providers.dart';
import 'package:kgsyks_destek/theme_section/app_colors.dart';

// AnalizPage artık bir ConsumerWidget'tır, yani state dinleyebilir.
class AnalizPage extends ConsumerWidget {
  const AnalizPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // build metodu artık WidgetRef ref alır
    return Scaffold(
      appBar: AppBar(
        title: const Text("Analiz"),
        centerTitle: true,
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
      body: SingleChildScrollView(
        // Ekranın kaydırılabilir olması için
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Eğer bu bölümü kullanmak isterseniz: _buildUserInfoSection(context),
              const SizedBox(height: 20),
              _buildGraphCard(
                context: context,
                ref: ref, // ref'i alt metoda iletiyoruz
                title: 'Ders Çalışma Süresi',
                highest: '**',
                average: '**',
                saatNet: 'Saat',
                kayitVeri: "1",
              ),
              /*const SizedBox(height: 20),
              _buildGraphCard(
                context: context,
                ref: ref,
                title: 'TYT',
                highest: '**',
                average: '**',
                saatNet: 'Net',
                kayitVeri: "2",
              ),
              const SizedBox(height: 20),
              _buildGraphCard(
                context: context,
                ref: ref,
                title: 'AYT',
                highest: '**',
                average: '**',
                saatNet: 'Net',
                kayitVeri: "3",
              ), // AYT bölümü*/
            ],
          ),
        ),
      ),
    );
  }

  // Grafik kartları için ortak bir widget - context ve ref'i zorunlu parametre olarak alıyor
  Widget _buildGraphCard({
    required BuildContext context,
    required WidgetRef ref, // Artık ref'i parametre olarak alıyoruz
    required String title,
    required String highest,
    required String average,
    required String saatNet,
    required String kayitVeri,
    // Widget? graphWidget,
  }) {
    return Card(
      elevation: 0,
      color: Theme.of(context).colorScheme.primaryContainer,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  onPressed: () {
                    final ctx = context;
                    if (!ctx.mounted) return;
                    context.pushNamed(
                      AppRoute.analizAddPage.name,
                      pathParameters: {"id": kayitVeri},
                    );
                  },
                  icon: const Icon(Icons.add),
                  color: Colors.black,
                ),
              ],
            ),
            const SizedBox(height: 10),
            /*Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'En Yüksek: $highest $saatNet', // 'saat' veya 'Net' olarak değiştirilebilir
                  style: const TextStyle(fontSize: 14),
                ),
                Text(
                  'Ortalama: $average $saatNet',
                  style: const TextStyle(fontSize: 14),
                ),
              ],
            ),*/
            const SizedBox(height: 10),
            // Buraya grafik widget'ı gelecek
            _buildGraphWidget(
              context,
              ref,
              kayitVeri,
            ), // context ve ref'i grafiğe iletiyoruz
          ],
        ),
      ),
    );
  }

  // Grafik widget'ı - context ve ref'i kabul eder
  Widget _buildGraphWidget(BuildContext context, WidgetRef ref, String id) {
    // Not: Buradan 'id' kullanarak ilgili Riverpod provider'ını dinleyebilirsiniz:
    // final graphData = ref.watch(analizDataProvider(id));

    final asyncData = ref.watch(analysisProvider);

    return asyncData.when(
      data: (rows) {
        // rows: [{id:1,date:'2025-09-01',studyDuration:120}, ...]
        if (rows.isEmpty) {
          return const Center(
            child: Text(
              'Henüz veri kaydı yok. Lütfen bir kayıt ekleyin.',
              textAlign: TextAlign.center,
              style: TextStyle(fontStyle: FontStyle.italic, color: Colors.black54),
            ),
          );
        }
        final spots = <FlSpot>[];
        final dateLabels = <String>[];
        for (int i = 0; i < rows.length; i++) {
          final row = rows[i];
          final duration = (row['studyDuration'] as num).toDouble();
          spots.add(FlSpot(i.toDouble(), duration));
          dateLabels.add(row['date'] as String);
        }

        return Container(
          height: 150, // Grafiğin yüksekliği

          alignment: Alignment.center,
          child: LineChart(
            LineChartData(
              minX: 0,
              maxX: (spots.length - 1).toDouble(),
              minY: 0,
              maxY:
                  spots.map((s) => s.y).reduce((a, b) => a > b ? a : b) +
                  1, // biraz boşluk bırak
              lineBarsData: [
                LineChartBarData(
                  spots: spots,

                  gradient: LinearGradient(
                    colors: [AppColors.colorMat, AppColors.colorGeo],
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                  ),
                  isCurved: true,
                  barWidth: 3,
                  belowBarData: BarAreaData(
                    show: true,
                    gradient: LinearGradient(
                      colors: [
                        AppColors.colorMat.withValues(alpha: 0.3),
                        AppColors.colorGeo.withValues(alpha: 0.3),
                      ],
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                    ),
                  ),
                  preventCurveOverShooting: true,

                  //colors: [Colors.blue],
                  dotData: const FlDotData(show: false),
                ),
              ],
              gridData: const FlGridData(show: false),
              borderData: FlBorderData(
                show: true,
                border: const Border(left: BorderSide(), bottom: BorderSide()),
              ),

              titlesData: FlTitlesData(
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(showTitles: true, reservedSize: 22),
                ),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(showTitles: true, reservedSize: 28),
                ),
                rightTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),

                // Üst ekseni gizle
                topTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
              ),
              backgroundColor: Theme.of(context).colorScheme.primary,
            ),
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) => Center(child: Text('Hata: $err')),
    );
  }

  // Kullanıcı bilgileri bölümü - artık sınıfın bir metodu
  // ignore: unused_element
  Widget _buildUserInfoSection(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primaryContainer,
            borderRadius: BorderRadius.circular(15),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      'HEDEF: İstanbul Teknik Üniversitesi',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                    SizedBox(height: 5),
                    Text(
                      'BÖLÜM: Bilgisayar Mühendisliği',
                      style: TextStyle(fontSize: 14),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () {
                  final ctx = context;
                  if (!ctx.mounted) return;
                  context.pushNamed(
                    AppRoute.analizAddPage.name,
                    pathParameters: {"id": "0"},
                  );
                  // Hedef düzenleme işlemi
                },
                color: Colors.blue,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
