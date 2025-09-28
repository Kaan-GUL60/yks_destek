// lib/providers/soru_provider.dart

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:kgsyks_destek/pages/soru_ekle/database_helper.dart';
import 'package:kgsyks_destek/pages/soru_ekle/soru_model.dart';
// DatabaseHelper yolu

// Veritabanı sınıfına erişim için provider
final databaseProvider = Provider.autoDispose<DatabaseHelper>((ref) {
  return DatabaseHelper.instance;
});

// Kaydetme işleminin durumunu tutacak enum
enum SoruKayitState { initial, loading, success, error }

final internetProvider = FutureProvider<bool>((ref) async {
  final results = await Connectivity().checkConnectivity();
  return results.any((r) => r != ConnectivityResult.none);
});

// State Notifier
class SoruNotifier extends StateNotifier<SoruKayitState> {
  final Ref _ref;
  SoruNotifier(this._ref) : super(SoruKayitState.initial);

  Future<void> addSoru(SoruModel soru) async {
    try {
      state = SoruKayitState.loading;
      final dbHelper = _ref.read(databaseProvider);
      await dbHelper.addSoru(soru);
      state = SoruKayitState.success;
    } catch (e) {
      state = SoruKayitState.error;
    }
  }

  Future<void> addBilgi(SoruModel soru) async {
    try {
      state = SoruKayitState.loading;
      final dbHelper = _ref.read(databaseProvider);
      await dbHelper.addSoru(soru);
      state = SoruKayitState.success;
    } catch (e) {
      state = SoruKayitState.error;
    }
  }

  // Form temizlendiğinde veya sayfa kapandığında state'i sıfırlamak için
  void resetState() {
    state = SoruKayitState.initial;
  }
}

// UI'ın kullanacağı StateNotifierProvider
final soruNotifierProvider =
    StateNotifierProvider.autoDispose<SoruNotifier, SoruKayitState>((ref) {
      return SoruNotifier(ref);
    });

final bilgiNotifierProvider =
    StateNotifierProvider.autoDispose<SoruNotifier, SoruKayitState>((ref) {
      return SoruNotifier(ref);
    });
