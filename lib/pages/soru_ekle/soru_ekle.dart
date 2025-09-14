// ignore_for_file: unused_local_variable, unused_element

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kgsyks_destek/ana_ekran/home_state.dart';
import 'package:kgsyks_destek/analytics_helper/analytics_helper.dart';
import 'package:kgsyks_destek/pages/soru_ekle/image_picker_provider.dart';
import 'package:kgsyks_destek/pages/soru_ekle/list_providers.dart';
import 'package:kgsyks_destek/pages/soru_ekle/listeler.dart';
import 'package:kgsyks_destek/pages/soru_ekle/soru_ekle_provider.dart';
import 'package:kgsyks_destek/pages/soru_ekle/soru_model.dart';
import 'package:kgsyks_destek/sign/save_data.dart';
import 'package:kgsyks_destek/theme_section/app_colors.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

class SoruEkle extends ConsumerStatefulWidget {
  const SoruEkle({super.key});

  @override
  ConsumerState<SoruEkle> createState() => _SoruEkleState();
}

class _SoruEkleState extends ConsumerState<SoruEkle> {
  DateTime? selectedDate;
  final _formKey = GlobalKey<FormState>();
  final _controllerAciklama = TextEditingController();

  Future<void> _selectDate() async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      setState(() {
        selectedDate = picked;
      });
    }
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

    //kayıt işlemler
    final File? selectedImage = ref.watch(imagePickerProvider);
    //kayıt durumu kontrolü için
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
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
      // geri dön butonu gelmesi için Navigator.of(context).push(...) bu şekilde aç bu sayfayı
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            children: [
              _addSoruManuel(
                selectedImage,
                context,
                secilenHataNedeni,
                secilenDurum,
                secilenDers,
                secilenKonu,
                soruKayitState,
                auth,
              ),
              const Gap(20),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(children: [
                  
                ],),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Column _addSoruManuel(
    File? selectedImage,
    BuildContext context,
    String? secilenHataNedeni,
    String? secilenDurum,
    String? secilenDers,
    String? secilenKonu,
    SoruKayitState soruKayitState,
    UserAuth auth,
  ) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 10),
        Padding(
          padding: const EdgeInsets.only(left: 15.0, right: 15),
          child: Column(
            children: [
              addSoru(selectedImage, context),
              Padding(
                padding: const EdgeInsets.only(left: 15, right: 15, top: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: _secimButton(
                        context,
                        secilenHataNedeni,
                        "Hata Nedeni",
                        filteredHataNedeniProvider,
                        searchQueryHataNedeniProvider,
                        selectedHataNedeniProvider,
                      ),
                    ),
                    Gap(10),
                    Expanded(
                      child: _secimButton(
                        context,
                        secilenDurum,
                        "Durum",
                        filteredDurumProvider,
                        searchQueryDurumProvider,
                        selectedDurumProvider,
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 15, right: 15, top: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: _secimButton(
                        context,
                        secilenDers,
                        "Ders",
                        filteredDerslerProvider,
                        searchQueryDersProvider,
                        selectedDersProvider,
                      ),
                    ),
                    Gap(10),
                    Expanded(
                      child: _secimButton(
                        context,
                        secilenKonu,
                        "Konu",
                        filteredKonuProvider,
                        searchQueryKonuProvider,
                        selectedKonuProvider,
                      ),
                    ),
                  ],
                ),
              ),
              Gap(10),

              _soruCevabSecim(),
              SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                child: SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    style: ButtonStyle(
                      shape: WidgetStatePropertyAll(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                      ),
                    ),
                    onPressed: _selectDate,
                    child: Text(
                      selectedDate == null
                          ? "Hatırlatıcı Tarihi Seç"
                          : "Seçilen: ${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}",
                      style: TextStyle(
                        color: AppColors.shadow,
                        letterSpacing: 1,
                        fontFamily: GoogleFonts.montserrat(
                          fontWeight: FontWeight.w900,
                        ).fontFamily,
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Form(
                      key: _formKey,
                      child: TextFormField(
                        controller: _controllerAciklama,
                        decoration: InputDecoration(
                          labelText: "Soru Açıklaması",
                          fillColor: AppColors.surface,
                          filled: true,
                          border: OutlineInputBorder(), // M3 ile uyumlu
                        ),
                        maxLines: 5,
                        minLines: 2,
                        maxLength: 255,
                        keyboardType: TextInputType.text, // multiline değil
                        textInputAction: TextInputAction.done,
                        validator: (value) {
                          if (value != null && value.length > 255) {
                            return "255 karakteri geçemez";
                          }
                          return null;
                        },
                      ),
                    ),
                    Gap(10),
                    SizedBox(
                      width: MediaQuery.of(context).size.height * 0.3,
                      child: FilledButton(
                        style: ButtonStyle(
                          backgroundColor: const WidgetStatePropertyAll(
                            AppColors.colorSurface,
                          ),
                          shape: WidgetStatePropertyAll(
                            RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15.0),
                            ),
                          ),
                        ),
                        onPressed: soruKayitState == SoruKayitState.loading
                            ? null
                            : () async {
                                // 1. Önce gerekli alanların dolu olup olmadığını kontrol et
                                final secilenSoruCevap = ref.read(
                                  soruCevabiProvider,
                                );
                                if (secilenDers == null ||
                                    secilenKonu == null ||
                                    secilenDurum == null ||
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
                                final appDir =
                                    await getApplicationDocumentsDirectory();
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
                                await savedImage.writeAsBytes(
                                  compressedImageBytes,
                                );

                                // 2. Verilerden SoruModel nesnesi oluştur
                                final yeniSoru = SoruModel(
                                  ders: secilenDers,
                                  konu: secilenKonu,
                                  durum: secilenDurum,
                                  hataNedeni: secilenHataNedeni,
                                  soruCevap: secilenSoruCevap.name,
                                  imagePath:
                                      savedImage.path, // Resmin yolunu al
                                  aciklama: _controllerAciklama.text,
                                  eklenmeTarihi: DateTime.now(),
                                  hatirlaticiTarihi: selectedDate,
                                );

                                auth.soruSayiArtir("soruSayi");
                                AnalyticsService().trackCount(
                                  "buttonClick",
                                  "soru_eklendi",
                                ); // soru sayıyor

                                // 3. Provider aracılığıyla veritabanına kaydet
                                ref
                                    .read(soruNotifierProvider.notifier)
                                    .addSoru(yeniSoru);
                              },
                        child: soruKayitState == SoruKayitState.loading
                            ? const CircularProgressIndicator(
                                color: Colors.white,
                              )
                            : Text(
                                "Kaydet",

                                style: TextStyle(
                                  letterSpacing: 2,
                                  color: AppColors.shadow,
                                  fontFamily: GoogleFonts.montserrat(
                                    fontWeight: FontWeight.w900,
                                  ).fontFamily,
                                ),
                              ),
                      ),
                    ),
                    SizedBox(height: 20),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Padding addSoru(File? selectedImage, BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 15, right: 15, top: 10),
      child: GestureDetector(
        child: ClipRRect(
          borderRadius: BorderRadius.circular(18),
          // Duruma göre ya seçilen resmi ya da placeholder'ı göster
          child: selectedImage != null
              ? Image.file(selectedImage, fit: BoxFit.cover)
              : Image.asset(
                  'assets/images/soru_ekle.png', // pubspec.yaml'da belirttiğiniz resim
                  fit: BoxFit.cover,
                ),
        ),
        onTap: () {
          //açılır meni çağır galeri veya kamera ile resim getir burdan sonra
          _showImageSourceDialog(context, ref);
        },
      ),
    );
  }

  SegmentedButton<OptionSoruCevabi> _soruCevabSecim() {
    return SegmentedButton<OptionSoruCevabi>(
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
      selected: {ref.watch(soruCevabiProvider)},
      onSelectionChanged: (newSelection) {
        ref.read(soruCevabiProvider.notifier).state = newSelection.first;
      },
      multiSelectionEnabled: false,
      // kapsül arka plan
      style: ButtonStyle(
        padding: const WidgetStatePropertyAll(
          EdgeInsets.symmetric(horizontal: 8),
        ),
        backgroundColor: WidgetStateProperty.resolveWith((states) {
          return Colors.indigo[300]; // kapsül zemin rengi
        }),
        shape: WidgetStatePropertyAll(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(40), // kapsül köşe yuvarlatma
          ),
        ),
        // her segment için daire
        side: const WidgetStatePropertyAll(
          BorderSide(color: Colors.black, width: 2),
        ),
        foregroundColor: WidgetStateProperty.resolveWith((states) {
          return states.contains(WidgetState.selected)
              ? Colors.white
              : Colors.black;
        }),
        overlayColor: const WidgetStatePropertyAll(Colors.transparent),
      ),
    );
  }

  FilledButton _secimButton(
    BuildContext context,
    String? secilenAT,
    String baslik,
    Provider filtered,
    StateProvider query,
    StateProvider selected,
  ) {
    return FilledButton(
      style: ButtonStyle(
        shape: WidgetStatePropertyAll(
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
        ),
      ),
      onPressed: () {
        // Dialog'u çağırıyoruz.

        if (filtered == filteredKonuProvider) {
          if (filterKonular.isEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Lütfen önce ders seçiniz.')),
            );
            return;
          }
        }

        _secimDialog(context, filtered, query, selected);
      },

      // Butonun metnini provider'dan gelen değere göre belirliyoruz.
      child: Text(
        (secilenAT != null && secilenAT.length > 20)
            ? "${secilenAT.substring(0, 20)}..."
            : secilenAT ?? baslik,
        style: TextStyle(
          color: AppColors.shadow,
          fontSize: 16,
          letterSpacing: 1,
          fontFamily: GoogleFonts.montserrat(
            fontWeight: FontWeight.w900,
          ).fontFamily,
        ),
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
                  // Diyalogu kapat
                  Navigator.of(context).pop();
                  // Galeriden resim seçme fonksiyonunu tetikle
                  ref.read(imagePickerProvider.notifier).pickImageFromGallery();
                },
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Kameradan Çek'),
                onTap: () {
                  // Diyalogu kapat
                  Navigator.of(context).pop();
                  // Kameradan resim çekme fonksiyonunu tetikle
                  ref.read(imagePickerProvider.notifier).pickImageFromCamera();
                },
              ),
            ],
          ),
        );
      },
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
}
