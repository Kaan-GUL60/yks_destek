import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:kgsyks_destek/sign/bilgi_database_helper.dart';
import 'package:kgsyks_destek/sign/yerel_kayit.dart';

// Önceki adımda oluşturduğumuz Model ve DatabaseHelper sınıflarını import ediyoruz.
// Dosya yollarının projenizdekiyle eşleştiğinden emin olun.
// 1. DatabaseHelper Sınıfına Erişim İçin Provider
// Bu provider, KullaniciDatabaseHelper'ın singleton (tekil) örneğini uygulamanın
// herhangi bir yerinden okumamızı sağlar.
final kullaniciDatabaseProvider = Provider<KullaniciDatabaseHelper>((ref) {
  return KullaniciDatabaseHelper.instance;
});

// 2. Veritabanı İşlemlerinin Durumunu Tutacak Enum
// UI'a işlemin hangi aşamada olduğunu (yükleniyor, başarılı, hatalı vb.) bildirmek için kullanılır.
enum KullaniciState {
  initial, // Başlangıç durumu
  loading, // İşlem yapılıyor
  success, // İşlem başarılı
  error, // İşlemde hata oluştu
}

// 3. StateNotifier Sınıfı
// Kullanıcıyı kaydetme veya silme gibi "aksiyonları" yönetir. Bu aksiyonların
// durumunu (KullaniciState) tutar.
class KullaniciNotifier extends StateNotifier<KullaniciState> {
  final Ref _ref;
  KullaniciNotifier(this._ref) : super(KullaniciState.initial);

  /// Yeni kullanıcıyı veritabanına kaydeder veya mevcut olanı günceller.
  Future<void> saveKullanici(KullaniciModel kullanici) async {
    try {
      state = KullaniciState.loading;
      final dbHelper = _ref.read(kullaniciDatabaseProvider);
      await dbHelper.saveKullanici(kullanici);
      state = KullaniciState.success;
      // ÖNEMLİ: Veri değiştiği için, kullanıcı verisini çeken
      // 'kullaniciProvider'ı yenileyerek UI'ın güncellenmesini sağlıyoruz.
      _ref.refresh(kullaniciProvider);
    } catch (e) {
      state = KullaniciState.error;
    }
  }

  /// Kayıtlı kullanıcıyı veritabanından siler (Örn: Çıkış yapma).
  Future<void> deleteKullanici() async {
    try {
      state = KullaniciState.loading;
      final dbHelper = _ref.read(kullaniciDatabaseProvider);
      await dbHelper.deleteKullanici();
      state = KullaniciState.success;
      // Veri silindiği için UI'ı güncellemek amacıyla provider'ı yeniliyoruz.
      _ref.refresh(kullaniciProvider);
    } catch (e) {
      state = KullaniciState.error;
    }
  }

  /// UI'da işlem (örn: success popup) gösterildikten sonra state'i başa döndürür.
  void resetState() {
    state = KullaniciState.initial;
  }
}

// 4. StateNotifierProvider
// UI katmanının KullaniciNotifier'a erişip `saveKullanici` gibi metotları çağırmasını sağlar.
// Buton tıklaması gibi olaylarda bu provider kullanılır.
final kullaniciNotifierProvider =
    StateNotifierProvider<KullaniciNotifier, KullaniciState>((ref) {
      return KullaniciNotifier(ref);
    });

// 5. FutureProvider
// Veritabanından kullanıcı verisini asenkron olarak "okumak" için kullanılır.
// UI'da kullanıcı bilgilerini (isim, email vb.) göstermek için bu provider'ı
// dinlemek (watch) en doğru yöntemdir.
final kullaniciProvider = FutureProvider<KullaniciModel?>((ref) {
  // Database provider'ını dinleyerek helper'a erişiyoruz.
  final dbHelper = ref.watch(kullaniciDatabaseProvider);
  return dbHelper.getKullanici();
});
