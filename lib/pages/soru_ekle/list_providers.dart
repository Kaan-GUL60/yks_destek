// Seçilen dersi tutacak provider
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:kgsyks_destek/pages/soru_ekle/listeler.dart';

final selectedDersProvider = StateProvider.autoDispose<String?>((ref) => null);
final selectedDurumProvider = StateProvider.autoDispose<String?>((ref) => null);
final selectedKonuProvider = StateProvider.autoDispose<String?>((ref) => null);
final selectedHataNedeniProvider = StateProvider.autoDispose<String?>(
  (ref) => null,
);

// Arama sorgusunu tutacak provider
final searchQueryDersProvider = StateProvider.autoDispose<String>((ref) => '');
final searchQueryDurumProvider = StateProvider.autoDispose<String>((ref) => '');
final searchQueryKonuProvider = StateProvider.autoDispose<String>((ref) => '');
final searchQueryHataNedeniProvider = StateProvider.autoDispose<String>(
  (ref) => '',
);

//

// Arama sorgusuna göre filtrelenmiş ders listesini oluşturan provider
final filteredDerslerProvider = Provider.autoDispose<List<String>>((ref) {
  final query = ref
      .watch(searchQueryDersProvider)
      .toLowerCase(); // Arama sorgusunu dinle

  if (query.isEmpty) {
    return dersler; // Sorgu boşsa tüm listeyi döndür
  } else {
    // Sorguya uyan dersleri filtrele
    return dersler.where((a) => a.toLowerCase().contains(query)).toList();
  }
});

final filteredDurumProvider = Provider.autoDispose<List<String>>((ref) {
  final query = ref
      .watch(searchQueryDurumProvider)
      .toLowerCase(); // Arama sorgusunu dinle

  if (query.isEmpty) {
    return durum; // Sorgu boşsa tüm listeyi döndür
  } else {
    // Sorguya uyan dersleri filtrele
    return durum.where((a) => a.toLowerCase().contains(query)).toList();
  }
});

final filteredHataNedeniProvider = Provider.autoDispose<List<String>>((ref) {
  final query = ref
      .watch(searchQueryHataNedeniProvider)
      .toLowerCase(); // Arama sorgusunu dinle

  if (query.isEmpty) {
    return hataNedeni; // Sorgu boşsa tüm listeyi döndür
  } else {
    // Sorguya uyan dersleri filtrele
    return hataNedeni.where((a) => a.toLowerCase().contains(query)).toList();
  }
});
final filteredKonuProvider = Provider.autoDispose<List<String>>((ref) {
  final secilenDers = ref.watch(selectedDersProvider);
  final query = ref.watch(searchQueryKonuProvider);

  if (secilenDers == null) return [];

  final dersIndex = dersler.indexOf(secilenDers);
  if (dersIndex == -1) return [];

  final konular = konularMap[dersIndex] ?? [];

  if (query.isEmpty) return konular;
  return konular
      .where((k) => k.toLowerCase().contains(query.toLowerCase()))
      .toList();
});
