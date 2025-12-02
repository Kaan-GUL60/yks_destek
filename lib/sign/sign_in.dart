// ignore_for_file: use_build_context_synchronously

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kgsyks_destek/ana_ekran/home_state.dart';
import 'package:kgsyks_destek/go_router/router.dart';
import 'package:kgsyks_destek/sign/bilgi_database_helper.dart';
import 'package:kgsyks_destek/sign/kontrol_db.dart';
import 'package:kgsyks_destek/sign/yerel_kayit.dart';

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
  final _formKey = GlobalKey<FormState>();
  bool _isSecure = true;
  bool _isLoading = false;

  VoidCallback? get onPressed => null;
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

  // --- TASARIM YARDIMCISI METODLAR ---
  // Diğer sayfadaki stilin aynısını buraya ekledik
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
      // İkisini de buraya atıyoruz
      suffixIcon: suffixIcon,
      prefixIcon: prefixIcon,
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
            padding: const EdgeInsets.all(24.0), // Kenar boşlukları
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start, // Sola hizalı yapı
              children: [
                const SizedBox(height: 20),
                Center(
                  child: Icon(Icons.school, size: 64, color: primaryColor),
                ),
                const SizedBox(height: 30),
                Center(
                  child: Text(
                    "Tekrar Hoşgeldin", // Veya "Giriş Yap"
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
                            // E-posta formatı için RegExp
                            final emailRegex = RegExp(
                              r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+",
                            );
                            if (!emailRegex.hasMatch(value)) {
                              return 'Lütfen geçerli bir e-posta adresi girin.';
                            }
                            return null; // Her şey yolundaysa null döndür.
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
                            // E-posta formatı için RegExp
                            return null; // Her şey yolundaysa null döndür.
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
                                      // --- LOGIC KORUNDU ---
                                      FocusScope.of(context).unfocus();
                                      setState(() => _isLoading = true);
                                      try {
                                        final userCredential = await _auth
                                            .signInWithEmailAndPassword(
                                              email: _emailController.text
                                                  .trim(),
                                              password: _passwordController.text
                                                  .trim(),
                                            );
                                        final storage = BooleanSettingStorage();
                                        await storage.initializeDatabase();
                                        // --- VERİ KAYDETME (Örneğin: true olarak kaydet) ---
                                        await storage.saveSetting(true);

                                        // --- VERİ OKUMA ---

                                        // İsteğe bağlı: İşiniz bitince veritabanını kapatabilirsiniz (genelde açık kalması sorun olmaz)
                                        await storage.closeDatabase();
                                        final ctx = context;
                                        if (!ctx.mounted) return;
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          const SnackBar(
                                            content: Text('Hoşgeldiniz'),
                                          ),
                                        );

                                        final codeDoc = await _firestore
                                            .collection("users")
                                            .doc(userCredential.user!.uid)
                                            .get();

                                        _userKayit(
                                          codeDoc.data()?['userName'] ?? '',
                                          codeDoc.data()?['sinav'] != null
                                              ? Option.values[codeDoc
                                                    .data()!['sinav']]
                                              : Option.first,
                                          codeDoc
                                                  .data()?['sinif']
                                                  ?.toString() ??
                                              '12',
                                          codeDoc.data()?['alan'] != null
                                              ? Option2.values[codeDoc
                                                    .data()!['alan']]
                                              : Option2.first,
                                          codeDoc.data()?['isPro'] ?? false,
                                        );

                                        router.goNamed(AppRoute.anaekran.name);
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
                                            break; // break eklendi
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
                                      // --- LOGIC SONU ---
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

                        const SizedBox(height: 24),
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
        color: Colors.grey, // İkon rengi
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
      uid: _auth.currentUser!.uid, // Genellikle Firebase Auth'dan alınır
      userName: userName,
      email: _auth.currentUser!.email!,
      profilePhotos:
          _auth.currentUser!.photoURL ??
          "", // Kaydedilen profil fotoğrafının yolu
      sinif: int.parse(
        selectedSinif,
      ), // Örneğin bir dropdown'dan gelen int değer (örn: 12)
      sinav: selectedSinav
          .index, // Örneğin bir dropdown'dan gelen int değer (örn: 1)
      alan: selectedSinav2
          .index, // Örneğin bir dropdown'dan gelen int değer (örn: 2)
      kurumKodu: _passwordController.text.isEmpty
          ? ""
          : _passwordController.text,
      isPro: isPro, // Örneğin bir checkbox'tan gelen bool değer (true/false)
    );
    await KullaniciDatabaseHelper.instance.saveKullanici(yeniKullanici);
    router.goNamed(AppRoute.anaekran.name);
  }
}
