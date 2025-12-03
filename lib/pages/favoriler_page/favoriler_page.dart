// ignore_for_file: avoid_print

import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kgsyks_destek/analytics_helper/analytics_helper.dart';
import 'package:kgsyks_destek/go_router/router.dart';
import 'package:kgsyks_destek/pages/favoriler_page/sorular_list_provider.dart';

import 'package:kgsyks_destek/pages/soru_ekle/soru_ekle.dart';
import 'package:kgsyks_destek/pages/soru_ekle/soru_model.dart';
import 'package:kgsyks_destek/sign/save_data.dart';

class FavorilerPage extends ConsumerWidget {
  const FavorilerPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    //final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = const Color(0xFF0099FF);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,

      floatingActionButton: FloatingActionButton(
        backgroundColor: primaryColor,
        shape: const CircleBorder(),
        child: const Icon(Icons.add, color: Colors.white, size: 32),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const SoruEkle()),
          );
        },
      ),
      body: SafeArea(
        child: Column(
          children: [
            _FilterControls(), // Filtre Alanı
            SizedBox(height: 10),
            Expanded(child: _SorularListesi()), // Liste Alanı
          ],
        ),
      ),
    );
  }
}

// FİLTRE KONTROLLERİ WIDGET'I
class _FilterControls extends ConsumerWidget {
  const _FilterControls();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    final filterState = ref.watch(sorularFilterProvider);
    final dersler = ref.watch(dersListProvider);
    final konular = ref.watch(konuListProvider);
    final notifier = ref.read(sorularFilterProvider.notifier);

    // Dekorasyon
    final dropdownDecoration = InputDecoration(
      filled: true,
      fillColor: isDarkMode ? const Color(0xFF1F2937) : Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      hintStyle: TextStyle(
        color: isDarkMode ? Colors.white70 : Colors.grey[600],
        fontSize: 14,
        fontWeight: FontWeight.bold,
      ),
    );

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          // --- Ders ve Konu Filtreleri ---
          Row(
            children: [
              // Ders Dropdown
              Expanded(
                child: Platform.isIOS
                    // --- iOS KISMI (YENİ) ---
                    ? GestureDetector(
                        onTap: () {
                          showCupertinoModalPopup(
                            context: context,
                            builder: (context) => Container(
                              height: 250,
                              color: isDarkMode
                                  ? const Color(0xFF1F2937)
                                  : Colors.white,
                              child: Column(
                                children: [
                                  SizedBox(
                                    height: 180,
                                    child: CupertinoPicker(
                                      itemExtent: 32,
                                      onSelectedItemChanged: (index) {
                                        // toSet().toList() sırası korunur, güvenlidir
                                        final ders = dersler
                                            .toSet()
                                            .toList()[index];
                                        notifier.setDers(ders);
                                      },
                                      children: dersler
                                          .toSet()
                                          .toList()
                                          .map((e) => Text(e))
                                          .toList(),
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
                          padding: const EdgeInsets.symmetric(
                            horizontal: 15,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            color: isDarkMode
                                ? const Color(0xFF1F2937)
                                : Colors.white,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                filterState['ders'] ?? 'Ders Seç',
                                style: dropdownDecoration.hintStyle?.copyWith(
                                  color: isDarkMode
                                      ? Colors.white
                                      : Colors.black,
                                ),
                              ),
                              Icon(
                                Icons.keyboard_arrow_down,
                                color: isDarkMode
                                    ? Colors.white70
                                    : Colors.grey,
                              ),
                            ],
                          ),
                        ),
                      )
                    // --- ANDROID KISMI (ESKİ KODUNUZ) ---
                    : DropdownButtonFormField<String>(
                        initialValue: filterState['ders'],
                        hint: Text(
                          'Ders Seç',
                          style: dropdownDecoration.hintStyle,
                          maxLines: 1, // EKLENDİ
                          overflow: TextOverflow.ellipsis, // EKLENDİ
                        ),
                        isExpanded: true,
                        // ... (Geri kalan Android kodunuz buraya) ...
                        items: dersler.toSet().toList().map((ders) {
                          return DropdownMenuItem(
                            value: ders,
                            child: Text(
                              ders,
                              maxLines: 1, // EKLENDİ
                              overflow: TextOverflow.ellipsis, // EKLENDİ),
                            ),
                          );
                        }).toList(),
                        onChanged: (value) => notifier.setDers(value),
                      ),
              ),
              const SizedBox(width: 16),
              // Konu Dropdown
              Expanded(
                child: Platform.isIOS
                    // --- iOS KISMI (YENİ) ---
                    ? GestureDetector(
                        onTap: () {
                          if (filterState['ders'] == null) return;
                          showCupertinoModalPopup(
                            context: context,
                            builder: (context) => Container(
                              height: 250,
                              color: isDarkMode
                                  ? const Color(0xFF1F2937)
                                  : Colors.white,
                              child: Column(
                                children: [
                                  SizedBox(
                                    height: 180,
                                    child: CupertinoPicker(
                                      itemExtent: 32,
                                      onSelectedItemChanged: (index) {
                                        final konu = konular
                                            .toSet()
                                            .toList()[index];
                                        notifier.setKonu(konu);
                                      },
                                      children: konular
                                          .toSet()
                                          .toList()
                                          .map((e) => Text(e))
                                          .toList(),
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
                          padding: const EdgeInsets.symmetric(
                            horizontal: 15,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            color: isDarkMode
                                ? const Color(0xFF1F2937)
                                : Colors.white,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  filterState['konu'] ?? 'Konu Seç',
                                  overflow: TextOverflow.ellipsis,
                                  style: dropdownDecoration.hintStyle?.copyWith(
                                    color: isDarkMode
                                        ? Colors.white
                                        : Colors.black,
                                  ),
                                ),
                              ),
                              Icon(
                                Icons.keyboard_arrow_down,
                                color: isDarkMode
                                    ? Colors.white70
                                    : Colors.grey,
                              ),
                            ],
                          ),
                        ),
                      )
                    // --- ANDROID KISMI (ESKİ KODUNUZ) ---
                    : DropdownButtonFormField<String>(
                        initialValue: filterState['konu'],
                        isExpanded: true,
                        hint: Text(
                          'Konu Seç',
                          maxLines: 1, // EKLENDİ
                          overflow: TextOverflow.ellipsis, // EKLENDİ
                          style: dropdownDecoration.hintStyle,
                        ),
                        // ... (Geri kalan Android kodunuz buraya) ...
                        items: (filterState['ders'] != null)
                            ? konular.toSet().toList().map((konu) {
                                return DropdownMenuItem(
                                  value: konu,
                                  child: Text(
                                    konu,
                                    maxLines: 1, // EKLENDİ
                                    overflow: TextOverflow.ellipsis, // EKLENDİ
                                  ),
                                );
                              }).toList()
                            : [],
                        onChanged: (value) => notifier.setKonu(value),
                      ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // --- Durum Filtreleri ---
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: Platform.isIOS ? const BouncingScrollPhysics() : null,
            child: Row(
              children: [
                FilterButton(
                  label: 'Hepsi',
                  isSelected: filterState['durum'] == DurumFiltresi.hepsi,
                  onPressed: () => notifier.setDurum(DurumFiltresi.hepsi),
                ),
                const SizedBox(width: 10),
                FilterButton(
                  label: 'Yanlışlarım',
                  isSelected: filterState['durum'] == DurumFiltresi.yanlislarim,
                  onPressed: () => notifier.setDurum(DurumFiltresi.yanlislarim),
                ),
                const SizedBox(width: 10),
                FilterButton(
                  label: 'Boşlarım',
                  isSelected: filterState['durum'] == DurumFiltresi.boslarim,
                  onPressed: () => notifier.setDurum(DurumFiltresi.boslarim),
                ),
                const SizedBox(width: 10),
                FilterButton(
                  label: 'Öğrenildi',
                  isSelected:
                      filterState['durum'] == DurumFiltresi.tamamladiklarim,
                  onPressed: () =>
                      notifier.setDurum(DurumFiltresi.tamamladiklarim),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// SORU LİSTESİ WIDGET'I
class _SorularListesi extends ConsumerWidget {
  const _SorularListesi();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final allSorularAsync = ref.watch(allSorularProvider);
    final filteredSorular = ref.watch(filteredSorularProvider);

    return allSorularAsync.when(
      loading: () => Center(
        child: Platform.isIOS
            ? const CupertinoActivityIndicator()
            : const CircularProgressIndicator(),
      ),
      error: (err, stack) => Center(child: Text('Hata: $err')),
      data: (_) {
        if (filteredSorular.isEmpty) {
          return Center(
            child: Text(
              'Bu filtrede gösterilecek soru bulunamadı.',
              style: TextStyle(color: Theme.of(context).hintColor),
            ),
          );
        }
        return ListView.builder(
          padding: const EdgeInsets.only(bottom: 80),
          itemCount: filteredSorular.length,
          physics: Platform.isIOS
              ? const BouncingScrollPhysics()
              : const ClampingScrollPhysics(),
          itemBuilder: (context, index) {
            final soru = filteredSorular[index];
            return _SoruCard(soru: soru);
          },
        );
      },
    );
  }
}

// TEK BİR SORU KARTI WIDGET'I
class _SoruCard extends StatelessWidget {
  final SoruModel soru;
  _SoruCard({required this.soru});
  final UserAuth auther = UserAuth();

  Widget _buildStatusChip(BuildContext context, String durum) {
    Color bgColor;
    Color textColor;
    IconData? icon;
    String text = durum;

    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (durum.contains('Yanlış') || durum == 'Yanlış İşaretleme') {
      bgColor = isDark ? const Color(0xFF452020) : const Color(0xFFFFEbee);
      textColor = const Color(0xFFE53935);
      icon = Icons.close;
      text = "Yanlış";
    } else if (durum.contains('Boş') || durum == 'Beklemede') {
      bgColor = isDark ? const Color(0xFF2D333B) : const Color(0xFFF5F5F5);
      textColor = isDark ? Colors.grey[400]! : Colors.grey[700]!;
      icon = Icons.remove;
      text = "Çözülmedi";
    } else if (durum == 'Öğrenildi' || durum.contains('Öğrenildi')) {
      bgColor = isDark ? const Color(0xFF1B3A24) : const Color(0xFFE8F5E9);
      textColor = const Color(0xFF43A047);
      icon = Icons.check_circle;
      text = "Öğrenildi";
    } else {
      bgColor = isDark ? const Color(0xFF423E20) : const Color(0xFFFFF9C4);
      textColor = const Color(0xFFFBC02D);
      icon = Icons.refresh;
      text = "Tekrar Edilecek";
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          ...[Icon(icon, size: 14, color: textColor), const SizedBox(width: 6)],
          Text(
            text,
            style: TextStyle(
              color: textColor,
              fontSize: 12,
              fontWeight: FontWeight.bold,
              fontFamily: GoogleFonts.montserrat().fontFamily,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDarkMode ? const Color(0xFF191919) : Colors.white;
    final textColor = isDarkMode ? Colors.white : const Color(0xFF1C1E21);
    final subTextColor = isDarkMode ? Colors.grey[400] : Colors.grey[600];

    return GestureDetector(
      onTap: () async {
        final result = await Connectivity().checkConnectivity();
        final online = result.any((r) => r != ConnectivityResult.none);
        if (online) {
          await auther.soruSayiArtir("soruAcmaSayisi");
          AnalyticsService().trackCount("soru_acma", "favoriler_page");
        }
        final ctx = context;
        if (!ctx.mounted) return;
        context.pushNamed(
          AppRoute.soruViewer.name,
          pathParameters: {"id": soru.id.toString()},
        );
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(20),
          boxShadow: isDarkMode
              ? []
              : [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
          border: isDarkMode ? Border.all(color: Colors.white12) : null,
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: SizedBox(
                  width: 80,
                  height: 80,
                  child: Image.file(
                    File(soru.imagePath),
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: isDarkMode ? Colors.grey[800] : Colors.grey[200],
                        child: Icon(Icons.image, color: subTextColor),
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(width: 16),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "${soru.ders} - ${soru.konu}",
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: textColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        fontFamily: GoogleFonts.montserrat().fontFamily,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      soru.aciklama != null && soru.aciklama!.length > 2
                          ? soru.aciklama!
                          : "Açıklama girilmemiş...",
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: subTextColor,
                        fontSize: 13,
                        fontFamily: GoogleFonts.montserrat().fontFamily,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildStatusChip(context, soru.durum),
                  ],
                ),
              ),

              Padding(
                padding: const EdgeInsets.only(top: 30, left: 5),
                child: Icon(Icons.chevron_right, color: subTextColor, size: 20),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class FilterButton extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onPressed;

  const FilterButton({
    super.key,
    required this.label,
    required this.isSelected,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final activeColor = const Color(0xFF0099FF);
    final inactiveBg = isDarkMode ? const Color(0xFF1F2937) : Colors.white;
    final inactiveText = isDarkMode ? Colors.white70 : const Color(0xFF1C1E21);

    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? activeColor : inactiveBg,
          borderRadius: BorderRadius.circular(25),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : inactiveText,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
            fontFamily: GoogleFonts.montserrat().fontFamily,
            fontSize: 14,
          ),
        ),
      ),
    );
  }
}
