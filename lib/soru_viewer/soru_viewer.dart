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
                Text(
                  'Soru ID: ${soru.id}',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 10),
                Text('Ders: ${soru.ders}'),
                Text('Konu: ${soru.konu}'),
                Text('Durum: ${soru.durum}'),
                // Geri kalan verileri bu şekilde ekleyebilirsiniz
                if (soru.imagePath.isNotEmpty)
                  Image.file(
                    File(soru.imagePath),
                  ), // Veya Image.file(File(soru.imagePath))
              ],
            ),
          );
        },
      ),
    );
  }
}
