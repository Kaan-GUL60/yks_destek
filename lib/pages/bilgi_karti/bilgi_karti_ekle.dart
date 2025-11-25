// lib/pages/bilgi_notu_ekle/bilgi_notu_ekle.dart

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:gap/gap.dart';
import 'package:kgsyks_destek/pages/bilgi_karti/bilgi_notu_model.dart';
import 'package:kgsyks_destek/pages/bilgi_karti/bilgi_notu_providers.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

// Kendi proje yapına göre import yollarını kontrol et:
import 'package:kgsyks_destek/pages/soru_ekle/image_picker_provider.dart';
import 'package:kgsyks_destek/pages/soru_ekle/listeler.dart'; // Ders ve Konu listeleri buradan geliyor
import 'package:kgsyks_destek/pages/soru_ekle/soru_ekle_provider.dart'; // SoruKayitState

class BilgiNotuEklePage extends ConsumerStatefulWidget {
  const BilgiNotuEklePage({super.key});

  @override
  ConsumerState<BilgiNotuEklePage> createState() => _BilgiNotuEklePageState();
}

class _BilgiNotuEklePageState extends ConsumerState<BilgiNotuEklePage> {
  late TextEditingController _descriptionController;
  DateTime _selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _descriptionController = TextEditingController();
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  // --- İŞLEVSEL FONKSİYONLAR ---

  Future<void> _showImageSourceDialog() async {
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Resim Kaynağını Seçin'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Galeriden Seç'),
                onTap: () {
                  Navigator.of(context).pop();
                  ref.read(imagePickerProvider.notifier).pickImageFromGallery();
                },
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Kameradan Çek'),
                onTap: () {
                  Navigator.of(context).pop();
                  ref.read(imagePickerProvider.notifier).pickImageFromCamera();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime(2030),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  // Tarihi Türkçe formatla
  String _getFormattedDate(DateTime date) {
    const List<String> aylar = [
      'Ocak',
      'Şubat',
      'Mart',
      'Nisan',
      'Mayıs',
      'Haziran',
      'Temmuz',
      'Ağustos',
      'Eylül',
      'Ekim',
      'Kasım',
      'Aralık',
    ];
    return "${date.day} ${aylar[date.month - 1]} ${date.year}";
  }

  Future<void> _saveInfoNote() async {
    final selectedDers = ref.read(selectedBilgiDersProvider);
    final selectedKonu = ref.read(selectedBilgiKonuProvider);
    final selectedPriority = ref.read(selectedBilgiOnemProvider);
    final selectedImage = ref.read(imagePickerProvider);

    // 1. Validasyon
    if (selectedDers == null || selectedKonu == null || selectedImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Lütfen ders, konu ve fotoğraf alanlarını doldurunuz."),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    // 2. Resmi Kalıcı Hafızaya Kaydetme (Sıkıştırma ile)
    try {
      final appDir = await getApplicationDocumentsDirectory();
      final fileName = p.basename(selectedImage.path);
      final savedImagePath = p.join(appDir.path, 'note_$fileName');

      final compressedImageBytes = await FlutterImageCompress.compressWithFile(
        selectedImage.path,
        quality: 85,
      );

      if (compressedImageBytes == null) return;

      final File savedImage = File(savedImagePath);
      await savedImage.writeAsBytes(compressedImageBytes);

      // 3. Modeli Oluştur
      final yeniNot = BilgiNotuModel(
        ders: selectedDers,
        konu: selectedKonu,
        onemDerecesi: selectedPriority,
        aciklama: _descriptionController.text.isEmpty
            ? "-"
            : _descriptionController.text,
        imagePath: savedImage.path,
        eklenmeTarihi: DateTime.now(),
        hatirlaticiTarihi: _selectedDate,
      );

      // 4. Veritabanına Kaydet
      await ref.read(bilgiNotuNotifierProvider.notifier).saveBilgiNotu(yeniNot);

      // Bildirim kurma işlemleri buraya eklenebilir (SoruEkle sayfasındaki gibi)
    } catch (e) {
      debugPrint("Hata oluştu: $e");
    }
  }

  void _resetForm() {
    _descriptionController.clear();
    ref.read(selectedBilgiDersProvider.notifier).state = null;
    ref.read(selectedBilgiKonuProvider.notifier).state = null;
    ref.read(selectedBilgiOnemProvider.notifier).state = 1;
    ref.read(imagePickerProvider.notifier).clearImage();
    setState(() {
      _selectedDate = DateTime.now();
    });
    ref.read(bilgiNotuNotifierProvider.notifier).resetState();
  }

  @override
  Widget build(BuildContext context) {
    // State İzleme
    final File? selectedImage = ref.watch(imagePickerProvider);
    final String? secilenDers = ref.watch(selectedBilgiDersProvider);
    final String? secilenKonu = ref.watch(selectedBilgiKonuProvider);
    final int secilenOnem = ref.watch(selectedBilgiOnemProvider);
    final kayitDurumu = ref.watch(bilgiNotuNotifierProvider);

    // Konu listesini seçilen derse göre filtrele (listeler.dart'tan geliyor)
    List<String> currentKonuListesi = [];
    if (secilenDers != null) {
      currentKonuListesi = konuListeleri[secilenDers] ?? [];
    }

    // Listener: Kayıt başarılıysa
    ref.listen<SoruKayitState>(bilgiNotuNotifierProvider, (prev, next) {
      if (next == SoruKayitState.success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Bilgi notu başarıyla kaydedildi!'),
            backgroundColor: Colors.green,
          ),
        );
        _resetForm();
      } else if (next == SoruKayitState.error) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Hata: Kayıt yapılamadı!'),
            backgroundColor: Colors.red,
          ),
        );
      }
    });

    // --- TEMA RENKLERİ ---
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final Color bgColor = Theme.of(context).scaffoldBackgroundColor;
    final Color cardColor = Theme.of(context).cardColor;
    final Color textColor =
        Theme.of(context).textTheme.bodyLarge?.color ?? Colors.black;
    final Color subTextColor = Theme.of(context).hintColor;
    final Color primaryBlue = const Color(0xFF1A56DB); // Tasarımdaki mavi
    final Color dashedBorderColor = primaryBlue.withValues(
      alpha: isDark ? 0.5 : 0.3,
    );

    // Öncelik Buton Renkleri
    final List<Color> priorityColors = [
      const Color(0xFFE53935), // Kritik (Kırmızı)
      const Color(0xFFF57C00), // Olağan (Turuncu)
      const Color(0xFF43A047), // Düşük (Yeşil)
    ];
    final List<IconData> priorityIcons = [
      Icons.local_fire_department_rounded,
      Icons.priority_high_rounded,
      Icons.arrow_downward_rounded,
    ];
    final List<String> priorityLabels = ["Kritik", "Olağan", "Düşük"];

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        elevation: 0,
        leading: BackButton(color: textColor),
        centerTitle: true,
        title: Text(
          "Bilgi Notu Ekle",
          style: TextStyle(
            color: textColor,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- RESİM EKLEME ALANI ---
              GestureDetector(
                onTap: _showImageSourceDialog,
                child: Container(
                  height: 180,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: cardColor.withValues(alpha: isDark ? 0.5 : 1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: dashedBorderColor,
                      width: 2,
                      // Düz çizgi (dotted border paketi olmadığı için)
                    ),
                  ),
                  child: selectedImage != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(18),
                          child: Image.file(selectedImage, fit: BoxFit.cover),
                        )
                      : Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.camera_alt_rounded,
                              size: 40,
                              color: primaryBlue,
                            ),
                            const Gap(10),
                            Text(
                              "Bilgi Notu Fotoğrafı Ekle",
                              style: TextStyle(
                                color: primaryBlue,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                ),
              ),
              const Gap(24),

              // --- DERS VE KONU DROPDOWNLARI ---
              Row(
                children: [
                  // Ders Dropdown
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Ders",
                          style: TextStyle(
                            color: textColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Gap(8),
                        _buildDropdown(
                          value: secilenDers,
                          items: dersler, // listeler.dart'taki liste
                          hint: "Seçiniz",
                          cardColor: cardColor,
                          textColor: textColor,
                          onChanged: (val) {
                            ref.read(selectedBilgiDersProvider.notifier).state =
                                val;
                            ref.read(selectedBilgiKonuProvider.notifier).state =
                                null; // Ders değişince konuyu sıfırla
                          },
                        ),
                      ],
                    ),
                  ),
                  const Gap(16),
                  // Konu Dropdown
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Konu",
                          style: TextStyle(
                            color: textColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Gap(8),
                        _buildDropdown(
                          value: secilenKonu,
                          items:
                              currentKonuListesi, // Seçili derse göre filtrelenmiş liste
                          hint: "Seçiniz",
                          cardColor: cardColor,
                          textColor: textColor,
                          onChanged: (val) =>
                              ref
                                      .read(selectedBilgiKonuProvider.notifier)
                                      .state =
                                  val,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const Gap(24),

              // --- ÖNEM DÜZEYİ BUTONLARI ---
              Text(
                "Önem Düzeyi",
                style: TextStyle(color: textColor, fontWeight: FontWeight.bold),
              ),
              const Gap(12),
              Row(
                children: List.generate(3, (index) {
                  final isSelected = secilenOnem == index;
                  return Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(right: index == 2 ? 0 : 12.0),
                      child: InkWell(
                        onTap: () {
                          ref.read(selectedBilgiOnemProvider.notifier).state =
                              index;
                        },
                        borderRadius: BorderRadius.circular(30),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? priorityColors[index]
                                : cardColor,
                            borderRadius: BorderRadius.circular(30),
                            border: Border.all(
                              color: isSelected
                                  ? Colors.transparent
                                  : (isDark
                                        ? Colors.transparent
                                        : Colors.grey.shade300),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                priorityIcons[index],
                                size: 18,
                                color: isSelected
                                    ? Colors.white
                                    : priorityColors[index],
                              ),
                              const Gap(8),
                              Text(
                                priorityLabels[index],
                                style: TextStyle(
                                  color: isSelected ? Colors.white : textColor,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              ),
              const Gap(24),

              // --- AÇIKLAMA ---
              Text(
                "Bilgi Notu Açıklaması",
                style: TextStyle(color: textColor, fontWeight: FontWeight.bold),
              ),
              const Gap(12),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isDark ? Colors.transparent : Colors.grey.shade300,
                  ),
                ),
                child: TextField(
                  controller: _descriptionController,
                  maxLines: 5,
                  minLines: 3,
                  style: TextStyle(color: textColor),
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: "Önemli detayları buraya yaz...",
                    hintStyle: TextStyle(color: subTextColor),
                  ),
                ),
              ),
              const Gap(24),

              // --- TARİH ---
              Text(
                "Hatırlatıcı Tarihi Seç",
                style: TextStyle(color: textColor, fontWeight: FontWeight.bold),
              ),
              const Gap(12),
              GestureDetector(
                onTap: () => _selectDate(context),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                  decoration: BoxDecoration(
                    color: cardColor,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isDark ? Colors.transparent : Colors.grey.shade300,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.calendar_month_rounded, color: primaryBlue),
                      const Gap(12),
                      Expanded(
                        child: Text(
                          _getFormattedDate(_selectedDate),
                          style: TextStyle(
                            color: textColor,
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                      ),
                      Icon(Icons.edit_calendar_rounded, color: subTextColor),
                    ],
                  ),
                ),
              ),
              const Gap(30),

              // --- KAYDET BUTONU ---
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton.icon(
                  onPressed: kayitDurumu == SoruKayitState.loading
                      ? null
                      : _saveInfoNote,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryBlue,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  icon: kayitDurumu == SoruKayitState.loading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Icon(Icons.save_rounded),
                  label: Text(
                    kayitDurumu == SoruKayitState.loading
                        ? "Kaydediliyor..."
                        : "Kaydet",
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const Gap(20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDropdown({
    required String? value,
    required List<String> items,
    required String hint,
    required Color cardColor,
    required Color textColor,
    required Function(String?) onChanged,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? Colors.transparent : Colors.grey.shade300,
        ),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          hint: Text(hint, style: TextStyle(color: Colors.grey.shade500)),
          isExpanded: true,
          icon: Icon(Icons.keyboard_arrow_down_rounded, color: textColor),
          dropdownColor: cardColor,
          borderRadius: BorderRadius.circular(16),
          items: items.map((String item) {
            return DropdownMenuItem<String>(
              value: item,
              child: Text(item, style: TextStyle(color: textColor)),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}
