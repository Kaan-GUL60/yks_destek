// SoruViewer'ı Riverpod ile kullanıma uygun hale getirme
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kgsyks_destek/soru_viewer/soru_view_provider.dart'; // SoruModel dosyanızı içe aktarın

class SoruViewer extends ConsumerWidget {
  final int soruId;
  const SoruViewer({super.key, required this.soruId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // soruId'yi parametre olarak ileterek soruProvider'ı dinliyoruz
    final soruAsyncValue = ref.watch(soruProvider(soruId));

    return Scaffold(
      appBar: AppBar(title: const Text("Soru Detayları")),
      body: soruAsyncValue.when(
        // Veri yüklenirken gösterilecek widget
        loading: () => const Center(child: CircularProgressIndicator()),

        // Bir hata oluştuğunda gösterilecek widget
        error: (error, stack) => Center(child: Text('Bir hata oluştu: $error')),

        // Veri başarıyla yüklendiğinde gösterilecek widget
        data: (soru) {
          if (soru == null) {
            return const Center(child: Text("Soru bulunamadı."));
          }

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Card.outlined(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  elevation: 1,
                  child: Padding(
                    padding: const EdgeInsets.all(15.0),
                    child: Column(
                      children: [
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Soru ID: ${soru.id}',
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                            const SizedBox(height: 10),
                            Text('Ders: ${soru.ders}'),
                            const SizedBox(height: 10),
                            Text('Konu: ${soru.konu}'),
                            const SizedBox(height: 10),
                            Text('Durum: ${soru.durum}'),
                            const SizedBox(height: 10),
                            Text('Sorunun Cevabı: ${soru.soruCevap} Şıkkı'),
                            const SizedBox(height: 10),
                            if (soru.imagePath.isNotEmpty)
                              Image.file(File(soru.imagePath)),
                          ],
                        ),
                        SizedBox(height: 15),
                        ElevatedButton(
                          onPressed: () {},
                          child: Text("Kalem aracı çok yakında..."),
                        ),
                      ],
                    ),
                  ),
                ),

                // Geri kalan verileri bu şekilde ekleyebilirsiniz
                // Veya Image.file(File(soru.imagePath))
              ],
            ),
          );
        },
      ),
    );
  }
}
