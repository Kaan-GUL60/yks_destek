import 'package:flutter_riverpod/legacy.dart';

final bottomNavIndexProvider = StateProvider<int>((ref) => 2);

enum Option { first, second }

enum Option2 { first, second, third }

enum OptionSoruCevabi { A, B, C, D, E }

/// seçili olanı tutan provider
final sinavProvider = StateProvider.autoDispose<Option>((ref) => Option.first);
final sinavProvider2 = StateProvider.autoDispose<Option2>(
  (ref) => Option2.first,
);
final soruCevabiProvider = StateProvider.autoDispose<OptionSoruCevabi?>(
  (ref) => null,
);
// Bir kez tıklandı mı durumunu takip eden provider
final isClickedProvider = StateProvider.autoDispose<bool>((ref) => false);
// Sınıf seçimi için provider
final sinifProvider = StateProvider.autoDispose<String>((ref) => 'Mezun');
