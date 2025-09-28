import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:kgsyks_destek/go_router/router.dart';
import 'package:kgsyks_destek/main.dart';

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
                "Kayıt Ol",
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
                      SizedBox(height: 10),
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

                          return null; // Her şey yolundaysa null döndür.
                        },
                        decoration: InputDecoration(
                          labelText: "Şifre Tekrar",
                          suffixIcon: _iconButton(),
                          border: OutlineInputBorder(),
                        ),
                      ),
                      SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            // Eğer form geçerliyse, butona basma işlemini gerçekleştir
                            sendMail();
                            // Kayıt olma fonksiyonunuzu çağırabilirsiniz
                          } else {
                            // Form geçerli değilse, kullanıcıya hata mesajı göster
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Lütfen formdaki hataları düzeltin.',
                                ),
                              ),
                            );
                          }
                        },
                        child: Text("Doğrulama maili gönder"),
                      ),
                      SizedBox(height: 20),
                      InkWell(
                        onTap: () {
                          //print("Text tıklandı");
                          router.goNamed(AppRoute.signIn.name);
                        },
                        child: Text(
                          "Zaten bir hesabınız var mı? Giriş yapın",
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

  Future<void> checkEmailVerification() async {
    // Kullanıcı doğrulamayı yapana kadar bu döngüyü çalıştırın

    // E-posta doğrulama linkine tıkladıktan sonra firebase Auth'u günceller
    await FirebaseAuth.instance.currentUser!.reload();
    final user = FirebaseAuth.instance.currentUser;

    if (user!.emailVerified) {
      // Doğrulama yapıldı, döngüyü durdur

      return;
    } else {
      ref.read(textProvider.notifier).state = "Henüz doğrulama yapılmadı.";
    }

    // Her 3 saniyede bir kontrol et (kullanıcının linke tıklamasını beklerken)
    await Future.delayed(const Duration(seconds: 1));
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
                      'Doğrulama maili gönderildi. Lütfen e-postanızı kontrol edin. Eğer maili bulamıyorsanız, spam klasörünüze de bakmayı unutmayın.',
                      style: TextStyle(fontSize: 18),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () async {
                        checkEmailVerification().then((_) {
                          // Doğrulama başarılı olduğunda text'i tekrar güncelleyebiliriz
                          ref.read(textProvider.notifier).state =
                              "Doğrulama Başarılı!";
                          // Alt sayfayı kapat
                        });
                      },
                      child: const Text(
                        "Maili doğruladım",
                        style: TextStyle(fontSize: 16),
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
                      child: const Text('Kapat'),
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
        message = 'Bu e-posta adresi zaten kullanılıyor.';
        //KULLANICI VAR AMA DOĞRULAMA YAPMAMIŞ OLABİLİR
        //FİRESTORE dan kulllnıcı kayıtlı mı bak ona gçre mail gönder
        if (_auth.currentUser != null && !_auth.currentUser!.emailVerified) {
          await _auth.currentUser!.sendEmailVerification();
          openSheet();
        } else {
          _auth.currentUser?.delete();
        }
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
      ),
    );
  }
}
