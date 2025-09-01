// lib/providers/soru_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kgsyks_destek/pages/soru_ekle/database_helper.dart';
import 'package:kgsyks_destek/pages/soru_ekle/soru_model.dart';

final soruProvider = FutureProvider.family<SoruModel?, int>((ref, id) async {
  // DatabaseHelper'daki getSoru() metodunu çağırıp veriyi döndürün
  return await DatabaseHelper.instance.getSoru(id);
});
