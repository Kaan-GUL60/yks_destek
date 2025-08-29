import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kgsyks_destek/go_router/router.dart';

class SignIn extends ConsumerStatefulWidget {
  const SignIn({super.key});

  @override
  ConsumerState<SignIn> createState() => _SignInState();
}

class _SignInState extends ConsumerState<SignIn> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final _formKey = GlobalKey<FormState>();
  bool _isSecure = true;

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: SingleChildScrollView(
          child: Column(
            children: [
              Image.asset(
                "assets/logo/logo.png",
                width: 160,
                color: Colors.red,
              ),
              SizedBox(height: 20),
              Text(
                "Giriş Yap",
                style: TextStyle(fontSize: 42, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 20),
              Form(
                key: _formKey,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32.0),
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.next,
                        autovalidateMode: AutovalidateMode.onUnfocus,
                        autofillHints: [AutofillHints.email],
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
                        decoration: InputDecoration(
                          labelText: "Email",
                          border: OutlineInputBorder(),
                          suffixIcon: Icon(Icons.email_outlined),
                        ),
                      ),
                      SizedBox(height: 10),
                      TextFormField(
                        keyboardType: TextInputType.visiblePassword,
                        textInputAction: TextInputAction.next,
                        controller: _passwordController,
                        autovalidateMode: AutovalidateMode.onUnfocus,
                        obscureText: _isSecure,
                        validator: (value) {
                          if ((value?.length ?? 0) < 6) {
                            return 'Şifre en az 6 karakter olmalı.';
                          }
                          // E-posta formatı için RegExp
                          return null; // Her şey yolundaysa null döndür.
                        },
                        decoration: InputDecoration(
                          labelText: "Şifre",
                          suffixIcon: _iconButton(),
                          border: OutlineInputBorder(),
                        ),
                      ),
                      SizedBox(height: 30),
                      ElevatedButton(
                        onPressed: () async {
                          if (_formKey.currentState!.validate()) {
                            // Form geçerliyse giriş işlemini gerçekleştir
                            try {
                              await _auth.signInWithEmailAndPassword(
                                email: _emailController.text.trim(),
                                password: _passwordController.text.trim(),
                              );

                              // Giriş başarılı
                              final ctx = context;
                              if (!ctx.mounted) return;
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'Hoşgeldiniz',
                                  ), // user.email'e buradan erişmek biraz farklı olabilir.
                                ),
                              );
                              router.goNamed(AppRoute.anaekran.name);
                            } on FirebaseAuthException catch (e) {
                              // Sadece Firebase Authentication hatalarını yakalar
                              String errorMessage = '';
                              switch (e.code) {
                                case 'user-not-found':
                                  errorMessage = 'Kullanıcı bulunamadı.';
                                  break;
                                case 'wrong-password':
                                  errorMessage = 'Yanlış şifre.';
                                  break;
                                case 'invalid-email':
                                  errorMessage = 'Geçersiz e-posta adresi.';
                                  break;
                                case 'invalid-credential':
                                  errorMessage = 'Geçersiz kimlik bilgileri';
                                default:
                                  errorMessage =
                                      'Lütfen daha sonra tekrar deneyin.';
                              }

                              final ctx = context;
                              if (ctx.mounted) {
                                ScaffoldMessenger.of(ctx).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      'Giriş başarısız: $errorMessage',
                                    ),
                                  ),
                                );
                              }
                            } catch (e) {
                              // Diğer tüm hataları yakalar
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'Beklenmedik bir hata oluştu: $e',
                                  ),
                                ),
                              );
                              // Genel bir hata mesajı gösterebilirsiniz.
                            }
                          }
                        },
                        child: Text("Giriş Yap"),
                      ),
                      SizedBox(height: 10),
                      InkWell(
                        onTap: () {
                          //print("Text tıklandı");
                          router.goNamed(AppRoute.signUp.name);
                        },
                        child: Text(
                          "Hesabınız yok mu? Kayıt olun",
                          style: TextStyle(
                            decoration: TextDecoration.underline,
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
    );
  }

  IconButton _iconButton() {
    return IconButton(
      onPressed: togglePasswordView,
      icon: Icon(
        _isSecure ? Icons.visibility_off_outlined : Icons.visibility_outlined,
      ),
    );
  }
}
