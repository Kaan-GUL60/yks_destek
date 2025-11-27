import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kgsyks_destek/pages/bilgi_karti/bilgi_notu_database_helper.dart';
import 'package:kgsyks_destek/pages/grafikler/deneme_database_helper.dart';
import 'package:kgsyks_destek/pages/grafikler/deneme_model.dart';
import 'package:kgsyks_destek/pages/soru_ekle/database_helper.dart'; // Sorular DB

// Ekranda göstereceğimiz verilerin paketi
class DashboardStats {
  final int cozulenSoru;
  final int bekleyenSoru;
  final int yanlisSoru;
  final int notSayisi;
  final double maxTytNet;
  final double maxAytNet;
  final double son3TytOrt;
  final double son3AytOrt;

  DashboardStats({
    required this.cozulenSoru,
    required this.bekleyenSoru,
    required this.yanlisSoru,
    required this.notSayisi,
    required this.maxTytNet,
    required this.maxAytNet,
    required this.son3TytOrt,
    required this.son3AytOrt,
  });
}

// --- NET HESAPLAMA FONKSİYONLARI (Burada tekrar tanımladık veya import edebilirsin) ---
double _hesaplaTyt(TytDenemeModel d) =>
    (d.turkceD - d.turkceY / 4) +
    (d.sosyalD - d.sosyalY / 4) +
    (d.matD - d.matY / 4) +
    (d.fenD - d.fenY / 4);
double _hesaplaAyt(AytDenemeModel d) =>
    (d.matD - d.matY / 4) +
    (d.fizD - d.fizY / 4) +
    (d.kimD - d.kimY / 4) +
    (d.biyD - d.biyY / 4) +
    (d.edbD - d.edbY / 4) +
    (d.tarD - d.tarY / 4) +
    (d.cogD - d.cogY / 4) +
    (d.felD - d.felY / 4) +
    (d.dinD - d.dinY / 4);

// --- ANA PROVIDER ---
final dashboardProvider = FutureProvider.autoDispose<DashboardStats>((
  ref,
) async {
  // 1. Soruları Çek
  final sorular = await DatabaseHelper.instance.getAllSorular();

  int cozulen = 0;
  int bekleyen = 0;
  int yanlis = 0;

  for (var s in sorular) {
    if (s.durum == 'Öğrenildi') {
      cozulen++;
    } else if (s.durum.contains('Yanlış')) {
      yanlis++;
    } else {
      bekleyen++; // Boş, Beklemede, Tekrar Edilecek vb.
    }
  }

  // 2. Notları Çek
  final notlar = await BilgiNotuDatabaseHelper.instance.getAllBilgiNotlari();
  final int notCount = notlar.length;

  // 3. Denemeleri Çek ve Hesapla
  final tytler = await DenemeDatabaseHelper.instance
      .getAllTyt(); // Tarihe göre sıralı (Eskiden yeniye)
  final aytler = await DenemeDatabaseHelper.instance.getAllAyt();

  // TYT Hesaplamaları
  double maxTyt = 0.0;
  double son3TytTop = 0.0;
  int tytAdet = 0;

  // En yüksek neti bul
  for (var t in tytler) {
    double net = _hesaplaTyt(t);
    if (net > maxTyt) maxTyt = net;
  }

  // Son 3 ortalama (Listeyi ters çevirip son eklenenleri alıyoruz)
  final reversedTyt = tytler.reversed.take(3).toList();
  if (reversedTyt.isNotEmpty) {
    for (var t in reversedTyt) {
      son3TytTop += _hesaplaTyt(t);
    }
    tytAdet = reversedTyt.length;
  }

  // AYT Hesaplamaları
  double maxAyt = 0.0;
  double son3AytTop = 0.0;
  int aytAdet = 0;

  for (var a in aytler) {
    double net = _hesaplaAyt(a);
    if (net > maxAyt) maxAyt = net;
  }

  final reversedAyt = aytler.reversed.take(3).toList();
  if (reversedAyt.isNotEmpty) {
    for (var a in reversedAyt) {
      son3AytTop += _hesaplaAyt(a);
    }
    aytAdet = reversedAyt.length;
  }

  return DashboardStats(
    cozulenSoru: cozulen,
    bekleyenSoru: bekleyen,
    yanlisSoru: yanlis,
    notSayisi: notCount,
    maxTytNet: maxTyt,
    maxAytNet: maxAyt,
    son3TytOrt: tytAdet > 0 ? son3TytTop / tytAdet : 0.0,
    son3AytOrt: aytAdet > 0 ? son3AytTop / aytAdet : 0.0,
  );
});
