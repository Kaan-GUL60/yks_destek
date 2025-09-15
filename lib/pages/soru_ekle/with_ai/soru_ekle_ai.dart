// ignore_for_file: avoid_print, unused_local_variable

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_gemini/flutter_gemini.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kgsyks_destek/pages/soru_ekle/listeler.dart';
import 'package:kgsyks_destek/pages/soru_ekle/soru_ekle.dart';
import 'package:kgsyks_destek/pages/soru_ekle/with_ai/ocr_servie.dart';
import 'package:lottie/lottie.dart';
import 'package:kgsyks_destek/pages/soru_ekle/image_picker_provider.dart';

class SoruEkleAi extends ConsumerStatefulWidget {
  const SoruEkleAi({super.key});

  @override
  ConsumerState<SoruEkleAi> createState() => _SoruEkleAiState();
}

class _SoruEkleAiState extends ConsumerState<SoruEkleAi>
    with TickerProviderStateMixin {
  late final AnimationController _processingLottieController;
  late final AnimationController _confettiLottieController;
  bool _showConfetti = false;
  final bool _control = true;

  final Gemini _gemini = Gemini.instance;

  @override
  void initState() {
    super.initState();

    _processingLottieController = AnimationController(vsync: this);
    _confettiLottieController = AnimationController(vsync: this);
  }

  @override
  void dispose() {
    _processingLottieController.dispose();
    _confettiLottieController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final File? selectedImage = ref.watch(imagePickerProvider);
    final String? ocrText = ref.watch(ocrResultProvider);
    final String? geminiText = ref.watch(geminiResultProvider);

    // Özelliğin kullanılabilirliği

    // Provider state değişimlerini dinle ve OCR başlat
    ref.listen<File?>(imagePickerProvider, (previous, next) {
      if (next != null && next != previous) {
        _handleSelectedImage(next);
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Yapay Zeka ile Soru Ekle'),
        centerTitle: true,
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
      body: Stack(
        children: [
          Center(
            child: Padding(
              padding: const EdgeInsets.all(15.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  addSoru(selectedImage, context),
                  const SizedBox(height: 20),
                  if (ocrText != null)
                    Expanded(
                      child: SingleChildScrollView(
                        child: Text(
                          "$ocrText -------- $geminiText",
                          style: const TextStyle(fontSize: 16),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          // Full-screen processing Lottie
          if (ref.watch(ocrProcessingProvider))
            Positioned.fill(
              child: Container(
                color: const Color.fromARGB(255, 245, 245, 245),
                child: Center(
                  child: SizedBox(
                    width: 200,
                    height: 200,
                    child: Lottie.asset(
                      'assets/animations/ai_load.json',
                      controller: _processingLottieController,
                      onLoaded: (composition) {
                        _processingLottieController
                          ..duration = composition.duration
                          ..repeat();
                      },
                    ),
                  ),
                ),
              ),
            ),
          // Confetti Lottie overlay
          if (_showConfetti)
            Positioned.fill(
              child: Container(
                color: Colors.transparent,
                child: Center(
                  child: SizedBox(
                    width: 250,
                    height: 250,
                    child: Lottie.asset(
                      'assets/animations/confetti.json',
                      controller: _confettiLottieController,
                      onLoaded: (composition) {
                        _confettiLottieController
                          ..duration = composition.duration
                          ..forward(from: 0)
                          ..addStatusListener((status) {
                            if (status == AnimationStatus.completed) {
                              setState(() => _showConfetti = false);
                            }
                          });
                      },
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Padding addSoru(File? selectedImage, BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 15, right: 15, top: 10),
      child: GestureDetector(
        child: ClipRRect(
          borderRadius: BorderRadius.circular(18),
          child: selectedImage != null
              ? Image.file(selectedImage, fit: BoxFit.cover)
              : Image.asset(
                  'assets/images/soru_ekle_ai.png',
                  fit: BoxFit.cover,
                ),
        ),
        onTap: () {
          _showImageSourceDialog(context, ref);
        },
      ),
    );
  }

  Future<void> _showImageSourceDialog(
    BuildContext context,
    WidgetRef ref,
  ) async {
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Resim Kaynağını Seçin'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Galeriden Seç'),
                onTap: () {
                  Navigator.of(context).pop();
                  ref.read(imagePickerProvider.notifier).pickImageFromGallery();
                },
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Kameradan Çek'),
                onTap: () {
                  Navigator.of(context).pop();
                  ref.read(imagePickerProvider.notifier).pickImageFromCamera();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _handleSelectedImage(File file) async {
    ref.read(ocrProcessingProvider.notifier).state = true;

    try {
      final text = await ref.read(ocrServiceProvider).recognizeFromFile(file);
      ref.read(ocrResultProvider.notifier).state = text;

      if (text.isNotEmpty) {
        setState(() => _showConfetti = true);
      }
    } catch (e) {
      ref.read(ocrResultProvider.notifier).state = null;
    } finally {
      //buraya girmeden gemini kısmına git ki herşey netleşene kadar
      //anmasyon dönsün

      final result = await getGeminiAnalysis(); // fonksiyonun adı örnek
      final raw = ref.watch(geminiResultProvider) ?? '';
      final reg = RegExp(
        r'ders:\s*(.*?),\s*konu:\s*(.*)$',
        dotAll: true, // \n dahil et
      );

      final match = reg.firstMatch(raw);
      final ders = match?.group(1)?.trim() ?? '';
      final konu = match?.group(2)?.trim() ?? '';
      print("-*/-*/*/*/-*/-*/-*/-*/-*/*/-*/-*/-*/-*/-*/*/*-/-*/-*");
      print("ders: $ders");
      print("konu: $konu");
      print("raw: $raw");
      print("-*/-*/*/*/-*/-*/-*/-*/-*/*/-*/-*/-*/-*/-*/*/*-/-*/-*");
      print("Gemini Analysis: $result");

      ref.read(ocrProcessingProvider.notifier).state = false;
    }
  }

  // The getGeminiAnalysis() function to be implemented

  Future<Map<String, String>> getGeminiAnalysis() async {
    final text = ref.read(ocrResultProvider);
    if (text == null || text.isEmpty) {
      return {'ders': '', 'konu': ''};
    }

    try {
      final response = await _gemini.prompt(
        parts: [
          Part.text(
            "Aşağıdaki soru hangi derse aittir? Sadece '<Ders Adı>' formatında cevap ver ve başka hiçbir şey ekleme: \n\n$text",
          ),
        ],
      );

      String? responseText;
      if (response != null &&
          response.content != null &&
          response.content!.parts != null) {
        // Use a simple for loop to find the TextPart, which avoids
        // the type issues of firstWhere.
        for (var part in response.content!.parts!) {
          if (part is TextPart) {
            responseText = part.text;
            break; // Stop iterating once the text is found
          }
        }
        try {
          String ders = responseText!.trim().toLowerCase();

          // Listedeki elemanlarla karşılaştır ve eşleşen ilkini bul.
          final String bulunanDers = dkonuListeleri.firstWhere(
            (dersInList) => dersInList.toLowerCase() == ders,
            orElse: () => "null", // Eğer eşleşme yoksa `null` döner.
          );

          final List<String> dersinKonulari = konuListeleri[bulunanDers] ?? [];

          if (dersinKonulari.isEmpty) {
            return {'ders': ders, 'konu': 'Bilinmiyor'};
          }
          final responseKonu = await _gemini.prompt(
            parts: [
              Part.text(
                "Aşağıdaki soru hangi ${dersinKonulari.join(', ')} konuya aittir? Sadece '<Konu Adı>' formatında cevap ver ve başka hiçbir şey ekleme: \n\n$text",
              ),
            ],
          );
          String? responseTextKonu;
          if (responseKonu != null &&
              responseKonu.content != null &&
              responseKonu.content!.parts != null) {
            // Use a simple for loop to find the TextPart, which avoids
            // the type issues of firstWhere.
            for (var part in responseKonu.content!.parts!) {
              if (part is TextPart) {
                responseTextKonu = part.text;
                break; // Stop iterating once the text is found
              }
            }
            ref.read(geminiResultProvider.notifier).state =
                "ders: ${responseText.toString()},konu: ${responseTextKonu.toString()}";
            return {
              'ders': responseText.toString(),
              'konu': responseTextKonu.toString(),
            };
          }
        } catch (e) {
          print('Gemini API hatası: $e');
        }
      }
    } catch (e) {
      print('Gemini API hatası: $e');
    }

    return {'ders': 'Bilinmiyor', 'konu': 'Bilinmiyor'};
  }
}
