import 'package:flutter_riverpod/legacy.dart';

final bottomNavIndexProvider = StateProvider<int>((ref) => 2);

enum Option { first, second }

enum Option2 { first, second, third }

/// seçili olanı tutan provider
final sinavProvider = StateProvider<Option>((ref) => Option.first);
final sinavProvider2 = StateProvider<Option2>((ref) => Option2.first);

// Sınıf seçimi için provider
final sinifProvider = StateProvider<String>((ref) => 'Mezun');
