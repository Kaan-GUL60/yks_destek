import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kgsyks_destek/pages/bilgi_karti/bilgi_notu_database_helper.dart';
import 'package:kgsyks_destek/pages/bilgi_karti/bilgi_notu_model.dart';

// Veritabanından verileri çekip RASTGELE karıştıran provider
final shuffledBilgiNotlariProvider =
    FutureProvider.autoDispose<List<BilgiNotuModel>>((ref) async {
      // 1. Verileri çek
      final allNotes = await BilgiNotuDatabaseHelper.instance
          .getAllBilgiNotlari();

      // 2. Listeyi karıştır (Shuffle)
      // Listeyi kopyalayıp karıştırıyoruz ki orijinal sıralama bozulmasın (database'de)
      final shuffledList = List<BilgiNotuModel>.from(allNotes)..shuffle();

      return shuffledList;
    });
