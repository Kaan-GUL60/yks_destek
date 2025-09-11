import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kgsyks_destek/sign/bilgi_ekle_provider.dart';

class AnaEkran extends ConsumerWidget {
  const AnaEkran({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final kullaniciAsyncValue = ref.watch(kullaniciProvider);
    final myList = [
      MyData(value: 10, color: Colors.amber, title: "Türkçe"),
      MyData(value: 10, color: Colors.blue, title: "Matematik"),
      MyData(value: 10, color: Colors.brown, title: "Fizik"),
      MyData(value: 10, color: Colors.amber, title: "Kimya"),
      MyData(value: 10, color: Colors.green, title: "Biyoloji"),
      MyData(value: 10, color: Colors.blueAccent, title: "Geometri"),
      MyData(value: 10, color: Colors.deepOrangeAccent, title: "Sosyal"),
    ];

    //int touchIndex = 0;

    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(height: 50),
            Padding(
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
                          fontWeight: FontWeight.bold,
                        ),
                      );
                    },
                    loading: () =>
                        const CircularProgressIndicator(), // Veri yüklenirken
                    error: (err, stack) =>
                        Text('Hata: $err'), // Hata oluştuğunda
                  ),
                  Text("<-Puan->", style: TextStyle(fontSize: 20)),
                ],
              ),
            ),
            SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.only(left: 30.0, right: 30.0),
              child: Card.outlined(
                color: Theme.of(context).colorScheme.primaryContainer,
                elevation: 1,
                child: Column(
                  children: [
                    SizedBox(height: 20),
                    Text(
                      "Toplam Soru Sayısı",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(height: 5),
                    Text("<-Soru Sayısı->", style: TextStyle(fontSize: 20)),
                    SizedBox(height: 20),
                    AspectRatio(
                      aspectRatio: 1,
                      child: PieChart(
                        PieChartData(
                          sections: myList
                              .map(
                                (data) => PieChartSectionData(
                                  value: data.value,
                                  color: data.color,
                                  title: "${data.title}\n${data.value.toInt()}",
                                  radius: 70,
                                  borderSide: BorderSide(
                                    width: 2,
                                    color: Colors.black,
                                  ),
                                  showTitle: true,
                                  titleStyle: TextStyle(
                                    fontSize: 16,
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
                                //seçileni işaretleme için riverpod kullan setstate yok.
                                //touchIndex = r.touchedSection!.touchedSectionIndex;
                              }
                            },
                          ),

                          sectionsSpace: 4,
                        ),
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
                elevation: 1,
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
                            readOnly: true,

                            // İçinde görünecek metin.
                            controller: TextEditingController(
                              text: 'Çok yakında...',
                            ),

                            // Tasarım (isteğe bağlı)
                            decoration: InputDecoration(
                              border: OutlineInputBorder(),
                              hintText: 'Çok yakında...',
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
}

class MyData {
  final double value;
  final Color color;
  final String title;

  MyData({required this.value, required this.title, required this.color});
}
