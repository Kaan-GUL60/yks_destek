import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import 'package:kgsyks_destek/pages/soru_ekle/image_picker_provider.dart';

import 'package:kgsyks_destek/pages/soru_ekle/list_providers.dart';
import 'package:kgsyks_destek/pages/soru_ekle/listeler.dart';
import 'package:kgsyks_destek/pages/soru_ekle/soru_ekle_provider.dart';
import 'package:kgsyks_destek/pages/soru_ekle/soru_model.dart';
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
      appBar: AppBar(title: const Text("Soru Ekle"), centerTitle: true),
      // geri dön butonu gelmesi için Navigator.of(context).push(...) bu şekilde aç bu sayfayı
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 50),

            Padding(
              padding: const EdgeInsets.only(left: 15.0, right: 15),
              child: Card.outlined(
                color: Theme.of(context).colorScheme.primaryContainer,
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(
                        left: 10,
                        right: 10,
                        top: 5,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _secimButton(
                            context,
                            secilenHataNedeni,
                            "Hata Nedeni",
                            filteredHataNedeniProvider,
                            searchQueryHataNedeniProvider,
                            selectedHataNedeniProvider,
                          ),
                          _secimButton(
                            context,
                            secilenDurum,
                            "Durum",
                            filteredDurumProvider,
                            searchQueryDurumProvider,
                            selectedDurumProvider,
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(
                        left: 10,
                        right: 10,
                        top: 5,
                      ),
                      child: GestureDetector(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
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
                    ),
                    Padding(
                      padding: const EdgeInsets.only(
                        left: 10,
                        right: 10,
                        top: 5,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _secimButton(
                            context,
                            secilenDers,
                            "Ders",
                            filteredDerslerProvider,
                            searchQueryDersProvider,
                            selectedDersProvider,
                          ),
                          _secimButton(
                            context,
                            secilenKonu,
                            "Konu",
                            filteredKonuProvider,
                            searchQueryKonuProvider,
                            selectedKonuProvider,
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: 16),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 15),
                      child: SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
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
                                filled: true,
                                border: OutlineInputBorder(), // M3 ile uyumlu
                              ),
                              maxLines: 5,
                              minLines: 1,
                              maxLength: 255,
                              keyboardType:
                                  TextInputType.text, // multiline değil
                              textInputAction: TextInputAction.done,
                              validator: (value) {
                                if (value != null && value.length > 255) {
                                  return "255 karakteri geçemez";
                                }
                                return null;
                              },
                            ),
                          ),
                          SizedBox(height: 20),
                          SizedBox(
                            width: MediaQuery.of(context).size.height * 0.3,
                            child: FilledButton(
                              style: ButtonStyle(
                                shape: WidgetStatePropertyAll(
                                  RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(15.0),
                                  ),
                                ),
                              ),
                              onPressed:
                                  soruKayitState == SoruKayitState.loading
                                  ? null
                                  : () async {
                                      // 1. Önce gerekli alanların dolu olup olmadığını kontrol et
                                      if (secilenDers == null ||
                                          secilenKonu == null ||
                                          secilenDurum == null ||
                                          secilenHataNedeni == null ||
                                          selectedImage == null) {
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
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
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
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

                                      // Dosyayı geçici yoldan kalıcı yola kopyala
                                      final File savedImage =
                                          await selectedImage2.copy(
                                            savedImagePath,
                                          );

                                      // 2. Verilerden SoruModel nesnesi oluştur
                                      final yeniSoru = SoruModel(
                                        ders: secilenDers,
                                        konu: secilenKonu,
                                        durum: secilenDurum,
                                        hataNedeni: secilenHataNedeni,
                                        imagePath:
                                            savedImage.path, // Resmin yolunu al
                                        aciklama: _controllerAciklama.text,
                                        eklenmeTarihi: DateTime.now(),
                                        hatirlaticiTarihi: selectedDate,
                                      );

                                      // 3. Provider aracılığıyla veritabanına kaydet
                                      ref
                                          .read(soruNotifierProvider.notifier)
                                          .addSoru(yeniSoru);
                                    },
                              child: soruKayitState == SoruKayitState.loading
                                  ? const CircularProgressIndicator(
                                      color: Colors.white,
                                    )
                                  : const Text(
                                      "Kaydet",
                                      style: TextStyle(
                                        fontWeight: FontWeight.w700,
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
            ),
          ],
        ),
      ),
    );
  }

  ElevatedButton _secimButton(
    BuildContext context,
    String? secilenAT,
    String baslik,
    Provider filtered,
    StateProvider query,
    StateProvider selected,
  ) {
    return ElevatedButton(
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
