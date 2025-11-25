// ignore_for_file: avoid_print, dead_code

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_gemini/flutter_gemini.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kgsyks_destek/ana_ekran/home_state.dart';
import 'package:kgsyks_destek/analytics_helper/analytics_helper.dart';
import 'package:kgsyks_destek/cloud_message/services.dart';
import 'package:kgsyks_destek/pages/soru_ekle/image_picker_provider.dart';
import 'package:kgsyks_destek/pages/soru_ekle/list_providers.dart';
import 'package:kgsyks_destek/pages/soru_ekle/listeler.dart';
import 'package:kgsyks_destek/pages/soru_ekle/soru_ekle_provider.dart';
import 'package:kgsyks_destek/pages/soru_ekle/soru_model.dart';
import 'package:kgsyks_destek/pages/soru_ekle/with_ai/ocr_servie.dart';
import 'package:kgsyks_destek/sign/save_data.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

DateTime? selectedDate;

class SoruEkle extends ConsumerStatefulWidget {
  const SoruEkle({super.key});

  @override
  ConsumerState<SoruEkle> createState() => _SoruEkleState();
}

class _SoruEkleState extends ConsumerState<SoruEkle>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _controllerAciklama = TextEditingController();

  final Gemini _gemini = Gemini.instance;
  // ignore: unused_field
  final bool _ekranKontorl = false;
  String dersAi = "";
  String konuAi = "";

  Future<void> _selectDate() async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2030),
    );
    setState(() {
      selectedDate = picked;
    });
  }

  void _resetForm() {
    _controllerAciklama.clear();
    ref.read(selectedDersProvider.notifier).state = null;
    ref.read(selectedKonuProvider.notifier).state = null;
    ref.read(selectedDurumProvider.notifier).state = null;
    ref.read(selectedHataNedeniProvider.notifier).state = null;
    ref
        .read(imagePickerProvider.notifier)
        .clearImage(); // image picker provider'ına clear metodu eklemen gerekebilir.
    setState(() {
      selectedDate = null;
    });
    // Kaydetme durumunu da sıfırla
    ref.read(soruNotifierProvider.notifier).resetState();
  }

  @override
  Widget build(BuildContext context) {
    // selectedCourseProvider'ı dinliyoruz.
    final String? secilenDers = ref.watch(selectedDersProvider);
    final String? secilenDurum = ref.watch(selectedDurumProvider);
    final String? secilenHataNedeni = ref.watch(selectedHataNedeniProvider);
    final String? secilenKonu = ref.watch(selectedKonuProvider);
    final File? selectedImage = ref.watch(imagePickerProvider);

    final soruKayitState = ref.watch(soruNotifierProvider);

    final UserAuth auth = UserAuth();

    ref.listen<SoruKayitState>(soruNotifierProvider, (previous, next) {
      if (next == SoruKayitState.success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Soru başarıyla kaydedildi!'),
            backgroundColor: Colors.green,
          ),
        );
        _resetForm(); // Formu temizle
      } else if (next == SoruKayitState.error) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Hata: Kayıt yapılamadı!'),
            backgroundColor: Colors.red,
          ),
        );
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text("Soru Ekle"),
        centerTitle: true,
        backgroundColor:
            Colors.transparent, // Tasarımda header şeffaf gibi duruyor
        elevation: 0,
      ),
      // geri dön butonu gelmesi için Navigator.of(context).push(...) bu şekilde aç bu sayfayı
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildImagePickerArea(context, selectedImage, ref),
            const Gap(20),

            Row(
              children: [
                Expanded(
                  child: _buildDropdownStyleButton(
                    context: context,
                    label: "Ders",
                    value: secilenDers,
                    onTap: () {
                      _secimDialog(
                        context,
                        filteredDerslerProvider,
                        searchQueryDersProvider,
                        selectedDersProvider,
                      );
                    },
                  ),
                ),
                const Gap(15),
                Expanded(
                  child: _buildDropdownStyleButton(
                    context: context,
                    label: "Konu",
                    value: secilenKonu,
                    onTap: () {
                      if (secilenDers == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Lütfen önce ders seçiniz.'),
                          ),
                        );
                        return;
                      }
                      _secimDialog(
                        context,
                        filteredKonuProvider,
                        searchQueryKonuProvider,
                        selectedKonuProvider,
                      );
                    },
                  ),
                ),
              ],
            ),
            const Gap(20),

            // 3. HATA NEDENİ (Chips Listesi)
            Text("Hata Nedeni", style: _sectionTitleStyle(context)),
            const Gap(10),
            _buildChipSelection(
              context: context,
              items: hataNedeni, // listeler.dart'tan gelen liste
              selectedValue: secilenHataNedeni,
              onSelected: (val) {
                ref.read(selectedHataNedeniProvider.notifier).state = val;
              },
            ),
            const Gap(20),

            // 4. DURUM (Chips Listesi)
            Text("Durum", style: _sectionTitleStyle(context)),
            const Gap(10),
            _buildChipSelection(
              context: context,
              items: durum, // listeler.dart'tan gelen liste
              selectedValue: secilenDurum,
              onSelected: (val) {
                ref.read(selectedDurumProvider.notifier).state = val;
              },
            ),

            const Gap(20),
            // 5. DOĞRU CEVAP (Yuvarlak Seçim Butonları)
            Text("Doğru Cevap", style: _sectionTitleStyle(context)),
            const Gap(10),
            _buildAnswerKeySelector(context, ref),

            const Gap(20),
            Text("Soru Açıklaması", style: _sectionTitleStyle(context)),
            const Gap(10),
            Form(
              key: _formKey,
              child: TextFormField(
                autofocus: false,
                controller: _controllerAciklama,
                maxLines: 4,
                maxLength: 255,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface,
                ),
                decoration: InputDecoration(
                  hintText: "Eklemek istediğiniz notlar...",
                  // Tema dosyasındaki decoration otomatik uygulanır ama özelleştirme gerekirse:
                  fillColor: Theme.of(context).inputDecorationTheme.fillColor,
                  filled: true,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: BorderSide.none,
                  ),
                ),
                validator: (value) {
                  if (value != null && value.length > 255) {
                    return "255 karakteri geçemez";
                  }
                  return null;
                },
              ),
            ),

            const Gap(15),

            // 7. HATIRLATICI TARİHİ
            Text("Hatırlatıcı Tarihi", style: _sectionTitleStyle(context)),
            const Gap(10),
            GestureDetector(
              onTap: _selectDate,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 16,
                ),
                decoration: BoxDecoration(
                  color: Theme.of(context).inputDecorationTheme.fillColor,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: Theme.of(
                      context,
                    ).dividerColor.withValues(alpha: 0.1),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.calendar_today,
                      color: Theme.of(context).primaryColor,
                    ),
                    const Gap(10),
                    Text(
                      selectedDate == null
                          ? "Tarih Seçiniz"
                          : "${selectedDate!.day} Ekim ${selectedDate!.year}", // Ay ismini dinamik yapmak için intl paketi önerilir
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    const Spacer(),
                    if (selectedDate != null)
                      Icon(Icons.edit, size: 18, color: Colors.grey),
                  ],
                ),
              ),
            ),

            const Gap(30),

            // 8. KAYDET BUTONU
            SizedBox(
              width: double.infinity,
              height: 55,
              child: FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(
                    0xFF3B82F6,
                  ), // Tasarımdaki canlı mavi
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                onPressed: soruKayitState == SoruKayitState.loading
                    ? null
                    : () async {
                        // 1. Önce gerekli alanların dolu olup olmadığını kontrol et
                        final secilenSoruCevap = ref.read(soruCevabiProvider);
                        if (secilenDers == null ||
                            secilenKonu == null ||
                            secilenDurum == null ||
                            secilenSoruCevap == null ||
                            secilenHataNedeni == null ||
                            selectedImage == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                "Lütfen resim dahil tüm alanları seçin!",
                              ),
                              backgroundColor: Colors.orange,
                            ),
                          );
                          return; // Eksik bilgi varsa işlemi durdur
                        }
                        if (!_formKey.currentState!.validate()) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Lütfen resim dahil tüm alanları seçin!',
                              ),
                            ),
                          );
                          return;
                        }
                        final File? selectedImage2 = ref.read(
                          imagePickerProvider,
                        );
                        if (selectedImage2 == null) return;

                        // 2. KALICI BİR YOL OLUŞTUR VE RESMİ KOPYALA
                        final appDir = await getApplicationDocumentsDirectory();
                        final fileName = p.basename(
                          selectedImage2.path,
                        ); // Resmin orijinal adını alır (örn: image_picker_12345.jpg)
                        final savedImagePath = p.join(
                          appDir.path,
                          fileName,
                        ); // Yeni kalıcı yol (örn: .../Documents/image_picker_12345.jpg)

                        // OPTİMİZASYON: Resmi kaydetmeden önce sıkıştır

                        final compressedImageBytes =
                            await FlutterImageCompress.compressWithFile(
                              selectedImage2.path,
                              quality:
                                  88, // Sıkıştırma kalitesini ayarla (0-100 arası)
                            );

                        if (compressedImageBytes == null) {
                          return;
                        }

                        // Dosyayı geçici yoldan kalıcı yola kopyala
                        final File savedImage = File(savedImagePath);
                        await savedImage.writeAsBytes(compressedImageBytes);
                        DateTime? selectedDate2 = selectedDate;

                        // 2. Verilerden SoruModel nesnesi oluştur
                        final yeniSoru = SoruModel(
                          ders: secilenDers,
                          konu: secilenKonu,
                          durum: secilenDurum,
                          hataNedeni: secilenHataNedeni,
                          soruCevap: secilenSoruCevap.name,
                          imagePath: savedImage.path, // Resmin yolunu al
                          aciklama: _controllerAciklama.text == ""
                              ? "-"
                              : _controllerAciklama.text,
                          eklenmeTarihi: DateTime.now(),
                          hatirlaticiTarihi: selectedDate2,
                        );

                        auth.soruSayiArtir("soruSayi");
                        AnalyticsService().trackCount(
                          "buttonClick",
                          "soru_eklendi",
                        ); // soru sayıyor

                        //**************************************************************

                        //-----------------------------------------------------------

                        // 3. Provider aracılığıyla veritabanına kaydet
                        final int yeniId = await ref
                            .read(soruNotifierProvider.notifier)
                            .addSoru(yeniSoru);
                        //print("---------------------$yeniId");
                        //print("---------------------$selectedDate2");
                        if (yeniId > 0 && selectedDate2 != null) {
                          final DateTime tarih = selectedDate2;
                          final now = DateTime.now();
                          final DateTime saat12 = DateTime(
                            tarih.year,
                            tarih.month,
                            tarih.day,
                            12,
                            0,
                          );
                          final DateTime saat15 = DateTime(
                            tarih.year,
                            tarih.month,
                            tarih.day,
                            15,
                            0,
                          );
                          final String bildirimBasligi =
                              '${yeniSoru.ders} Hatırlatması ⏰';
                          final String bildirimGovdesi =
                              '${yeniSoru.konu} konusundaki soruyu tekrar etme zamanı!';
                          /*debugPrint(
                            "Test bildirimi 5 saniye içinde gönderiliyor (ID: $yeniId)...",
                          );*/
                          /*await scheduleLocalNotification(
                                  notificationId:
                                      yeniId * 10 +
                                      99, // Benzersiz bir test ID'si
                                  soruId:
                                      yeniId, // Tıklanınca açılacak GERÇEK soru ID'si
                                  title: '🧪 Test Bildirimi (ID: $yeniId)',
                                  body: '${yeniSoru.konu} sorusu için test.',
                                  scheduledTime: DateTime.now().add(
                                    const Duration(seconds: 5),
                                  ),
                                  imagePath: yeniSoru
                                      .imagePath, // Resim testini de yapar
                                );*/
                          if (saat12.isAfter(now)) {
                            await scheduleLocalNotification(
                              notificationId:
                                  yeniId * 10 + 1, // Benzersiz bildirim ID'si
                              soruId:
                                  yeniId, // Tıklanınca açılacak GERÇEK soru ID'si
                              title: bildirimBasligi,
                              body: '$bildirimGovdesi (Saat 12:00)',
                              scheduledTime: saat12,
                              imagePath: yeniSoru.imagePath,
                            );
                          }

                          if (saat15.isAfter(now)) {
                            await scheduleLocalNotification(
                              notificationId:
                                  yeniId * 10 + 2, // Benzersiz bildirim ID'si
                              soruId:
                                  yeniId, // Tıklanınca açılacak GERÇEK soru ID'si
                              title: bildirimBasligi,
                              body: '$bildirimGovdesi (Saat 15:00)',
                              scheduledTime: saat15,
                              imagePath: yeniSoru.imagePath,
                            );
                          }

                          debugPrint(
                            "Soru $yeniId ile kaydedildi ve bildirimler kuruldu.",
                          );
                        }
                      },
                child: soruKayitState == SoruKayitState.loading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : Text(
                        "Kaydet",
                        style: GoogleFonts.montserrat(
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                        ),
                      ),
              ),
            ),
            const Gap(40),
          ],
        ),
      ),
    );
  }

  Widget _buildImagePickerArea(
    BuildContext context,
    File? selectedImage,
    WidgetRef ref,
  ) {
    return GestureDetector(
      onTap: () => _showImageSourceDialog(context, ref),
      child: Container(
        width: double.infinity,
        height: 200,
        decoration: BoxDecoration(
          color: Theme.of(context).brightness == Brightness.dark
              ? const Color(0xFF1F2937) // Dark mod için koyu gri
              : const Color(0xFFF0F4F8), // Light mod için çok açık mavi/gri
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: Theme.of(context).dividerColor.withValues(alpha: 0.2),
            width: 1.5,
            style: BorderStyle
                .solid, // Tasarımda kesikli çizgi yok gibi ama istenirse değiştirilir
          ),
        ),
        child: selectedImage != null
            ? ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: Image.file(selectedImage, fit: BoxFit.cover),
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.add_photo_alternate_outlined,
                    size: 40,
                    color: Theme.of(context).colorScheme.secondary,
                  ),
                  const Gap(10),
                  Text(
                    "Soru Fotoğrafı Ekle",
                    style: GoogleFonts.montserrat(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  const Gap(5),
                  Text(
                    "Çözemediğin sorunun fotoğrafını yükle",
                    style: GoogleFonts.montserrat(
                      fontWeight: FontWeight.w400,
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
  // --- YENİ UI WIDGETLARI ---

  // Başlık Stili
  TextStyle _sectionTitleStyle(BuildContext context) {
    return GoogleFonts.montserrat(
      fontWeight: FontWeight.w700,
      fontSize: 16,
      color: Theme.of(context).colorScheme.onSurface,
    );
  }

  // 2. Dropdown Görünümlü Buton
  Widget _buildDropdownStyleButton({
    required BuildContext context,
    required String label,
    required String? value,
    required VoidCallback onTap,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.montserrat(
            fontWeight: FontWeight.w700,
            fontSize: 14,
          ),
        ),
        const Gap(8),
        GestureDetector(
          onTap: onTap,
          child: Container(
            height: 50,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: Theme.of(context).inputDecorationTheme.fillColor,
              borderRadius: BorderRadius.circular(25), // Rounded
              border: Border.all(color: Colors.transparent),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    value ?? "Seçiniz",
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: value == null
                          ? Colors.grey
                          : Theme.of(context).colorScheme.onSurface,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                Icon(Icons.keyboard_arrow_down, color: Colors.grey),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // 3. Chip Seçim Listesi (Hata Nedeni, Durum için)
  Widget _buildChipSelection({
    required BuildContext context,
    required List<String> items,
    required String? selectedValue,
    required Function(String) onSelected,
  }) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: items.map((item) {
          final bool isSelected = selectedValue == item;
          return Padding(
            padding: const EdgeInsets.only(right: 10),
            child: GestureDetector(
              onTap: () => onSelected(item),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: isSelected
                      ? const Color(0xFF3B82F6) // Seçiliyse Mavi
                      : Theme.of(
                          context,
                        ).inputDecorationTheme.fillColor, // Değilse Input rengi
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(
                    color: isSelected
                        ? Colors.transparent
                        : Theme.of(context).dividerColor.withValues(alpha: 0.1),
                  ),
                ),
                child: Text(
                  item,
                  style: TextStyle(
                    color: isSelected
                        ? Colors.white
                        : Theme.of(context).colorScheme.secondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  // 5. Doğru Cevap Seçici (Circular)
  Widget _buildAnswerKeySelector(BuildContext context, WidgetRef ref) {
    final options = OptionSoruCevabi.values;
    final currentSelection = ref.watch(soruCevabiProvider);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: options.map((option) {
        final isSelected = currentSelection == option;
        return GestureDetector(
          onTap: () {
            ref.read(soruCevabiProvider.notifier).state = option;
          },
          child: Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: isSelected
                  ? const Color(0xFF3B82F6)
                  : Theme.of(context).inputDecorationTheme.fillColor,
              shape: BoxShape.rectangle,
              borderRadius: BorderRadius.circular(
                16,
              ), // Hafif kareye yakın yuvarlak
            ),
            child: Center(
              child: Text(
                option.name,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isSelected
                      ? Colors.white
                      : Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  void _secimDialog(
    BuildContext context,
    Provider filtered,
    StateProvider query,
    StateProvider selected,
  ) async {
    // Diyalogdan dönen değeri yakala
    final String? secilen = await showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        // ProviderScope ile diyaloğun kendi içinde state yönetimi sağlamış oluyoruz.
        return ProviderScope(
          child: Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20.0),
            ),
            child: Consumer(
              builder: (context, ref, child) {
                // Burada filtrelenmiş listeyi doğrudan provider'dan dinliyoruz.
                final filteredOlan = ref.watch(filtered);

                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    // Arama çubuğu
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16.0,
                        vertical: 8.0,
                      ),
                      child: TextField(
                        decoration: InputDecoration(
                          hintText: "Ara",
                          prefixIcon: const Icon(Icons.search),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.0),
                            borderSide: BorderSide.none,
                          ),
                          filled: true,
                          fillColor: Colors.grey[200],
                        ),
                        onChanged: (value) {
                          // TextField'ın değeri değiştikçe provider'ı güncelliyoruz.
                          // filteredDerslerProvider bu güncellemeyi otomatik olarak algılayıp yeniden filtreleme yapar.
                          ref.read(query.notifier).state = value;
                        },
                      ),
                    ),
                    const Divider(height: 1),

                    // Filtrelenmiş ders listesi
                    Flexible(
                      child: filteredOlan.isEmpty
                          ? const Padding(
                              padding: EdgeInsets.all(20.0),
                              child: Text("Sonuç bulunamadı."),
                            )
                          : ListView.separated(
                              shrinkWrap: true,
                              itemCount: filteredOlan.length,
                              separatorBuilder: (context, index) =>
                                  const Divider(height: 1),
                              itemBuilder: (context, index) {
                                final ders = filteredOlan[index];

                                return ListTile(
                                  title: Text(ders),
                                  onTap: () {
                                    // Seçilen dersi döndürerek diyaloğu kapatıyoruz.
                                    Navigator.of(context).pop(ders);
                                  },
                                );
                              },
                            ),
                    ),
                  ],
                );
              },
            ),
          ),
        );
      },
    );

    // Eğer bir ders seçildiyse (dialog null dönmediyse)
    if (secilen != null) {
      // provider'ın değerini güncelliyoruz.
      ref.read(selected.notifier).state = secilen;
      if (filtered == filteredDerslerProvider) {
        int konununNetlesmesi = dersler.indexOf(secilen);
        setFilterKonBasedOnX(konununNetlesmesi);
      }
    }

    // Diyalog kapandığında arama sorgusunu sıfırla.
    ref.read(query.notifier).state = '';
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
  /*
  Future<void> _handleSelectedImage(File file) async {
    ref.read(ocrProcessingProvider.notifier).state = true;

    try {
      final text = await ref.read(ocrServiceProvider).recognizeFromFile(file);
      ref.read(ocrResultProvider.notifier).state = text;
    } catch (e) {
      ref.read(ocrResultProvider.notifier).state = null;
    } finally {
      //buraya girmeden gemini kısmına git ki herşey netleşene kadar
      //anmasyon dönsün
      /*await getGeminiAnalysis(); // fonksiyonun adı örnek
      final raw = ref.watch(geminiResultProvider) ?? '';
      final reg = RegExp(
        r'ders:\s*(.*?),\s*konu:\s*(.*)$',
        dotAll: true, // \n dahil et
      );
      final match = reg.firstMatch(raw);
      dersAi = match?.group(1)?.trim() ?? '';
      konuAi = match?.group(2)?.trim() ?? '';
      ref.read(selectedDersProvider.notifier).state = dersAi;
      ref.read(selectedKonuProvider.notifier).state = konuAi;

      ref.read(ocrProcessingProvider.notifier).state = false;*/
    }
  }
*/
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
              "Aşağıdaki soru hangi ${dersinKonulari.join(', ')} konuya aittir? Sadece '<Konu Adı>' formatında cevap ver ve başka hiçbir şey ekleme ve listeden bir en yakın konuyu seçmeye çalışarak enazından cevap ver: \n\n$text",
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
      }
      // ignore: unused_catch_clause
    } on GeminiException catch (e) {
      print('Gemini API hatası: ${e.message}');

      if (!mounted) return {'ders': 'Bilinmiyor', 'konu': 'Bilinmiyor'};
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Sunucuya erişilemiyor. Lütfen daha sonra tekrar deneyin.",
          ),
        ),
      );
    } catch (e) {
      print('Bilinmeyen hata: $e');
      if (!mounted) return {'ders': 'Bilinmiyor', 'konu': 'Bilinmiyor'};
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Beklenmeyen bir hata oluştu. Lütfen daha sonra tekrar deneyin.",
          ),
        ),
      );
    }

    return {'ders': 'Bilinmiyor', 'konu': 'Bilinmiyor'};
  }
}
