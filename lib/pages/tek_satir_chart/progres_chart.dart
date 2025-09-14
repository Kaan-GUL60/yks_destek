import 'package:flutter/material.dart';
import 'package:kgsyks_destek/theme_section/app_colors.dart';

class ProgressTrackerBar extends StatelessWidget {
  final double correctCount;
  final double emptyCount;
  final double incorrectCount;
  final double barHeight;
  final double legendSpacing; // Açıklamalar arası boşluk
  final double borderRadius; // Köşe yuvarlaklığı

  const ProgressTrackerBar({
    super.key,
    required this.correctCount,
    required this.emptyCount,
    required this.incorrectCount,
    this.barHeight = 24,
    this.legendSpacing = 24,
    this.borderRadius = 12,
  });

  @override
  Widget build(BuildContext context) {
    final total = correctCount + emptyCount + incorrectCount;

    if (total == 0) {
      return const SizedBox.shrink();
    }

    return Column(
      children: [
        // Açıklama (Legend) kısmı
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _ModernLegendItem(color: AppColors.colorGreen, text: 'Doğru'),
            SizedBox(width: legendSpacing),
            _ModernLegendItem(color: AppColors.colorGrey, text: 'Boş'),
            SizedBox(width: legendSpacing),
            _ModernLegendItem(color: AppColors.colorRed, text: 'Yanlış'),
          ],
        ),
        const SizedBox(height: 20),

        // Çubuk (Bar) kısmı
        ClipRRect(
          borderRadius: BorderRadius.circular(borderRadius),
          child: Row(
            children: [
              Expanded(
                flex: (correctCount * 100).toInt(),
                child: Container(
                  height: barHeight,
                  color: AppColors.colorGreen,
                ),
              ),
              Expanded(
                flex: (emptyCount * 100).toInt(),
                child: Container(height: barHeight, color: AppColors.colorGrey),
              ),
              Expanded(
                flex: (incorrectCount * 100).toInt(),
                child: Container(height: barHeight, color: AppColors.colorRed),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// Legend için yardımcı widget
class _ModernLegendItem extends StatelessWidget {
  final Color color;
  final String text;

  const _ModernLegendItem({required this.color, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        CircleAvatar(backgroundColor: color, radius: 6),
        const SizedBox(width: 8),
        Text(
          text,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }
}
