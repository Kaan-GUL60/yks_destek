// ignore_for_file: unused_local_variable, avoid_print

import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gap/gap.dart';
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
  bool _isLoading = false;
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

  InputDecoration _inputStyle({
    required String hintText,
    required bool isDarkMode,
    Widget? suffixIcon,
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
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: isDarkMode
            ? BorderSide.none
            : const BorderSide(color: Color(0xFFE0E0E0)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color(0xFF1E88E5), width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Colors.red),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Colors.red, width: 1.5),
      ),
      suffixIcon: suffixIcon,
    );
  }

  Widget _buildLabel(String text, Color color, {String? subText}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 5.0, left: 12.0, top: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            text,
            textAlign: TextAlign.left,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: color,
              fontSize: 14,
            ),
          ),
          if (subText != null) ...[
            Text(
              subText,
              style: const TextStyle(
                color: Colors.red,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ],
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    // Google ile gelen ismi otomatik doldur
    final user = FirebaseAuth.instance.currentUser;
    if (user?.displayName != null && user!.displayName!.isNotEmpty) {
      _userNameController.text = user.displayName!;
    }
  }

  @override
  Widget build(BuildContext context) {
    final selectedSinav = ref.watch(sinavProvider);
    final selectedSinav2 = ref.watch(sinavProvider2);
    final selectedSinif = ref.watch(sinifProvider);
    // Tema Renkleri
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDarkMode ? Colors.white : const Color(0xFF1C1E21);
    final primaryColor = const Color(0xFF1E88E5);

    return Scaffold(
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),

        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            children: [
              SizedBox(height: 20),
              Text(
                "Kayıt Ol",
                textAlign: TextAlign.left,
                style: TextStyle(
                  fontSize: 32, // Resimdeki kadar büyük
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
              const SizedBox(height: 30),

              Form(
                key: _formKey,
                child: AutofillGroup(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildLabel("Ad Soyad", textColor),
                      TextFormField(
                        controller: _userNameController,
                        autofillHints: const [AutofillHints.name],
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Lütfen ad soyad giriniz.';
                          }
                          // E-posta formatı için RegExp
                          return null; // Her şey yolundaysa null döndür.
                        },
                        decoration: _inputStyle(
                          hintText: "Kullanıcı Adı",
                          isDarkMode: isDarkMode,
                        ),
                      ),
                      // --- SINAV SEÇİMİ ---
                      _buildLabel(
                        "Sınav Seçimi",
                        textColor,
                        subText: "Daha sonra değiştirilemez",
                      ),
                      _sinavSecim(
                        selectedSinav,
                        "Sınav Seçimi",
                        label1: "YKS",
                        label2: "LGS",
                        icon1: Icon(Icons.school_outlined),
                        icon2: Icon(Icons.assessment_outlined),
                      ),
                      _buildLabel("Alan Seçimi", textColor),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [_alanSecim()],
                      ),

                      _buildLabel("Sınıf Seçimi", textColor),
                      Platform.isIOS
                          ? _buildIOSClassPicker(
                              isDarkMode,
                              textColor,
                              selectedSinif,
                            )
                          : _sinifSecim(),

                      _buildLabel(
                        "Kullanıcı kodu(yoksa boş bırakın)",
                        textColor,
                      ),
                      TextFormField(
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
                        decoration: _inputStyle(
                          hintText: "XXXXXXXX",
                          isDarkMode: isDarkMode,
                        ),
                      ),
                      SizedBox(height: 30),

                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: FilledButton(
                          onPressed: _isLoading
                              ? null
                              : () async {
                                  if (_formKey.currentState!.validate()) {
                                    // Eğer form geçerliyse, butona basma işlemini gerçekleştir
                                    //Firestore a kayıt işlem
                                    setState(() => _isLoading = true);
                                    FocusScope.of(context).unfocus();
                                    final selectedSinav = ref.read(
                                      sinavProvider,
                                    );
                                    final selectedSinav2 = ref.read(
                                      sinavProvider2,
                                    );
                                    final selectedSinif = ref.read(
                                      sinifProvider,
                                    );
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
                                      _passwordController.text.isEmpty
                                          ? ""
                                          : _passwordController.text,
                                    );
                                    final ctx = context;
                                    if (!ctx.mounted) return;
                                    switch (asd) {
                                      case 4:
                                        //mail doğrulanmış mı kontrol et sonra kayıt yap
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
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          const SnackBar(
                                            content: Text(
                                              'Üzgünüz, maalesef girdiğiniz kodun kullanım hakkı dolmuş.',
                                            ),
                                            backgroundColor: Colors.red,
                                          ),
                                        );
                                        break;
                                      case 2:
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          const SnackBar(
                                            content: Text(
                                              'Üzgünüz, maalesef girdiğiniz kod geçersiz',
                                            ),
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
                                      const SnackBar(
                                        content: Text(
                                          'Lütfen formdaki hataları düzeltin.',
                                        ),
                                      ),
                                    );
                                  }
                                },
                          style: FilledButton.styleFrom(
                            backgroundColor: const Color(
                              0xFFBBDEFB,
                            ), // Çok açık mavi
                            foregroundColor:
                                primaryColor, // Yazı rengi koyu mavi
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(50),
                            ),
                          ),
                          child: _isLoading
                              ? SizedBox(
                                  height: 24,
                                  width: 24,
                                  child: Platform.isIOS
                                      ? const CupertinoActivityIndicator()
                                      : const CircularProgressIndicator(
                                          strokeWidth: 2,
                                        ),
                                )
                              : const Text(
                                  "Kaydı Tamamla",
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                        ),
                      ),
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
      ),
    );
  }

  // --- iOS İÇİN ÖZEL SINIF SEÇİCİ WIDGET'I ---
  Widget _buildIOSClassPicker(
    bool isDark,
    Color textColor,
    String currentValue,
  ) {
    return GestureDetector(
      onTap: () {
        showCupertinoModalPopup(
          context: context,
          builder: (_) => Container(
            height: 250,
            color: isDark ? const Color(0xFF1F2937) : Colors.white,
            child: Column(
              children: [
                SizedBox(
                  height: 180,
                  child: CupertinoPicker(
                    itemExtent: 32,
                    onSelectedItemChanged: (index) {
                      // Mezun -> 13 dönüşümü gerekirse burada yapılır
                      // Ama listeniz string olduğu için direkt atıyoruz
                      ref.read(sinifProvider.notifier).state = dersler[index];
                    },
                    children: dersler.map((e) => Text(e)).toList(),
                  ),
                ),
                CupertinoButton(
                  child: const Text("Tamam"),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E252F) : Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: isDark ? null : Border.all(color: const Color(0xFFE0E0E0)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              currentValue,
              style: TextStyle(color: textColor, fontSize: 16),
            ),
            Icon(
              CupertinoIcons.chevron_down,
              color: isDark ? Colors.grey : Colors.black54,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }

  Expanded _alanSecim() {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final colorScheme = Theme.of(context).colorScheme;
    if (Platform.isIOS) {
      return Expanded(
        child: CupertinoSlidingSegmentedControl<Option2>(
          groupValue: ref.watch(sinavProvider2),
          thumbColor: colorScheme.primary,
          backgroundColor: isDarkMode ? Colors.grey[800]! : Colors.grey[200]!,
          children: {
            Option2.first: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Text(
                "SAY",
                style: TextStyle(
                  color: ref.watch(sinavProvider2) == Option2.first
                      ? Colors.white
                      : colorScheme.onSurface,
                ),
              ),
            ),
            Option2.second: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Text(
                "EA",
                style: TextStyle(
                  color: ref.watch(sinavProvider2) == Option2.second
                      ? Colors.white
                      : colorScheme.onSurface,
                ),
              ),
            ),
            Option2.third: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Text(
                "SÖZ",
                style: TextStyle(
                  color: ref.watch(sinavProvider2) == Option2.third
                      ? Colors.white
                      : colorScheme.onSurface,
                ),
              ),
            ),
          },
          onValueChanged: (Option2? newValue) {
            if (newValue != null) {
              ref.read(sinavProvider2.notifier).state = newValue;
            }
          },
        ),
      );
    }
    // Resimdeki gibi seçili butonun arka planını hafifletmek için (opsiyonel)
    final selectedBackgroundColor = isDarkMode
        ? colorScheme.primary.withValues(
            alpha: 0.2,
          ) // Koyu modda daha şeffaf mavi
        : const Color(0xFFBBDEFB); // Açık modda çok açık mavi
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
          // Seçili durumun arka plan rengi (Açık mavi veya şeffaf mavi)
          backgroundColor: WidgetStateProperty.resolveWith<Color>((states) {
            if (states.contains(WidgetState.selected)) {
              return selectedBackgroundColor;
            }
            // Seçili olmayan butonların arkaplanı (Koyu modda Surface, Açık modda Surface)
            return colorScheme.surface;
          }),
          // Yazı/İkon rengi
          foregroundColor: WidgetStateProperty.resolveWith<Color>((states) {
            if (states.contains(WidgetState.selected)) {
              return Color(0xFF1E88E5); // Seçili ise Mavi
            }
            return colorScheme.onSurface; // Seçili değilse ana metin rengi
          }),
          // Dış çizgi rengi
          side: WidgetStateProperty.resolveWith<BorderSide>((states) {
            if (states.contains(WidgetState.selected)) {
              return BorderSide(
                color: Color(0xFF1E88E5),
                width: 1.5,
              ); // Seçili ise Mavi çizgi
            }
            // Seçili değilse, koyu modda ince gri, açık modda daha belirgin gri
            return BorderSide(
              color: isDarkMode
                  ? colorScheme.onSurface.withValues(alpha: 0.3)
                  : Colors.grey.shade300,
              width: 1,
            );
          }),
          shape: WidgetStatePropertyAll(
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        ),
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
    // Tema renklerine erişim
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final colorScheme = Theme.of(context).colorScheme;

    // İYİLEŞTİRME 4: Platforma Duyarlı Sınav Seçimi
    if (Platform.isIOS) {
      return Row(
        children: [
          Expanded(
            child: CupertinoSlidingSegmentedControl<Option>(
              groupValue: selected,
              thumbColor: colorScheme.primary,
              backgroundColor: isDarkMode
                  ? Colors.grey[800]!
                  : Colors.grey[200]!,
              children: {
                Option.first: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 8,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.school_outlined,
                        size: 18,
                        color: selected == Option.first
                            ? Colors.white
                            : Colors.grey,
                      ),
                      const Gap(5),
                      Text(
                        label1,
                        style: TextStyle(
                          color: selected == Option.first
                              ? Colors.white
                              : colorScheme.onSurface,
                        ),
                      ),
                    ],
                  ),
                ),
                Option.second: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 8,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.assessment_outlined,
                        size: 18,
                        color: selected == Option.second
                            ? Colors.white
                            : Colors.grey,
                      ),
                      const Gap(5),
                      Text(
                        label2,
                        style: TextStyle(
                          color: selected == Option.second
                              ? Colors.white
                              : colorScheme.onSurface,
                        ),
                      ),
                    ],
                  ),
                ),
              },
              onValueChanged: (Option? newValue) {
                if (newValue != null) {
                  ref.read(sinavProvider.notifier).state = newValue;
                }
              },
            ),
          ),
        ],
      );
    }

    // Seçili butonun arkaplanı için açık mavi tonu (Light mod) veya şeffaf mavi (Dark mod)
    final selectedBackgroundColor = isDarkMode
        ? colorScheme.primary.withValues(alpha: 0.2)
        : const Color(0xFFBBDEFB);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: SegmentedButton<Option>(
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
              // Arka plan rengi (Seçili ise Mavi tonu, değilse Surface)
              backgroundColor: WidgetStateProperty.resolveWith<Color>((states) {
                if (states.contains(WidgetState.selected)) {
                  return selectedBackgroundColor;
                }
                return colorScheme.surface;
              }),
              // Yazı/İkon rengi (Seçili ise Mavi, değilse onSurface)
              foregroundColor: WidgetStateProperty.resolveWith<Color>((states) {
                if (states.contains(WidgetState.selected)) {
                  return Color(0xFF1E88E5);
                }
                return colorScheme.onSurface;
              }),
              // Dış çizgi/Kenarlık rengi
              side: WidgetStateProperty.resolveWith<BorderSide>((states) {
                if (states.contains(WidgetState.selected)) {
                  return BorderSide(color: Color(0xFF1E88E5), width: 1.5);
                }
                return BorderSide(
                  color: isDarkMode
                      ? colorScheme.onSurface.withValues(alpha: 0.3)
                      : Colors.grey.shade300,
                  width: 1,
                );
              }),
              shape: WidgetStatePropertyAll(
                RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10), // Radius korundu
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  DropdownMenu<String> _sinifSecim() {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final Color fillColor = isDarkMode ? const Color(0xFF1E252F) : Colors.white;
    final Color textColor = isDarkMode ? Colors.white : const Color(0xFF1C1E21);
    final Color borderColor = isDarkMode
        ? Colors.transparent
        : const Color(0xFFE0E0E0);
    return DropdownMenu<String>(
      initialSelection: dersler.first,
      label: Text(
        'Sınıf Seçimi',
        style: TextStyle(color: isDarkMode ? Colors.grey : Colors.black54),
      ),
      width: double.infinity,
      // Genişliği TextField ile aynı yapar
      // --- TASARIM AYARLARI (YENİ EKLENEN KISIM) ---
      textStyle: TextStyle(color: textColor), // Seçilen yazının rengi
      // Açılan menünün arka plan rengi
      menuStyle: MenuStyle(
        backgroundColor: WidgetStatePropertyAll(fillColor),
        surfaceTintColor: const WidgetStatePropertyAll(Colors.transparent),
      ),

      // Input kutusunun şekli ve rengi
      inputDecorationTheme: InputDecorationTheme(
        floatingLabelBehavior: FloatingLabelBehavior.never,
        filled: true,
        fillColor: fillColor,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 24,
          vertical: 14,
        ),

        // Radius'u 50 yaptık (Tam yuvarlak)
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: isDarkMode
              ? BorderSide.none
              : BorderSide(color: borderColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFF1E88E5), width: 1.5),
        ),
      ),

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

  void _userKayit(
    String userName,
    Option selectedSinav,
    String selectedSinif,
    Option2 selectedSinav2,
    BuildContext context,
    bool isPro,
  ) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw FirebaseAuthException(
          code: "user-not-found",
          message: "Oturum bulunamadı.",
        );
      }
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
