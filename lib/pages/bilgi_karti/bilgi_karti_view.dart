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
// -------------------------------------------------------------------------
// 1. ADIM: _BilgiFilterControls SINIFINI TAMAMEN BU KOD İLE DEĞİŞTİRİN
// -------------------------------------------------------------------------

class _BilgiFilterControls extends ConsumerWidget {
  const _BilgiFilterControls();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Platform kontrolü
    final isIOS = Platform.isIOS;

    // Tema ve Veriler
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final filterState = ref.watch(bilgiFilterProvider);
    final dersler = ref.watch(dersListProvider);
    final konular = ref.watch(konuListProvider);
    final notifier = ref.read(bilgiFilterProvider.notifier);

    // iOS Tasarımı İçin Dekorasyon (Mevcut kodunuzdan)
    final iosDecoration = BoxDecoration(
      color: isDarkMode ? const Color(0xFF1F2937) : Colors.white,
      borderRadius: BorderRadius.circular(12),
    );

    final iosTextStyle = TextStyle(
      color: isDarkMode ? Colors.white : Colors.black,
      fontSize: 14,
      fontWeight: FontWeight.bold,
    );

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
      child: Column(
        children: [
          // -------------------------------------------------
          // 1. BÖLÜM: DERS VE KONU SEÇİMİ (PLATFORM AYRIMI)
          // -------------------------------------------------
          Row(
            children: [
              // --- DERS SEÇİMİ ---
              Expanded(
                child: isIOS
                    // [iOS KISMI] Orijinal Cupertino Tasarım
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
                          decoration: iosDecoration,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                filterState.ders ?? 'Ders Seç',
                                style: iosTextStyle,
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
                    // [ANDROID KISMI] Yeni Modern Tasarım
                    : _ModernSelectButton(
                        title: filterState.ders ?? 'Ders Seç',
                        hint: 'Ders',
                        icon: Icons.menu_book_rounded,
                        isActive: filterState.ders != null,
                        onTap: () {
                          _showAndroidSelectionSheet(
                            context,
                            title: "Ders Seçiniz",
                            items: dersler,
                            selectedItem: filterState.ders,
                            onSelected: (val) => notifier.setDers(val),
                          );
                        },
                      ),
              ),

              const SizedBox(width: 12),

              // --- KONU SEÇİMİ ---
              Expanded(
                child: isIOS
                    // [iOS KISMI] Orijinal Cupertino Tasarım
                    ? GestureDetector(
                        onTap: () {
                          if (filterState.ders == null) return;
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
                          decoration: iosDecoration,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  filterState.konu ?? 'Konu Seç',
                                  overflow: TextOverflow.ellipsis,
                                  style: iosTextStyle,
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
                    // [ANDROID KISMI] Yeni Modern Tasarım
                    : _ModernSelectButton(
                        title: filterState.konu ?? 'Konu Seç',
                        hint: 'Konu',
                        icon: Icons.category_rounded,
                        isActive: filterState.konu != null,
                        isDisabled: filterState.ders == null,
                        onTap: () {
                          if (filterState.ders == null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: const Text(
                                  "Lütfen önce ders seçiniz.",
                                ),
                              ),
                            );
                            return;
                          }
                          _showAndroidSelectionSheet(
                            context,
                            title: "${filterState.ders} Konuları",
                            items: konular,
                            selectedItem: filterState.konu,
                            onSelected: (val) => notifier.setKonu(val),
                          );
                        },
                      ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // -------------------------------------------------
          // 2. BÖLÜM: ÖNEM DERECESİ FİLTRELERİ (Status Yerine)
          // -------------------------------------------------
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: isIOS
                ? const BouncingScrollPhysics()
                : const ClampingScrollPhysics(),
            child: Row(
              children: [
                _buildFilterItem(
                  context,
                  isIOS: isIOS,
                  label: 'Hepsi',
                  isSelected: filterState.onemDerecesi == null,
                  onPressed: () => notifier.setOnemDerecesi(null),
                ),
                const SizedBox(width: 8),
                _buildFilterItem(
                  context,
                  isIOS: isIOS,
                  label: 'Kritik',
                  isSelected: filterState.onemDerecesi == 0,
                  onPressed: () => notifier.setOnemDerecesi(0),
                  activeColor: const Color(0xFFE53935), // Kırmızı
                ),
                const SizedBox(width: 8),
                _buildFilterItem(
                  context,
                  isIOS: isIOS,
                  label: 'Olağan',
                  isSelected: filterState.onemDerecesi == 1,
                  onPressed: () => notifier.setOnemDerecesi(1),
                  activeColor: Colors.orange, // Turuncu
                ),
                const SizedBox(width: 8),
                _buildFilterItem(
                  context,
                  isIOS: isIOS,
                  label: 'Düşük',
                  isSelected: filterState.onemDerecesi == 2,
                  onPressed: () => notifier.setOnemDerecesi(2),
                  activeColor: const Color(0xFF43A047), // Yeşil
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // YARDIMCI METOT: Platforma göre doğru filtre butonunu seçer
  Widget _buildFilterItem(
    BuildContext context, {
    required bool isIOS,
    required String label,
    required bool isSelected,
    required VoidCallback onPressed,
    Color activeColor = const Color(0xFF0099FF),
  }) {
    if (isIOS) {
      // iOS ise Eski "FilterButton" widget'ını kullan
      return FilterButton(
        label: label,
        isSelected: isSelected,
        onPressed: onPressed,
      );
    } else {
      // Android ise Yeni "ModernFilterChip" widget'ını kullan
      return _ModernFilterChip(
        label: label,
        isSelected: isSelected,
        onPressed: onPressed,
        activeColor: activeColor,
      );
    }
  }

  // YARDIMCI METOT: Sadece Android için Bottom Sheet
  void _showAndroidSelectionSheet(
    BuildContext context, {
    required String title,
    required List<String> items,
    required String? selectedItem,
    required Function(String) onSelected,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      showDragHandle: true,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (ctx) {
        return DraggableScrollableSheet(
          initialChildSize: 0.5,
          minChildSize: 0.3,
          maxChildSize: 0.9,
          expand: false,
          builder: (context, scrollController) {
            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      fontFamily: GoogleFonts.montserrat().fontFamily,
                    ),
                  ),
                ),
                const Divider(height: 1),
                Expanded(
                  child: ListView.builder(
                    controller: scrollController,
                    itemCount: items.length,
                    itemBuilder: (context, index) {
                      final item = items[index];
                      final isSelected = item == selectedItem;
                      final primaryColor = const Color(0xFF0099FF);

                      return Material(
                        color: Colors.transparent,
                        child: ListTile(
                          onTap: () {
                            onSelected(item);
                            Navigator.pop(context);
                          },
                          title: Text(
                            item,
                            style: TextStyle(
                              fontWeight: isSelected
                                  ? FontWeight.w700
                                  : FontWeight.normal,
                              color: isSelected ? primaryColor : null,
                              fontFamily: GoogleFonts.montserrat().fontFamily,
                            ),
                          ),
                          trailing: isSelected
                              ? Icon(
                                  Icons.check_circle_rounded,
                                  color: primaryColor,
                                )
                              : null,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 4,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            );
          },
        );
      },
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
// -------------------------------------------------------------------------
// 2. ADIM: DOSYANIN EN ALTINDA BU 3 SINIF DA BULUNMALIDIR
// (Mevcut FilterButton'ı silip bunları yapıştırın)
// -------------------------------------------------------------------------

// 1. [iOS İçin] Eski Stil Filtre Butonu (Korundu)
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

// 2. [Android İçin] Modern Seçim Butonu
class _ModernSelectButton extends StatelessWidget {
  final String title;
  final String hint;
  final IconData icon;
  final bool isActive;
  final bool isDisabled;
  final VoidCallback onTap;

  const _ModernSelectButton({
    required this.title,
    required this.hint,
    required this.icon,
    required this.onTap,
    this.isActive = false,
    this.isDisabled = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    // Tasarım renkleri
    Color fillColor = isDarkMode
        ? const Color(0xFF1F2937)
        : const Color(0xFFF3F4F6);
    if (isDisabled) {
      fillColor = isDarkMode
          ? const Color(0xFF121212)
          : const Color(0xFFF9FAFB);
    }

    Color contentColor = isDarkMode ? Colors.white : const Color(0xFF111827);
    if (isDisabled) {
      contentColor = isDarkMode ? Colors.grey[700]! : Colors.grey[400]!;
    }

    return InkWell(
      onTap: isDisabled ? null : onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        height: 56,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: fillColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isActive ? const Color(0xFF0099FF) : Colors.transparent,
            width: 1.5,
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isActive
                  ? const Color(0xFF0099FF)
                  : (isDisabled ? contentColor : Colors.grey),
              size: 20,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (isActive)
                    Text(
                      hint,
                      style: TextStyle(
                        fontSize: 10,
                        color: const Color(0xFF0099FF),
                        fontWeight: FontWeight.w600,
                        fontFamily: GoogleFonts.montserrat().fontFamily,
                      ),
                    ),
                  Text(
                    isActive ? title : hint,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: isActive
                          ? contentColor
                          : (isDisabled ? contentColor : Colors.grey[600]),
                      fontSize: isActive ? 14 : 14,
                      fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                      fontFamily: GoogleFonts.montserrat().fontFamily,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.keyboard_arrow_down_rounded,
              color: isDisabled ? contentColor : Colors.grey,
            ),
          ],
        ),
      ),
    );
  }
}

// 3. [Android İçin] Modern Filtre Çipi
class _ModernFilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onPressed;
  final Color activeColor;

  const _ModernFilterChip({
    required this.label,
    required this.isSelected,
    required this.onPressed,
    this.activeColor = const Color(0xFF0099FF),
  });

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(20),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? activeColor.withValues(alpha: 0.15)
              : (isDarkMode
                    ? const Color(0xFF1F2937)
                    : const Color(0xFFF3F4F6)),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? activeColor : Colors.transparent,
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isSelected) ...[
              Icon(Icons.check, size: 16, color: activeColor),
              const SizedBox(width: 6),
            ],
            Text(
              label,
              style: TextStyle(
                color: isSelected
                    ? activeColor
                    : (isDarkMode ? Colors.white70 : Colors.black87),
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                fontSize: 13,
                fontFamily: GoogleFonts.montserrat().fontFamily,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
