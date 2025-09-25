import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:kgsyks_destek/theme_section/app_colors.dart';

class AnalizPage extends StatefulWidget {
  const AnalizPage({super.key});

  @override
  State<AnalizPage> createState() => _AnalizPageState();
}

class _AnalizPageState extends State<AnalizPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Analiz"),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
      body: SingleChildScrollView(
        // Ekranın kaydırılabilir olması için
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildUserInfoSection(), // Kullanıcı bilgileri bölümü
              const SizedBox(height: 20),
              _buildGraphCard(
                title: 'Ders Çalışma Süresi',
                highest: '**',
                average: '**',
                saatNet: 'Saat',
                // _buildGraphWidget()'a grafik verilerini buraya ekle
              ),
              const SizedBox(height: 20),
              _buildGraphCard(
                title: 'TYT',
                highest: '**',
                average: '**',
                saatNet: 'Net',
                // _buildGraphWidget()'a grafik verilerini buraya ekle
              ),
              const SizedBox(height: 20),
              _buildGraphCard(
                title: 'AYT',
                highest: '**',
                average: '**',
                saatNet: 'Net',
                // _buildGraphWidget()'a grafik verilerini buraya ekle
              ), // AYT bölümü
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUserInfoSection() {
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
                icon: Icon(Icons.edit),
                onPressed: () {
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

  // Grafik kartları için ortak bir widget
  Widget _buildGraphCard({
    required String title,
    required String highest,
    required String average,
    required String saatNet,
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
                const Icon(Icons.add, color: Colors.black),
              ],
            ),
            const SizedBox(height: 10),
            Row(
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
            ),
            const SizedBox(height: 10),
            // Buraya grafik widget'ı gelecek
            _buildGraphWidget(),
          ],
        ),
      ),
    );
  }

  // Grafik placeholder'ı. Gerçek grafik kütüphanesi (fl_chart, charts_flutter vb.) buraya entegre edilebilir.
  Widget _buildGraphWidget() {
    return Container(
      height: 150, // Grafiğin yüksekliği

      alignment: Alignment.center,
      child: LineChart(
        LineChartData(
          lineBarsData: [
            LineChartBarData(
              spots: const [
                FlSpot(0, 1),
                FlSpot(1, 3),
                FlSpot(2, 2),
                FlSpot(3, 5),
                FlSpot(4, 3),
                FlSpot(5, 4),
                FlSpot(6, 7),
                FlSpot(7, 2),
                FlSpot(8, 1),
              ],

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
              dotData: FlDotData(show: false),
            ),
          ],
          gridData: FlGridData(show: false),
          borderData: FlBorderData(
            show: true,
            border: Border(left: BorderSide(), bottom: BorderSide()),
          ),

          titlesData: FlTitlesData(
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(showTitles: true, reservedSize: 22),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(showTitles: true, reservedSize: 28),
            ),
            rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),

            // Üst ekseni gizle
            topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          backgroundColor: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }

  // AYT bölümü
}
