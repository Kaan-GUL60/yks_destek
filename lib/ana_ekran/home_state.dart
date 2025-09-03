import 'package:flutter_riverpod/legacy.dart';

final bottomNavIndexProvider = StateProvider<int>((ref) => 2);

enum Option { first, second }

enum Option2 { first, second, third }

enum OptionSoruCevabi { A, B, C, D, E }

/// seçili olanı tutan provider
final sinavProvider = StateProvider<Option>((ref) => Option.first);
final sinavProvider2 = StateProvider<Option2>((ref) => Option2.first);
final soruCevabiProvider = StateProvider<OptionSoruCevabi>(
  (ref) => OptionSoruCevabi.A,
);

// Sınıf seçimi için provider
final sinifProvider = StateProvider<String>((ref) => 'Mezun');
