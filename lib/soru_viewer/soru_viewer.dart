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
import 'package:kgsyks_destek/pages/soru_ekle/database_helper.dart';
import 'package:kgsyks_destek/pages/soru_ekle/soru_model.dart';
import 'package:kgsyks_destek/pages/soru_ekle/with_ai/ocr_servie.dart';
import 'package:kgsyks_destek/soru_viewer/drawing_page.dart';
import 'package:kgsyks_destek/soru_viewer/soru_view_provider.dart';
import 'package:kgsyks_destek/theme_section/app_colors.dart'; // SoruModel dosyanızı içe aktarın

class SoruViewer extends ConsumerWidget {
  final int soruId;
  SoruViewer({super.key, required this.soruId});

  final Gemini _gemini = Gemini.instance;
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  // --- YARDIMCI METOTLAR ---

  // Durum güncelleme ve Riverpod'u yenileme
  // HATA 1 DÜZELTİLDİ: yeniHataNedeni artık zorunlu
  Future<void> _updateSoruDurum(
    WidgetRef ref,
    int id,
    String durum,
    String yeniHataNedeni,
  ) async {
    await _dbHelper.updateSoruDurum(id, durum, yeniHataNedeni);
    // Verileri yenilemek için FutureProvider'ı geçersiz kıl
    ref.invalidate(soruProvider(id));
  }

  // Açıklamayı güncelleme
  Future<void> _updateAciklama(
    WidgetRef ref,
    int id,
    String yeniAciklama,
  ) async {
    await _dbHelper.updateSoruAciklama(id, yeniAciklama);
    ref.invalidate(soruProvider(id));
  }

  // Hatırlatıcı tarihi güncelleme (DateTime tipini kabul ediyor)
  Future<void> _updateHatirlaticiTarih(
    WidgetRef ref,
    int id,
    DateTime? tarih,
  ) async {
    // DatabaseHelper zaten DateTime? tipini alıp String'e çeviriyor.
    await _dbHelper.updateSoruHatirlaticiTarihi(id, tarih);
    ref.invalidate(soruProvider(id));
  }

  // Tarih seçiciyi açar
  Future<void> _selectDate(BuildContext context, WidgetRef ref, int id) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      await _updateHatirlaticiTarih(ref, id, picked);
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Hatırlatıcı tarihi ${picked.day}.${picked.month}.${picked.year} olarak güncellendi!',
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final soruAsyncValue = ref.watch(soruProvider(soruId));
    final aiSolution = ref.watch(aiSolutionProvider);
    //final isClicked = ref.watch(isClickedProvider);

    final aciklamaController = ref.watch(aciklamaControllerProvider);

    return Scaffold(
      appBar: AppBar(title: const Text("Soru Detayları")),
      body: soruAsyncValue.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Bir hata oluştu: $error')),

        data: (soru) {
          if (soru == null) {
            return const Center(child: Text("Soru bulunamadı."));
          }

          if (aciklamaController.text.isEmpty && soru.aciklama != null) {
            aciklamaController.text = soru.aciklama!;
          }

          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // --- SORU BİLGİLERİ KARTI ---
                  Card.outlined(
                    color: Theme.of(context).colorScheme.primaryContainer,
                    elevation: 1,
                    child: Padding(
                      padding: const EdgeInsets.all(15.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${soru.ders} - ${soru.konu}',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const SizedBox(height: 10),
                          // GÜNCEL DURUM GÖSTERİMİ
                          Text('Durum: ${soru.durum}'),
                          // Hatırlatıcı Tarihi Gösterimi
                          Text(
                            // HATA 2 İLE İLGİLİ DÜZELTME: DateTime'dan String formatına çevirim.
                            'Tekrar Tarihi: ${soru.hatirlaticiTarihi != null ? soru.hatirlaticiTarihi!.toLocal().toString().substring(0, 10) : 'Belirtilmedi'}',
                          ),
                          const SizedBox(height: 10),
                          if (soru.imagePath.isNotEmpty)
                            Image.file(File(soru.imagePath)),

                          SizedBox(height: 15),

                          // --- AKSİYON BUTONLARI ---
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              ElevatedButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => DrawingPage(
                                        imagePath: soru.imagePath,
                                      ),
                                    ),
                                  );
                                },
                                child: Text(
                                  "Soruyu Çöz",
                                  style: Theme.of(
                                    context,
                                  ).textTheme.titleMedium,
                                ),
                              ),
                              // HATIRLATICI TARİHİ GÜNCELLE BUTONU
                              ElevatedButton.icon(
                                onPressed: () =>
                                    _selectDate(context, ref, soru.id!),
                                icon: Icon(Icons.calendar_today),
                                label: Text("Tarih Ayarla"),
                              ),
                            ],
                          ),

                          Gap(10),
                          //_ai_ile_coz(isClicked, ref, soru, context),
                          //Gap(20),

                          // --- CEVAP SEÇİM VE DURUM GÜNCELLEME ---
                          Text(
                            "Cevabınız: ",
                            style: Theme.of(context).textTheme.titleMedium,
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
                                final selectedCevap = newSelection.first;

                                if (ref.read(soruCevabiProvider) == null) {
                                  ref.read(soruCevabiProvider.notifier).state =
                                      selectedCevap;

                                  // --- DURUM GÜNCELLEME MANTIĞI ---
                                  if (soru.soruCevap == selectedCevap.name) {
                                    // DOĞRU CEVAP: hataNedeni'ni boş string yapıyoruz.
                                    _updateSoruDurum(
                                      ref,
                                      soru.id!,
                                      'Öğrenildi',
                                      '',
                                    );
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          "Doğru cevap! Soru durumu 'Öğrenildi' olarak güncellendi.",
                                        ),
                                        backgroundColor: Colors.green,
                                      ),
                                    );
                                  } else {
                                    // YANLIŞ CEVAP: hataNedeni'ni kaydediyoruz.
                                    final hataNedeni =
                                        "Seçim: ${selectedCevap.name}, Doğru: ${soru.soruCevap}";
                                    _updateSoruDurum(
                                      ref,
                                      soru.id!,
                                      'Öğrenilecek',
                                      hataNedeni,
                                    );
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          "Yanlış cevap! Doğru cevap: ${soru.soruCevap}. Durum 'Öğrenilecek' olarak güncellendi.",
                                        ),
                                        backgroundColor: Colors.red,
                                      ),
                                    );
                                  }
                                }
                              },
                              // ... (SegmentedButton stil kodunun geri kalanı) ...
                              multiSelectionEnabled: false,
                              emptySelectionAllowed: true,
                              style: ButtonStyle(
                                padding: const WidgetStatePropertyAll(
                                  EdgeInsets.symmetric(horizontal: 8),
                                ),
                                backgroundColor:
                                    WidgetStateProperty.resolveWith((states) {
                                      return Colors.indigo[300];
                                    }),
                                shape: WidgetStatePropertyAll(
                                  RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(40),
                                  ),
                                ),
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

                  // --- AÇIKLAMA DÜZENLEME KARTI ---
                  Card.outlined(
                    color: Theme.of(context).colorScheme.primaryContainer,
                    child: Padding(
                      padding: const EdgeInsets.all(15.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Kendi Notların/Açıklama:",
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          Gap(10),
                          TextField(
                            controller: aciklamaController,
                            maxLines: null,
                            keyboardType: TextInputType.multiline,
                            decoration: InputDecoration(
                              hintText:
                                  "Sorunun çözümüne dair kendi notlarını buraya yaz...",
                              border: OutlineInputBorder(),
                            ),
                          ),
                          Gap(10),
                          Align(
                            alignment: Alignment.centerRight,
                            child: ElevatedButton.icon(
                              onPressed: () {
                                _updateAciklama(
                                  ref,
                                  soru.id!,
                                  aciklamaController.text,
                                );
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      "Açıklama başarıyla güncellendi.",
                                    ),
                                  ),
                                );
                              },
                              icon: Icon(Icons.save),
                              label: Text("Açıklamayı Güncelle"),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  Gap(20),

                  // --- AI ÇÖZÜM KARTI ---
                  if (aiSolution != null)
                    Card.outlined(
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
                              key: ValueKey(aiSolution),
                              totalRepeatCount: 1,
                              animatedTexts: [
                                TypewriterAnimatedText(
                                  aiSolution,
                                  speed: const Duration(milliseconds: 30),
                                ),
                              ],
                              onFinished: () {},
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

  // _ai_ile_coz metodu aynı kalır (Daha önceki yanıtlardaki ile aynı)
  // ignore: non_constant_identifier_names, unused_element
  ElevatedButton _ai_ile_coz(
    bool isClicked,
    WidgetRef ref,
    SoruModel soru,
    BuildContext context,
  ) {
    // ... (metot içeriği aynı kalır)
    return ElevatedButton.icon(
      onPressed: isClicked
          ? null
          : () async {
              ref.read(isClickedProvider.notifier).state = true;
              String? text;
              try {
                File imageFile = File(soru.imagePath);
                final text2 = await ref
                    .read(ocrServiceProvider)
                    .recognizeFromFile(imageFile);
                text = text2;
              } catch (e) {
                text = null;
              } finally {
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
                    for (var part in response.content!.parts!) {
                      if (part is TextPart) {
                        tesxte = part.text;
                        break;
                      }
                    }

                    if (tesxte != null) {
                      ref.read(aiSolutionProvider.notifier).state = tesxte;
                    }
                  }
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("AI çözümü alınırken bir hata oluştu."),
                    ),
                  );
                }
              }
            },
      icon: const Icon(CupertinoIcons.sparkles, color: AppColors.colorSurface),
      label: Text("AI ile Çöz", style: Theme.of(context).textTheme.titleMedium),
    );
  }
}
