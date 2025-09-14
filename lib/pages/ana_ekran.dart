import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kgsyks_destek/pages/tek_satir_chart/progres_chart.dart';
import 'package:kgsyks_destek/sign/yerel_kayit.dart';
import 'package:kgsyks_destek/theme_section/app_colors.dart';
import 'package:kgsyks_destek/sign/bilgi_ekle_provider.dart';

class AnaEkran extends ConsumerWidget {
  const AnaEkran({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // ignore: unused_local_variable
    final kullaniciAsyncValue = ref.watch(kullaniciProvider);

    final myList = [
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
    ];

    //int touchIndex = 0;

    return Scaffold(
      appBar: AppBar(
        title: Text("İstatistikler"),
        centerTitle: true,
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
      body: SingleChildScrollView(
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
                    /*Text(
                      "İstatistikler",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                      ),
                    ),*/
                    SizedBox(height: 5),

                    AspectRatio(
                      aspectRatio: 1,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          PieChart(
                            PieChartData(
                              sections: myList
                                  .map(
                                    (data) => PieChartSectionData(
                                      value: data.value,
                                      color: data.color,
                                      title: data.title,
                                      radius: 70,
                                      showTitle: true,
                                      titleStyle: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                  )
                                  .toList(),
                              centerSpaceRadius: 75,
                              pieTouchData: PieTouchData(
                                touchCallback: (FlTouchEvent e, PieTouchResponse? r) {
                                  if (r != null && r.touchedSection != null) {
                                    // seçileni işaretleme için riverpod kullan setState yok.
                                    // touchIndex = r.touchedSection!.touchedSectionIndex;
                                  }
                                },
                              ),
                              sectionsSpace: 0,
                            ),
                          ),

                          // 🎯 Ortadaki yazı
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            children: const [
                              Text(
                                "Toplam",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              Text(
                                "70", // Buraya toplam değeri dinamik olarak da verebilirsin
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
                        correctCount: 45,
                        emptyCount: 35,
                        incorrectCount: 20,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 20),
            Padding(
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
                          Text("KGS AI", style: TextStyle(fontSize: 20)),
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
            ),
          ],
        ),
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
