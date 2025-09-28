// lib/providers.dart (Güncellenmiş)

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:kgsyks_destek/pages/analiz_page/database_analiz.dart';

// Seçilen tarihi tutan provider
final selectedDateProvider = StateProvider<DateTime?>((ref) => null);

// Ders süresi girişini tutan provider
final studyDurationProvider = Provider.autoDispose<TextEditingController>((
  ref,
) {
  final controller = TextEditingController();
  ref.onDispose(() => controller.dispose());
  return controller;
});

// DatabaseService örneğini sağlayan provider
final databaseServiceProvider = Provider<DatabaseService>((ref) {
  return DatabaseService();
});

final analysisProvider = FutureProvider.autoDispose<List<Map<String, dynamic>>>(
  (ref) async {
    final rows = await DatabaseService().getAllDataSorted();
    return rows;
  },
);
final analysisProvider2 =
    FutureProvider.autoDispose<List<Map<String, dynamic>>>(
      //bu tyt için olacak
      (ref) async {
        final rows = await DatabaseService().getAllDataSorted();
        return rows;
      },
    );
final analysisProvider3 =
    FutureProvider.autoDispose<List<Map<String, dynamic>>>(
      //bu ayt için olacak
      (ref) async {
        final rows = await DatabaseService().getAllDataSorted();
        return rows;
      },
    );
