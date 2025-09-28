// SoruViewer'ı Riverpod ile kullanıma uygun hale getirme
import 'dart:io';

import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gemini/flutter_gemini.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kgsyks_destek/ana_ekran/home_state.dart';
import 'package:kgsyks_destek/pages/soru_ekle/soru_model.dart';
import 'package:kgsyks_destek/pages/soru_ekle/with_ai/ocr_servie.dart';
import 'package:kgsyks_destek/soru_viewer/drawingPage.dart';
import 'package:kgsyks_destek/soru_viewer/soru_view_provider.dart';
import 'package:kgsyks_destek/theme_section/app_colors.dart'; // SoruModel dosyanızı içe aktarın

class SoruViewer extends ConsumerWidget {
  final int soruId;
  SoruViewer({super.key, required this.soruId});
  final Gemini _gemini = Gemini.instance;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // soruId'yi parametre olarak ileterek soruProvider'ı dinliyoruz
    final soruAsyncValue = ref.watch(soruProvider(soruId));
    final aiSolution = ref.watch(aiSolutionProvider);
    final isClicked = ref.watch(isClickedProvider);

    return Scaffold(
      appBar: AppBar(title: const Text("Soru Detayları")),
      body: soruAsyncValue.when(
        // Veri yüklenirken gösterilecek widget
        loading: () => const Center(child: CircularProgressIndicator()),

        // Bir hata oluştuğunda gösterilecek widget
        error: (error, stack) => Center(child: Text('Bir hata oluştu: $error')),

        // Veri başarıyla yüklendiğinde gösterilecek widget
        data: (soru) {
          if (soru == null) {
            return const Center(child: Text("Soru bulunamadı."));
          }

          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Card.outlined(
                    color: Theme.of(context).colorScheme.primaryContainer,
                    elevation: 1,
                    child: Padding(
                      padding: const EdgeInsets.all(15.0),
                      child: Column(
                        children: [
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${soru.ders} - ${soru.konu}',
                                style: Theme.of(context).textTheme.titleLarge,
                              ),
                              const SizedBox(height: 10),
                              Text('Durum: ${soru.durum}'),
                              //const SizedBox(height: 10),
                              //Text('Sorunun Cevabı: ${soru.soruCevap} Şıkkı'),
                              const SizedBox(height: 10),
                              if (soru.imagePath.isNotEmpty)
                                Image.file(File(soru.imagePath)),
                            ],
                          ),
                          SizedBox(height: 15),
                          ElevatedButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) =>
                                      DrawingPage(imagePath: soru.imagePath),
                                ),
                              );
                            },
                            child: Text(
                              "Soruyu Çöz",
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                          ),
                          Gap(10),
                          //_ai_ile_coz(isClicked, ref, soru, context),
                          Gap(10),
                          SizedBox(
                            width: double.infinity,
                            child: Text("Cevabınız: "),
                          ),
                          Gap(10),
                          Center(
                            child: SegmentedButton<OptionSoruCevabi>(
                              segments: <ButtonSegment<OptionSoruCevabi>>[
                                ButtonSegment(
                                  value: OptionSoruCevabi.A,
                                  label: Text(
                                    'A',
                                    style: TextStyle(
                                      letterSpacing: 1,
                                      fontFamily: GoogleFonts.montserrat(
                                        fontWeight: FontWeight.w900,
                                      ).fontFamily,
                                    ),
                                  ),
                                ),
                                ButtonSegment(
                                  value: OptionSoruCevabi.B,
                                  label: Text(
                                    'B',
                                    style: TextStyle(
                                      letterSpacing: 1,
                                      fontFamily: GoogleFonts.montserrat(
                                        fontWeight: FontWeight.w900,
                                      ).fontFamily,
                                    ),
                                  ),
                                ),
                                ButtonSegment(
                                  value: OptionSoruCevabi.C,
                                  label: Text(
                                    'C',
                                    style: TextStyle(
                                      letterSpacing: 1,
                                      fontFamily: GoogleFonts.montserrat(
                                        fontWeight: FontWeight.w900,
                                      ).fontFamily,
                                    ),
                                  ),
                                ),
                                ButtonSegment(
                                  value: OptionSoruCevabi.D,
                                  label: Text(
                                    'D',
                                    style: TextStyle(
                                      letterSpacing: 1,
                                      fontFamily: GoogleFonts.montserrat(
                                        fontWeight: FontWeight.w900,
                                      ).fontFamily,
                                    ),
                                  ),
                                ),
                                ButtonSegment(
                                  value: OptionSoruCevabi.E,
                                  label: Text(
                                    'E',
                                    style: TextStyle(
                                      letterSpacing: 1,
                                      fontFamily: GoogleFonts.montserrat(
                                        fontWeight: FontWeight.w900,
                                      ).fontFamily,
                                    ),
                                  ),
                                ),
                              ],
                              selected: {
                                ref.watch(soruCevabiProvider),
                              }.whereType<OptionSoruCevabi>().toSet(),
                              onSelectionChanged: (newSelection) {
                                if (ref.read(soruCevabiProvider) == null) {
                                  ref.read(soruCevabiProvider.notifier).state =
                                      newSelection.first;

                                  if (soru.soruCevap ==
                                      newSelection.first.name) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text("Doğru cevap!"),
                                        backgroundColor: Colors.green,
                                      ),
                                    );
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          "Yanlış cevap! Doğru cevap: ${soru.soruCevap}",
                                        ),
                                        backgroundColor: Colors.red,
                                      ),
                                    );
                                  }
                                }
                              },
                              multiSelectionEnabled: false,
                              emptySelectionAllowed: true, // <-- Add this line
                              // kapsül arka plan
                              style: ButtonStyle(
                                padding: const WidgetStatePropertyAll(
                                  EdgeInsets.symmetric(horizontal: 8),
                                ),
                                backgroundColor:
                                    WidgetStateProperty.resolveWith((states) {
                                      return Colors
                                          .indigo[300]; // kapsül zemin rengi
                                    }),
                                shape: WidgetStatePropertyAll(
                                  RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(
                                      40,
                                    ), // kapsül köşe yuvarlatma
                                  ),
                                ),
                                // her segment için daire
                                side: const WidgetStatePropertyAll(
                                  BorderSide(color: Colors.black, width: 2),
                                ),
                                foregroundColor:
                                    WidgetStateProperty.resolveWith((states) {
                                      return states.contains(
                                            WidgetState.selected,
                                          )
                                          ? Colors.white
                                          : Colors.black;
                                    }),
                                overlayColor: const WidgetStatePropertyAll(
                                  Colors.transparent,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Gap(20),
                  // Geri kalan verileri bu şekilde ekleyebilirsiniz
                  // Veya Image.file(File(soru.imagePath))
                  if (aiSolution != null)
                    Card.outlined(
                      // Kart rengini farklı bir renkle belirleyin
                      color: Theme.of(context).colorScheme.primaryContainer,
                      elevation: 1,
                      child: Padding(
                        padding: const EdgeInsets.all(15.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text(
                              "AI Çözümü:",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            AnimatedTextKit(
                              key: ValueKey(
                                aiSolution,
                              ), // Metin değiştiğinde animasyonu yeniden başlatmak için
                              totalRepeatCount:
                                  1, // Animasyonu sadece bir kez oynat
                              animatedTexts: [
                                TypewriterAnimatedText(
                                  aiSolution,

                                  speed: const Duration(
                                    milliseconds: 30,
                                  ), // Yazma hızı
                                ),
                              ],
                              // Animasyon tamamlandığında bir eylem yapmak için onFinished'ı kullanabilirsiniz
                              onFinished: () {
                                // Animasyon bittiğinde yapılacak işlemler
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  ElevatedButton _ai_ile_coz(
    bool isClicked,
    WidgetRef ref,
    SoruModel soru,
    BuildContext context,
  ) {
    return ElevatedButton.icon(
      onPressed: isClicked
          ? null // Eğer tıklandıysa, onPressed null olsun ve buton pasifleşsin
          : () async {
              // button sadece bir kez tıklanabilir yap
              ref.read(isClickedProvider.notifier).state = true;
              String? text;
              // AI ile çözme işlemi burada yapılacak
              try {
                File imageFile = File(soru.imagePath);
                final text2 = await ref
                    .read(ocrServiceProvider)
                    .recognizeFromFile(imageFile);
                text = text2;
              } catch (e) {
                text = null;
              } finally {
                // İşlem tamamlandıktan sonra yapılacak işlemler
                try {
                  final response = await _gemini.prompt(
                    parts: [
                      Part.text(
                        "Aşağıdaki soruyu kısa ve net bir şekilde öğrencinin anlayabileceği seviyede çöz. sadece öğrenciye çözümü anlatır şekilde cevap olarak ver ve başka hiçbir şey ekleme: \n\n$text",
                      ),
                    ],
                  );
                  String? tesxte;
                  if (response != null &&
                      response.content != null &&
                      response.content!.parts != null) {
                    // Use a simple for loop to find the TextPart, which avoids
                    // the type issues of firstWhere.
                    for (var part in response.content!.parts!) {
                      if (part is TextPart) {
                        tesxte = part.text;
                        break; // Stop iterating once the text is found
                      }
                    }

                    // Metin varsa provider'a ata
                    if (tesxte != null) {
                      ref.read(aiSolutionProvider.notifier).state = tesxte;
                    }
                    //elde edilen cevabı başka bir animasyonlu kart içinde ayzdır
                  }
                } catch (e) {
                  ScaffoldMessenger.of(
                    // ignore: use_build_context_synchronously
                    context,
                  ).showSnackBar(
                    const SnackBar(
                      content: Text("AI çözümü alınırken bir hata oluştu."),
                    ),
                  );
                }
              }
            },
      icon: const Icon(
        CupertinoIcons.sparkles,
        color: AppColors.colorSurface,
      ), // Ikonu buraya ekleyin
      label: Text("AI ile Çöz", style: Theme.of(context).textTheme.titleMedium),
    );
  }
}
