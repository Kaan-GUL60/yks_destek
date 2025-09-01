import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import 'package:kgsyks_destek/pages/soru_ekle/database_helper.dart';
import 'package:kgsyks_destek/pages/soru_ekle/listeler.dart';
import 'package:kgsyks_destek/pages/soru_ekle/soru_model.dart'; // Model yolu

// Durum Filtresi için Enum (Aynen kalıyor)
enum DurumFiltresi { hepsi, yanlislarim, boslarim, tamamladiklarim }

// 1. VERİTABANI SAĞLAYICI (Aynen kalıyor)
final soruDatabaseProvider = Provider<DatabaseHelper>((ref) {
  return DatabaseHelper.instance;
});

// 2. TÜM SORULARI ÇEKEN PROVIDER (Aynen kalıyor)
final allSorularProvider = FutureProvider<List<SoruModel>>((ref) {
  final dbHelper = ref.watch(soruDatabaseProvider);
  return dbHelper.getAllSorular();
});

// 3. FİLTRE DURUMUNU TUTAN STATE NOTIFIER (Aynen kalıyor)
class SorularFilterNotifier extends StateNotifier<Map<String, dynamic>> {
  SorularFilterNotifier()
    : super({'ders': null, 'konu': null, 'durum': DurumFiltresi.hepsi});

  void setDers(String? ders) {
    state = {'ders': ders, 'konu': null, 'durum': state['durum']};
  }

  void setKonu(String? konu) {
    state = {...state, 'konu': konu};
  }

  void setDurum(DurumFiltresi durum) {
    state = {...state, 'durum': durum};
  }
}

final sorularFilterProvider =
    StateNotifierProvider<SorularFilterNotifier, Map<String, dynamic>>((ref) {
      return SorularFilterNotifier();
    });

// DEĞİŞEN PROVIDER'LAR ////////////////////////////////////////////////////

// 5. TÜM DERSLERİN LİSTESİNİ OLUŞTURAN PROVIDER (GÜNCELLENDİ)
// Artık veritabanını okumak yerine doğrudan listeler.dart dosyasındaki
// 'dersler' listesini döndürüyor.
final dersListProvider = Provider<List<String>>((ref) {
  return dersler; // listeler.dart'tan gelen statik liste
});

// 6. SEÇİLİ DERSE GÖRE KONU LİSTESİNİ OLUŞTURAN PROVIDER (GÜNCELLENDİ)
// Artık veritabanını filtrelemek yerine, seçilen derse göre
// listeler.dart'taki 'konuMap'ten ilgili konu listesini getiriyor.
final konuListProvider = Provider<List<String>>((ref) {
  final selectedDers = ref.watch(sorularFilterProvider)['ders'];

  // Eğer bir ders seçilmemişse boş liste döndür.
  if (selectedDers == null) {
    return [];
  }
  // konuMap'ten seçili derse ait konu listesini al, bulunamazsa boş liste döndür.
  return konuMap[selectedDers] ?? [];
});

/////////////////////////////////////////////////////////////////////////

// 4. FİLTRELENMİŞ LİSTEYİ OLUŞTURAN NİHAİ PROVIDER (Aynen kalıyor)
// Bu provider'ın mantığı değişmedi çünkü o, filtrelenecek asıl sorularla ilgileniyor,
// filtre seçeneklerinin nereden geldiğiyle değil.
final filteredSorularProvider = Provider<List<SoruModel>>((ref) {
  final allSorularAsyncValue = ref.watch(allSorularProvider);
  final filter = ref.watch(sorularFilterProvider);

  if (!allSorularAsyncValue.hasValue) {
    return [];
  }

  final allSorular = allSorularAsyncValue.value!;

  return allSorular.where((soru) {
    final dersMatch = filter['ders'] == null || soru.ders == filter['ders'];
    final konuMatch = filter['konu'] == null || soru.konu == filter['konu'];

    bool durumMatch = false;
    switch (filter['durum']) {
      case DurumFiltresi.yanlislarim:
        durumMatch = soru.durum == 'Öğrenilecek';
        break;
      case DurumFiltresi.boslarim:
        durumMatch = soru.durum == 'Beklemede';
        break;
      case DurumFiltresi.tamamladiklarim:
        durumMatch = soru.durum == 'Öğrenildi';
        break;
      case DurumFiltresi.hepsi:
      default:
        durumMatch = true;
        break;
    }

    return dersMatch && konuMatch && durumMatch;
  }).toList();
});
