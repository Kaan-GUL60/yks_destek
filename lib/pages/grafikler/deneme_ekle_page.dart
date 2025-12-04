// lib/pages/deneme_ekle/deneme_ekle_page.dart

import 'dart:io'; // Platform kontrolü
import 'package:flutter/cupertino.dart'; // iOS widget'ları
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:kgsyks_destek/pages/grafikler/deneme_database_helper.dart';
import 'package:kgsyks_destek/pages/grafikler/deneme_model.dart';

class DenemeEklePage extends StatefulWidget {
  const DenemeEklePage({super.key});

  @override
  State<DenemeEklePage> createState() => _DenemeEklePageState();
}

class _DenemeEklePageState extends State<DenemeEklePage> {
  // Ortak Değişkenler
  DateTime _selectedDate = DateTime.now();
  final TextEditingController _denemeAdiController = TextEditingController();

  // iOS Tab Kontrolü için (TYT/AYT Geçişi)
  int _cupertinoTabIndex = 0;

  // --- TYT Controllerları ---
  final tytTurkceD = TextEditingController();
  final tytTurkceY = TextEditingController();
  final tytSosyalD = TextEditingController();
  final tytSosyalY = TextEditingController();
  final tytMatD = TextEditingController();
  final tytMatY = TextEditingController();
  final tytFenD = TextEditingController();
  final tytFenY = TextEditingController();

  // --- AYT Controllerları ---
  Set<int> _selectedAlan = {0}; // 0: Sayısal, 1: EA, 2: Sözel

  // Sayısal
  final aytMatD = TextEditingController();
  final aytMatY = TextEditingController();
  final aytFizD = TextEditingController();
  final aytFizY = TextEditingController();
  final aytKimD = TextEditingController();
  final aytKimY = TextEditingController();
  final aytBiyD = TextEditingController();
  final aytBiyY = TextEditingController();
  // EA - Sözel Ortak
  final aytEdbD = TextEditingController();
  final aytEdbY = TextEditingController();
  // İsimlerini modelle uyumlu olsun diye Tar1/Cog1 olarak düşünüyoruz
  final aytTar1D = TextEditingController(); // Eski aytTarD
  final aytTar1Y = TextEditingController(); // Eski aytTarY
  final aytCog1D = TextEditingController(); // Eski aytCogD
  final aytCog1Y = TextEditingController(); // Eski aytCogY

  // YENİ EKLENENLER
  final aytTar2D = TextEditingController();
  final aytTar2Y = TextEditingController();
  final aytCog2D = TextEditingController();
  final aytCog2Y = TextEditingController();
  // Sözel Ekstra
  final aytFelD = TextEditingController();
  final aytFelY = TextEditingController();
  final aytDinD = TextEditingController();
  final aytDinY = TextEditingController();

  // Limit kontrol fonksiyonu
  bool _validateScore(String dersAdi, String dText, String yText, int maxSoru) {
    int d = int.tryParse(dText) ?? 0;
    int y = int.tryParse(yText) ?? 0;

    if (d + y > maxSoru) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "$dersAdi için toplam işaretlenen (D+Y) $maxSoru sayısını geçemez!",
          ),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return false; // Hata var
    }
    return true; // Sorun yok
  }

  @override
  void dispose() {
    _denemeAdiController.dispose();
    tytTurkceD.dispose();
    tytTurkceY.dispose();
    tytSosyalD.dispose();
    tytSosyalY.dispose();
    tytMatD.dispose();
    tytMatY.dispose();
    tytFenD.dispose();
    tytFenY.dispose();
    aytMatD.dispose();
    aytMatY.dispose();
    aytFizD.dispose();
    aytFizY.dispose();
    aytKimD.dispose();
    aytKimY.dispose();
    aytBiyD.dispose();
    aytBiyY.dispose();
    aytEdbD.dispose();
    aytEdbY.dispose();
    aytTar1D.dispose();
    aytTar1Y.dispose();
    aytCog1D.dispose();
    aytCog1Y.dispose();
    aytTar2D.dispose();
    aytTar2Y.dispose(); // Yeni
    aytCog2D.dispose();
    aytCog2Y.dispose();
    aytFelD.dispose();
    aytFelY.dispose();
    aytDinD.dispose();
    aytDinY.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    initializeDateFormatting('tr_TR', null);
  }

  // --- PLATFORMA DUYARLI TARİH SEÇİCİ ---
  Future<void> _selectDate(BuildContext context) async {
    DateTime? picked;

    if (Platform.isIOS) {
      // iOS: Alttan Kayan Tekerlek
      await showCupertinoModalPopup(
        context: context,
        builder: (_) => Container(
          height: 250,
          color: const Color.fromARGB(255, 255, 255, 255),
          child: Column(
            children: [
              SizedBox(
                height: 180,
                child: CupertinoDatePicker(
                  mode: CupertinoDatePickerMode.date,
                  initialDateTime: _selectedDate,
                  minimumDate: DateTime(2020),
                  maximumDate: DateTime(2030),
                  onDateTimeChanged: (val) {
                    setState(() {
                      _selectedDate = val;
                    });
                  },
                ),
              ),
              CupertinoButton(
                child: const Text('Tamam'),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
        ),
      );
    } else {
      // Android: Takvim Popup
      picked = await showDatePicker(
        context: context,
        initialDate: _selectedDate,
        firstDate: DateTime(2020),
        lastDate: DateTime(2030),
      );
      if (picked != null && picked != _selectedDate) {
        setState(() {
          _selectedDate = picked!;
        });
      }
    }
  }

  Future<void> _saveTYT() async {
    // Validasyonlar (Limit Kontrolleri)
    if (!_validateScore("Türkçe", tytTurkceD.text, tytTurkceY.text, 40)) return;
    if (!_validateScore("Sosyal", tytSosyalD.text, tytSosyalY.text, 20)) return;
    if (!_validateScore("Matematik", tytMatD.text, tytMatY.text, 40)) return;
    if (!_validateScore("Fen", tytFenD.text, tytFenY.text, 20)) return;

    final deneme = TytDenemeModel(
      denemeAdi: _denemeAdiController.text.isEmpty
          ? "TYT Denemesi"
          : _denemeAdiController.text,
      tarih: _selectedDate,
      turkceD: int.tryParse(tytTurkceD.text) ?? 0,
      turkceY: int.tryParse(tytTurkceY.text) ?? 0,
      sosyalD: int.tryParse(tytSosyalD.text) ?? 0,
      sosyalY: int.tryParse(tytSosyalY.text) ?? 0,
      matD: int.tryParse(tytMatD.text) ?? 0,
      matY: int.tryParse(tytMatY.text) ?? 0,
      fenD: int.tryParse(tytFenD.text) ?? 0,
      fenY: int.tryParse(tytFenY.text) ?? 0,
    );

    await DenemeDatabaseHelper.instance.addTyt(deneme);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("TYT Kaydedildi!"),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context);
    }
  }

  Future<void> _saveAYT() async {
    String alanKodu = "SAY";
    if (_selectedAlan.contains(1)) alanKodu = "EA";
    if (_selectedAlan.contains(2)) alanKodu = "SOZ";

    // Validasyonlar (Alana Göre Özelleştirilmiş)
    if (alanKodu == "SAY") {
      if (!_validateScore("Matematik", aytMatD.text, aytMatY.text, 40)) return;
      if (!_validateScore("Fizik", aytFizD.text, aytFizY.text, 14)) return;
      if (!_validateScore("Kimya", aytKimD.text, aytKimY.text, 13)) return;
      if (!_validateScore("Biyoloji", aytBiyD.text, aytBiyY.text, 13)) return;
    } else if (alanKodu == "EA") {
      if (!_validateScore("Matematik", aytMatD.text, aytMatY.text, 40)) return;
      if (!_validateScore("Edebiyat", aytEdbD.text, aytEdbY.text, 24)) return;
      if (!_validateScore("Tarih-1", aytTar1D.text, aytTar1Y.text, 10)) return;
      if (!_validateScore("Coğrafya-1", aytCog1D.text, aytCog1Y.text, 6)) {
        return;
      }
    } else if (alanKodu == "SOZ") {
      if (!_validateScore("Edebiyat", aytEdbD.text, aytEdbY.text, 24)) return;
      if (!_validateScore("Tarih-1", aytTar1D.text, aytTar1Y.text, 10)) return;
      if (!_validateScore("Coğrafya-1", aytCog1D.text, aytCog1Y.text, 6)) {
        return;
      }
      if (!_validateScore("Tarih-2", aytTar2D.text, aytTar2Y.text, 11)) return;
      if (!_validateScore("Coğrafya-2", aytCog2D.text, aytCog2Y.text, 11)) {
        return;
      }
      if (!_validateScore("Felsefe", aytFelD.text, aytFelY.text, 12)) return;
      if (!_validateScore("Din", aytDinD.text, aytDinY.text, 6)) return;
    }

    final deneme = AytDenemeModel(
      denemeAdi: _denemeAdiController.text.isEmpty
          ? "AYT Denemesi"
          : _denemeAdiController.text,
      tarih: _selectedDate,
      alan: alanKodu,
      matD: int.tryParse(aytMatD.text) ?? 0,
      matY: int.tryParse(aytMatY.text) ?? 0,
      fizD: int.tryParse(aytFizD.text) ?? 0,
      fizY: int.tryParse(aytFizY.text) ?? 0,
      kimD: int.tryParse(aytKimD.text) ?? 0,
      kimY: int.tryParse(aytKimY.text) ?? 0,
      biyD: int.tryParse(aytBiyD.text) ?? 0,
      biyY: int.tryParse(aytBiyY.text) ?? 0,
      edbD: int.tryParse(aytEdbD.text) ?? 0,
      edbY: int.tryParse(aytEdbY.text) ?? 0,
      tar1D: int.tryParse(aytTar1D.text) ?? 0,
      tar1Y: int.tryParse(aytTar1Y.text) ?? 0,
      cog1D: int.tryParse(aytCog1D.text) ?? 0,
      cog1Y: int.tryParse(aytCog1Y.text) ?? 0,
      tar2D: int.tryParse(aytTar2D.text) ?? 0, // Yeni
      tar2Y: int.tryParse(aytTar2Y.text) ?? 0, // Yeni
      cog2D: int.tryParse(aytCog2D.text) ?? 0, // Yeni
      cog2Y: int.tryParse(aytCog2Y.text) ?? 0, // Yeni
      felD: int.tryParse(aytFelD.text) ?? 0,
      felY: int.tryParse(aytFelY.text) ?? 0,
      dinD: int.tryParse(aytDinD.text) ?? 0,
      dinY: int.tryParse(aytDinY.text) ?? 0,
    );

    await DenemeDatabaseHelper.instance.addAyt(deneme);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("AYT Kaydedildi!"),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = const Color(0xFF0099FF);
    final bgColor = Theme.of(context).scaffoldBackgroundColor;
    final textColor = isDark ? Colors.white : Colors.black87;

    // --- 1. iOS TASARIMI ---
    if (Platform.isIOS) {
      return CupertinoPageScaffold(
        backgroundColor: bgColor,
        navigationBar: CupertinoNavigationBar(
          middle: Text(
            "Deneme Ekle",
            style: GoogleFonts.montserrat(fontWeight: FontWeight.bold),
          ),
          backgroundColor: bgColor,
          border: null,
        ),
        child: SafeArea(
          child: Material(
            type: MaterialType
                .transparency, // <--- Arka planı bozmaması için şeffaf yapın
            child: Column(
              children: [
                const Gap(10),
                // iOS Tipi Tab Seçici (Segmented Control)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: SizedBox(
                    width: double.infinity,
                    child: CupertinoSlidingSegmentedControl<int>(
                      groupValue: _cupertinoTabIndex,
                      thumbColor: primaryColor,
                      backgroundColor: isDark
                          ? Colors.grey[800]!
                          : Colors.grey[200]!,
                      children: {
                        0: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Text(
                            "TYT Ekle",
                            style: TextStyle(
                              color: _cupertinoTabIndex == 0
                                  ? Colors.white
                                  : textColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        1: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Text(
                            "AYT Ekle",
                            style: TextStyle(
                              color: _cupertinoTabIndex == 1
                                  ? Colors.white
                                  : textColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      },
                      onValueChanged: (int? value) {
                        if (value != null) {
                          setState(() {
                            _cupertinoTabIndex = value;
                          });
                        }
                      },
                    ),
                  ),
                ),
                const Gap(10),
                Expanded(
                  child: _cupertinoTabIndex == 0
                      ? _buildTytForm(textColor, primaryColor, isDark)
                      : _buildAytForm(textColor, primaryColor, isDark),
                ),
              ],
            ),
          ),
        ),
      );
    }
    // --- 2. ANDROID TASARIMI (Mevcut Kod) ---
    else {
      return DefaultTabController(
        length: 2,
        child: Scaffold(
          backgroundColor: bgColor,
          appBar: AppBar(
            title: Text(
              "Deneme Ekle",
              style: GoogleFonts.montserrat(fontWeight: FontWeight.bold),
            ),
            centerTitle: true,
            elevation: 0,
            backgroundColor: bgColor,
            foregroundColor: textColor,
            bottom: TabBar(
              dividerColor: Colors.transparent,
              indicatorColor: primaryColor,
              labelColor: primaryColor,
              unselectedLabelColor: Colors.grey,
              labelStyle: GoogleFonts.montserrat(fontWeight: FontWeight.bold),
              tabs: const [
                Tab(text: "TYT Ekle"),
                Tab(text: "AYT Ekle"),
              ],
            ),
          ),
          body: TabBarView(
            children: [
              _buildTytForm(textColor, primaryColor, isDark),
              _buildAytForm(textColor, primaryColor, isDark),
            ],
          ),
        ),
      );
    }
  }

  Widget _buildTytForm(Color textColor, Color primaryColor, bool isDark) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          _buildHeaderInput(isDark, textColor),
          const Gap(20),
          _buildDersRow("Türkçe", tytTurkceD, tytTurkceY, isDark),
          _buildDersRow("Sosyal", tytSosyalD, tytSosyalY, isDark),
          _buildDersRow("Matematik", tytMatD, tytMatY, isDark),
          _buildDersRow("Fen", tytFenD, tytFenY, isDark),
          const Gap(30),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: _saveTYT,
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
              child: const Text(
                "TYT Kaydet",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAytForm(Color textColor, Color primaryColor, bool isDark) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          _buildHeaderInput(isDark, textColor),
          const Gap(20),

          // PLATFORMA DUYARLI ALAN SEÇİMİ
          Platform.isIOS
              ? SizedBox(
                  width: double.infinity,
                  child: CupertinoSlidingSegmentedControl<int>(
                    groupValue: _selectedAlan.first,
                    thumbColor: primaryColor,
                    backgroundColor: isDark
                        ? Colors.grey[800]!
                        : Colors.grey[200]!,
                    children: {
                      0: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: Text(
                          "Sayısal",
                          style: TextStyle(
                            color: _selectedAlan.contains(0)
                                ? Colors.white
                                : textColor,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      1: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: Text(
                          "Eşit Ağırlık",
                          style: TextStyle(
                            color: _selectedAlan.contains(1)
                                ? Colors.white
                                : textColor,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      2: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: Text(
                          "Sözel",
                          style: TextStyle(
                            color: _selectedAlan.contains(2)
                                ? Colors.white
                                : textColor,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    },
                    onValueChanged: (int? value) {
                      if (value != null) {
                        setState(() {
                          _selectedAlan = {value};
                        });
                      }
                    },
                  ),
                )
              : SizedBox(
                  width: double.infinity,
                  child: SegmentedButton<int>(
                    segments: const [
                      ButtonSegment<int>(value: 0, label: Text("Sayısal")),
                      ButtonSegment<int>(value: 1, label: Text("Eşit Ağırlık")),
                      ButtonSegment<int>(value: 2, label: Text("Sözel")),
                    ],
                    selected: _selectedAlan,
                    onSelectionChanged: (Set<int> newSelection) {
                      setState(() {
                        _selectedAlan = newSelection;
                      });
                    },
                    style: ButtonStyle(
                      backgroundColor: WidgetStateProperty.resolveWith<Color>((
                        states,
                      ) {
                        if (states.contains(WidgetState.selected)) {
                          return primaryColor;
                        }
                        return isDark ? Colors.grey[800]! : Colors.grey[200]!;
                      }),
                      foregroundColor: WidgetStateProperty.resolveWith<Color>((
                        states,
                      ) {
                        if (states.contains(WidgetState.selected)) {
                          return Colors.white;
                        }
                        return isDark ? Colors.white : Colors.black;
                      }),
                    ),
                  ),
                ),

          const Gap(20),

          if (_selectedAlan.contains(0)) ...[
            _buildDersRow("Matematik", aytMatD, aytMatY, isDark),
            _buildDersRow("Fizik", aytFizD, aytFizY, isDark),
            _buildDersRow("Kimya", aytKimD, aytKimY, isDark),
            _buildDersRow("Biyoloji", aytBiyD, aytBiyY, isDark),
          ] else if (_selectedAlan.contains(1)) ...[
            _buildDersRow("Matematik", aytMatD, aytMatY, isDark),
            _buildDersRow("Edebiyat", aytEdbD, aytEdbY, isDark),
            _buildDersRow("Tarih-1", aytTar1D, aytTar1Y, isDark),
            _buildDersRow("Coğrafya-1", aytCog1D, aytCog1Y, isDark),
          ] else ...[
            _buildDersRow("Edebiyat", aytEdbD, aytEdbY, isDark),
            _buildDersRow("Tarih-1", aytTar1D, aytTar1Y, isDark),
            _buildDersRow("Coğrafya-1", aytCog1D, aytCog1Y, isDark),
            const Gap(10), // Ayrım için boşluk
            _buildDersRow("Tarih-2", aytTar2D, aytTar2Y, isDark), // Yeni
            _buildDersRow("Coğrafya-2", aytCog2D, aytCog2Y, isDark), // Yeni
            const Gap(10),
            _buildDersRow("Felsefe", aytFelD, aytFelY, isDark),
            _buildDersRow("Din Kültürü", aytDinD, aytDinY, isDark),
          ],

          const Gap(30),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: () async {
                try {
                  await _saveAYT();
                } catch (e) {
                  // 1. Veritabanını sil
                  await DenemeDatabaseHelper.instance.nukeDatabase();

                  if (mounted) {
                    // 2. Kullanıcıya bilgi ver
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          "Veritabanı güncellendi. Lütfen tekrar 'AYT Kaydet' butonuna basın.",
                        ),
                        backgroundColor: Colors.orange,
                        duration: Duration(seconds: 4),
                      ),
                    );
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                elevation: 4, // Biraz gölge ekledik
                shadowColor: primaryColor.withValues(alpha: 0.4),
              ),
              child: const Text(
                "AYT Kaydet",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const Gap(30), // Klavye açılınca altta boşluk kalsın
        ],
      ),
    );
  }

  Widget _buildHeaderInput(bool isDark, Color textColor) {
    return Container(
      // Dış kutunun iç boşluğunu biraz artırdım (Daha ferah durması için)
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1F2937) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // --- DENEME ADI GİRİŞİ ---
          TextField(
            controller: _denemeAdiController,
            style: TextStyle(
              color: textColor,
              fontWeight: FontWeight.bold,
              fontSize: 18, // Yazı boyutu büyütüldü
            ),
            decoration: InputDecoration(
              hintText: "Deneme Adı (Örn: X TYT TG 1)",
              hintStyle: TextStyle(
                color: Colors.grey[500],
                fontSize: 16, // Hint yazısı da büyütüldü
                fontWeight: FontWeight.normal,
              ),

              // SADECE GRİ FONU KAPATIYORUZ, BOYUTU KISITLAMIYORUZ
              filled: false,

              // isDense ve contentPadding kaldırıldı -> Alan genişledi
              border: InputBorder.none,
              focusedBorder: InputBorder.none,
              enabledBorder: InputBorder.none,
              errorBorder: InputBorder.none,
              disabledBorder: InputBorder.none,

              // İkon
              prefixIcon: const Icon(
                Icons.edit_note,
                color: Colors.blueAccent,
                size: 28,
              ),
            ),
          ),

          const Padding(
            padding: EdgeInsets.symmetric(
              vertical: 16.0,
            ), // Çizgi ile yazı arası açıldı
            child: Divider(height: 1),
          ),

          // --- TARİH SEÇİCİ ---
          GestureDetector(
            onTap: () => _selectDate(context),
            child: Row(
              children: [
                Icon(
                  Platform.isIOS
                      ? CupertinoIcons.calendar
                      : Icons.calendar_month,
                  color: Colors.blueAccent,
                  size: 24,
                ),
                const Gap(12),
                Text(
                  DateFormat('dd MMMM yyyy', 'tr_TR').format(_selectedDate),
                  style: TextStyle(
                    color: textColor,
                    fontWeight: FontWeight.w600,
                    fontSize: 16, // Tarih yazısı büyütüldü
                  ),
                ),
                const Spacer(),
                const Icon(Icons.arrow_drop_down, color: Colors.grey),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDersRow(
    String dersAdi,
    TextEditingController dogruCont,
    TextEditingController yanlisCont,
    bool isDark,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF2D333B) : Colors.grey[50],
        borderRadius: BorderRadius.circular(16), // Daha yumuşak köşeler
        border: Border.all(
          color: isDark ? Colors.white10 : Colors.grey.shade300,
        ),
      ),
      child: Row(
        children: [
          // Ders Adı Alanı
          Expanded(
            flex: 3, // Yazıya biraz daha alan bıraktık
            child: Text(
              dersAdi,
              style: GoogleFonts.montserrat(
                fontWeight: FontWeight.bold,
                fontSize: 15, // Yazı boyutu ideal
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
          ),
          // Doğru Kutusu
          SizedBox(
            width: 60, // Sabit genişlik vererek kutuların hizasını garantiledik
            child: _buildMiniInput(dogruCont, "D", Colors.green, isDark),
          ),
          const Gap(12), // Kutu arası boşluk
          // Yanlış Kutusu
          SizedBox(
            width: 60, // Sabit genişlik
            child: _buildMiniInput(yanlisCont, "Y", Colors.red, isDark),
          ),
        ],
      ),
    );
  }

  // --- KUTUCUK TASARIMI (Mini Input) - DÜZELTİLMİŞ HALİ ---
  Widget _buildMiniInput(
    TextEditingController controller,
    String hint,
    Color color,
    bool isDark,
  ) {
    return Container(
      height: 50,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        // Arka plan rengini (Karanlık/Aydınlık) buraya veriyoruz
        color: isDark ? const Color(0xFF1F2937) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withValues(alpha: 0.6), // Çerçeve Rengi (Yeşil/Kırmızı)
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Center(
        child: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          textAlign: TextAlign.center,
          textAlignVertical: TextAlignVertical.center,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: isDark ? Colors.white : Colors.black87,
          ),
          // --- İŞTE BURASI DÜZELTİYOR ---
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(
              color: color.withValues(alpha: 0.5),
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
            // İçerdeki tüm çizgileri ve dolguları kapatıyoruz:
            filled: false, // Arka plan dolgusunu kapatır (Gri kutuyu siler)
            border: InputBorder.none, // Alt çizgiyi siler
            focusedBorder: InputBorder.none, // Tıklanınca çıkan çizgiyi siler
            enabledBorder: InputBorder.none, // Normal çizgiyi siler
            errorBorder: InputBorder.none,
            disabledBorder: InputBorder.none,
            isDense: true,
            contentPadding: EdgeInsets.zero, // İç boşluğu sıfırlar
          ),
        ),
      ),
    );
  }
}
