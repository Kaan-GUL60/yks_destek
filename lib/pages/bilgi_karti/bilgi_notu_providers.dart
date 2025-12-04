// lib/pages/bilgi_notu_ekle/bilgi_notu_providers.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:kgsyks_destek/pages/bilgi_karti/bilgi_notu_database_helper.dart';
import 'package:kgsyks_destek/pages/bilgi_karti/bilgi_notu_model.dart';
import 'package:kgsyks_destek/pages/soru_ekle/soru_ekle_provider.dart'; // SoruKayitState enum'ı için

// --- Form Seçim Provider'ları ---
// Kullanıcı ekrandan seçim yaptıkça bu değerler değişir.
final selectedBilgiDersProvider = StateProvider.autoDispose<String?>(
  (ref) => null,
);
final selectedBilgiKonuProvider = StateProvider.autoDispose<String?>(
  (ref) => null,
);
// Varsayılan önem derecesi: 1 (Olağan)
final selectedBilgiOnemProvider = StateProvider.autoDispose<int>((ref) => 1);

// --- Kayıt İşlemi Notifier'ı ---
class BilgiNotuNotifier extends StateNotifier<SoruKayitState> {
  // Constructor'da artık parametre almıyoruz çünkü singleton kullanıyoruz.
  BilgiNotuNotifier() : super(SoruKayitState.initial);

  Future<int> saveBilgiNotu(BilgiNotuModel not) async {
    try {
      state = SoruKayitState.loading;

      // Veritabanı helper'ına singleton üzerinden erişiyoruz
      final dbHelper = BilgiNotuDatabaseHelper.instance;

      final int id = await dbHelper.addBilgiNotu(not);

      state = SoruKayitState.success;
      return id;
    } catch (e) {
      // Hata durumunda state güncellenir
      state = SoruKayitState.error;
      return 0;
    }
  }

  // İşlem bitince veya sayfa kapanınca durumu sıfırlamak için
  void resetState() {
    state = SoruKayitState.initial;
  }
}

// UI Tarafından kullanılan Provider
final bilgiNotuNotifierProvider =
    StateNotifierProvider.autoDispose<BilgiNotuNotifier, SoruKayitState>((ref) {
      return BilgiNotuNotifier();
    });

// lib/pages/bilgi_notu_ekle/bilgi_notu_providers.dart dosyasının en altına ekle:

// Tek bir bilgi notunu ID ile getiren provider (AutoDispose, sayfadan çıkınca belleği temizler)
final bilgiNotuDetailProvider = FutureProvider.autoDispose
    .family<BilgiNotuModel?, int>((ref, id) async {
      final dbHelper = BilgiNotuDatabaseHelper.instance;
      return await dbHelper.getBilgiNotu(id);
    });

// Açıklama alanı için controller provider'ı (Soru görüntüleme mantığıyla aynı)
final bilgiAciklamaControllerProvider =
    Provider.autoDispose<TextEditingController>((ref) {
      return TextEditingController();
    });
