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
      appBar: AppBar(title: const Text("Soru Görüntüle")),
      body: SingleChildScrollView(
        child: Center(
          child: FutureBuilder<List<SoruModel>>(
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
          ),
        ),
      ),
    );
  }
}
