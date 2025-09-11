import 'package:flutter/material.dart';
import 'package:kgsyks_destek/pages/soru_ekle/database_helper.dart';
import 'package:kgsyks_destek/pages/soru_ekle/soru_model.dart';

class AnalizPage extends StatefulWidget {
  const AnalizPage({super.key});

  @override
  State<AnalizPage> createState() => _AnalizPageState();
}

class _AnalizPageState extends State<AnalizPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Analiz")),
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
                // _buildGraphWidget()'a grafik verilerini buraya ekle
              ),
              const SizedBox(height: 20),
              _buildGraphCard(
                title: 'TYT',
                highest: '**',
                average: '**',
                // _buildGraphWidget()'a grafik verilerini buraya ekle
              ),
              const SizedBox(height: 20),
              _buildGraphCard(
                title: 'AYT',
                highest: '**',
                average: '**',
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
                      'HEDEF: X Üniversitesi',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                    SizedBox(height: 5),
                    Text('BÖLÜM: Y Bölümü', style: TextStyle(fontSize: 14)),
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
                  'En Yüksek: $highest saat', // 'saat' veya 'Net' olarak değiştirilebilir
                  style: const TextStyle(fontSize: 14),
                ),
                Text(
                  'Ortalama: $average saat',
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
      color: Colors.grey[200],
      alignment: Alignment.center,
      child: const Text(
        'Grafik alanı',
        style: TextStyle(color: Colors.black54),
      ),
    );
  }

  // AYT bölümü

  // ignore: unused_element
  FutureBuilder<List<SoruModel>> _hamSoruVerileri() {
    return FutureBuilder<List<SoruModel>>(
      future: DatabaseHelper.instance.getAllSorular(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Text("Yükleniyor...");
        }
        if (snapshot.hasError) {
          return Text("Hata: ${snapshot.error}");
        }

        final sorular = snapshot.data ?? [];
        if (sorular.isEmpty) {
          return const Text("Henüz kayıt yok");
        }
        final tumVeriler = sorular
            .map((soru) {
              return """
    ID: ${soru.id}
    Ders: ${soru.ders}
    Konu: ${soru.konu}
    Durum: ${soru.durum}
    Hata Nedeni: ${soru.hataNedeni}
    Açıklama: ${soru.aciklama}
    Resim Yolu: ${soru.imagePath}
    Eklenme Tarihi: ${soru.eklenmeTarihi}
    Hatırlatıcı Tarihi: ${soru.hatirlaticiTarihi}
    --------------------------
    """;
            })
            .join("\n");

        return Text(tumVeriler, style: const TextStyle(fontSize: 16));
      },
    );
  }
}
