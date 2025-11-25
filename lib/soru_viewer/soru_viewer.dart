// ignore_for_file: use_build_context_synchronously

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kgsyks_destek/ana_ekran/home_state.dart';
import 'package:kgsyks_destek/cloud_message/services.dart';
import 'package:kgsyks_destek/go_router/router.dart';
import 'package:kgsyks_destek/pages/soru_ekle/database_helper.dart';
import 'package:kgsyks_destek/pages/soru_ekle/soru_model.dart';
import 'package:kgsyks_destek/soru_viewer/drawing_page.dart';
import 'package:kgsyks_destek/soru_viewer/soru_view_provider.dart';

class SoruViewer extends ConsumerWidget {
  final int soruId;

  SoruViewer({super.key, required this.soruId});
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  Future<void> _updateSoruDurum(
    WidgetRef ref,
    int id,
    String durum,
    String yeniHataNedeni,
  ) async {
    await _dbHelper.updateSoruDurum(id, durum, yeniHataNedeni);
    ref.invalidate(soruProvider(id));
  }

  // Açıklamayı güncelleme
  Future<void> _updateAciklama(
    WidgetRef ref,
    int id,
    String yeniAciklama,
  ) async {
    await _dbHelper.updateSoruAciklama(id, yeniAciklama);
    ref.invalidate(soruProvider(id));
  }

  // Hatırlatıcı tarihi güncelleme (DateTime tipini kabul ediyor)
  Future<void> _updateHatirlaticiTarih(
    WidgetRef ref,
    int id,
    DateTime? tarih,
  ) async {
    final SoruModel? soru = ref.read(soruProvider(id)).value;

    // 2. Bir güvenlik kontrolü ekleyelim.
    // Bu kod 'data' bloğundan çağrıldığı için 'soru' null olmamalı, ama kontrol iyidir.
    if (soru == null) {
      debugPrint("Hata: Soru verisi okunamadı. Bildirim planlanamıyor.");
      return; // Soru yoksa işlemi durdur
    }
    // 1️⃣ Tarihi veritabanına kaydet
    await _dbHelper.updateSoruHatirlaticiTarihi(id, tarih);
    ref.invalidate(soruProvider(id));

    if (tarih != null) {
      final now = DateTime.now();

      // 2️⃣ 12:00 ve 15:00 için planla
      final DateTime saat12 = DateTime(
        tarih.year,
        tarih.month,
        tarih.day,
        12,
        0,
      );
      final DateTime saat15 = DateTime(
        tarih.year,
        tarih.month,
        tarih.day,
        17,
        0,
      );
      final String bildirimBasligi = '${soru.ders} Hatırlatması ⏰';
      final String bildirimGovdesi =
          '${soru.konu} konusundaki soruyu tekrar etme zamanı!';

      if (saat12.isAfter(now)) {
        await scheduleLocalNotification(
          notificationId: id * 10 + 1, // 1. Hesaplanan ID
          soruId: id, // 2. Gerçek Soru ID
          title: bildirimBasligi,
          body: '$bildirimGovdesi 🎯',
          scheduledTime: saat12,
          imagePath: soru.imagePath,
        );
      }

      // 🎯 SAAT 15 ÇAĞRISI GÜNCELLENDİ
      if (saat15.isAfter(now)) {
        await scheduleLocalNotification(
          notificationId: id * 10 + 2, // 1. Hesaplanan ID
          soruId: id, // 2. Gerçek Soru ID
          title: bildirimBasligi,
          body: '$bildirimGovdesi 🎯',
          scheduledTime: saat15,
          imagePath: soru.imagePath,
        );
      }
    }
  }

  // Tarih seçiciyi açar
  Future<void> _selectDate(BuildContext context, WidgetRef ref, int id) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      await _updateHatirlaticiTarih(ref, id, picked);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Hatırlatıcı tarihi ${picked.day}.${picked.month}.${picked.year} olarak güncellendi!',
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final soruAsyncValue = ref.watch(soruProvider(soruId));
    final aciklamaController = ref.watch(aciklamaControllerProvider);

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final Color primaryBlue = const Color(0xFF1A56DB); // Tasarımdaki mavi
    final Color lightBlueBg = const Color(
      0xFFE0E7FF,
    ); // Açık mavi buton arka planı

    return Scaffold(
      appBar: AppBar(
        title: const Text("Soru Detayları"),
        leading: BackButton(
          onPressed: () {
            // Cihazın 'geri' tuşuna basıp basamayacağını kontrol et
            if (Navigator.canPop(context)) {
              // EĞER BİR ÖNCEKİ SAYFA VARSA (örn: Soru Listesinden geldiniz):
              // Sadece normal 'geri' işlemini yap.
              Navigator.pop(context);
            } else {
              // EĞER BİLDİRİMDEN GELDİYSENİZ (yığındaki ilk sayfa):
              // 'anaekran'a (soru listenizin olduğu sayfaya) yönlendir.
              router.goNamed(AppRoute.anaekran.name);
            }
          },
        ),
      ),
      body: soruAsyncValue.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Bir hata oluştu: $error')),

        data: (soru) {
          if (soru == null) {
            return const Center(child: Text("Soru bulunamadı."));
          }

          if (aciklamaController.text.isEmpty && soru.aciklama != null) {
            aciklamaController.text = soru.aciklama!;
            debugPrint('Açıklama yüklendi: ${soru.aciklama}');
          }

          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    soru.ders,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: primaryBlue,
                    ),
                  ),
                  const Gap(4),
                  Text(
                    soru.konu,
                    style: GoogleFonts.inter(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : Colors.black,
                    ),
                  ),
                  const Gap(16),
                  // --- Bilgi Çipleri (Öğrenilecek / Tarih) ---
                  Builder(
                    builder: (context) {
                      // --- Senin Verdiğin Renk/İkon Mantığı ---
                      Color statusBgColor;
                      Color statusTextColor;
                      IconData statusIcon;
                      String statusText;

                      // 'durum' değişkeni yerine 'soru.durum' kullanıyoruz
                      if (soru.durum.contains('Yanlış') ||
                          soru.durum == 'Yanlış İşaretleme') {
                        statusBgColor = isDark
                            ? const Color(0xFF452020)
                            : const Color(0xFFFFEbee);
                        statusTextColor = const Color(0xFFE53935);
                        statusIcon = Icons.close;
                        statusText = "Yanlış";
                      } else if (soru.durum.contains('Boş') ||
                          soru.durum == 'Beklemede') {
                        statusBgColor = isDark
                            ? const Color(0xFF2D333B)
                            : const Color(0xFFF5F5F5);
                        statusTextColor = isDark
                            ? Colors.grey[400]!
                            : Colors.grey[700]!;
                        statusIcon = Icons.remove;
                        statusText = "Çözülmedi";
                      } else if (soru.durum == 'Öğrenildi' ||
                          soru.durum.contains('Öğrenildi')) {
                        statusBgColor = isDark
                            ? const Color(0xFF1B3A24)
                            : const Color(0xFFE8F5E9);
                        statusTextColor = const Color(0xFF43A047);
                        statusIcon = Icons.check_circle;
                        statusText = "Öğrenildi";
                      } else {
                        statusBgColor = isDark
                            ? const Color(0xFF423E20)
                            : const Color(0xFFFFF9C4);
                        statusTextColor = const Color(0xFFFBC02D);
                        statusIcon = Icons.refresh;
                        statusText = "Tekrar Edilecek";
                      }

                      return Row(
                        children: [
                          // Dinamik Durum Çipi
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: statusBgColor,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  statusIcon,
                                  size: 16,
                                  color: statusTextColor,
                                ),
                                const Gap(6),
                                Text(
                                  statusText,
                                  style: TextStyle(
                                    color: statusTextColor,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Gap(12),

                          // Tarih Çipi (Burası değişmedi, sadece yanına eklendi)
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
                                  soru.hatirlaticiTarihi != null
                                      ? "${soru.hatirlaticiTarihi!.day} ${['Ocak', 'Şubat', 'Mart', 'Nisan', 'Mayıs', 'Haziran', 'Temmuz', 'Ağustos', 'Eylül', 'Ekim', 'Kasım', 'Aralık'][soru.hatirlaticiTarihi!.month - 1]} ${soru.hatirlaticiTarihi!.year}"
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
                      );
                    },
                  ),

                  const Gap(24),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(
                      16,
                    ), // Resim etrafında padding
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
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Görselin kendisi
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: soru.imagePath.isNotEmpty
                              ? Image.file(
                                  File(soru.imagePath),
                                  height: 250,
                                  width: double.infinity,
                                  fit: BoxFit.cover,
                                )
                              : Container(
                                  height: 200,
                                  width: double.infinity,
                                  color: Colors.grey[200],
                                  child: const Center(
                                    child: Icon(Icons.image_not_supported),
                                  ),
                                ),
                        ),
                      ],
                    ),
                  ),
                  const Gap(24),

                  // --- Butonlar (Soruyu Çöz / Tarih Ayarla) ---
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    DrawingPage(imagePath: soru.imagePath),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryBlue,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 0,
                          ),
                          icon: const Icon(Icons.edit, size: 18),
                          label: const Text(
                            "Soruyu Çöz",
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ),
                      ),
                      const Gap(12),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => _selectDate(context, ref, soru.id!),
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
                          icon: const Icon(Icons.calendar_month, size: 18),
                          label: const Text(
                            "Tarih Ayarla",
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const Gap(30),
                  // --- Cevabınız Kısmı (Orijinal Mantık Korundu) ---
                  Text(
                    "Cevabınız",
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                  const Gap(12),
                  // DÜZELTME: Senin yazdığın SegmentedButton mantığı burada aynen duruyor.
                  // Sadece 'style' kısmını görsele benzetmek için güncelledim.
                  SizedBox(
                    width: double.infinity,

                    child: SegmentedButton<OptionSoruCevabi>(
                      emptySelectionAllowed: true,
                      segments: OptionSoruCevabi.values.map((e) {
                        return ButtonSegment<OptionSoruCevabi>(
                          value: e,
                          label: Text(
                            e.name,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        );
                      }).toList(),
                      selected: {
                        ref.watch(soruCevabiProvider),
                      }.whereType<OptionSoruCevabi>().toSet(),
                      onSelectionChanged: (newSelection) {
                        // --- BURASI SENİN ORİJİNAL KODUN ---
                        // Kullanıcı seçim yaptığında çalışacak, doğru/yanlış kontrolü yapacak.
                        final selectedCevap = newSelection.first;

                        if (ref.read(soruCevabiProvider) == null) {
                          ref.read(soruCevabiProvider.notifier).state =
                              selectedCevap;

                          // --- DURUM GÜNCELLEME MANTIĞI ---
                          if (soru.soruCevap == selectedCevap.name) {
                            // DOĞRU CEVAP
                            _updateSoruDurum(ref, soru.id!, 'Öğrenildi', '');
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  "Doğru cevap! Soru durumu 'Öğrenildi' olarak güncellendi.",
                                ),
                                backgroundColor: Colors.green,
                              ),
                            );
                          } else {
                            // YANLIŞ CEVAP
                            final hataNedeni =
                                "Seçim: ${selectedCevap.name}, Doğru: ${soru.soruCevap}";
                            _updateSoruDurum(
                              ref,
                              soru.id!,
                              'Öğrenilecek',
                              hataNedeni,
                            );
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  "Yanlış cevap! Doğru cevap: ${soru.soruCevap}. Durum 'Öğrenilecek' olarak güncellendi.",
                                ),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        }
                      },
                      // Tasarım iyileştirmeleri (Mantığı etkilemez)
                      showSelectedIcon: false,
                      style: ButtonStyle(
                        padding: const WidgetStatePropertyAll(
                          EdgeInsets.symmetric(vertical: 12),
                        ),
                        backgroundColor: WidgetStateProperty.resolveWith((
                          states,
                        ) {
                          if (states.contains(WidgetState.selected)) {
                            return primaryBlue; // Seçiliyse mavi
                          }
                          return isDark
                              ? const Color(0xFF374151)
                              : Colors.transparent;
                        }),
                        foregroundColor: WidgetStateProperty.resolveWith((
                          states,
                        ) {
                          if (states.contains(WidgetState.selected)) {
                            return Colors.white; // Seçili yazı beyaz
                          }
                          return isDark ? Colors.white : Colors.black54;
                        }),
                        side: WidgetStateProperty.all(
                          BorderSide(
                            color: isDark
                                ? Colors.transparent
                                : Colors.grey.shade300,
                          ),
                        ),
                        shape: WidgetStateProperty.all(
                          RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                  ),

                  const Gap(30),
                  // --- Kendi Notların ---
                  Text(
                    "Kendi Notların/Açıklama",
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                  const Gap(12),

                  Container(
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF1F2937) : Colors.white,
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
                      decoration: InputDecoration.collapsed(
                        hintText:
                            "Sorunun çözümüne dair kendi notlarını buraya yaz...",
                        hintStyle: TextStyle(color: Colors.grey.shade500),
                      ),
                    ),
                  ),
                  const Gap(16),

                  // --- Açıklamayı Güncelle Butonu ---
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () async {
                        _updateAciklama(ref, soru.id!, aciklamaController.text);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("Açıklama başarıyla güncellendi."),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isDark
                            ? Colors.blue.shade900
                            : lightBlueBg,
                        foregroundColor: isDark ? Colors.white : primaryBlue,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Icon(Icons.refresh_rounded, size: 20),
                          SizedBox(width: 8),
                          Text(
                            "Açıklamayı Güncelle",
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
    );
  }
}
