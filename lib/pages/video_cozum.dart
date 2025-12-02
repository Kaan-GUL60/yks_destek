// publishing_house_list.dart
import 'dart:io'; // Platform kontrolü
import 'package:flutter/cupertino.dart'; // iOS widget'ları
import 'package:flutter/material.dart';
import 'package:kgsyks_destek/pages/webviewer_page.dart';

// 📚 Yayinevi Veri Modeli
class Yayinevi {
  final String ad;
  final String link;

  Yayinevi({required this.ad, required this.link});
}

// 🏢 Ana Liste Ekrani
class YayinevleriListesi extends StatelessWidget {
  YayinevleriListesi({super.key});

  // 📝 Statik Yayinevi Verileri
  final List<Yayinevi> yayinevleri = [
    Yayinevi(ad: "345 Yayınları", link: "https://ucdortbesvideo.frns.in/"),
    Yayinevi(ad: "Orijinal Yayınları", link: "https://orjinalvideo.frns.in/"),
    Yayinevi(ad: "Çözüm Yayınları", link: "https://cozum.aciyayinlari.com.tr/"),
    Yayinevi(
      ad: "3D Yayınları",
      link: "https://www.3dyayinlari.com/video-cozumler",
    ),
    Yayinevi(ad: "Arı Yayınları", link: "https://arivideo.frns.in"),
    Yayinevi(ad: "Aydın Yayınları", link: "https://aydinvideo.frns.in"),
    Yayinevi(
      ad: "Bilgisarmal Yayınları",
      link: "https://bilgisarmalvideo.frns.in",
    ),
    Yayinevi(ad: "Biyotik Yayınları", link: "https://biyotikvideo.frns.in"),
    Yayinevi(ad: "Çap Yayınları", link: "https://capvideo.frns.in"),
    Yayinevi(
      ad: "Endemik Yayınları",
      link: "https://video.endemikyayinlari.com.tr/",
    ),
    Yayinevi(ad: "Hız ve Renk Yayınları", link: "https://hizrenkvideo.frns.in"),
    Yayinevi(ad: "Karekök Yayınları", link: "https://karekokvideocozum.com/"),
    Yayinevi(ad: "Limit Yayınları", link: "https://limitvideo.frns.in"),
    Yayinevi(ad: "Metin Yayınları", link: "https://cozmetinvideo.frns.in"),
    Yayinevi(ad: "Orbital Yayınları", link: "https://orbitalvideo.frns.in"),
    Yayinevi(ad: "Özdebir Yayınları", link: "https://ozdebirvideo.frns.in"),
    Yayinevi(ad: "Paraf Yayınları", link: "https://parafvideo.frns.in"),
    Yayinevi(ad: "Toprak Yayınları", link: "https://toprakvideo.frns.in"),
    Yayinevi(
      ad: "Yayın Denizi Yayınları",
      link: "https://yayindenizivideo.frns.in",
    ),
  ];

  @override
  Widget build(BuildContext context) {
    // Tema değişkenleri
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = Theme.of(context).scaffoldBackgroundColor;
    final textColor =
        Theme.of(context).textTheme.bodyLarge?.color ?? Colors.black;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        title: Text(
          'Yayınevleri',
          style: TextStyle(color: textColor, fontWeight: FontWeight.bold),
        ),
        centerTitle: true, // İYİLEŞTİRME 1: Başlık ortalama (iOS standardı)
        backgroundColor: bgColor,
        elevation: 0,
        iconTheme: IconThemeData(color: textColor),
      ),
      // İYİLEŞTİRME 2: SafeArea
      body: SafeArea(
        child: ListView.builder(
          // İYİLEŞTİRME 3: iOS tarzı esneme efekti
          physics: Platform.isIOS
              ? const BouncingScrollPhysics()
              : const ClampingScrollPhysics(),
          itemCount: yayinevleri.length,
          itemBuilder: (context, index) {
            final yayinevi = yayinevleri[index];
            return Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 8.0,
              ),
              child: Container(
                decoration: BoxDecoration(
                  color: isDark
                      ? const Color(0xFF1F2937)
                      : Colors.white, // Koyu mod desteği
                  borderRadius: BorderRadius.circular(12.0),
                  boxShadow: isDark
                      ? [] // Koyu modda gölge yok
                      : [
                          BoxShadow(
                            color: Colors.grey.withValues(alpha: 0.2),
                            spreadRadius: 2,
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                  border: isDark ? Border.all(color: Colors.white12) : null,
                ),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: _getAvatarColor(index),
                    child: Text(
                      yayinevi.ad[0],
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.secondary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  title: Text(
                    yayinevi.ad,
                    style: TextStyle(
                      color: textColor,
                      fontSize: 16.0,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  // İYİLEŞTİRME 4: Platforma Duyarlı Ok İkonu
                  trailing: Icon(
                    Platform.isIOS
                        ? CupertinoIcons.chevron_forward
                        : Icons.arrow_forward_ios,
                    size: 18.0, // iOS okları genelde biraz daha küçüktür
                    color: Colors.grey,
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => WebViewScreen(
                          url: yayinevi.link,
                          title: yayinevi.ad,
                        ),
                      ),
                    );
                  },
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Color _getAvatarColor(int index) {
    final colors = [
      const Color(0xFFF0E5D7),
      const Color(0xFF1E6C53),
      const Color(0xFFE5F0D7),
      const Color(0xFF135043),
      const Color(0xFFDCEFE2),
      const Color(0xFFC7E4F2),
    ];
    return colors[index % colors.length];
  }
}
