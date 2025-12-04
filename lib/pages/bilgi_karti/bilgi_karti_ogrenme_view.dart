// ignore_for_file: avoid_print

import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kgsyks_destek/pages/bilgi_karti/bilgi_notu_model.dart';
import 'package:kgsyks_destek/pages/bilgi_karti/bilgi_notu_viewer.dart';
import 'package:kgsyks_destek/pages/bilgi_karti/bilgi_ogrenme_provider.dart';

class BilgiKartiOgrenmePage extends ConsumerStatefulWidget {
  const BilgiKartiOgrenmePage({super.key});

  @override
  ConsumerState<BilgiKartiOgrenmePage> createState() =>
      _BilgiKartiOgrenmePageState();
}

class _BilgiKartiOgrenmePageState extends ConsumerState<BilgiKartiOgrenmePage> {
  late PageController _pageController;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    // Viewport fraction: Kartın ekranda kaplayacağı genişlik oranı (0.85 = yanlardan boşluk kalır)
    _pageController = PageController(viewportFraction: 0.9);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final shuffledListAsync = ref.watch(shuffledBilgiNotlariProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Tema Renkleri
    final bgColor = Theme.of(context).scaffoldBackgroundColor;
    final textColor = isDark ? Colors.white : const Color(0xFF1C1E21);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        elevation: 0,
        centerTitle: true,
        title: Text(
          "Hızlı Tekrar",
          style: GoogleFonts.montserrat(
            color: textColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          // Tekrar Karıştır Butonu
          IconButton(
            icon: Icon(
              Platform.isIOS ? CupertinoIcons.shuffle : Icons.shuffle,
              color: textColor,
            ),
            onPressed: () {
              ref.invalidate(shuffledBilgiNotlariProvider);
              setState(() => _currentIndex = 0);
            },
          ),
        ],
      ),
      body: shuffledListAsync.when(
        loading: () => Center(
          child: Platform.isIOS
              ? const CupertinoActivityIndicator()
              : const CircularProgressIndicator(),
        ),
        error: (err, stack) => Center(child: Text('Hata: $err')),
        data: (notlar) {
          if (notlar.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.note_alt_outlined, size: 64, color: Colors.grey),
                  const SizedBox(height: 16),
                  Text(
                    "Henüz bilgi notu eklemediniz.",
                    style: TextStyle(color: textColor, fontSize: 16),
                  ),
                ],
              ),
            );
          }

          return SafeArea(
            child: Column(
              children: [
                // Üst Kısım: İlerleme Göstergesi
                Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 10,
                    horizontal: 24,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Kart ${_currentIndex + 1} / ${notlar.length}",
                        style: TextStyle(
                          color: Colors.grey,
                          fontWeight: FontWeight.bold,
                          fontFamily: GoogleFonts.montserrat().fontFamily,
                        ),
                      ),
                      SizedBox(
                        width: 100,
                        child: LinearProgressIndicator(
                          value: (notlar.isNotEmpty)
                              ? (_currentIndex + 1) / notlar.length
                              : 0,
                          backgroundColor: Colors.grey.shade300,
                          color: const Color(0xFF0099FF),
                          minHeight: 6,
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ],
                  ),
                ),

                // Orta Kısım: Kart Alanı
                Expanded(
                  child: PageView.builder(
                    controller: _pageController,
                    physics: const BouncingScrollPhysics(),
                    itemCount: notlar.length,
                    onPageChanged: (index) {
                      setState(() {
                        _currentIndex = index;
                      });
                    },
                    itemBuilder: (context, index) {
                      // Animasyonlu geçiş için scale efekti (Opsiyonel ama şık durur)
                      return AnimatedBuilder(
                        animation: _pageController,
                        builder: (context, child) {
                          return _FlashCardItem(
                            not: notlar[index],
                            isDark: isDark,
                          );
                        },
                      );
                    },
                  ),
                ),
                const SizedBox(height: 30), // Alt boşluk
              ],
            ),
          );
        },
      ),
    );
  }
}

class _FlashCardItem extends StatelessWidget {
  final BilgiNotuModel not;
  final bool isDark;

  const _FlashCardItem({required this.not, required this.isDark});

  Color _getPriorityColor(int priority) {
    switch (priority) {
      case 0:
        return const Color(0xFFE53935); // Kritik
      case 1:
        return const Color(0xFFFBC02D); // Olağan
      case 2:
        return const Color(0xFF43A047); // Düşük
      default:
        return Colors.grey;
    }
  }

  String _getPriorityLabel(int priority) {
    switch (priority) {
      case 0:
        return "Kritik";
      case 1:
        return "Olağan";
      case 2:
        return "Düşük";
      default:
        return "-";
    }
  }

  @override
  Widget build(BuildContext context) {
    // Kartın ana rengi
    final cardBg = isDark ? const Color(0xFF1F2937) : Colors.white;
    final priorityColor = _getPriorityColor(not.onemDerecesi);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: GestureDetector(
        onTap: () {
          // --- DÜZELTME BURADA ---
          // Doğrudan detay sayfasına (BilgiNotuViewer) yönlendiriyoruz.
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => BilgiNotuViewer(notId: not.id!)),
          );
        },
        child: ClipRRect(
          borderRadius: BorderRadius.circular(30),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // 1. KATMAN: RESİM
              Image.file(
                File(not.imagePath),
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => Container(
                  color: isDark ? Colors.grey[800] : Colors.grey[200],
                  child: const Icon(
                    Icons.broken_image,
                    size: 50,
                    color: Colors.grey,
                  ),
                ),
              ),

              // 2. KATMAN: KARARTMA GRADIENTİ
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.transparent,
                        Colors.black.withValues(alpha: 0.7),
                        Colors.black.withValues(alpha: 0.95),
                      ],
                      stops: const [0.0, 0.5, 0.8, 1.0],
                    ),
                  ),
                ),
              ),

              // 3. KATMAN: BİLGİLER
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Ders ve Öncelik Etiketleri
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFF0099FF),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              not.ders,
                              style: GoogleFonts.montserrat(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: priorityColor.withValues(alpha: 0.2),
                              border: Border.all(
                                color: priorityColor,
                                width: 1.5,
                              ),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.circle,
                                  size: 8,
                                  color: priorityColor,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  _getPriorityLabel(not.onemDerecesi),
                                  style: GoogleFonts.montserrat(
                                    color: priorityColor,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // Konu Başlığı
                      Text(
                        not.konu,
                        style: GoogleFonts.montserrat(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),

                      // Açıklama Metni
                      Container(
                        constraints: const BoxConstraints(maxHeight: 120),
                        child: SingleChildScrollView(
                          child: Text(
                            not.aciklama,
                            style: GoogleFonts.montserrat(
                              color: Colors.white.withValues(alpha: 0.9),
                              fontSize: 15,
                              height: 1.4,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                    ],
                  ),
                ),
              ),

              // 4. KATMAN: Tarih (Sağ Üst)
              Positioned(
                top: 20,
                right: 20,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black45,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    "${not.eklenmeTarihi.day}.${not.eklenmeTarihi.month}.${not.eklenmeTarihi.year}",
                    style: const TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
