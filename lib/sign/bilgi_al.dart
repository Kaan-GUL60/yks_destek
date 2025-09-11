// ignore_for_file: unused_local_variable, avoid_print

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:flutter_svg/svg.dart';
import 'package:kgsyks_destek/ana_ekran/home_state.dart';
import 'package:kgsyks_destek/go_router/router.dart';
import 'package:kgsyks_destek/sign/bilgi_database_helper.dart';
import 'package:kgsyks_destek/sign/save_data.dart';
import 'package:kgsyks_destek/sign/yerel_kayit.dart';

final textProvider = StateProvider.autoDispose<String>((ref) => "-");

class BilgiAl extends ConsumerStatefulWidget {
  const BilgiAl({super.key});

  @override
  ConsumerState<BilgiAl> createState() => _BilgiAlState();
}

class _BilgiAlState extends ConsumerState<BilgiAl> {
  // TextFormField'lardaki metni kontrol etmek için controller'lar.

  final _passwordController = TextEditingController();
  final _userNameController = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  final FirebaseAuth _auth = FirebaseAuth.instance;

  static const List<String> dersler = <String>[
    'Mezun',
    '12',
    '11',
    '10',
    '9',
    '8',
    '7',
    '6',
    '5',
  ];

  @override
  Widget build(BuildContext context) {
    final selectedSinav = ref.watch(sinavProvider);
    final selectedSinav2 = ref.watch(sinavProvider2);

    final selectedSinif = ref.watch(sinifProvider);

    return Scaffold(
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),

        child: ListView(
          children: [
            SizedBox(height: 50),
            SizedBox(
              width: double.infinity,
              child: Padding(
                padding: const EdgeInsets.only(left: 15.0, right: 15),
                child: Text(
                  "Kayıt Ol",
                  textAlign: TextAlign.left,

                  style: TextStyle(fontSize: 42, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            SizedBox(height: 20),
            Form(
              key: _formKey,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15.0),
                child: Column(
                  children: [
                    SizedBox(height: 10),
                    TextFormField(
                      controller: _userNameController,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Lütfen ad soyad giriniz.';
                        }
                        // E-posta formatı için RegExp
                        return null; // Her şey yolundaysa null döndür.
                      },
                      decoration: InputDecoration(
                        labelText: "Ad Soyad",

                        border: OutlineInputBorder(),
                      ),
                    ),
                    SizedBox(height: 10),

                    _sinavSecim(
                      selectedSinav,
                      "Sınav Seçimi",
                      label1: "YKS",
                      label2: "LGS",
                      icon1: Icon(Icons.school_outlined),
                      icon2: Icon(Icons.assessment_outlined),
                    ),
                    SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Alan", style: TextStyle(fontSize: 18)),
                            Text("Seçimi", style: TextStyle(fontSize: 18)),
                          ],
                        ),
                        SizedBox(width: 10),
                        _alanSecim(),
                      ],
                    ),
                    SizedBox(height: 20),

                    _sinifSecim(),
                    SizedBox(height: 20),
                    _kullaniciKodu(),
                    SizedBox(height: 20),

                    _kayitTamamButton(context),
                    SizedBox(height: 50),
                    SizedBox(
                      width: double.infinity,
                      height: MediaQuery.of(context).size.height * 0.3,
                      child: SvgPicture.asset(
                        "assets/Illustrations/education.svg",
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Expanded _alanSecim() {
    return Expanded(
      child: SegmentedButton<Option2>(
        segments: const <ButtonSegment<Option2>>[
          ButtonSegment(
            value: Option2.first,
            label: Text('SAY'),
            //icon: Icon(Icons.school_outlined),
          ),
          ButtonSegment(
            value: Option2.second,
            label: Text('EA'),
            //icon: Icon(Icons.assessment_outlined),
          ),
          ButtonSegment(
            value: Option2.third,
            label: Text('SÖZ'),
            //icon: Icon(Icons.assessment_outlined),
          ),
        ],
        selected: {ref.watch(sinavProvider2)},
        onSelectionChanged: (newSelection) {
          ref.read(sinavProvider2.notifier).state = newSelection.first;
        },
        multiSelectionEnabled: false,
        style: ButtonStyle(
          shape: WidgetStatePropertyAll(
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
          ),
        ),
      ),
    );
  }

  TextFormField _kullaniciKodu() {
    return TextFormField(
      keyboardType: TextInputType.text,
      textInputAction: TextInputAction.next,
      controller: _passwordController,
      autovalidateMode: AutovalidateMode.onUnfocus,
      validator: (value) {
        final trimmedValue = value?.trim();

        if (trimmedValue == null || trimmedValue.isEmpty) {
          return null; // Boş bırakılabilir, bu yüzden hata yok.
        }

        // Eğer boş değilse, uzunluğunun 8 karakter olup olmadığını kontrol eder.
        if (trimmedValue.length != 8) {
          return 'Kullanıcı kodu 8 karakter olmalıdır';
        }

        // Her iki koşul da sağlanıyorsa, yani değer ya boş ya da 8 karakterse hata yok.
        return null;
      },
      decoration: InputDecoration(
        labelText: "Kullanıcı kodu(yoksa boş bırakın)",
        hintText: "XXXXXXXX",

        border: OutlineInputBorder(),
      ),
    );
  }

  Row _sinavSecim(
    Option selected,
    String baslik, {
    required String label1,
    required String label2,
    required Icon icon1,
    required Icon icon2,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Sınav Seçimi", style: TextStyle(fontSize: 20)),
            Text(
              "Daha sonra değiştirilemez",
              style: TextStyle(fontSize: 12, color: Colors.red),
            ),
          ],
        ),
        SizedBox(width: 10),
        SegmentedButton<Option>(
          segments: const <ButtonSegment<Option>>[
            ButtonSegment(
              value: Option.first,
              label: Text('YKS'),
              icon: Icon(Icons.school_outlined),
            ),
            ButtonSegment(
              value: Option.second,
              label: Text('LGS'),
              icon: Icon(Icons.assessment_outlined),
            ),
          ],
          selected: {selected},
          onSelectionChanged: (newSelection) {
            ref.read(sinavProvider.notifier).state = newSelection.first;
          },
          style: ButtonStyle(
            shape: WidgetStatePropertyAll(
              RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4), // 🔹 köşe radius
              ),
            ),
          ),
        ),
      ],
    );
  }

  DropdownMenu<String> _sinifSecim() {
    return DropdownMenu<String>(
      initialSelection: dersler.first,
      label: const Text('Sınıf Seçimi'),
      width: double.infinity,
      // Genişliği TextField ile aynı yapar
      dropdownMenuEntries: dersler
          .map<DropdownMenuEntry<String>>(
            (String value) => DropdownMenuEntry<String>(
              value: value == 'Mezun' ? '13' : value,
              label: value,
            ),
          )
          .toList(),
      onSelected: (String? value) {
        // Seçilen dersi burada kullanabilirsiniz
        ref.read(sinifProvider.notifier).state = value!;
      },
    );
  }

  ElevatedButton _kayitTamamButton(BuildContext context) {
    return ElevatedButton(
      onPressed: () async {
        if (_formKey.currentState!.validate()) {
          // Eğer form geçerliyse, butona basma işlemini gerçekleştir
          //Firestore a kayıt işlem
          final selectedSinav = ref.read(sinavProvider);
          final selectedSinav2 = ref.read(sinavProvider2);
          final selectedSinif = ref.read(sinifProvider);
          final UserAuth auth = UserAuth();
          int asd;

          if (_passwordController.text.isEmpty) {
            _userKayit(
              _userNameController.text,
              selectedSinav,
              selectedSinif,
              selectedSinav2,
              context,
              false,
            );
            return;
          }
          asd = await auth.checkLicenseKey(
            _passwordController.text.isEmpty ? "" : _passwordController.text,
          );
          final ctx = context;
          if (!ctx.mounted) return;
          switch (asd) {
            case 4:
              _userKayit(
                _userNameController.text,
                selectedSinav,
                selectedSinif,
                selectedSinav2,
                context,
                true,
              );

              break;
            case 3:
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                    'Üzgünüz, maalesef girdiğiniz kodun kullanım hakkı dolmuş.',
                  ),
                  backgroundColor: Colors.red,
                ),
              );
              break;
            case 2:
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Üzgünüz, maalesef girdiğiniz kod geçersiz'),
                  backgroundColor: Colors.red,
                ),
              );
              break;
            default:
            //bilinmeyen bir hata oldu
          }

          //, sinif: sinif, sinav: sinav, alan: alan, kurumKodu: kurumKodu)
          // Kayıt olma fonksiyonunuzu çağırabilirsiniz
        } else {
          // Form geçerli değilse, kullanıcıya hata mesajı göster
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Lütfen formdaki hataları düzeltin.')),
          );
        }
      },
      child: Text("Kayıtı Tamamla"),
    );
  }

  void _userKayit(
    String userName,
    Option selectedSinav,
    String selectedSinif,
    Option2 selectedSinav2,
    BuildContext context,
    bool isPro,
  ) async {
    try {
      UserAuth().saveUserData(
        userName: userName,
        email: _auth.currentUser!.email!,
        uid: _auth.currentUser!.uid,
        profilePhotos: _auth.currentUser!.photoURL ?? "",
        sinav: selectedSinav.index,
        sinif: int.parse(selectedSinif),
        alan: selectedSinav2.index,
        kurumKodu: _passwordController.text.isEmpty
            ? ""
            : _passwordController.text,
        isPro: isPro,
      );
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
      final ctx = context;
      if (!ctx.mounted) return;
      router.goNamed(AppRoute.anaekran.name);
    } on FirebaseAuthException catch (e) {
      String mesaj;
      if (e.code == "user-not-found") {
        mesaj = "Kullanıcı bulunamadı.";
      } else if (e.code == "invalid-email") {
        mesaj = "Geçersiz email.";
      } else if (e.toString().contains("FirebaseAuth'ta mevcut değil")) {
        mesaj = "Lütfen tekrar kayıt olunuz.";
      } else {
        mesaj = "Hata: ${e.message}";
      }
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Hata: ${e.toString()}")));
    }
  }
}
