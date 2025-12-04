// lib/pages/bilgi_karti/bilgi_notu_viewer.dart

// ignore_for_file: use_build_context_synchronously

import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kgsyks_destek/cloud_message/services.dart';
import 'package:kgsyks_destek/pages/bilgi_karti/bilgi_notu_database_helper.dart';
import 'package:kgsyks_destek/pages/bilgi_karti/bilgi_notu_model.dart';
import 'package:kgsyks_destek/pages/bilgi_karti/bilgi_notu_providers.dart';
import 'package:kgsyks_destek/soru_viewer/drawing_page.dart';
import 'package:permission_handler/permission_handler.dart';

// Eğer 'scheduleLocalNotification' başka bir yerdeyse import et:
// import 'package:kgsyks_destek/cloud_message/services.dart';

class BilgiNotuViewer extends ConsumerWidget {
  final int notId;

  BilgiNotuViewer({super.key, required this.notId});

  // Helper'a erişim
  final BilgiNotuDatabaseHelper _dbHelper = BilgiNotuDatabaseHelper.instance;

  // --- GÜNCELLEME FONKSİYONLARI ---

  // 1. Önem Derecesini Güncelle
  Future<void> _updateOnemDerecesi(
    WidgetRef ref,
    BilgiNotuModel not,
    int yeniOnem,
  ) async {
    // Modeli kopyalayıp yeni değerle oluşturuyoruz (Immutable yapı)
    final guncelNot = BilgiNotuModel(
      id: not.id,
      ders: not.ders,
      konu: not.konu,
      onemDerecesi: yeniOnem, // Değişen kısım
      aciklama: not.aciklama,
      imagePath: not.imagePath,
      eklenmeTarihi: not.eklenmeTarihi,
      hatirlaticiTarihi: not.hatirlaticiTarihi,
    );

    await _dbHelper.updateBilgiNotu(guncelNot);
    // Provider'ı yenile ki arayüz güncellensin
    ref.invalidate(bilgiNotuDetailProvider(not.id!));
  }

  // 2. Açıklamayı Güncelle
  Future<void> _updateAciklama(
    WidgetRef ref,
    BilgiNotuModel not,
    String yeniAciklama,
  ) async {
    final guncelNot = BilgiNotuModel(
      id: not.id,
      ders: not.ders,
      konu: not.konu,
      onemDerecesi: not.onemDerecesi,
      aciklama: yeniAciklama, // Değişen kısım
      imagePath: not.imagePath,
      eklenmeTarihi: not.eklenmeTarihi,
      hatirlaticiTarihi: not.hatirlaticiTarihi,
    );
    await _dbHelper.updateBilgiNotu(guncelNot);
    ref.invalidate(bilgiNotuDetailProvider(not.id!));
  }

  // 3. Hatırlatıcı Tarihini Güncelle
  Future<void> _updateHatirlaticiTarih(
    WidgetRef ref,
    BilgiNotuModel not,
    DateTime? tarih,
  ) async {
    final guncelNot = BilgiNotuModel(
      id: not.id,
      ders: not.ders,
      konu: not.konu,
      onemDerecesi: not.onemDerecesi,
      aciklama: not.aciklama,
      imagePath: not.imagePath,
      eklenmeTarihi: not.eklenmeTarihi,
      hatirlaticiTarihi: tarih, // Değişen kısım
    );

    await _dbHelper.updateBilgiNotu(guncelNot);
    ref.invalidate(bilgiNotuDetailProvider(not.id!));

    // Bildirim Planlama (Opsiyonel - Eğer projenizde servis varsa açabilirsiniz)
    /*
    if (tarih != null) {
      // SoruViewer'daki bildirim mantığının aynısını buraya ekleyebilirsiniz.
      // Sadece 'soru' yerine 'not' değişkenlerini kullanın.
    }
    */
  }

  Future<void> _selectDate(
    BuildContext context,
    WidgetRef ref,
    BilgiNotuModel not,
  ) async {
    DateTime? picked;
    final initialDate = DateTime.now();

    if (Platform.isIOS) {
      // iOS İÇİN: CupertinoDatePicker
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
                  initialDateTime: initialDate,
                  minimumDate: initialDate,
                  maximumDate: DateTime(2101),
                  onDateTimeChanged: (val) {
                    picked = val;
                  },
                ),
              ),
              CupertinoButton(
                child: const Text('Tamam'),
                onPressed: () {
                  // Eğer kullanıcı hiç çevirmeden basarsa bugünü seçmiş sayalım
                  picked ??= initialDate;
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        ),
      );
    } else {
      // ANDROID İÇİN: Material DatePicker
      picked = await showDatePicker(
        context: context,
        initialDate: initialDate,
        firstDate: initialDate,
        lastDate: DateTime(2101),
      );
    }

    if (picked != null) {
      await _updateHatirlaticiTarih(ref, not, picked);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Hatırlatıcı tarihi güncellendi!')),
      );
    }

    if (Platform.isAndroid) {
      await Permission.notification.request();
      await fln
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >()
          ?.requestExactAlarmsPermission();
    } else if (Platform.isIOS) {
      await fln
          .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin
          >()
          ?.requestPermissions(alert: true, badge: true, sound: true);
    }
  }

  Widget _buildPrioritySelector(
    BuildContext context,
    WidgetRef ref,
    BilgiNotuModel not,
    bool isDark,
    Color primaryBlue,
  ) {
    // iOS İÇİN: CupertinoSlidingSegmentedControl
    if (Platform.isIOS) {
      return SizedBox(
        width: double.infinity,
        child: CupertinoSlidingSegmentedControl<int>(
          groupValue: not.onemDerecesi,
          children: const {
            0: Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Text("Kritik"),
            ),
            1: Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Text("Olağan"),
            ),
            2: Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Text("Düşük"),
            ),
          },
          onValueChanged: (int? newValue) {
            if (newValue != null) {
              _updateOnemDerecesi(ref, not, newValue);
            }
          },
          backgroundColor: isDark ? Colors.grey[800]! : Colors.grey[200]!,
          thumbColor: isDark ? const Color(0xFF6366F1) : Colors.white,
        ),
      );
    }
    // ANDROID İÇİN: SegmentedButton
    else {
      return SizedBox(
        width: double.infinity,
        child: SegmentedButton<int>(
          segments: const [
            ButtonSegment<int>(
              value: 0,
              label: Text("Kritik"),
              icon: Icon(Icons.local_fire_department),
            ),
            ButtonSegment<int>(
              value: 1,
              label: Text("Olağan"),
              icon: Icon(Icons.priority_high),
            ),
            ButtonSegment<int>(
              value: 2,
              label: Text("Düşük"),
              icon: Icon(Icons.arrow_downward),
            ),
          ],
          selected: {not.onemDerecesi},
          onSelectionChanged: (Set<int> newSelection) {
            _updateOnemDerecesi(ref, not, newSelection.first);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text("Önem derecesi güncellendi"),
                duration: Duration(seconds: 1),
              ),
            );
          },
          style: ButtonStyle(
            backgroundColor: WidgetStateProperty.resolveWith<Color>((states) {
              if (states.contains(WidgetState.selected)) return primaryBlue;
              return isDark ? const Color(0xFF374151) : Colors.transparent;
            }),
            foregroundColor: WidgetStateProperty.resolveWith<Color>((states) {
              if (states.contains(WidgetState.selected)) return Colors.white;
              return isDark ? Colors.white : Colors.black87;
            }),
          ),
        ),
      );
    }
  }
  // --- ARAYÜZ KISMI ---

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notAsyncValue = ref.watch(bilgiNotuDetailProvider(notId));
    final aciklamaController = ref.watch(bilgiAciklamaControllerProvider);

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final Color primaryBlue = const Color(0xFF1A56DB);
    final Color lightBlueBg = const Color(0xFFE0E7FF);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Bilgi Notu Detayı"),
        centerTitle: true,
        leading: BackButton(),
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: SafeArea(
          child: notAsyncValue.when(
            loading: () => Center(
              child: Platform.isIOS
                  ? const CupertinoActivityIndicator()
                  : const CircularProgressIndicator(),
            ),
            error: (error, stack) =>
                Center(child: Text('Bir hata oluştu: $error')),
            data: (not) {
              // Eski Hali:
              // if (not == null) return const Center(child: Text("Bilgi notu bulunamadı."));

              // Yeni Hali (Süslü parantezli):
              if (not == null) {
                return const Center(child: Text("Bilgi notu bulunamadı."));
              }

              // Controller'ı ilk değerle doldur (eğer boşsa)
              if (aciklamaController.text.isEmpty && not.aciklama.isNotEmpty) {
                aciklamaController.text = not.aciklama;
              }

              return SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // --- Başlık Kısmı ---
                      Text(
                        not.ders,
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: primaryBlue,
                        ),
                      ),
                      const Gap(4),
                      Text(
                        not.konu,
                        style: GoogleFonts.inter(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : Colors.black,
                        ),
                      ),
                      const Gap(16),

                      // --- Bilgi Çipleri (Önem Derecesi / Tarih) ---
                      Row(
                        children: [
                          // Önem Derecesi Çipi
                          _buildPriorityChip(context, not.onemDerecesi),
                          const Gap(12),

                          // Tarih Çipi
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: isDark
                                  ? const Color(0xFF374151)
                                  : const Color(0xFFF3F4F6),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.calendar_today_outlined,
                                  size: 16,
                                  color: isDark
                                      ? Colors.grey[300]
                                      : Colors.grey[600],
                                ),
                                const Gap(6),
                                Text(
                                  not.hatirlaticiTarihi != null
                                      ? "${not.hatirlaticiTarihi!.day}.${not.hatirlaticiTarihi!.month}.${not.hatirlaticiTarihi!.year}"
                                      : 'Tarih Yok',
                                  style: TextStyle(
                                    color: isDark
                                        ? Colors.grey[300]
                                        : Colors.grey[600],
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const Gap(24),

                      // --- Resim Alanı ---
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  DrawingPage(imagePath: not.imagePath),
                            ),
                          );
                        },
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: isDark
                                ? const Color(0xFF1F2937)
                                : const Color(0xFFF8FAFC),
                            borderRadius: BorderRadius.circular(24),
                            boxShadow: [
                              if (!isDark)
                                BoxShadow(
                                  color: Colors.grey.withValues(alpha: 0.1),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: not.imagePath.isNotEmpty
                                ? Image.file(
                                    File(not.imagePath),
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      return const SizedBox(
                                        height: 200,
                                        child: Center(
                                          child: Icon(
                                            Icons.broken_image,
                                            size: 50,
                                          ),
                                        ),
                                      );
                                    },
                                  )
                                : const SizedBox(
                                    height: 200,
                                    child: Center(
                                      child: Icon(Icons.image_not_supported),
                                    ),
                                  ),
                          ),
                        ),
                      ),
                      const Gap(24),

                      // --- Tarih Ayarla Butonu ---
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () => _selectDate(context, ref, not),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: isDark
                                ? const Color(0xFF374151)
                                : Colors.white,
                            foregroundColor: isDark
                                ? Colors.white
                                : Colors.black87,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                              side: isDark
                                  ? BorderSide.none
                                  : BorderSide(color: Colors.grey.shade300),
                            ),
                            elevation: 0,
                          ),
                          icon: Icon(
                            Platform.isIOS
                                ? CupertinoIcons.calendar
                                : Icons.calendar_month,
                            size: 18,
                          ),
                          label: const Text(
                            "Tarih Ayarla",
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ),
                      ),
                      const Gap(30),

                      // --- Önem Derecesi Değiştirme ---
                      Text(
                        "Önem Derecesi",
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                      ),
                      const Gap(12),
                      _buildPrioritySelector(
                        context,
                        ref,
                        not,
                        isDark,
                        primaryBlue,
                      ),

                      const Gap(30),

                      // --- Notlar/Açıklama ---
                      Text(
                        "Notların/Açıklama",
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                      ),
                      const Gap(12),
                      Container(
                        decoration: BoxDecoration(
                          color: isDark
                              ? const Color(0xFF1F2937)
                              : Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isDark
                                ? Colors.transparent
                                : Colors.grey.shade200,
                          ),
                        ),
                        padding: const EdgeInsets.all(16),
                        child: TextField(
                          controller: aciklamaController,
                          maxLines: 4,
                          minLines: 2,
                          style: GoogleFonts.inter(fontSize: 14),
                          decoration: InputDecoration(
                            hintText: "Buraya notlarını ekleyebilirsin...",
                            hintStyle: TextStyle(color: Colors.grey.shade500),
                            border: InputBorder.none,
                            filled: false, // Arka plan gri dolgusunu kapatır

                            focusedBorder: InputBorder
                                .none, // Tıklanınca çıkan çizgiyi siler
                            enabledBorder: InputBorder
                                .none, // Normal durumdaki çizgiyi siler
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 10,
                            ), // Yazıyı hizalamak için
                            // --- İstediğiniz şeffaflık ve boşluk ayarları ---
                          ),
                        ),
                      ),
                      const Gap(16),

                      // Güncelle Butonu
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            _updateAciklama(ref, not, aciklamaController.text);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("Açıklama kaydedildi."),
                              ),
                            );
                            // Klavyeyi kapat
                            FocusScope.of(context).unfocus();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: isDark
                                ? Colors.blue.shade900
                                : lightBlueBg,
                            foregroundColor: isDark
                                ? Colors.white
                                : primaryBlue,
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Platform.isIOS
                                    ? CupertinoIcons.floppy_disk
                                    : Icons.save_as_outlined,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              const Text(
                                "Açıklamayı Kaydet",
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const Gap(40),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  // Yardımcı Widget: Önem Derecesi Çipi
  Widget _buildPriorityChip(BuildContext context, int priority) {
    Color bg;
    Color textC;
    IconData icon;
    String label;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    switch (priority) {
      case 0: // Kritik
        bg = isDark ? const Color(0xFF452020) : const Color(0xFFFFEbee);
        textC = const Color(0xFFE53935);
        icon = Icons.local_fire_department_rounded;
        label = "Kritik";
        break;
      case 1: // Olağan
        bg = isDark ? const Color(0xFF423E20) : const Color(0xFFFFF9C4);
        textC = const Color(0xFFFBC02D);
        icon = Icons.priority_high_rounded;
        label = "Olağan";
        break;
      case 2: // Düşük
        bg = isDark ? const Color(0xFF1B3A24) : const Color(0xFFE8F5E9);
        textC = const Color(0xFF43A047);
        icon = Icons.arrow_downward_rounded;
        label = "Düşük";
        break;
      default:
        bg = Colors.grey;
        textC = Colors.black;
        icon = Icons.help;
        label = "-";
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Icon(icon, size: 16, color: textC),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              color: textC,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
