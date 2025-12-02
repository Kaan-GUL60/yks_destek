// ignore_for_file: avoid_print

import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kgsyks_destek/pages/bilgi_karti/bilgi_karti_ekle.dart';
// Projenin dosya yollarına göre bunları düzenle:
import 'package:kgsyks_destek/pages/bilgi_karti/bilgi_list_provider.dart';
import 'package:kgsyks_destek/pages/bilgi_karti/bilgi_notu_model.dart';
import 'package:kgsyks_destek/pages/bilgi_karti/bilgi_notu_viewer.dart';
import 'package:kgsyks_destek/pages/favoriler_page/sorular_list_provider.dart'; // Ders/Konu listesi için

class BilgiKartlariPage extends ConsumerWidget {
  const BilgiKartlariPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final primaryColor = const Color(0xFF0099FF);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      // Yeni Bilgi Notu Ekleme Butonu
      floatingActionButton: FloatingActionButton(
        backgroundColor: primaryColor,
        shape: const CircleBorder(),
        child: const Icon(Icons.add, color: Colors.white, size: 32),
        onPressed: () async {
          // Bilgi Notu Ekleme Sayfasına Git
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const BilgiNotuEklePage()),
          );
          if (context.mounted) {
            ref.invalidate(allBilgiNotlariProvider);
          }
        },
      ),
      body: SafeArea(
        child: const Column(
          children: [
            _BilgiFilterControls(), // Filtre Alanı (Özelleştirilmiş)
            SizedBox(height: 10),
            Expanded(child: _BilgiNotlariListesi()), // Liste Alanı
          ],
        ),
      ),
    );
  }
}

// --- FİLTRE KONTROLLERİ ---
class _BilgiFilterControls extends ConsumerWidget {
  const _BilgiFilterControls();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    // YENİ PROVIDERLARI KULLANIYORUZ
    final filterState = ref.watch(bilgiFilterProvider);
    final notifier = ref.read(bilgiFilterProvider.notifier);

    // Ders ve Konu listeleri ortak olduğu için eskileri kullanabiliriz
    final dersler = ref.watch(dersListProvider);
    final konular = ref.watch(konuListProvider);

    final dropdownDecoration = InputDecoration(
      filled: true,
      fillColor: isDarkMode ? const Color(0xFF1F2937) : Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
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
              Expanded(
                child: Platform.isIOS
                    // --- iOS KISMI (YENİ EKLENDİ) ---
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
                                        notifier.setDers(
                                          dersler.toSet().toList()[index],
                                        );
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
                                filterState.ders ?? 'Ders Seç',
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
                    // --- ANDROID KISMI (AYNEN KORUNDU) ---
                    : DropdownButtonFormField<String>(
                        key: ValueKey(filterState.ders ?? 'ders-reset'),
                        initialValue: filterState.ders,
                        hint: Text(
                          'Ders Seç',
                          style: dropdownDecoration.hintStyle,
                        ),
                        isExpanded: true,
                        icon: Icon(
                          Icons.keyboard_arrow_down,
                          color: isDarkMode ? Colors.white70 : Colors.grey,
                        ),
                        dropdownColor: isDarkMode
                            ? const Color(0xFF1F2937)
                            : Colors.white,
                        style: TextStyle(
                          color: isDarkMode ? Colors.white : Colors.black,
                          fontWeight: FontWeight.w600,
                          fontFamily: GoogleFonts.montserrat().fontFamily,
                        ),
                        decoration: dropdownDecoration,
                        items: dersler.toSet().toList().map((ders) {
                          return DropdownMenuItem(
                            value: ders,
                            child: Text(ders),
                          );
                        }).toList(),
                        onChanged: (value) => notifier.setDers(value),
                      ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Platform.isIOS
                    // --- iOS KISMI (YENİ EKLENDİ) ---
                    ? GestureDetector(
                        onTap: () {
                          if (filterState.ders == null) {
                            return;
                          } // Ders seçilmediyse açma
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
                                        notifier.setKonu(
                                          konular.toSet().toList()[index],
                                        );
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
                                // Taşmayı önlemek için
                                child: Text(
                                  filterState.konu ?? 'Konu Seç',
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
                    // --- ANDROID KISMI (AYNEN KORUNDU) ---
                    : DropdownButtonFormField<String>(
                        key: ValueKey(filterState.konu ?? 'konu-reset'),
                        initialValue: filterState.konu,
                        hint: Text(
                          'Konu Seç',
                          style: dropdownDecoration.hintStyle,
                        ),
                        isExpanded: true,
                        icon: Icon(
                          Icons.keyboard_arrow_down,
                          color: isDarkMode ? Colors.white70 : Colors.grey,
                        ),
                        dropdownColor: isDarkMode
                            ? const Color(0xFF1F2937)
                            : Colors.white,
                        style: TextStyle(
                          color: isDarkMode ? Colors.white : Colors.black,
                          fontWeight: FontWeight.w600,
                          fontFamily: GoogleFonts.montserrat().fontFamily,
                        ),
                        decoration: dropdownDecoration,
                        items: (filterState.ders != null)
                            ? konular.toSet().toList().map((konu) {
                                return DropdownMenuItem(
                                  value: konu,
                                  child: Text(konu),
                                );
                              }).toList()
                            : [],
                        onChanged: (value) => notifier.setKonu(value),
                      ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // --- ÖNEM DERECESİ FİLTRELERİ (Status yerine) ---
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                FilterButton(
                  label: 'Hepsi',
                  isSelected: filterState.onemDerecesi == null,
                  onPressed: () => notifier.setOnemDerecesi(null),
                ),
                const SizedBox(width: 10),
                FilterButton(
                  label: 'Kritik',
                  isSelected: filterState.onemDerecesi == 0,
                  onPressed: () => notifier.setOnemDerecesi(0),
                ),
                const SizedBox(width: 10),
                FilterButton(
                  label: 'Olağan',
                  isSelected: filterState.onemDerecesi == 1,
                  onPressed: () => notifier.setOnemDerecesi(1),
                ),
                const SizedBox(width: 10),
                FilterButton(
                  label: 'Düşük',
                  isSelected: filterState.onemDerecesi == 2,
                  onPressed: () => notifier.setOnemDerecesi(2),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// --- BİLGİ NOTU LİSTESİ ---
class _BilgiNotlariListesi extends ConsumerWidget {
  const _BilgiNotlariListesi();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // YENİ PROVIDERLARI DİNLİYORUZ
    final allNotesAsync = ref.watch(allBilgiNotlariProvider);
    final filteredNotes = ref.watch(filteredBilgiNotlariProvider);

    return allNotesAsync.when(
      loading: () => Center(
        child: Platform.isIOS
            ? const CupertinoActivityIndicator()
            : const CircularProgressIndicator(),
      ),
      error: (err, stack) => Center(child: Text('Hata: $err')),
      data: (_) {
        if (filteredNotes.isEmpty) {
          return Center(
            child: Text(
              'Bu filtrede gösterilecek not bulunamadı.',
              style: TextStyle(color: Theme.of(context).hintColor),
            ),
          );
        }
        return ListView.builder(
          padding: const EdgeInsets.only(bottom: 80),
          itemCount: filteredNotes.length,
          physics: Platform.isIOS
              ? const BouncingScrollPhysics()
              : const ClampingScrollPhysics(),
          itemBuilder: (context, index) {
            final not = filteredNotes[index];
            return _BilgiNotuCard(not: not);
          },
        );
      },
    );
  }
}

// --- TEK BİR BİLGİ KARTI ---
// DÜZELTME: StatelessWidget -> ConsumerWidget
class _BilgiNotuCard extends ConsumerWidget {
  final BilgiNotuModel not;
  const _BilgiNotuCard({required this.not});

  // --- ÖNEM DERECESİ CHIP YAPISI ---
  Widget _buildPriorityChip(BuildContext context, int onemDerecesi) {
    Color bgColor;
    Color textColor;
    IconData icon;
    String text;

    final isDark = Theme.of(context).brightness == Brightness.dark;

    // 0: Kritik, 1: Olağan, 2: Düşük
    switch (onemDerecesi) {
      case 0: // Kritik
        bgColor = isDark ? const Color(0xFF452020) : const Color(0xFFFFEbee);
        textColor = const Color(0xFFE53935);
        icon = Icons.local_fire_department_rounded;
        text = "Kritik";
        break;
      case 1: // Olağan
        bgColor = isDark ? const Color(0xFF423E20) : const Color(0xFFFFF9C4);
        textColor = const Color(0xFFFBC02D); // Koyu sarı/turuncu
        icon = Icons.priority_high_rounded;
        text = "Olağan";
        break;
      case 2: // Düşük
        bgColor = isDark ? const Color(0xFF1B3A24) : const Color(0xFFE8F5E9);
        textColor = const Color(0xFF43A047);
        icon = Icons.arrow_downward_rounded;
        text = "Düşük";
        break;
      default:
        bgColor = Colors.grey;
        textColor = Colors.black;
        icon = Icons.help;
        text = "-";
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
          Icon(icon, size: 16, color: textColor),
          const SizedBox(width: 6),
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
  // DÜZELTME: WidgetRef ref parametresi eklendi
  Widget build(BuildContext context, WidgetRef ref) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDarkMode ? const Color(0xFF191919) : Colors.white;
    final textColor = isDarkMode ? Colors.white : const Color(0xFF1C1E21);
    final subTextColor = isDarkMode ? Colors.grey[400] : Colors.grey[600];

    return GestureDetector(
      onTap: () async {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => BilgiNotuViewer(notId: not.id!)),
        );
        if (context.mounted) {
          ref.invalidate(allBilgiNotlariProvider);
        }
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
              // RESİM ALANI
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: SizedBox(
                  width: 80,
                  height: 80,
                  child: Image.file(
                    File(not.imagePath),
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

              // BİLGİLER ALANI
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "${not.ders} - ${not.konu}",
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
                      not.aciklama.length > 2
                          ? not.aciklama
                          : "Açıklama yok...",
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: subTextColor,
                        fontSize: 13,
                        fontFamily: GoogleFonts.montserrat().fontFamily,
                      ),
                    ),
                    const SizedBox(height: 12),
                    // YENİ CHIP WIDGET'I
                    _buildPriorityChip(context, not.onemDerecesi),
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

// BU BUTON AYNI KALIYOR (Görünüm amaçlı olduğu için)
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
