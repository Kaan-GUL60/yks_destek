// ignore_for_file: avoid_print

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kgsyks_destek/go_router/router.dart';
import 'package:kgsyks_destek/pages/favoriler_page/sorular_list_provider.dart';

import 'package:kgsyks_destek/pages/soru_ekle/soru_model.dart';

class FavorilerPage extends ConsumerWidget {
  const FavorilerPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Favoriler'),
        // elevation: 0, // AppBar'ın varsayılan stilini temadan alması daha iyi
      ),
      body: const Column(
        children: [
          _FilterControls(), // Filtre Butonları
          SizedBox(height: 16),
          Expanded(child: _SorularListesi()), // Soru Listesi
        ],
      ),
    );
  }
}

// FİLTRE KONTROLLERİ WIDGET'I
class _FilterControls extends ConsumerWidget {
  const _FilterControls();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Mevcut temayı context üzerinden alıyoruz
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // Provider'lardan state ve listeleri alıyoruz
    final filterState = ref.watch(sorularFilterProvider);
    final dersler = ref.watch(dersListProvider);
    final konular = ref.watch(konuListProvider);
    final notifier = ref.read(sorularFilterProvider.notifier);

    // Dropdown stilini temadan alacak şekilde güncelliyoruz
    final dropdownDecoration = InputDecoration(
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      enabledBorder: OutlineInputBorder(
        borderSide: BorderSide(
          color: colorScheme.outline.withValues(alpha: 0.5),
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(color: colorScheme.primary),
        borderRadius: BorderRadius.circular(8),
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
                child: DropdownButtonFormField<String>(
                  initialValue:
                      filterState['ders'], // initialValue yerine value kullandık
                  hint: Text(
                    'Ders Seç',
                    style: TextStyle(color: theme.hintColor),
                  ),
                  isExpanded: true,
                  dropdownColor: theme.cardColor, // Açılır menü arkaplanı
                  style: theme.textTheme.bodyLarge, // Yazı stili temadan
                  decoration: dropdownDecoration,
                  items: dersler.map((ders) {
                    return DropdownMenuItem(value: ders, child: Text(ders));
                  }).toList(),
                  onChanged: (value) => notifier.setDers(value),
                ),
              ),
              const SizedBox(width: 16),
              // Konu Dropdown
              Expanded(
                child: DropdownButtonFormField<String>(
                  initialValue:
                      filterState['konu'], // initialValue yerine value kullandık
                  hint: Text(
                    'Konu Seç',
                    style: TextStyle(color: theme.hintColor),
                  ),
                  isExpanded: true,
                  dropdownColor: theme.cardColor,
                  style: theme.textTheme.bodyLarge,
                  decoration: dropdownDecoration,
                  items: (filterState['ders'] != null)
                      ? konular.map((konu) {
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

          // --- Durum Filtreleri ---
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                FilterButton(
                  label: 'Hepsi',
                  count: 10,
                  isSelected: filterState['durum'] == DurumFiltresi.hepsi,
                  // Temanın ana rengini kullanıyoruz
                  color: Colors.blueGrey,
                  onPressed: () => notifier.setDurum(DurumFiltresi.hepsi),
                ),
                const SizedBox(width: 8),
                FilterButton(
                  label: 'Yanlışlarım',
                  count: 60,
                  isSelected: filterState['durum'] == DurumFiltresi.yanlislarim,
                  // Temanın 'hata' rengini kullanıyoruz
                  color: Colors.blueGrey,
                  onPressed: () => notifier.setDurum(DurumFiltresi.yanlislarim),
                ),
                const SizedBox(width: 8),
                FilterButton(
                  label: 'Boşlarım',
                  count: 38,
                  isSelected: filterState['durum'] == DurumFiltresi.boslarim,
                  // Temanın ikincil rengini kullanıyoruz
                  color: Colors.blueGrey,
                  onPressed: () => notifier.setDurum(DurumFiltresi.boslarim),
                ),
                const SizedBox(width: 8),
                FilterButton(
                  label: 'Tamamladıklarım',
                  count: 18,
                  isSelected:
                      filterState['durum'] == DurumFiltresi.tamamladiklarim,
                  // Statik Yeşil yerine sistemin kendi renklerinden birini atıyoruz
                  color: Colors
                      .blueGrey, // Durum renkleri evrensel olduğu için kalabilir
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
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) => Center(child: Text('Hata: $err')),
      data: (_) {
        if (filteredSorular.isEmpty) {
          return const Center(
            child: Text('Bu filtrede gösterilecek soru bulunamadı.'),
          );
        }
        return ListView.builder(
          itemCount: filteredSorular.length,
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
  const _SoruCard({required this.soru});

  // Duruma göre renk döndüren fonksiyon.
  // Bu renkler (kırmızı, yeşil) evrensel durum bildirdiği için
  // tema rengi yerine statik kalmaları daha anlamlıdır.
  Color _getDurumColor(String durum) {
    if (durum == 'Öğrenildi') return Colors.green;
    if (durum == 'Beklemede') return Colors.grey;
    return Colors.red;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    return GestureDetector(
      onTap: () async {
        print("Soru ID: ${soru.id} tıklandı.");
        context.pushNamed(
          AppRoute.soruViewer.name,
          pathParameters: {"id": soru.id.toString()},
        );
      },
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        // Card'ın rengi otomatik olarak temadan gelir (theme.cardColor)
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            children: [
              // Soru Resmi (Thumbnail)
              SizedBox(
                width: 80,
                height: 80,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.file(
                    File(soru.imagePath),
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Icon(
                        Icons.image_not_supported,
                        // Hata ikonunun rengi de temadan gelir
                        color: theme.colorScheme.onSurface.withValues(
                          alpha: 0.4,
                        ),
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(width: 16),
              // Soru Bilgileri
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      soru.konu,
                      // Yazı stilleri ve renkleri artık temadan geliyor
                      style: textTheme.titleMedium,
                    ),
                    const SizedBox(height: 4),
                    Text(soru.hataNedeni, style: textTheme.bodyLarge),
                    const SizedBox(height: 8),
                    Text(
                      soru.aciklama ?? '',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurface.withValues(
                          alpha: 0.7,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // Sağ Taraftaki İkonlar
              Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: _getDurumColor(soru.durum),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Icon rengi de otomatik olarak temadan gelir (IconTheme)
                  const Icon(Icons.favorite_border),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Özel Filtre Buton Widget'ı
class FilterButton extends StatelessWidget {
  final String label;
  final int count;
  final bool isSelected;
  final Color color;
  final VoidCallback onPressed;

  const FilterButton({
    super.key,
    required this.label,
    required this.count,
    required this.isSelected,
    required this.color,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Seçili olmayan butonun rengini de temadan alıyoruz
    final unselectedColor = theme.colorScheme.surfaceContainerHighest;

    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: isSelected ? color : unselectedColor,
        // Buton üzerindeki yazı rengi, arkaplan rengine göre otomatik ayarlanır.
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      child: Text('$label ($count)'),
    );
  }
}
