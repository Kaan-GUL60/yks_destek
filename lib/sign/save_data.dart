// user_auth.dart
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:firebase_auth/firebase_auth.dart';

class UserAuth {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<bool> checkUserVeri(String uid) async {
    final docRef = _firestore.collection("users").doc(uid);
    final doc = await docRef.get();

    if (!doc.exists) return false;
    return true;
  }

  Future<void> soruSayiArtir(String arttirilacakDeger) async {
    final user = _auth.currentUser;

    // Eğer bir kullanıcı oturum açmadıysa (yani `user` null ise), işlemi sonlandırın
    if (user == null) {
      return;
    }
    // Kullanıcı oturum açtıysa, UID'sine güvenle erişebilirsiniz
    final docRef = _firestore.collection("users").doc(user.uid);

    await docRef.set({
      arttirilacakDeger: FieldValue.increment(1),
    }, SetOptions(merge: true));
  }

  /// Firestore'dan kullanıcı verilerini okur
  Future<int> checkLicenseKey(String key) async {
    final docRef = _firestore.collection("lisansKeys").doc("lisansKeys");
    final doc = await docRef.get();

    if (!doc.exists) return 1;

    final data = doc.data() as Map<String, dynamic>;
    if (!data.containsKey(key)) return 2;

    final currentValue = data[key] as int;
    if (currentValue <= 0) return 3;

    await docRef.update({key: currentValue - 1});
    return 4;
  }

  /// Mail doğrulandıysa kullanıcı verilerini Firestore’a kaydeder
  Future<void> saveUserData({
    required String userName,
    required String email,
    required String uid,
    required String profilePhotos,
    required int sinif,
    required int sinav,
    required int alan,
    required String kurumKodu,
    required bool isPro,
    required String nerdenDuydunuz, // 1. Yeni parametre eklendi
  }) async {
    final user = _auth.currentUser;

    if (user == null) {
      throw Exception("Kullanıcı oturumu bulunamadı.");
    }

    try {
      await user.reload();
    } on FirebaseAuthException catch (e) {
      if (e.code == "user-not-found") {
        throw Exception("Bu kullanıcı FirebaseAuth'ta mevcut değil.");
      }
      rethrow;
    }

    /*if (!user.emailVerified) {
      throw Exception("Mail doğrulanmamış, kayıt yapılamaz.");
    }
    if (!user.emailVerified) {
      throw Exception("Mail doğrulanmamış, kayıt yapılamaz.");
    }*/

    await _firestore.collection("users").doc(user.uid).set({
      'userName': userName,
      'email': email,
      'uid': uid,
      'profilePhotos': profilePhotos,
      'sinif': sinif,
      'sinav': sinav,
      'alan': alan,
      'kurumKodu': kurumKodu,
      'isPro': isPro,
      'nerdenDuydunuz': nerdenDuydunuz, // 2. Firestore map'ine eklendi
      'createdAt': FieldValue.serverTimestamp(),
    });
  }
}
