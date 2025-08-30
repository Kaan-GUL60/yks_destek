// lib/models/soru_model.dart

class KullaniciModel {
  final String userName;
  final String email;
  final String uid;
  final String profilePhotos;
  final int sinif;
  final int sinav;
  final int alan;
  final String kurumKodu;
  final bool isPro;
  // Kullanıcı seçmeyebilir, bu yüzden nullable

  KullaniciModel({
    required this.userName,
    required this.email,
    required this.uid,
    required this.profilePhotos,
    required this.sinif,
    required this.sinav,
    required this.alan,
    required this.kurumKodu,
    required this.isPro,
  });

  Map<String, dynamic> toMap() {
    return {
      'userName': userName,
      'email': email,
      'uid': uid,
      'profilePhotos': profilePhotos,
      'sinif': sinif,
      'sinav': sinav,
      'alan': alan,
      // DateTime nesnelerini veritabanı için String'e çeviriyoruz
      'kurumKodu': kurumKodu,
      'isPro': isPro,
    };
  }

  factory KullaniciModel.fromMap(Map<String, dynamic> map) {
    return KullaniciModel(
      userName: map['userName'],
      email: map['email'],
      uid: map['uid'],
      profilePhotos: map['profilePhotos'],
      sinif: map['sinif'],
      sinav: map['sinav'],
      alan: map['alan'],
      // Veritabanından okurken String'i tekrar DateTime'a çeviriyoruz
      kurumKodu: map['kurumKodu'],
      isPro: map['isPro'],
    );
  }
}
