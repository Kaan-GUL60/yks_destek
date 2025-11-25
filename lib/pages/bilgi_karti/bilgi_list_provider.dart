import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:kgsyks_destek/pages/bilgi_karti/bilgi_notu_database_helper.dart';
import 'package:kgsyks_destek/pages/bilgi_karti/bilgi_notu_model.dart';

// --- 1. TÜM NOTLARI ÇEKEN PROVIDER ---
final allBilgiNotlariProvider =
    FutureProvider.autoDispose<List<BilgiNotuModel>>((ref) async {
      // Veritabanından tüm notları getir
      return await BilgiNotuDatabaseHelper.instance.getAllBilgiNotlari();
    });

// --- 2. FİLTRE DURUMUNU TUTAN PROVIDER ---
class BilgiFilterState {
  final String? ders;
  final String? konu;
  final int? onemDerecesi; // null: Hepsi, 0: Kritik, 1: Olağan, 2: Düşük

  BilgiFilterState({this.ders, this.konu, this.onemDerecesi});

  BilgiFilterState copyWith({String? ders, String? konu, int? onemDerecesi}) {
    return BilgiFilterState(
      ders: ders ?? this.ders,
      konu: konu ?? this.konu,
      onemDerecesi: onemDerecesi, // null gelebilir o yüzden ?? kullanmadık
    );
  }
}

class BilgiFilterNotifier extends StateNotifier<BilgiFilterState> {
  BilgiFilterNotifier()
    : super(BilgiFilterState(onemDerecesi: null)); // Varsayılan: Hepsi

  void setDers(String? ders) {
    // Ders değişirse konuyu sıfırla
    state = BilgiFilterState(
      ders: ders,
      konu: null,
      onemDerecesi: state.onemDerecesi,
    );
  }

  void setKonu(String? konu) {
    state = state.copyWith(konu: konu);
  }

  void setOnemDerecesi(int? onem) {
    // onem: null (Hepsi), 0, 1, 2
    state = BilgiFilterState(
      ders: state.ders,
      konu: state.konu,
      onemDerecesi: onem,
    );
  }
}

final bilgiFilterProvider =
    StateNotifierProvider.autoDispose<BilgiFilterNotifier, BilgiFilterState>((
      ref,
    ) {
      return BilgiFilterNotifier();
    });

// lib/pages/bilgi_karti/bilgi_list_provider.dart

final filteredBilgiNotlariProvider = Provider.autoDispose<List<BilgiNotuModel>>(
  (ref) {
    final allNotesAsync = ref.watch(allBilgiNotlariProvider);
    final filter = ref.watch(bilgiFilterProvider);

    return allNotesAsync.when(
      data: (notes) {
        return notes.where((note) {
          // Ders Filtresi
          if (filter.ders != null && note.ders != filter.ders) {
            return false;
          }

          // Konu Filtresi
          if (filter.konu != null && note.konu != filter.konu) {
            return false;
          }

          // Önem Derecesi Filtresi (null ise hepsini göster)
          if (filter.onemDerecesi != null &&
              note.onemDerecesi != filter.onemDerecesi) {
            return false;
          }

          return true;
        }).toList();
      },
      loading: () => [],
      error: (_, _) => [],
    );
  },
);
