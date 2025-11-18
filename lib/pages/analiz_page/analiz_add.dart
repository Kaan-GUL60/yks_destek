import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';

import 'package:kgsyks_destek/pages/analiz_page/providers.dart';

import 'package:kgsyks_destek/pages/soru_ekle/list_providers.dart';

class AnalizAddPage extends ConsumerWidget {
  final int durumId;
  const AnalizAddPage({super.key, required this.durumId});
  // AnalizAddPage.dart içindeki _saveData metodunun yerine kullanabilirsiniz

  String getTitleByDurumId(int durumId) {
    switch (durumId) {
      case 0:
        return 'Hedef Ekle';
      case 1:
        return 'Ders Çalışma Süresi Ekle';
      case 2:
        return 'TYT Sınavı Ekle';
      case 3:
        return 'AYT Sınavı Ekle';
      case 4:
        return 'Çözülen Soru Sayısı Ekle';
      default:
        return 'Genel Analiz Ekle';
    }
  }

  Future<void> _showDatePicker(BuildContext context, WidgetRef ref) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: ref.read(secilenTarihProvider) ?? DateTime.now(),
      firstDate: DateTime(2024),
      lastDate: DateTime(2040),
    );

    if (picked != null) {
      ref.read(secilenTarihProvider.notifier).state = picked;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final DateTime? secilenTarih = ref.watch(secilenTarihProvider);
    final TextEditingController denemeAdiController = TextEditingController();
    final Map<String, TextEditingController> dogruCevapControllers = {};
    final Map<String, TextEditingController> yanlisCevapControllers = {};
    const List<String> dersler = [
      "Türkçe",
      "Tarih",
      "Coğrafya",
      "Felsefe",
      "Din",
      "Matematik",
      "Fizik",
      "Kimya",
      "Biyoloji",
    ];
    const List<String> aytDersler = [
      "Matematik", // AYT Matematik
      "Fizik",
      "Kimya",
      "Biyoloji",
      "Edebiyat", // AYT Edebiyat
      "Tarih", // AYT Tarih
      "Coğrafya", // AYT Coğrafya
      "Felsefe", // AYT Felsefe (Sosyal-2 Felsefe Grubu)
      "Din", // AYT Din (Sosyal-2 Din)
    ];

    // Ders süresi için controller ve provider
    final dersSuresiController = ref.watch(studyDurationProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(getTitleByDurumId(durumId)),
        centerTitle: true,
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                const Gap(20),
                if (durumId == 1)
                  Card(
                    elevation: 0,
                    color: Theme.of(context).colorScheme.primaryContainer,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                "Tarih",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Row(
                                children: [
                                  Text(
                                    secilenTarih == null
                                        ? 'Tarih Seçilmedi'
                                        : '${secilenTarih.day}/${secilenTarih.month}/${secilenTarih.year}',
                                    style: const TextStyle(fontSize: 16),
                                  ),
                                  const Gap(8),
                                  IconButton(
                                    icon: const Icon(Icons.calendar_today),
                                    onPressed: () =>
                                        _showDatePicker(context, ref),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const Gap(16),
                          // Ders Süresi Satırı
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                "Ders Süresi (Saat)",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(
                                width: 80,
                                child: TextField(
                                  controller: dersSuresiController,
                                  textAlign: TextAlign.center,
                                  keyboardType: TextInputType.number,
                                  decoration: const InputDecoration(
                                    border: OutlineInputBorder(),
                                    hintText: '0-20',
                                    contentPadding: EdgeInsets.all(8.0),
                                  ),
                                  onChanged: (value) {
                                    // Girilen değeri anlık kontrol etme
                                    final int? sure = int.tryParse(value);
                                    if (sure != null &&
                                        (sure < 0 || sure > 20)) {
                                      // Hata durumunda ne yapılacağını buraya ekleyebilirsiniz
                                      // Örneğin: dersSuresiController.clear();
                                    }
                                  },
                                ),
                              ),
                            ],
                          ),
                          const Gap(20),
                          // KAYDET BUTONU
                          ElevatedButton(
                            onPressed: () => _saveData(context, ref),
                            child: const Text('Kaydet'),
                          ),
                        ],
                      ),
                    ),
                  ),

                if (durumId == 2)
                  Card(
                    elevation: 0,
                    color: Theme.of(context).colorScheme.primaryContainer,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // 1. Deneme Adı ve Tarih Seçici Satırı
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              // Deneme Adı (Lesson Name) - TextField
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.only(right: 16.0),
                                  child: TextField(
                                    controller: denemeAdiController,
                                    // İmleç Rengi Siyah
                                    cursorColor: Colors.black,
                                    decoration: InputDecoration(
                                      labelText: "Deneme Adı",
                                      hintText: "Deneme Adı",

                                      // Siyah ve Kesintisiz Çerçeve Tanımı
                                      // ------------------------------------
                                      // Bu, labelText'in kenarlığı kesmesini engeller.
                                      border: const OutlineInputBorder(
                                        borderRadius: BorderRadius.all(
                                          Radius.circular(4.0),
                                        ),
                                        borderSide: BorderSide(
                                          color: Colors.black,
                                          width: 1.0,
                                        ),
                                      ),

                                      // Normal Durumda Kenarlık (Siyah ve Sabit)
                                      enabledBorder: const OutlineInputBorder(
                                        borderRadius: BorderRadius.all(
                                          Radius.circular(4.0),
                                        ),
                                        borderSide: BorderSide(
                                          color: Colors.black,
                                          width: 1.0,
                                        ),
                                      ),

                                      // Odaklanıldığında Kenarlık (Aynı Siyah Stil)
                                      focusedBorder: const OutlineInputBorder(
                                        borderRadius: BorderRadius.all(
                                          Radius.circular(4.0),
                                        ),
                                        borderSide: BorderSide(
                                          color: Colors.black,
                                          width:
                                              1.0, // Kalınlığı 1.0'da tutarak kesiksiz görünüm sağlar
                                        ),
                                      ),

                                      // ------------------------------------
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                            horizontal: 10,
                                            vertical: 8,
                                          ),
                                    ),
                                    style: const TextStyle(fontSize: 16),
                                  ),
                                ),
                              ),

                              // Tarih Seçici (Date Picker)
                              Row(
                                children: [
                                  Text(
                                    secilenTarih ==
                                            null // Placeholder
                                        ? 'Tarih Seçilmedi'
                                        : '${secilenTarih.day}/${secilenTarih.month}/${secilenTarih.year}',
                                    style: const TextStyle(fontSize: 16),
                                  ),
                                  // const Gap(8), // Use Gap or SizedBox
                                  const SizedBox(width: 8),
                                  IconButton(
                                    icon: const Icon(Icons.calendar_today),
                                    onPressed: () => _showDatePicker(
                                      context,
                                      ref,
                                    ), // Placeholder
                                  ),
                                ],
                              ),
                            ],
                          ),

                          // const Gap(16), // Spacer
                          const SizedBox(height: 16),

                          // Başlıklar Satırı (Headers)
                          const Padding(
                            padding: EdgeInsets.only(top: 8.0, bottom: 8.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "Ders Adı",
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Row(
                                  children: [
                                    SizedBox(
                                      width: 60, // Width for Doğru (Correct)
                                      child: Center(
                                        child: Text(
                                          "Doğru",
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ),
                                    SizedBox(
                                      width: 12,
                                    ), // Space between Correct and Incorrect
                                    SizedBox(
                                      width: 60, // Width for Yanlış (Incorrect)
                                      child: Center(
                                        child: Text(
                                          "Yanlış",
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),

                          // Ayracı (Divider)
                          const Divider(),

                          // Dersler ve Metin Girişleri (Subjects and Text Fields)
                          ...dersler.map((ders) {
                            // Placeholder: dersler list
                            const OutlineInputBorder
                            fixedBorder = OutlineInputBorder(
                              borderRadius: BorderRadius.all(
                                Radius.circular(4.0),
                              ),
                              borderSide: BorderSide(
                                color: Colors
                                    .black, // Veya Theme.of(context).colorScheme.onSurface gibi bir renk
                                width: 1.0,
                              ),
                            );
                            return Padding(
                              padding: const EdgeInsets.symmetric(
                                vertical: 8.0,
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  // Ders Adı (Subject Name) - Left Aligned
                                  Expanded(
                                    child: Text(
                                      ders,
                                      style: const TextStyle(fontSize: 16),
                                    ),
                                  ),

                                  // Doğru ve Yanlış Sayıları (Correct and Incorrect Counts) - Right Aligned
                                  Row(
                                    children: [
                                      // Doğru Sayısı (Correct Count)
                                      SizedBox(
                                        width: 60,
                                        child: TextField(
                                          controller:
                                              dogruCevapControllers[ders], // Placeholder
                                          textAlign: TextAlign.center,
                                          keyboardType: TextInputType.number,
                                          cursorColor: Colors.black,
                                          decoration: const InputDecoration(
                                            enabledBorder: fixedBorder,
                                            focusedBorder: fixedBorder,
                                            border: fixedBorder,
                                            contentPadding: EdgeInsets.all(8.0),
                                            hintText: '0',
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 12), // Space
                                      // Yanlış Sayısı (Incorrect Count)
                                      SizedBox(
                                        width: 60,
                                        child: TextField(
                                          controller:
                                              yanlisCevapControllers[ders], // Placeholder
                                          textAlign: TextAlign.center,
                                          keyboardType: TextInputType.number,
                                          cursorColor: Colors.black,
                                          decoration: const InputDecoration(
                                            enabledBorder: fixedBorder,
                                            focusedBorder: fixedBorder,
                                            border: fixedBorder,
                                            contentPadding: EdgeInsets.all(8.0),
                                            hintText: '0',
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            );
                          }),

                          // const Gap(24), // Spacer before button
                          const SizedBox(height: 24),

                          // Kaydet Butonu (Save Button)
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () {}, // ⬅️ BURAYI KULLANIN
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                ),
                                textStyle: const TextStyle(fontSize: 18),
                              ),
                              child: const Text("Kaydet"),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                if (durumId == 3)
                  Card(
                    elevation: 0,
                    color: Theme.of(context).colorScheme.primaryContainer,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // 1. Deneme Adı ve Tarih Seçici Satırı
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              // Deneme Adı (Lesson Name) - TextField
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.only(right: 16.0),
                                  child: TextField(
                                    controller: denemeAdiController,
                                    // İmleç Rengi Siyah
                                    cursorColor: Colors.black,
                                    decoration: InputDecoration(
                                      labelText: "Deneme Adı",
                                      hintText: "Deneme Adı",

                                      // Siyah ve Kesintisiz Çerçeve Tanımı
                                      // ------------------------------------
                                      // Bu, labelText'in kenarlığı kesmesini engeller.
                                      border: const OutlineInputBorder(
                                        borderRadius: BorderRadius.all(
                                          Radius.circular(4.0),
                                        ),
                                        borderSide: BorderSide(
                                          color: Colors.black,
                                          width: 1.0,
                                        ),
                                      ),

                                      // Normal Durumda Kenarlık (Siyah ve Sabit)
                                      enabledBorder: const OutlineInputBorder(
                                        borderRadius: BorderRadius.all(
                                          Radius.circular(4.0),
                                        ),
                                        borderSide: BorderSide(
                                          color: Colors.black,
                                          width: 1.0,
                                        ),
                                      ),

                                      // Odaklanıldığında Kenarlık (Aynı Siyah Stil)
                                      focusedBorder: const OutlineInputBorder(
                                        borderRadius: BorderRadius.all(
                                          Radius.circular(4.0),
                                        ),
                                        borderSide: BorderSide(
                                          color: Colors.black,
                                          width:
                                              1.0, // Kalınlığı 1.0'da tutarak kesiksiz görünüm sağlar
                                        ),
                                      ),

                                      // ------------------------------------
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                            horizontal: 10,
                                            vertical: 8,
                                          ),
                                    ),
                                    style: const TextStyle(fontSize: 16),
                                  ),
                                ),
                              ),

                              // Tarih Seçici (Date Picker)
                              Row(
                                children: [
                                  Text(
                                    secilenTarih ==
                                            null // Placeholder
                                        ? 'Tarih Seçilmedi'
                                        : '${secilenTarih.day}/${secilenTarih.month}/${secilenTarih.year}',
                                    style: const TextStyle(fontSize: 16),
                                  ),
                                  // const Gap(8), // Use Gap or SizedBox
                                  const SizedBox(width: 8),
                                  IconButton(
                                    icon: const Icon(Icons.calendar_today),
                                    onPressed: () => _showDatePicker(
                                      context,
                                      ref,
                                    ), // Placeholder
                                  ),
                                ],
                              ),
                            ],
                          ),

                          // const Gap(16), // Spacer
                          const SizedBox(height: 16),

                          // Başlıklar Satırı (Headers)
                          const Padding(
                            padding: EdgeInsets.only(top: 8.0, bottom: 8.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "Ders Adı",
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Row(
                                  children: [
                                    SizedBox(
                                      width: 60, // Width for Doğru (Correct)
                                      child: Center(
                                        child: Text(
                                          "Doğru",
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ),
                                    SizedBox(
                                      width: 12,
                                    ), // Space between Correct and Incorrect
                                    SizedBox(
                                      width: 60, // Width for Yanlış (Incorrect)
                                      child: Center(
                                        child: Text(
                                          "Yanlış",
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),

                          // Ayracı (Divider)
                          const Divider(),

                          // Dersler ve Metin Girişleri (Subjects and Text Fields)
                          ...aytDersler.map((ders) {
                            // Placeholder: dersler list
                            const OutlineInputBorder
                            fixedBorder = OutlineInputBorder(
                              borderRadius: BorderRadius.all(
                                Radius.circular(4.0),
                              ),
                              borderSide: BorderSide(
                                color: Colors
                                    .black, // Veya Theme.of(context).colorScheme.onSurface gibi bir renk
                                width: 1.0,
                              ),
                            );
                            return Padding(
                              padding: const EdgeInsets.symmetric(
                                vertical: 8.0,
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  // Ders Adı (Subject Name) - Left Aligned
                                  Expanded(
                                    child: Text(
                                      ders,
                                      style: const TextStyle(fontSize: 16),
                                    ),
                                  ),

                                  // Doğru ve Yanlış Sayıları (Correct and Incorrect Counts) - Right Aligned
                                  Row(
                                    children: [
                                      // Doğru Sayısı (Correct Count)
                                      SizedBox(
                                        width: 60,
                                        child: TextField(
                                          controller:
                                              dogruCevapControllers[ders], // Placeholder
                                          textAlign: TextAlign.center,
                                          keyboardType: TextInputType.number,
                                          cursorColor: Colors.black,
                                          decoration: const InputDecoration(
                                            enabledBorder: fixedBorder,
                                            focusedBorder: fixedBorder,
                                            border: fixedBorder,
                                            contentPadding: EdgeInsets.all(8.0),
                                            hintText: '0',
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 12), // Space
                                      // Yanlış Sayısı (Incorrect Count)
                                      SizedBox(
                                        width: 60,
                                        child: TextField(
                                          controller:
                                              yanlisCevapControllers[ders], // Placeholder
                                          textAlign: TextAlign.center,
                                          keyboardType: TextInputType.number,
                                          cursorColor: Colors.black,
                                          decoration: const InputDecoration(
                                            enabledBorder: fixedBorder,
                                            focusedBorder: fixedBorder,
                                            border: fixedBorder,
                                            contentPadding: EdgeInsets.all(8.0),
                                            hintText: '0',
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            );
                          }),

                          // const Gap(24), // Spacer before button
                          const SizedBox(height: 24),

                          // Kaydet Butonu (Save Button)
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () {}, // ⬅️ BURAYI KULLANIN
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                ),
                                textStyle: const TextStyle(fontSize: 18),
                              ),
                              child: const Text("Kaydet"),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _saveData(BuildContext context, WidgetRef ref) async {
    final selectedDate = ref.read(secilenTarihProvider);
    final studyDurationText = ref.read(studyDurationProvider).text;
    final studyDuration = int.tryParse(studyDurationText);

    if (selectedDate == null ||
        studyDuration == null ||
        studyDuration < 0 ||
        studyDuration > 20) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Lütfen geçerli bir tarih ve ders süresi girin.'),
        ),
      );
      return;
    }

    final dbService = ref.read(databaseServiceProvider);
    final existingRecord = await dbService.getDataByDate(selectedDate);

    if (existingRecord != null) {
      final shouldUpdate = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Kayıt Bulundu'),
          content: const Text(
            'Bu tarihe ait bir ders süresi kaydı zaten var. Üzerine yazılsın mı?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('İptal'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Evet, Üzerine Yaz'),
            ),
          ],
        ),
      );

      if (shouldUpdate == true) {
        await dbService.updateData(selectedDate, studyDuration);
        print('Kayıt güncellendi: $selectedDate, Süre: $studyDuration');
      } else {
        return;
      }
    } else {
      await dbService.insertData(selectedDate, studyDuration);
      print('Yeni kayıt eklendi: $selectedDate, Süre: $studyDuration');
    }

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Veri başarıyla kaydedildi!')));
    ref.invalidate(analysisProvider);
    Navigator.pop(context); // geri dön
    // popup sonrası veriyi yenile
  }
}
