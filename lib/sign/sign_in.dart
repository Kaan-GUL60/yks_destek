// ignore_for_file: use_build_context_synchronously

import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crypto/crypto.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:kgsyks_destek/ana_ekran/home_state.dart';
import 'package:kgsyks_destek/go_router/router.dart';
import 'package:kgsyks_destek/sign/bilgi_database_helper.dart';
import 'package:kgsyks_destek/sign/kontrol_db.dart';
import 'package:kgsyks_destek/sign/save_data.dart';
import 'package:kgsyks_destek/sign/yerel_kayit.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

class SignIn extends ConsumerStatefulWidget {
  const SignIn({super.key});

  @override
  ConsumerState<SignIn> createState() => _SignInState();
}

final FirebaseFirestore _firestore = FirebaseFirestore.instance;

class _SignInState extends ConsumerState<SignIn> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Google Sign In Nesnesi
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  final _formKey = GlobalKey<FormState>();
  bool _isSecure = true;
  bool _isLoading = false;

  void togglePasswordView() {
    setState(() {
      _isSecure = !_isSecure;
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // --- GOOGLE GİRİŞ FONKSİYONU (GÜNCELLENDİ) ---
  // --- GOOGLE GİRİŞ FONKSİYONU (GÜNCELLENMİŞ MANTIK) ---
  Future<void> _signInWithGoogle() async {
    setState(() => _isLoading = true);
    try {
      // 1. Google Penceresini Aç
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        setState(() => _isLoading = false);
        return; // Kullanıcı vazgeçti
      }

      // 2. Kimlik bilgilerini al
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // 3. Firebase'e Giriş Yap
      final UserCredential userCredential = await _auth
          .signInWithCredential(credential)
          .timeout(
            const Duration(seconds: 15),
            onTimeout: () {
              throw FirebaseAuthException(
                code: 'timeout',
                message:
                    'Firebase sunucusu yanıt vermedi. Lütfen internetinizi kontrol edin.',
              );
            },
          );
      final User? user = userCredential.user;

      if (user != null) {
        // --- YÖNLENDİRME MANTIĞI ---

        // Veritabanını kontrol et: Bu kullanıcı kayıtlı mı?
        final DocumentSnapshot userDoc = await _firestore
            .collection('users')
            .doc(user.uid)
            .get();

        if (userDoc.exists) {
          //await syncFirestoreToLocal(user);
          // SENARYO 1: Kullanıcı Kayıtlı -> Ana Ekrana Al
          // Mevcut başarılı giriş fonksiyonunu çağır (Local kayıt ve yönlendirme orada var)
          await _processLoginSuccess(userCredential);
        } else {
          // SENARYO 2: Kullanıcı Yeni (Kayıtlı Değil) -> Bilgi Al Sayfasına Yolla

          // Yerel veritabanına "giriş yapıldı" olarak işaretleyelim ki token saklansın
          final storage = BooleanSettingStorage();
          await storage.initializeDatabase();
          await storage.saveSetting(true);

          if (mounted) {
            // Kullanıcıya bilgi verip yönlendiriyoruz
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                  'Kaydınızı tamamlamak için lütfen bilgilerinizi giriniz.',
                ),
              ),
            );
            router.goNamed(AppRoute.bilgiAl.name);
          }
        }
      }
    } on FirebaseAuthException catch (e) {
      _showErrorSnackbar(e.message ?? "Google girişi başarısız oldu.");
      // Hata durumunda oturumu temizlemek iyi bir pratiktir
      await _auth.signOut();
      await _googleSignIn.signOut();
    } catch (e) {
      _showErrorSnackbar("Beklenmedik bir hata: $e");
      await _auth.signOut();
      await _googleSignIn.signOut();
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // Kod tekrarını önlemek ve temizlik için başarılı giriş işlemlerini buraya aldım
  Future<void> _processLoginSuccess(UserCredential userCredential) async {
    final storage = BooleanSettingStorage();
    await storage.initializeDatabase();
    await storage.saveSetting(true);
    await storage.closeDatabase();

    final ctx = context;
    if (!ctx.mounted) return;

    // Snackbar gösterimi
    ScaffoldMessenger.of(
      ctx,
    ).showSnackBar(const SnackBar(content: Text('Hoşgeldiniz')));

    // Firestore verisini çek
    final codeDoc = await _firestore
        .collection("users")
        .doc(userCredential.user!.uid)
        .get();

    // Veri varsa işle, yoksa varsayılan değerlerle kaydetmeye çalışır
    _userKayit(
      codeDoc.data()?['userName'] ?? userCredential.user!.displayName ?? '',
      codeDoc.data()?['sinav'] != null
          ? Option.values[codeDoc.data()!['sinav']]
          : Option.first,
      codeDoc.data()?['sinif']?.toString() ?? '12',
      codeDoc.data()?['alan'] != null
          ? Option2.values[codeDoc.data()!['alan']]
          : Option2.first,
      codeDoc.data()?['isPro'] ?? false,
    );

    router.goNamed(AppRoute.anaekran.name);
  }

  void _showErrorSnackbar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  // --- APPLE GÜVENLİK FONKSİYONU (NONCE) ---
  String _generateNonce([int length = 32]) {
    const charset =
        '0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._';
    final random = Random.secure();
    return List.generate(
      length,
      (_) => charset[random.nextInt(charset.length)],
    ).join();
  }

  String _sha256ofString(String input) {
    final bytes = utf8.encode(input);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  // --- APPLE GİRİŞ FONKSİYONU ---
  Future<void> _signInWithApple() async {
    setState(() => _isLoading = true);
    try {
      UserCredential userCredential;
      User? user;

      // --- PLATFORM KONTROLÜ ---
      if (Platform.isAndroid) {
        // 🤖 ANDROID İÇİN: Firebase'in Kendi Yöntemini Kullan (Hatasız Çalışır)
        final provider = OAuthProvider("apple.com");
        provider.addScope('email');
        provider.addScope('name');

        // Bu satır Android'de otomatik tarayıcı açar ve işlemi halleder
        userCredential = await _auth.signInWithProvider(provider);
        user = userCredential.user;
      } else {
        // 🍎 IOS İÇİN: Native Paketi Kullan (Daha Şık Görünür)
        final rawNonce = _generateNonce();
        final nonce = _sha256ofString(rawNonce);

        final appleCredential = await SignInWithApple.getAppleIDCredential(
          scopes: [
            AppleIDAuthorizationScopes.email,
            AppleIDAuthorizationScopes.fullName,
          ],
          nonce: nonce,
        );

        final OAuthCredential credential = OAuthProvider("apple.com")
            .credential(
              idToken: appleCredential.identityToken,
              accessToken: appleCredential.authorizationCode,
              rawNonce: rawNonce,
            );

        userCredential = await _auth.signInWithCredential(credential);
        user = userCredential.user;

        // iOS'te isim güncellemesi
        if (user != null && appleCredential.givenName != null) {
          await user.updateDisplayName(
            "${appleCredential.givenName} ${appleCredential.familyName ?? ''}",
          );
        }
      }

      // --- ORTAK YÖNLENDİRME KISMI ---
      if (user != null) {
        // (Burası Sign In veya Sign Up dosyasına göre değişir, kendi mantığını koru)
        // Aşağısı Giriş Yap (Sign In) sayfası için örnektir:

        final DocumentSnapshot userDoc = await _firestore
            .collection('users')
            .doc(user.uid)
            .get();

        if (userDoc.exists) {
          //await syncFirestoreToLocal(user);
          // Kayıtlıysa -> Ana Ekrana (Giriş Başarılı fonksiyonunu çağır)
          if (mounted) await _processLoginSuccess(userCredential);
        } else {
          // Kayıtlı Değilse -> Bilgi Al Sayfasına
          final storage = BooleanSettingStorage();
          await storage.initializeDatabase();
          await storage.saveSetting(true);
          await storage.closeDatabase();

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                  'Kaydınızı tamamlamak için lütfen bilgilerinizi giriniz.',
                ),
              ),
            );
            router.goNamed(AppRoute.bilgiAl.name);
          }
        }
      }
    } on FirebaseAuthException catch (e) {
      _showErrorSnackbar(e.message ?? "Apple girişi başarısız oldu.");
    } catch (e) {
      if (!e.toString().contains('Canceled')) {
        _showErrorSnackbar("Hata: $e");
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // --- TASARIM YARDIMCISI METODLAR ---
  InputDecoration _inputStyle({
    required String hintText,
    required bool isDarkMode,
    Widget? suffixIcon,
    Widget? prefixIcon,
  }) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: TextStyle(
        color: isDarkMode ? const Color(0xFF656E77) : const Color(0xFF9EA6AD),
        fontSize: 14,
      ),
      filled: true,
      fillColor: isDarkMode ? const Color(0xFF1E252F) : Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(50),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(50),
        borderSide: isDarkMode
            ? BorderSide.none
            : const BorderSide(color: Color(0xFFE0E0E0)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(50),
        borderSide: const BorderSide(color: Color(0xFF1E88E5), width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(50),
        borderSide: const BorderSide(color: Colors.red),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(50),
        borderSide: const BorderSide(color: Colors.red, width: 1.5),
      ),
      suffixIcon: suffixIcon,
      prefixIcon: prefixIcon,
    );
  }

  // --- YENİ MODERN SOSYAL MEDYA BUTONU TASARIMI ---
  Widget _buildModernSocialButton({
    required String text,
    required Widget icon,
    required VoidCallback? onTap,
    required bool isDarkMode,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 56, // Yükseklik görseldeki gibi dolgun olsun
      child: OutlinedButton(
        onPressed: _isLoading ? null : onTap,
        style: OutlinedButton.styleFrom(
          backgroundColor: isDarkMode ? const Color(0xFF1E252F) : Colors.white,
          // Tıklama efekti rengi
          foregroundColor: isDarkMode ? Colors.white : Colors.black,
          // Kenarlık Rengi (Gri)
          side: BorderSide(
            color: isDarkMode
                ? const Color(0xFF2F3642)
                : const Color(0xFFE0E0E0),
            width: 1.5,
          ),
          // Tam yuvarlak kenarlar (Hap şekli)
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(50),
          ),
          elevation: 0,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // İkon
            icon,
            const SizedBox(width: 12),
            // Yazı
            Text(
              text,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: isDarkMode ? Colors.white : const Color(0xFF1C1E21),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLabel(String text, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0, left: 12.0),
      child: Text(
        text,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: color,
          fontSize: 14,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Renk ve Tema Tanımları
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDarkMode ? Colors.white : const Color(0xFF1C1E21);
    final primaryColor = const Color(0xFF1E88E5);

    return Scaffold(
      extendBodyBehindAppBar: true,
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                Center(
                  child: Icon(Icons.school, size: 64, color: primaryColor),
                ),
                const SizedBox(height: 30),
                Center(
                  child: Text(
                    "Tekrar Hoşgeldin",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Center(
                  child: Text(
                    "Kaldığın yerden devam etmek için giriş yap.",
                    style: TextStyle(
                      fontSize: 14,
                      color: isDarkMode
                          ? const Color(0xFF9EA6AD)
                          : const Color(0xFF7C828A),
                    ),
                  ),
                ),
                const SizedBox(height: 40),
                Form(
                  key: _formKey,
                  child: AutofillGroup(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildLabel("E-posta Adresi", textColor),
                        TextFormField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          textInputAction: TextInputAction.next,
                          autovalidateMode: AutovalidateMode.onUnfocus,
                          autofillHints: const [AutofillHints.email],
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Lütfen e-posta adresinizi girin.';
                            }
                            final emailRegex = RegExp(
                              r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+",
                            );
                            if (!emailRegex.hasMatch(value)) {
                              return 'Lütfen geçerli bir e-posta adresi girin.';
                            }
                            return null;
                          },
                          decoration: _inputStyle(
                            hintText: "kullanici@eposta.com",
                            isDarkMode: isDarkMode,
                            prefixIcon: const Icon(
                              Icons.email_outlined,
                              color: Colors.grey,
                            ),
                          ),
                        ),
                        SizedBox(height: 15),
                        _buildLabel("Şifre", textColor),
                        TextFormField(
                          keyboardType: TextInputType.visiblePassword,
                          textInputAction: TextInputAction.done,
                          controller: _passwordController,
                          autovalidateMode: AutovalidateMode.onUnfocus,
                          obscureText: _isSecure,
                          autofillHints: const [AutofillHints.password],
                          validator: (value) {
                            if ((value?.length ?? 0) < 6) {
                              return 'Şifre en az 6 karakter olmalı.';
                            }
                            return null;
                          },
                          decoration: _inputStyle(
                            hintText: "Şifrenizi girin",
                            isDarkMode: isDarkMode,
                            prefixIcon: const Icon(
                              Icons.lock_outline,
                              color: Colors.grey,
                            ),
                            suffixIcon: _iconButton(),
                          ),
                        ),

                        const SizedBox(height: 30),
                        SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: FilledButton(
                            onPressed: _isLoading
                                ? null
                                : () async {
                                    if (_formKey.currentState!.validate()) {
                                      FocusScope.of(context).unfocus();
                                      setState(() => _isLoading = true);
                                      try {
                                        // MEVCUT EMAIL/ŞİFRE GİRİŞ MANTIĞI
                                        final userCredential = await _auth
                                            .signInWithEmailAndPassword(
                                              email: _emailController.text
                                                  .trim(),
                                              password: _passwordController.text
                                                  .trim(),
                                            );

                                        // Başarılı giriş sonrası işlemleri ortak fonksiyona yönlendirdim
                                        await _processLoginSuccess(
                                          userCredential,
                                        );
                                      } on FirebaseAuthException catch (e) {
                                        String errorMessage = '';
                                        switch (e.code) {
                                          case 'user-not-found':
                                            errorMessage =
                                                'Kullanıcı bulunamadı.';
                                            break;
                                          case 'wrong-password':
                                            errorMessage = 'Yanlış şifre.';
                                            break;
                                          case 'invalid-email':
                                            errorMessage =
                                                'Geçersiz e-posta adresi.';
                                            break;
                                          case 'invalid-credential':
                                            errorMessage =
                                                'Geçersiz kimlik bilgileri';
                                            break;
                                          default:
                                            errorMessage =
                                                'Lütfen daha sonra tekrar deneyin.';
                                        }

                                        final ctx = context;
                                        if (ctx.mounted) {
                                          ScaffoldMessenger.of(
                                            ctx,
                                          ).showSnackBar(
                                            SnackBar(
                                              content: Text(
                                                'Giriş başarısız: $errorMessage',
                                              ),
                                            ),
                                          );
                                        }
                                      } catch (e) {
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          SnackBar(
                                            content: Text(
                                              'Beklenmedik bir hata oluştu: $e',
                                            ),
                                          ),
                                        );
                                      } finally {
                                        setState(() => _isLoading = false);
                                      }
                                    }
                                  },
                            style: FilledButton.styleFrom(
                              backgroundColor: primaryColor,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(50),
                              ),
                            ),
                            child: const Text(
                              "Giriş Yap",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),

                        // --- MODERN SOSYAL GİRİŞ ALANI ---
                        const SizedBox(height: 30),

                        // "veya" Ayracı
                        Row(
                          children: [
                            Expanded(
                              child: Divider(
                                color: isDarkMode
                                    ? const Color(0xFF2F3642)
                                    : const Color(0xFFE0E0E0),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                              ),
                              child: Text(
                                "veya",
                                style: TextStyle(
                                  color: isDarkMode
                                      ? const Color(0xFF9EA6AD)
                                      : const Color(0xFF7C828A),
                                  fontSize: 14,
                                ),
                              ),
                            ),
                            Expanded(
                              child: Divider(
                                color: isDarkMode
                                    ? const Color(0xFF2F3642)
                                    : const Color(0xFFE0E0E0),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 24),

                        // 1. GOOGLE BUTONU (Google Logosu Renkli)
                        _buildModernSocialButton(
                          text: "Google ile devam et",
                          isDarkMode: isDarkMode,
                          onTap: _signInWithGoogle, // Senin yazdığın fonksiyon
                          icon: Image.asset(
                            "assets/logo/google_logo.png", // VARSA BURAYA RESİM YOLUNU YAZ
                            height: 24,
                            // Resim yoksa geçici olarak renkli G harfi kullanıyoruz:
                            errorBuilder: (context, error, stackTrace) =>
                                const Text(
                                  "G",
                                  style: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.w900,
                                    color: Colors.red, // Google kırmızısı
                                  ),
                                ),
                          ),
                        ),

                        const SizedBox(height: 16), // İki buton arası boşluk
                        // 2. APPLE BUTONU (Siyah Logo, Fonksiyonu Boş)
                        _buildModernSocialButton(
                          text: "Apple ile devam et",
                          isDarkMode: isDarkMode,
                          onTap: _signInWithApple,
                          icon: Icon(
                            Icons
                                .apple, // Apple ikonu (Materyal kütüphanesinde olmayabilir*)
                            // Eğer ikon çıkmazsa font_awesome_flutter paketi veya asset kullanmalısın.
                            // Şimdilik standart bir ikon koyuyorum, asset varsa Image.asset kullan.
                            size: 28,
                            color: isDarkMode ? Colors.white : Colors.black,
                          ),
                        ),

                        // --- MODERN ALAN SONU ---
                        const SizedBox(height: 30),

                        Center(
                          child: InkWell(
                            onTap: () {
                              router.goNamed(AppRoute.signUp.name);
                            },
                            child: RichText(
                              text: TextSpan(
                                style: TextStyle(
                                  color: isDarkMode
                                      ? const Color(0xFF9EA6AD)
                                      : const Color(0xFF7C828A),
                                ),
                                children: [
                                  const TextSpan(text: "Hesabınız yok mu? "),
                                  TextSpan(
                                    text: "Kayıt Olun",
                                    style: TextStyle(
                                      color: primaryColor,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  IconButton _iconButton() {
    return IconButton(
      onPressed: togglePasswordView,
      icon: Icon(
        _isSecure ? Icons.visibility_off_outlined : Icons.visibility_outlined,
        color: Colors.grey,
      ),
    );
  }

  void _userKayit(
    String userName,
    Option selectedSinav,
    String selectedSinif,
    Option2 selectedSinav2,
    bool isPro,
  ) async {
    if (_auth.currentUser == null) return;
    final yeniKullanici = KullaniciModel(
      uid: _auth.currentUser!.uid,
      userName: userName,
      email: _auth.currentUser!.email!,
      profilePhotos: _auth.currentUser!.photoURL ?? "",
      sinif: int.parse(selectedSinif),
      sinav: selectedSinav.index,
      alan: selectedSinav2.index,
      kurumKodu: _passwordController.text.isEmpty
          ? ""
          : _passwordController.text,
      isPro: isPro,
    );
    await KullaniciDatabaseHelper.instance.saveKullanici(yeniKullanici);
    // Kayıt fonksiyonu içinde router çağrısı yapıldığı için buraya eklemeye gerek yok
    // ancak yukarıda _processLoginSuccess içinde çağırdık.
    // Bu metod sadece veritabanı helper'a veri yolluyor.
  }
}

Future<String> getReferralSource() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getString('referral_source') ?? "Bilinmiyor";
}

Future<void> syncFirestoreToLocal(User user) async {
  try {
    // 1. Firestore'dan ilgili kullanıcının dökümanını al
    final DocumentSnapshot userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();

    if (userDoc.exists && userDoc.data() != null) {
      final data = userDoc.data() as Map<String, dynamic>;

      // 2. Senin kullandığın saveUserData metodunu çağır
      // Firestore'dan gelen verileri tek tek parametre olarak gönderiyoruz
      final referralSource = await getReferralSource();
      await UserAuth().saveUserData(
        userName: data['userName'] ?? user.displayName ?? "İsimsiz",
        email: data['email'] ?? user.email ?? "",
        uid: user.uid,
        profilePhotos: data['profilePhotos'] ?? user.photoURL ?? "",
        sinav:
            data['sinav'] ??
            0, // Firestore'da int olarak saklandığını varsayıyoruz
        sinif: data['sinif'] is int
            ? data['sinif']
            : int.tryParse(data['sinif'].toString()) ?? 0,
        alan: data['alan'] ?? 0,
        kurumKodu: data['kurumKodu'] ?? "",
        isPro: data['isPro'] ?? false,
        nerdenDuydunuz: referralSource, // Yeni parametre
      );

      debugPrint("Veriler başarıyla Firestore'dan yerele senkronize edildi.");
    }
  } catch (e) {
    debugPrint("Firestore senkronizasyon hatası: $e");
  }
}
