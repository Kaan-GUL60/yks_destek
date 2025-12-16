import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crypto/crypto.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:gap/gap.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:kgsyks_destek/go_router/router.dart';
import 'package:kgsyks_destek/main.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

import 'kontrol_db.dart';

final textProvider = StateProvider<String>((ref) => "-");

class SignUp extends ConsumerStatefulWidget {
  const SignUp({super.key});

  @override
  ConsumerState<SignUp> createState() => _SignUpState();
}

class _SignUpState extends ConsumerState<SignUp> {
  // TextFormField'lardaki metni kontrol etmek için controller'lar.
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _passwordController2 = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance; // Eklendi
  final GoogleSignIn _googleSignIn = GoogleSignIn(); // Eklendi

  bool _isSecure = true;

  void togglePasswordView() {
    setState(() {
      _isSecure = !_isSecure;
    });
  }

  @override
  void dispose() {
    // Widget ağacından kaldırıldığında controller'ları temizle.
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // --- GOOGLE ILE KAYIT/GİRİŞ FONKSİYONU ---
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
      final UserCredential userCredential = await _auth.signInWithCredential(
        credential,
      );
      final User? user = userCredential.user;

      if (user != null) {
        // --- İSTEDİĞİNİZ MANTIK BURADA ---

        // Veritabanını kontrol et: Bu kullanıcı daha önce kayıt olmuş mu?
        final DocumentSnapshot userDoc = await _firestore
            .collection('users')
            .doc(user.uid)
            .get();

        if (userDoc.exists) {
          // SENARYO 1: Hesap zaten var (Eski kullanıcı) -> Ana Ekrana gönder
          if (mounted) {
            // Opsiyonel: Kullanıcıya bilgi verilebilir
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Hesabınız zaten mevcut, giriş yapıldı.'),
              ),
            );
            router.goNamed(AppRoute.anaekran.name);
          }
        } else {
          // SENARYO 2: Hesap yok (Yeni kullanıcı) -> Bilgi Al sayfasına gönder
          // Google ile gelen kullanıcı email doğrulamış sayılır, direkt bilgi almaya geçebilir.
          // İsterseniz burada da yerel ayarı kaydedebilirsiniz.
          await settingStorage.saveSetting(true);

          if (mounted) {
            router.goNamed(AppRoute.bilgiAl.name);
          }
        }
      }
    } on FirebaseAuthException catch (e) {
      _showErrorSnackbar(e.message ?? "Google işlemi başarısız oldu.");
    } catch (e) {
      _showErrorSnackbar("Beklenmedik bir hata: $e");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showErrorSnackbar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  // Sosyal Medya Butonu Tasarımı (Sign In ile aynı)
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

  // --- APPLE KAYIT FONKSİYONU ---
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

  // --- EKSİK OLAN FONKSİYON (Bunu Class içine ekle) ---
  Future<void> _processLoginSuccess(UserCredential userCredential) async {
    // 1. Giriş yapıldı bilgisini telefona kaydet
    final storage = BooleanSettingStorage();
    await storage.initializeDatabase();
    await storage.saveSetting(true);
    await storage.closeDatabase();

    if (!mounted) return;

    // 2. Kullanıcıya bilgi ver
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Hesabınız zaten mevcut, giriş yapıldı.')),
    );

    // 3. Ana ekrana gönder
    router.goNamed(AppRoute.anaekran.name);
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
      height: 56, // Yükseklik görseldeki gibi dolgun
      child: OutlinedButton(
        onPressed: _isLoading ? null : onTap,
        style: OutlinedButton.styleFrom(
          backgroundColor: isDarkMode ? const Color(0xFF1E252F) : Colors.white,
          foregroundColor: isDarkMode ? Colors.white : Colors.black,
          side: BorderSide(
            color: isDarkMode
                ? const Color(0xFF2F3642)
                : const Color(0xFFE0E0E0),
            width: 1.5,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(50), // Hap şekli
          ),
          elevation: 0,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            icon,
            const SizedBox(width: 12),
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

  InputDecoration _inputStyle({
    required String hintText,
    required bool isDarkMode,
    Widget? suffixIcon, // Sağdaki İkon (Göz)
    Widget? prefixIcon, // Soldaki İkon (Kilit/Mail)
  }) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: TextStyle(
        color: isDarkMode ? const Color(0xFF656E77) : const Color(0xFF9EA6AD),
        fontSize: 14,
      ),
      filled: true,
      // Resimdeki koyu renk: 0xFF1E252F, Light modda beyaz
      fillColor: isDarkMode ? const Color(0xFF1E252F) : Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),

      // KENARLIKSIZ VE TAM YUVARLAK (CAPSULE) GÖRÜNÜM
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(50), // Tam yuvarlak yapar
        borderSide: BorderSide.none, // Çizgiyi kaldırır
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(50),
        // Light modda ince çizgi, Dark modda çizgi yok (resimdeki gibi)
        borderSide: isDarkMode
            ? BorderSide.none
            : const BorderSide(color: Color(0xFFE0E0E0)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(50),
        // Tıklayınca mavi olsun
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
      // İkisini de buraya atıyoruz
      suffixIcon: suffixIcon,
      prefixIcon: prefixIcon,
    );
  }

  // Sınıfın en başında tanımla
  bool _isButtonDisabled = false;
  bool _isLoading = false; // İşlem durumunu kontrol eden değişken

  @override
  Widget build(BuildContext context) {
    // Temadan renkleri çekiyoruz
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    // Yazı renkleri için yine de temadan yardım alabiliriz veya manuel verebiliriz
    final textColor = isDarkMode ? Colors.white : const Color(0xFF1C1E21);
    final primaryColor = const Color(0xFF1E88E5);

    return Scaffold(
      // AppBar'ı şeffaf yapıyoruz ki tasarım bütünlüğü bozulmasın ama geri gitme butonu kalsın
      extendBodyBehindAppBar: true, // AppBar arkaplanı etkilemesin
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
                  child: Icon(
                    Icons.school,
                    size: 64,
                    color: primaryColor, // Temadan gelen Mavi
                  ),
                ),
                const SizedBox(height: 30),
                Center(
                  child: Text(
                    "Hesabını Oluştur",
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontSize: 24, // headlineSmall boyutu yaklaşık
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Center(
                  child: Text(
                    "Başarıya giden yolda ilk adımı at.",
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
                        // --- EMAIL ALANI ---
                        _buildLabel("E-posta Adresi"),
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
                          // Decoration'ı sadeleştirdik, tema main.dart'tan gelecek
                          decoration: _inputStyle(
                            hintText: "ornek@eposta.com",
                            isDarkMode: isDarkMode,
                            prefixIcon: const Icon(
                              Icons.email_outlined,
                              color: Colors.grey,
                            ),
                          ),
                        ),
                        const SizedBox(height: 15),

                        // --- ŞİFRE ALANI ---
                        _buildLabel("Şifre"),
                        TextFormField(
                          keyboardType: TextInputType.visiblePassword,
                          textInputAction: TextInputAction.next,
                          controller: _passwordController,
                          autovalidateMode: AutovalidateMode.onUnfocus,
                          obscureText: _isSecure,
                          autofillHints: const [AutofillHints.newPassword],
                          validator: (value) {
                            if ((value?.length ?? 0) < 6) {
                              return 'Şifre en az 6 karakter olmalı.';
                            }
                            return null;
                          },
                          decoration: _inputStyle(
                            hintText: "En az 6 karakter",
                            isDarkMode: isDarkMode,
                            prefixIcon: const Icon(
                              Icons.lock_outline,
                              color: Colors.grey,
                            ),
                            suffixIcon: _iconButton(),
                          ),
                        ),
                        const SizedBox(height: 15),

                        // --- ŞİFRE TEKRAR ALANI ---
                        _buildLabel("Şifre Tekrar"),
                        TextFormField(
                          keyboardType: TextInputType.visiblePassword,
                          textInputAction: TextInputAction.done,
                          obscureText: _isSecure,
                          autovalidateMode: AutovalidateMode.onUnfocus,
                          controller: _passwordController2,
                          validator: (value) {
                            if (value != _passwordController.text) {
                              return 'Şifreler eşleşmiyor.';
                            }
                            return null;
                          },
                          decoration: _inputStyle(
                            hintText: "Şifrenizi tekrar girin",
                            isDarkMode: isDarkMode,
                            prefixIcon: const Icon(
                              Icons.lock_outline,
                              color: Colors.grey,
                            ),
                            suffixIcon: _iconButton(),
                          ),
                        ),
                        const SizedBox(height: 30),

                        // --- BUTON ---
                        SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: FilledButton(
                            // ElevatedButton yerine FilledButton (Material 3)
                            onPressed: _isLoading
                                ? null
                                : () async {
                                    //bir kere tıklanınca loading yap tekrar basılamasın hata veriyor...
                                    if (_formKey.currentState!.validate()) {
                                      setState(() {
                                        _isLoading = true;
                                      });
                                      sendMail();
                                    } else {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                            'Lütfen formdaki hataları düzeltin.',
                                          ),
                                        ),
                                      );
                                    }
                                  },
                            style: FilledButton.styleFrom(
                              backgroundColor: primaryColor, // Mavi
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(
                                  50,
                                ), // Buton da tam yuvarlak
                              ),
                            ),
                            child: const Text(
                              "Doğrulama Maili Gönder",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),

                        // --- MODERN SOSYAL KAYIT ALANI ---
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

                        // 1. GOOGLE BUTONU
                        _buildModernSocialButton(
                          text:
                              "Google ile kayıt ol", // Metni "kayıt ol" yaptık
                          isDarkMode: isDarkMode,
                          onTap: _signInWithGoogle,
                          icon: Image.asset(
                            "assets/logo/google_logo.png", // Resim yolunu kontrol et
                            height: 24,
                            errorBuilder: (context, error, stackTrace) =>
                                const Text(
                                  "G",
                                  style: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.w900,
                                    color: Colors.red,
                                  ),
                                ),
                          ),
                        ),

                        const SizedBox(height: 16), // Boşluk
                        // 2. APPLE BUTONU
                        _buildModernSocialButton(
                          text: "Apple ile kayıt ol", // Metni "kayıt ol" yaptık
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
                        const SizedBox(height: 16), // Boşluk
                        // --- GİRİŞ YAP LİNKİ ---
                        Center(
                          child: InkWell(
                            onTap: () {
                              router.goNamed(AppRoute.signIn.name);
                            },
                            // RichText kullanarak tasarımı birebir uyguluyoruz
                            child: RichText(
                              text: TextSpan(
                                style: TextStyle(color: colorScheme.secondary),
                                children: [
                                  const TextSpan(
                                    text: "Zaten bir hesabınız var mı? ",
                                  ),
                                  TextSpan(
                                    text: "Giriş Yap",
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

  // Tasarımdaki input üstü etiketler için yardımcı metod
  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0, left: 12.0),
      child: Text(
        text,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
          fontWeight: FontWeight.bold,
          color: Theme.of(context).colorScheme.onSurface,
        ),
      ),
    );
  }

  Future<void> checkEmailVerification() async {
    // Bu döngü, doğrulama olana kadar veya sayfadan çıkılana kadar sonsuza dek döner
    while (true) {
      // 1. Önce widget hala ekranda mı diye kontrol et (Hata almamak için çok önemli)
      if (!mounted) break;

      User? user = FirebaseAuth.instance.currentUser;

      // Eğer kullanıcı oturumu bir şekilde düştüyse döngüyü kır
      if (user == null) break;

      // 2. Firebase'deki bilgiyi güncelle
      await user.reload();

      // user.reload() sonrası instance'ı tekrar yenilemek sağlıklıdır
      user = FirebaseAuth.instance.currentUser;

      // 3. Kontrol et
      if (user!.emailVerified) {
        // Doğrulandı! Döngüyü kır (fonksiyondan çık)
        ref.read(textProvider.notifier).state = "Doğrulama Başarılı!";
        break;
      } else {
        ref.read(textProvider.notifier).state = "Henüz doğrulama yapılmadı.";
      }

      // 4. Bekle (Yorumda 3 saniye demiştin, burayı 3 yapıyorum)
      await Future.delayed(const Duration(seconds: 5));
    }
  }

  void openSheet() {
    showModalBottomSheet(
      isDismissible: false, // Boşluğa tıklayarak kapatmayı engeller.
      enableDrag: false,
      context: context,
      builder: (context) {
        return PopScope(
          canPop: false,
          onPopInvokedWithResult: (didPop, result) {
            if (didPop) {
              return;
            }
          },
          // 2. Consumer ile sarın
          child: Consumer(
            builder: (context, ref, child) {
              // 3. Provider'ı dinleyin
              final verificationStatus = ref.watch(textProvider);
              ref.listen<String>(textProvider, (prev, next) {
                if (next == "Doğrulama Başarılı!") {
                  Navigator.pop(context);
                  router.goNamed(AppRoute.bilgiAl.name);
                }
              });

              return Container(
                padding: const EdgeInsets.all(16.0),
                height: 500,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    const Divider(
                      thickness: 4,
                      indent: 150,
                      endIndent: 150,
                      color: Colors.grey,
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Doğrulama maili gönderildi. Lütfen e-postanızı kontrol edin.',
                      style: TextStyle(fontSize: 18),
                      textAlign: TextAlign.center,
                    ),
                    Gap(5),
                    const Text(
                      'Eğer maili bulamıyorsanız, spam klasörünüze de bakmayı unutmayın.',
                      style: TextStyle(fontSize: 12),
                      textAlign: TextAlign.center,
                    ),
                    //metin devamını küçükçe yaz alt satıra
                    const SizedBox(height: 20),
                    ElevatedButton(
                      // EĞER buton devre dışı bırakıldıysa (_isButtonDisabled == true), onPressed'e NULL ver.
                      // NULL verdiğin anda buton otomatik olarak grileşir ve tıklanamaz olur.
                      onPressed: _isButtonDisabled
                          ? null
                          : () async {
                              // 1. Önce butonu pasif hale getir ve ekranı güncelle
                              setState(() {
                                _isButtonDisabled = true;
                              });

                              // 2. Fonksiyonu çalıştır
                              checkEmailVerification().then((_) {
                                // İşlem bittiğinde yapılacaklar
                                if (mounted) {
                                  // Ekran hala açıksa
                                  ref.read(textProvider.notifier).state =
                                      "Doğrulama Başarılı!";
                                  // Alt sayfayı kapatma kodun buraya gelecek
                                  // Navigator.pop(context); gibi
                                }
                              });
                            },
                      // İstersen butona basılınca yazısını da değiştirebilirsin
                      child: Text(
                        _isButtonDisabled
                            ? "Kontrol Ediliyor..."
                            : "Maili doğruladım",
                        style: TextStyle(
                          fontSize: 16,
                          color: Theme.of(context).colorScheme.onPrimary,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    // 5. Provider'dan gelen değeri kullanın
                    Text(verificationStatus),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () async {
                        try {
                          final user = FirebaseAuth.instance.currentUser;

                          if (user != null && !user.emailVerified) {
                            // Kullanıcı doğrulamamışsa sil
                            await user.delete();
                          }
                        } catch (e) {
                          //print("Hata: $e");
                        }
                        final ctx = context;
                        if (!ctx.mounted) {
                          return;
                        }
                        Navigator.pop(context);
                      },
                      child: Text(
                        'Kapat',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onPrimary,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }

  void sendMail() async {
    try {
      await _auth.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
      // Özelliği etkinleştir
      await settingStorage.saveSetting(true);
      // Kayıt başarılı, doğrulama maili gönder
      if (_auth.currentUser != null && !_auth.currentUser!.emailVerified) {
        await _auth.currentUser!.sendEmailVerification();
        openSheet();
      }
    } on FirebaseAuthException catch (e) {
      String message;
      if (e.code == 'email-already-in-use') {
        message =
            'Bu e-posta adresi zaten kullanılıyor. Kayıt yerine giriş yapınız.';
        //KULLANICI VAR AMA DOĞRULAMA YAPMAMIŞ OLABİLİR
        //FİRESTORE dan kulllnıcı kayıtlı mı bak ona gçre mail gönder
      } else if (e.code == 'invalid-email') {
        message = 'Geçersiz e-posta adresi.';
      } else if (e.code == 'weak-password') {
        message = 'Şifre çok zayıf.';
      } else if (e.code == 'too-many-requests') {
        message =
            'Çok fazla deneme yapıldı, lütfen daha sonra tekrar deneyiniz.';
      } else {
        message = 'Bir hata oluştu. Lütfen tekrar deneyin.';
      }
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
    } catch (e) {
      // Diğer hatalar
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Bir hata oluştu: ${e.toString()}')),
      );
    }
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
}
