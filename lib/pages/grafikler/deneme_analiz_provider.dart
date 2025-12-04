import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:kgsyks_destek/pages/grafikler/deneme_database_helper.dart';
import 'package:kgsyks_destek/pages/grafikler/deneme_model.dart';

// --- NET HESAPLAMA YARDIMCI FONKSİYONU ---
double hesaplaTytNet(TytDenemeModel d) {
  double turkce = d.turkceD - (d.turkceY / 4.0);
  double sosyal = d.sosyalD - (d.sosyalY / 4.0);
  double mat = d.matD - (d.matY / 4.0);
  double fen = d.fenD - (d.fenY / 4.0);
  return turkce + sosyal + mat + fen;
}

double hesaplaAytNet(AytDenemeModel d) {
  // Tüm derslerin netlerini topla (GÜNCELLENDİ)
  // Kullanıcı alanına göre doldurduğu için boş olanlar 0 gelecek ve sonucu etkilemeyecek.

  double mat = d.matD - (d.matY / 4.0);
  double fiz = d.fizD - (d.fizY / 4.0);
  double kim = d.kimD - (d.kimY / 4.0);
  double biy = d.biyD - (d.biyY / 4.0);
  double edb = d.edbD - (d.edbY / 4.0);

  double tar1 = d.tar1D - (d.tar1Y / 4.0); // Eski tar -> tar1
  double cog1 = d.cog1D - (d.cog1Y / 4.0); // Eski cog -> cog1

  double tar2 = d.tar2D - (d.tar2Y / 4.0); // Yeni
  double cog2 = d.cog2D - (d.cog2Y / 4.0); // Yeni

  double fel = d.felD - (d.felY / 4.0);
  double din = d.dinD - (d.dinY / 4.0);

  return mat + fiz + kim + biy + edb + tar1 + cog1 + tar2 + cog2 + fel + din;
}

// --- PROVIDERLAR ---

// 1. TYT Listesi Provider
final tytListProvider = FutureProvider.autoDispose<List<TytDenemeModel>>((
  ref,
) async {
  return await DenemeDatabaseHelper.instance.getAllTyt();
});

// 2. AYT Listesi Provider
final aytListProvider = FutureProvider.autoDispose<List<AytDenemeModel>>((
  ref,
) async {
  return await DenemeDatabaseHelper.instance.getAllAyt();
});

// 3. Seçili Tab (TYT mi AYT mi?)
// 0: TYT, 1: AYT
final analizTabProvider = StateProvider.autoDispose<int>((ref) => 0);
