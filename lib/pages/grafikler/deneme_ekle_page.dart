// lib/pages/deneme_ekle/deneme_ekle_page.dart

import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart'; // Tarih formatı için
import 'package:intl/date_symbol_data_local.dart'; // <-- BU SATIRI EKLE
// Importları kendi proje yapına göre ayarla:
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
  // Alan Seçimi: 0: Sayısal, 1: Eşit Ağırlık, 2: Sözel
  Set<int> _selectedAlan = {0};

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
  final aytTarD = TextEditingController();
  final aytTarY = TextEditingController();
  final aytCogD = TextEditingController();
  final aytCogY = TextEditingController();
  // Sözel Ekstra
  final aytFelD = TextEditingController();
  final aytFelY = TextEditingController();
  final aytDinD = TextEditingController();
  final aytDinY = TextEditingController();

  @override
  void dispose() {
    // Tüm controllerları dispose et
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
    aytTarD.dispose();
    aytTarY.dispose();
    aytCogD.dispose();
    aytCogY.dispose();
    aytFelD.dispose();
    aytFelY.dispose();
    aytDinD.dispose();
    aytDinY.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    // Türkçe tarih formatını başlatıyoruz
    initializeDateFormatting('tr_TR', null);
  }

  // Tarih Seçici
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  // --- KAYDETME FONKSİYONLARI ---

  Future<void> _saveTYT() async {
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
          content: Text("TYT Denemesi Kaydedildi!"),
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

    final deneme = AytDenemeModel(
      denemeAdi: _denemeAdiController.text.isEmpty
          ? "AYT Denemesi"
          : _denemeAdiController.text,
      tarih: _selectedDate,
      alan: alanKodu,
      // Sayısal
      matD: int.tryParse(aytMatD.text) ?? 0,
      matY: int.tryParse(aytMatY.text) ?? 0,
      fizD: int.tryParse(aytFizD.text) ?? 0,
      fizY: int.tryParse(aytFizY.text) ?? 0,
      kimD: int.tryParse(aytKimD.text) ?? 0,
      kimY: int.tryParse(aytKimY.text) ?? 0,
      biyD: int.tryParse(aytBiyD.text) ?? 0,
      biyY: int.tryParse(aytBiyY.text) ?? 0,
      // EA/Sözel
      edbD: int.tryParse(aytEdbD.text) ?? 0,
      edbY: int.tryParse(aytEdbY.text) ?? 0,
      tarD: int.tryParse(aytTarD.text) ?? 0,
      tarY: int.tryParse(aytTarY.text) ?? 0,
      cogD: int.tryParse(aytCogD.text) ?? 0,
      cogY: int.tryParse(aytCogY.text) ?? 0,
      // Sözel Ekstra
      felD: int.tryParse(aytFelD.text) ?? 0,
      felY: int.tryParse(aytFelY.text) ?? 0,
      dinD: int.tryParse(aytDinD.text) ?? 0,
      dinY: int.tryParse(aytDinY.text) ?? 0,
    );

    await DenemeDatabaseHelper.instance.addAyt(deneme);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("AYT Denemesi Kaydedildi!"),
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
            dividerColor: Colors.transparent, // Çizgiyi şeffaf yapar
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
            // --- TYT TAB ---
            _buildTytForm(textColor, primaryColor, isDark),
            // --- AYT TAB ---
            _buildAytForm(textColor, primaryColor, isDark),
          ],
        ),
      ),
    );
  }

  // --- TYT FORM WIDGET ---
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

  // --- AYT FORM WIDGET ---
  Widget _buildAytForm(Color textColor, Color primaryColor, bool isDark) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          _buildHeaderInput(isDark, textColor),
          const Gap(20),

          // ALAN SEÇİMİ
          SizedBox(
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

          // ALANA GÖRE DERSLER
          if (_selectedAlan.contains(0)) ...[
            // SAYISAL
            _buildDersRow("Matematik", aytMatD, aytMatY, isDark),
            _buildDersRow("Fizik", aytFizD, aytFizY, isDark),
            _buildDersRow("Kimya", aytKimD, aytKimY, isDark),
            _buildDersRow("Biyoloji", aytBiyD, aytBiyY, isDark),
          ] else if (_selectedAlan.contains(1)) ...[
            // EA
            _buildDersRow("Matematik", aytMatD, aytMatY, isDark),
            _buildDersRow("Edebiyat", aytEdbD, aytEdbY, isDark),
            _buildDersRow("Tarih", aytTarD, aytTarY, isDark),
            _buildDersRow("Coğrafya", aytCogD, aytCogY, isDark),
          ] else ...[
            // SÖZEL
            _buildDersRow("Edebiyat", aytEdbD, aytEdbY, isDark),
            _buildDersRow("Tarih", aytTarD, aytTarY, isDark),
            _buildDersRow("Coğrafya", aytCogD, aytCogY, isDark),
            _buildDersRow("Felsefe", aytFelD, aytFelY, isDark),
            _buildDersRow("Din", aytDinD, aytDinY, isDark),
          ],

          const Gap(30),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: _saveAYT,
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
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
        ],
      ),
    );
  }

  // --- YARDIMCI WIDGETLAR ---

  // Tarih ve Deneme Adı Girişi
  Widget _buildHeaderInput(bool isDark, Color textColor) {
    return Container(
      padding: const EdgeInsets.all(16),
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
          TextField(
            controller: _denemeAdiController,
            style: TextStyle(color: textColor),
            decoration: InputDecoration(
              hintText: "Deneme Adı (Örn: 3D TYT TG 1)",
              hintStyle: TextStyle(color: Colors.grey[500]),
              border: InputBorder.none,
              icon: Icon(Icons.edit_note, color: Colors.blueAccent),
            ),
          ),
          const Divider(),
          GestureDetector(
            onTap: () => _selectDate(context),
            child: Row(
              children: [
                const Icon(Icons.calendar_month, color: Colors.blueAccent),
                const Gap(10),
                Text(
                  DateFormat('dd MMMM yyyy', 'tr_TR').format(
                    _selectedDate,
                  ), // intl paketi gerekir, yoksa toString kullanın
                  style: TextStyle(
                    color: textColor,
                    fontWeight: FontWeight.w600,
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

  // Tekil Ders Satırı (Ders Adı | D | Y | Net)
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
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? Colors.white10 : Colors.grey.shade200,
        ),
      ),
      child: Row(
        children: [
          // Ders Adı
          Expanded(
            flex: 3,
            child: Text(
              dersAdi,
              style: GoogleFonts.montserrat(
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),
          // Doğru
          Expanded(
            flex: 2,
            child: _buildMiniInput(dogruCont, "D", Colors.green, isDark),
          ),
          const Gap(10),
          // Yanlış
          Expanded(
            flex: 2,
            child: _buildMiniInput(yanlisCont, "Y", Colors.red, isDark),
          ),
          const Gap(10),
          // Net (Otomatik hesaplama için basit bir text, canlı hesaplama için setState gerekir
          // ama karmaşıklığı artırmamak için statik bırakabilir veya dinleyici ekleyebiliriz.
          // Şimdilik sadece inputları alıyoruz)
        ],
      ),
    );
  }

  Widget _buildMiniInput(
    TextEditingController controller,
    String hint,
    Color color,
    bool isDark,
  ) {
    return Container(
      height: 40,
      decoration: BoxDecoration(
        color: isDark ? Colors.black26 : Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: TextField(
        controller: controller,
        keyboardType: TextInputType.number,
        textAlign: TextAlign.center,
        style: TextStyle(fontWeight: FontWeight.bold, color: color),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: color.withValues(alpha: 0.5)),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.only(bottom: 8),
        ),
      ),
    );
  }
}
