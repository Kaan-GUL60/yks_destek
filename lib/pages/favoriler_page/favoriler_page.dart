// ignore_for_file: avoid_print

import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
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

// Yardımcı fonksiyon (Page class'ı dışında veya içinde static)
Future<void> _performSync(WidgetRef ref, int count) async {
  final user = FirebaseAuth.instance.currentUser;
  if (user != null) {
    try {
      await FirebaseFirestore.instance.collection("users").doc(user.uid).update(
        {"stats.toplamSoruSayisi": count},
      ); // Nokta notasyonu daha güvenli

      // Senkronize edilen son sayıyı kaydet
      ref.read(lastSyncedProvider.notifier).state = count;
    } catch (e) {
      // stats alanı yoksa set ile oluştur (merge: true)
      await FirebaseFirestore.instance.collection("users").doc(user.uid).set({
        "stats": {"toplamSoruSayisi": count},
      }, SetOptions(merge: true));
      ref.read(lastSyncedProvider.notifier).state = count;
    }
  }
}

class FavorilerPage extends ConsumerWidget {
  const FavorilerPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    //final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = const Color(0xFF0099FF);
    ref.listen(filteredSorularProvider, (previous, next) {
      // Sadece veri (data) durumundayken işlem yap
      final count =
          next.length; // Listeyi sağlayan provider'ın tipine göre güncelleyin
      final lastSynced = ref.read(lastSyncedProvider);

      // Sayı değişmişse ve veri null değilse senkronize et
      if (count != lastSynced) {
        _performSync(ref, count);
      }
    });

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
// -------------------------------------------------------------------------
// 1. ADIM BAŞLANGICI: _FilterControls SINIFINI BURADAN İTİBAREN DEĞİŞTİRİN
// -------------------------------------------------------------------------
class _FilterControls extends ConsumerWidget {
  const _FilterControls();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Platform kontrolü için
    final isIOS = Platform.isIOS;

    // Tema ve Veriler
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final filterState = ref.watch(sorularFilterProvider);
    final dersler = ref.watch(dersListProvider);
    final konular = ref.watch(konuListProvider);
    final notifier = ref.read(sorularFilterProvider.notifier);

    // iOS Tasarımı İçin Dekorasyon (Eski kodunuzdan)
    final iosDecoration = BoxDecoration(
      color: isDarkMode ? const Color(0xFF1F2937) : Colors.white,
      borderRadius: BorderRadius.circular(12),
    );

    // iOS Metin Stili
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
                    // [iOS KISMI] Orijinal Cupertino Tasarımınız
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
                                filterState['ders'] ?? 'Ders Seç',
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
                        title: filterState['ders'] ?? 'Ders Seç',
                        hint: 'Ders',
                        icon: Icons.menu_book_rounded,
                        isActive: filterState['ders'] != null,
                        onTap: () {
                          _showAndroidSelectionSheet(
                            context,
                            title: "Ders Seçiniz",
                            items: dersler,
                            selectedItem: filterState['ders'],
                            onSelected: (val) => notifier.setDers(val),
                          );
                        },
                      ),
              ),

              const SizedBox(width: 12),

              // --- KONU SEÇİMİ ---
              Expanded(
                child: isIOS
                    // [iOS KISMI] Orijinal Cupertino Tasarımınız
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
                          decoration: iosDecoration,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  filterState['konu'] ?? 'Konu Seç',
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
                        title: filterState['konu'] ?? 'Konu Seç',
                        hint: 'Konu',
                        icon: Icons.category_rounded,
                        isActive: filterState['konu'] != null,
                        isDisabled: filterState['ders'] == null,
                        onTap: () {
                          if (filterState['ders'] == null) {
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
                            title: "${filterState['ders']} Konuları",
                            items: konular,
                            selectedItem: filterState['konu'],
                            onSelected: (val) => notifier.setKonu(val),
                          );
                        },
                      ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // -------------------------------------------------
          // 2. BÖLÜM: DURUM FİLTRELERİ (PLATFORM AYRIMI)
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
                  isSelected: filterState['durum'] == DurumFiltresi.hepsi,
                  onPressed: () => notifier.setDurum(DurumFiltresi.hepsi),
                ),
                const SizedBox(width: 8),
                _buildFilterItem(
                  context,
                  isIOS: isIOS,
                  label: 'Yanlışlarım',
                  isSelected: filterState['durum'] == DurumFiltresi.yanlislarim,
                  onPressed: () => notifier.setDurum(DurumFiltresi.yanlislarim),
                  activeColor: const Color(0xFFE53935), // Android için renk
                ),
                const SizedBox(width: 8),
                _buildFilterItem(
                  context,
                  isIOS: isIOS,
                  label: 'Boşlarım',
                  isSelected: filterState['durum'] == DurumFiltresi.boslarim,
                  onPressed: () => notifier.setDurum(DurumFiltresi.boslarim),
                  activeColor: Colors.orange, // Android için renk
                ),
                const SizedBox(width: 8),
                _buildFilterItem(
                  context,
                  isIOS: isIOS,
                  label: 'Öğrenildi',
                  isSelected:
                      filterState['durum'] == DurumFiltresi.tamamladiklarim,
                  onPressed: () =>
                      notifier.setDurum(DurumFiltresi.tamamladiklarim),
                  activeColor: const Color(0xFF43A047), // Android için renk
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

// -------------------------------------------------------------------------
// 1. ADIM SONU
// -------------------------------------------------------------------------
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

// -------------------------------------------------------------------------
// 2. ADIM: BU YENİ SINIFLARI DOSYANIN EN ALTINA EKLEYİN
// (Eski FilterButton sınıfını sildiğinizden emin olun)
// -------------------------------------------------------------------------

// -------------------------------------------------------------------------
// 2. ADIM: DOSYANIN EN ALTINDA BU 3 SINIF DA BULUNMALIDIR
// -------------------------------------------------------------------------

// 1. [iOS İçin] Eski Stil Filtre Butonu (Orijinal Kodunuzdan)
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
              ? activeColor.withValues(
                  alpha: 0.15,
                ) // Flutter 3.22+ withValues, eskiler için withOpacity
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
