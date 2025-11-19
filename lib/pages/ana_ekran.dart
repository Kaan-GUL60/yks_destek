import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kgsyks_destek/pages/tek_satir_chart/progres_chart.dart';
import 'package:kgsyks_destek/pages/video_cozum.dart';
import 'package:kgsyks_destek/sign/yerel_kayit.dart';
import 'package:kgsyks_destek/soru_viewer/soru_view_provider.dart';

class AnaEkran extends ConsumerWidget {
  const AnaEkran({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // ignore: unused_local_variable
    final touchedIndex = ref.watch(touchedIndexProvider);
    //final kullaniciAsyncValue = ref.watch(kullaniciProvider);
    final grafikDataAsync = ref.watch(grafikDataProvider);
    final durumSayilariAsync = ref.watch(durumSayilariProvider);

    double dogru = 0;
    double bos = 0;
    double yanlis = 0;

    /*final myList = [
      MyData(value: 10, color: AppColors.colorTr, title: "Türkçe"),
      MyData(value: 10, color: AppColors.colorMat, title: "Matematik"),
      MyData(value: 20, color: AppColors.colorGeo, title: "Geometri"),
      MyData(value: 10, color: AppColors.colorFiz, title: "Fizik"),
      MyData(value: 10, color: AppColors.colorKim, title: "Kimya"),
      MyData(value: 40, color: AppColors.colorBiy, title: "Biyoloji"),
      MyData(value: 10, color: AppColors.colorTar, title: "Tarih"),
      MyData(value: 10, color: AppColors.colorCog, title: "Coğrafya"),
      MyData(value: 20, color: AppColors.colorDin, title: "Din"),
      MyData(value: 20, color: AppColors.colorFel, title: "Felsefe"),
    ];*/

    //int touchIndex = 0;

    return Scaffold(
      appBar: AppBar(
        title: Text("İstatistikler"),
        centerTitle: true,
        backgroundColor: Theme.of(context).colorScheme.primary,
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: IconButton(
              icon: const Icon(Icons.video_collection),
              onPressed: () {
                // Grafikleri yeniden yükle
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => YayinevleriListesi()),
                );
              },
            ),
          ),
        ],
      ),
      body: grafikDataAsync.when(
        data: (grafikData) {
          return durumSayilariAsync.when(
            data: (durumSayilari) {
              // Durum verisini MyData listesine çevir

              dogru = durumSayilari['Öğrenildi']!.toDouble();

              yanlis = durumSayilari['Öğrenilecek']!.toDouble();

              bos = durumSayilari['Beklemede']!.toDouble();

              return SingleChildScrollView(
                child: Column(
                  children: [
                    //_userNameGetterSeciton(kullaniciAsyncValue),
                    SizedBox(height: 20),
                    Padding(
                      padding: const EdgeInsets.only(left: 30.0, right: 30.0),
                      child: Card.outlined(
                        color: Theme.of(context).colorScheme.primaryContainer,
                        elevation: 0,
                        child: Column(
                          children: [
                            SizedBox(height: 10),

                            AspectRatio(
                              aspectRatio: 1,
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  PieChart(
                                    PieChartData(
                                      sections: grafikData.asMap().entries.map((
                                        entry,
                                      ) {
                                        final index = entry.key;
                                        final data = entry.value;
                                        final isTouched = index == touchedIndex;
                                        final radius = isTouched ? 72.0 : 70.0;
                                        return PieChartSectionData(
                                          value: data.value.toDouble(),
                                          color: data.color,
                                          // 🚨 If the section is touched, display the value as the title.
                                          // Otherwise, show the original title.
                                          title: isTouched
                                              ? data.value.toStringAsFixed(0)
                                              : data.title,
                                          radius: radius,
                                          showTitle: true,
                                          titleStyle: const TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                          ),
                                        );
                                      }).toList(),
                                      centerSpaceRadius: 60,
                                      pieTouchData: PieTouchData(
                                        touchCallback:
                                            (
                                              FlTouchEvent e,
                                              PieTouchResponse? r,
                                            ) {
                                              if (r != null &&
                                                  r.touchedSection != null) {
                                                // Update the provider with the touched index
                                                ref
                                                    .read(
                                                      touchedIndexProvider
                                                          .notifier,
                                                    )
                                                    .state = r
                                                    .touchedSection!
                                                    .touchedSectionIndex;
                                              }
                                            },
                                      ),
                                      sectionsSpace: 0,
                                    ),
                                  ),

                                  // 🎯 Ortadaki yazı
                                  Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        "Toplam",
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      Text(
                                        grafikData
                                            .fold<double>(
                                              0,
                                              (sum, e) => sum + e.value,
                                            )
                                            .toStringAsFixed(
                                              0,
                                            ), // Buraya toplam değeri dinamik olarak da verebilirsin
                                        style: TextStyle(
                                          fontSize: 36,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(
                                left: 16,
                                right: 16,
                                bottom: 16,
                              ),
                              child: ProgressTrackerBar(
                                correctCount: dogru,
                                emptyCount: bos,
                                incorrectCount: yanlis,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 20),
                    /*Padding(
                      padding: const EdgeInsets.only(left: 30.0, right: 30.0),
                      child: Card.outlined(
                        color: Theme.of(context).colorScheme.primaryContainer,
                        elevation: 0,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(15.0),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "KGS AI",
                                    style: TextStyle(fontSize: 20),
                                  ),
                                  SizedBox(height: 10),
                                  TextField(
                                    // Bu, metin kutusuna sadece okunabilir hale getirir.

                                    // Tasarım (isteğe bağlı)
                                    decoration: InputDecoration(
                                      border: OutlineInputBorder(),
                                      hintText: 'Merhaba...',
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),*/
                  ],
                ),
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, _) => Center(child: Text('Durum verisi hata: $err')),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Grafik verisi hata: $err')),
      ),
    );
  }

  // ignore: unused_element
  Padding _userNameGetterSeciton(
    AsyncValue<KullaniciModel?> kullaniciAsyncValue,
  ) {
    return Padding(
      padding: const EdgeInsets.only(left: 15.0, right: 15.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          kullaniciAsyncValue.when(
            data: (kullanici) {
              // Kullanıcı verisi varsa `userName`'i, yoksa 'Misafir' gösterir.
              final userName = kullanici?.userName ?? 'Misafir';

              return Text(
                userName,
                style: TextStyle(
                  fontSize: 20,
                  //fontWeight: FontWeight.bold,
                ),
              );
            },
            loading: () =>
                const CircularProgressIndicator(), // Veri yüklenirken
            error: (err, stack) => Text('Hata: $err'), // Hata oluştuğunda
          ),
          Text("<-Puan->", style: TextStyle(fontSize: 20)),
        ],
      ),
    );
  }
}

class MyData {
  final double value;
  final Color color;
  final String title;

  MyData({required this.value, required this.title, required this.color});
}
