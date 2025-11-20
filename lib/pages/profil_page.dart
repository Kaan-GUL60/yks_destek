// ignore_for_file: use_build_context_synchronously

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gap/gap.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

final FirebaseAuth _auth = FirebaseAuth.instance;
final FirebaseFirestore _firestore = FirebaseFirestore.instance;
final TextEditingController _inviteController = TextEditingController();
int _inviteCount = 0;

class _ProfilePageState extends State<ProfilePage> {
  @override
  void initState() {
    super.initState();
    _loadInviteCount(); // Burada sadece
  }

  Future<void> _loadInviteCount() async {
    final user = _auth.currentUser;
    if (user == null) return;

    final userDoc = await _firestore.collection("users").doc(user.uid).get();
    final myCode = userDoc.data()?["inviteCode"];
    if (myCode == null) return;

    final codeDoc = await _firestore.collection("inviteCode").doc(myCode).get();
    final count = codeDoc.data()?["inviteCount"] ?? 0;

    setState(() {
      _inviteCount = count;
    });
  }

  final FirebaseAuth _auth = FirebaseAuth.instance;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil'),
        centerTitle: true,
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Yeni: Davet kodu doğrulama alanı
              Text(
                "Yakında en çok arkadaşını uygulamaya davet edenlere özel ödüller gelecek!",
              ),
              Gap(2),
              Divider(thickness: 1),
              Gap(10),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Davet kodu giriniz: (Toplam $_inviteCount kişi davet ettiniz)",
                  style: TextStyle(fontWeight: FontWeight.w900),
                ),
              ),
              Gap(10),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      enabled: false,
                      controller: _inviteController,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'Davet Kodunu Gir',
                      ),
                    ),
                  ),
                  SizedBox(width: 10), // İki widget arası boşluk
                  ElevatedButton(
                    onPressed: null,
                    /*() async {
                      await verifyInviteCode(_inviteController.text.trim());
                    },*/
                    child: Text("Doğrula"),
                  ),
                ],
              ),
              Gap(10),
              Divider(thickness: 1),
              Gap(10),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Veya kendi davet kodunuzu oluşturun:",
                  style: TextStyle(fontWeight: FontWeight.w900),
                ),
              ),

              Gap(10),
              ElevatedButton(
                onPressed: null,
                /*() async {
                  if (_auth.currentUser != null &&
                      !_auth.currentUser!.emailVerified) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Lütfen önce mailinizi doğrulayınız.'),
                      ),
                    );
                  } else if (_auth.currentUser != null &&
                      _auth.currentUser!.emailVerified) {
                    await createInviteCode();
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Kullanıcı bulunamadı veya hesap doğrulanmadı.',
                        ),
                      ),
                    );
                  }
                },*/
                child: Text("Davet kodu oluştur"),
              ),
              Gap(10),
              Divider(thickness: 1),
              Gap(10),
              Text("Mailinizi doğrulamadıysanız, lütfen doğrulayın."),
              Gap(10),
              ElevatedButton(
                onPressed: () async {
                  if (_auth.currentUser != null &&
                      !_auth.currentUser!.emailVerified) {
                    try {
                      await _auth.currentUser!.sendEmailVerification();
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Lütfen daha sonra tekrar deneyin.'),
                        ),
                      );
                    }
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Kullanıcı bulunamadı veya zaten doğrulandı.',
                        ),
                      ),
                    );
                  }
                },
                child: Text("Doğrulama Maili Gönder"),
              ),
              Gap(10),
              Text("Uygulamamız geliştirilmeye devam ediyor."),
              Gap(10),
              Text(
                "Yaşadığınız sorunları bize iletisim@kgstech.net mail adresi üzerinden bildirebilirsiniz.",
                textAlign: TextAlign.center,
              ),
              Gap(10),
              Text(
                "", //Yapay zeka özellikleri yakında aktif edilecektir.
                textAlign: TextAlign.center,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> verifyInviteCode(String code) async {
    final user = _auth.currentUser;
    if (user == null) return;
    if (code.length != 10) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Hatalı giriş, lütfen 10 karakter olacak şekilde giriniz.",
          ),
        ),
      );
      return;
    }

    final userDocRef = _firestore.collection("users").doc(user.uid);
    final userDoc = await userDocRef.get();

    if (!userDoc.exists ||
        !(userDoc.data()!.containsKey("davethakki")) ||
        userDoc["davethakki"] != true) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Davet hakkınız yok veya zaten kullanılmış."),
        ),
      );
      return;
    }
    final myCode = userDoc.data()!["inviteCode"];
    if (myCode == code) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Kendi davet kodunla kendini davet edemezsin."),
        ),
      );
      return;
    }

    // inviteCode koleksiyonunda girilen kodu ara
    final codeDoc = await _firestore.collection("inviteCode").doc(code).get();

    if (!codeDoc.exists) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Geçersiz davet kodu.")));
      return;
    }

    // inviteCount'u artır
    await _firestore.collection("inviteCode").doc(code).update({
      "inviteCount": FieldValue.increment(1),
    });

    // Kullanıcının davet hakkını false yap
    await userDocRef.update({"davethakki": false});

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Davet başarıyla kabul edildi!")),
    );
  }

  // createInviteCode ve generateInviteCode aynı şekilde kalabilir

  Future<String> generateInviteCode(String uid) async {
    final randomCode =
        uid.substring(0, 5) +
        DateTime.now().millisecondsSinceEpoch.toString().substring(7);
    return randomCode.toUpperCase();
  }

  Future<void> createInviteCode() async {
    final user = _auth.currentUser;

    if (user == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Kullanıcı oturum açmamış.")));
      return;
    }

    final userDoc = await _firestore.collection("users").doc(user.uid).get();

    // Eğer kod zaten varsa uyarı ver
    if (userDoc.exists && userDoc.data()!.containsKey("inviteCode")) {
      final existingCode = userDoc.data()!["inviteCode"];
      await Clipboard.setData(ClipboardData(text: existingCode));
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Zaten bir davet kodun var: $existingCode ve panoya kopyalandı.",
          ),
        ),
      );
      return;
    }

    final code = await generateInviteCode(user.uid);

    // Tüm veriler tek dokümanda field olarak kaydediliyor
    await _firestore.collection("users").doc(user.uid).set({
      "inviteCode": code,
      "inviteCreatedAt": FieldValue.serverTimestamp(),
      "inviteCount": 0,
    }, SetOptions(merge: true)); // diğer alanları ezmemesi için

    await Clipboard.setData(ClipboardData(text: code));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Davet kodun oluşturuldu: $code ve panoya kopyalandı."),
      ),
    );
    await _firestore.collection("inviteCode").doc(code).set({
      "inviteCode": code,
      "inviteCreatedAt": FieldValue.serverTimestamp(),
      "inviteCount": 0,
      "userId": user.uid,
    }); // diğer alanları ezmemesi için
  }
}
