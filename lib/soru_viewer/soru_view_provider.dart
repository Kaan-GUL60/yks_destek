// lib/providers/soru_provider.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:kgsyks_destek/pages/soru_ekle/database_helper.dart';
import 'package:kgsyks_destek/pages/soru_ekle/soru_model.dart';

final soruProvider = FutureProvider.family<SoruModel?, int>((ref, id) async {
  // DatabaseHelper'daki getSoru() metodunu çağırıp veriyi döndürün
  return await DatabaseHelper.instance.getSoru(id);
});

final grafikDataProvider = FutureProvider<List<MyData>>((ref) async {
  return await getSoruSayilariDerseGoreGrafik();
});
final durumSayilariProvider = FutureProvider<Map<String, int>>((ref) async {
  return await DatabaseHelper.instance.getSoruDurumSayilari();
});

// Add this provider outside of the AnaEkran class.
final touchedIndexProvider = StateProvider<int>((ref) => -1);

// Soru açıklamasını düzenlemek için kullanılan TextEditingController'ın durumunu tutar
final aciklamaControllerProvider =
    StateProvider.autoDispose<TextEditingController>((ref) {
      // Başlangıçta boş bir Controller oluşturulur. SoruModel'den gelen veri ile doldurulur.
      return TextEditingController();
    });
