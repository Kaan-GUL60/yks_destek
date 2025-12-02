// ignore_for_file: use_build_context_synchronously

import 'dart:io'; // Platform kontrolü
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart'; // iOS widget'ları
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gap/gap.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

// Global değişkenler korundu
final FirebaseAuth _auth = FirebaseAuth.instance;
final FirebaseFirestore _firestore = FirebaseFirestore.instance;
final TextEditingController _inviteController = TextEditingController();
int _inviteCount = 0;

class _ProfilePageState extends State<ProfilePage> {
  @override
  void initState() {
    super.initState();
    _loadInviteCount();
  }

  // --- MEVCUT MANTIK FONKSİYONLARI (AYNEN KORUNDU) ---
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

  Future<void> verifyInviteCode(String code) async {
    final user = _auth.currentUser;
    if (user == null) return;

    final userDocRef = _firestore.collection("users").doc(user.uid);
    final userDoc = await userDocRef.get();

    final myCode = userDoc.data()!["inviteCode"];
    if (myCode == code) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Kendi davet kodunla kendini davet edemezsin."),
        ),
      );
      return;
    }
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

    final codeDoc = await _firestore.collection("inviteCode").doc(code).get();

    if (!codeDoc.exists) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Geçersiz davet kodu.")));
      return;
    }

    await _firestore.collection("inviteCode").doc(code).update({
      "inviteCount": FieldValue.increment(1),
    });

    await userDocRef.update({"davethakki": false});

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Davet başarıyla kabul edildi!")),
    );
  }

  Future<String> generateInviteCode(String uid) async {
    final randomCode =
        uid.substring(0, 5) +
        DateTime.now().millisecondsSinceEpoch.toString().substring(7);
    return randomCode.toUpperCase();
  }

  Future<void> createInviteCode() async {
    final user = _auth.currentUser;

    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Kullanıcı oturum açmamış.")),
      );
      return;
    }

    final userDoc = await _firestore.collection("users").doc(user.uid).get();

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

    await _firestore.collection("users").doc(user.uid).set({
      "inviteCode": code,
      "inviteCreatedAt": FieldValue.serverTimestamp(),
      "inviteCount": 0,
      "davethakki": true,
    }, SetOptions(merge: true));

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
    });
  }
  // -------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    // --- TASARIM DEĞİŞKENLERİ ---
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final Color primaryBlue = const Color(0xFF1A56DB);
    final Color cardColor = isDark ? const Color(0xFF1F2937) : Colors.white;
    final Color bgColor = isDark
        ? const Color(0xFF111827)
        : const Color(0xFFF3F4F6);
    final Color textColor = isDark ? Colors.white : const Color(0xFF111827);
    final Color subTextColor = isDark
        ? Colors.grey.shade400
        : Colors.grey.shade600;
    final Color inputFillColor = isDark
        ? const Color(0xFF111827)
        : const Color(0xFFF9FAFB);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        title: Text(
          'Profil',
          style: TextStyle(color: textColor, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: bgColor,
        elevation: 0,
        iconTheme: IconThemeData(color: textColor),
      ),
      // İYİLEŞTİRME 1: SafeArea
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                // --- 1. KART: ARKADAŞLARINI DAVET ET ---
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: cardColor,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: isDark
                        ? []
                        : [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.05),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Başlık ve İkon
                      Row(
                        children: [
                          // İYİLEŞTİRME 2: Platform İkonu
                          Icon(
                            Platform.isIOS
                                ? CupertinoIcons.person_3_fill
                                : Icons.people_alt_rounded,
                            color: primaryBlue,
                            size: 24,
                          ),
                          const Gap(10),
                          Text(
                            "Arkadaşlarını Davet Et",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: textColor,
                            ),
                          ),
                        ],
                      ),
                      const Gap(12),
                      Text(
                        "Yakında en çok arkadaşını uygulamaya davet edenlere özel ödüller gelecek!",
                        style: TextStyle(color: subTextColor, fontSize: 14),
                      ),
                      const Gap(20),

                      // Davet Kodu Giriş Alanı
                      Text(
                        "Davet kodu giriniz:",
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: textColor,
                        ),
                      ),
                      const Gap(8),
                      Row(
                        children: [
                          Expanded(
                            child: SizedBox(
                              height: 48,
                              child: TextField(
                                controller: _inviteController,
                                style: TextStyle(color: textColor),
                                enabled: false, // Kodda false bırakılmıştı
                                decoration: InputDecoration(
                                  hintText: 'Davet Kodunu Gir',
                                  hintStyle: TextStyle(
                                    color: Colors.grey.shade500,
                                  ),
                                  filled: true,
                                  fillColor: inputFillColor,
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: BorderSide(
                                      color: isDark
                                          ? Colors.grey.shade700
                                          : Colors.grey.shade300,
                                    ),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: BorderSide(
                                      color: isDark
                                          ? Colors.grey.shade700
                                          : Colors.grey.shade300,
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: BorderSide(color: primaryBlue),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const Gap(10),
                          // Doğrula Butonu
                          SizedBox(
                            height: 48,
                            child: ElevatedButton(
                              onPressed: null,
                              /*() async {
                              // Yorum satırındaki kod aktifleştirildi
                              await verifyInviteCode(
                                _inviteController.text.trim(),
                              );
                            },*/
                              style: ElevatedButton.styleFrom(
                                backgroundColor: primaryBlue,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                ),
                                elevation: 0,
                              ),
                              child: const Text("Doğrula"),
                            ),
                          ),
                        ],
                      ),
                      const Gap(8),
                      Text(
                        "(Toplam $_inviteCount kişi davet ettiniz)",
                        style: TextStyle(color: subTextColor, fontSize: 12),
                      ),

                      const Gap(20),
                      // VEYA Çizgisi
                      Row(
                        children: [
                          Expanded(
                            child: Divider(
                              color: Colors.grey.shade700,
                              thickness: 0.5,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            child: Text(
                              "VEYA",
                              style: TextStyle(
                                color: subTextColor,
                                fontSize: 12,
                              ),
                            ),
                          ),
                          Expanded(
                            child: Divider(
                              color: Colors.grey.shade700,
                              thickness: 0.5,
                            ),
                          ),
                        ],
                      ),
                      const Gap(20),

                      // Davet Kodu Oluştur Alanı
                      Text(
                        "Veya kendi davet kodunuzu oluşturun:",
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: textColor,
                        ),
                      ),
                      const Gap(12),
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton(
                          onPressed: null,
                          /*() async {
                          // Yorum satırındaki kod mantığı aktifleştirildi
                          if (_auth.currentUser != null &&
                              !_auth.currentUser!.emailVerified) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Lütfen önce mailinizi doğrulayınız.',
                                ),
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
                          style: ElevatedButton.styleFrom(
                            backgroundColor: isDark
                                ? const Color(0xFF1E3A8A)
                                : const Color(0xFFDBEAFE),
                            foregroundColor: primaryBlue,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text(
                            "Davet Kodu Oluştur",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const Gap(20),

                // --- 2. KART: E-POSTA DOĞRULAMA ---
                if (_auth.currentUser != null &&
                    !_auth.currentUser!.emailVerified)
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: cardColor,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: isDark
                          ? []
                          : [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.05),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            // İYİLEŞTİRME 3: Platform İkonu
                            Icon(
                              Platform.isIOS
                                  ? CupertinoIcons.mail_solid
                                  : Icons.mark_email_unread_outlined,
                              color: primaryBlue,
                              size: 24,
                            ),
                            const Gap(10),
                            Text(
                              "E-posta Doğrulama",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: textColor,
                              ),
                            ),
                          ],
                        ),
                        const Gap(12),
                        Text(
                          "Mailinizi doğrulamadınız, lütfen doğrulayınız.",
                          style: TextStyle(color: subTextColor, fontSize: 14),
                        ),
                        const Gap(16),
                        SizedBox(
                          width: double.infinity,
                          height: 48,
                          child: ElevatedButton(
                            onPressed: () async {
                              // Mantık aynen korundu
                              if (_auth.currentUser != null &&
                                  !_auth.currentUser!.emailVerified) {
                                try {
                                  await _auth.currentUser!
                                      .sendEmailVerification();
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        "Doğrulama maili gönderildi.",
                                      ),
                                    ),
                                  );
                                } catch (e) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        'Lütfen daha sonra tekrar deneyin.',
                                      ),
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
                            style: ElevatedButton.styleFrom(
                              backgroundColor: primaryBlue,
                              foregroundColor: Colors.white,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: const Text(
                              "Doğrulama Maili Gönder",
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                if (_auth.currentUser != null &&
                    !_auth.currentUser!.emailVerified)
                  const Gap(20),

                // --- 3. KART: YARDIM & DESTEK ---
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: cardColor,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: isDark
                        ? []
                        : [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.05),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          // İYİLEŞTİRME 4: Platform İkonu
                          Icon(
                            Platform.isIOS
                                ? CupertinoIcons.headphones
                                : Icons.headset_mic_rounded,
                            color: primaryBlue,
                            size: 24,
                          ),
                          const Gap(10),
                          Text(
                            "Yardım & Destek",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: textColor,
                            ),
                          ),
                        ],
                      ),
                      const Gap(12),
                      Text(
                        "Uygulamamız geliştirilmeye devam ediyor.\nYaşadığınız sorunları bize aşağıdaki mail adresi üzerinden bildirebilirsiniz:",
                        style: TextStyle(color: subTextColor, fontSize: 14),
                      ),
                      const Gap(8),
                      GestureDetector(
                        onTap: () {
                          Clipboard.setData(
                            const ClipboardData(text: "iletisim@kgstech.net"),
                          );
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("Mail adresi kopyalandı"),
                            ),
                          );
                        },
                        child: Text(
                          "iletisim@kgstech.net",
                          style: TextStyle(
                            color: primaryBlue,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            decoration: TextDecoration.underline,
                            decorationColor: primaryBlue,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const Gap(20),
                // Hata mesajı alanı (Placeholder)
                if (true)
                  Text(
                    "",
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
