// Seçilen dersi tutacak provider
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:kgsyks_destek/pages/soru_ekle/listeler.dart';

final selectedDersProvider = StateProvider<String?>((ref) => null);
final selectedDurumProvider = StateProvider<String?>((ref) => null);
final selectedKonuProvider = StateProvider<String?>((ref) => null);
final selectedHataNedeniProvider = StateProvider<String?>((ref) => null);

// Arama sorgusunu tutacak provider
final searchQueryDersProvider = StateProvider<String>((ref) => '');
final searchQueryDurumProvider = StateProvider<String>((ref) => '');
final searchQueryKonuProvider = StateProvider<String>((ref) => '');
final searchQueryHataNedeniProvider = StateProvider<String>((ref) => '');

//

// Arama sorgusuna göre filtrelenmiş ders listesini oluşturan provider
final filteredDerslerProvider = Provider<List<String>>((ref) {
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

final filteredDurumProvider = Provider<List<String>>((ref) {
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

final filteredHataNedeniProvider = Provider<List<String>>((ref) {
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

final filteredKonuProvider = Provider<List<String>>((ref) {
  final query = ref
      .watch(searchQueryKonuProvider)
      .toLowerCase(); // Arama sorgusunu dinle

  if (query.isEmpty) {
    return filterKonular; // Sorgu boşsa tüm listeyi döndür
  } else {
    // Sorguya uyan dersleri filtrele
    return filterKonular.where((a) => a.toLowerCase().contains(query)).toList();
  }
});
