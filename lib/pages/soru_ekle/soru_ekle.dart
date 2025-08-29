import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import 'package:kgsyks_destek/pages/soru_ekle/list_providers.dart';
import 'package:kgsyks_destek/pages/soru_ekle/listeler.dart';

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

  @override
  Widget build(BuildContext context) {
    // selectedCourseProvider'ı dinliyoruz.
    final String? secilenDers = ref.watch(selectedDersProvider);
    final String? secilenDurum = ref.watch(selectedDurumProvider);
    final String? secilenHataNedeni = ref.watch(selectedHataNedeniProvider);
    final String? secilenKonu = ref.watch(selectedKonuProvider);

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
                          borderRadius: BorderRadius.circular(10),
                          child: Image.asset(
                            "assets/images/soru_ekle.png",
                            width: double.infinity,
                            fit: BoxFit.cover,
                          ),
                        ),
                        onTap: () {
                          //açılır meni çağır galeri veya kamera ile resim getir burdan sonra
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
                              onPressed: () {
                                if (_formKey.currentState!.validate()) {
                                  // Geçerli, işlem devam edebilir
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text("Başarılı!")),
                                  );
                                } else {
                                  // Hata varsa SnackBar ile uyar
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        "Hata: 255 karakteri geçemez",
                                      ),
                                    ),
                                  );
                                }
                              },
                              child: Text(
                                "Kaydet",
                                style: TextStyle(fontWeight: FontWeight.w700),
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
      child: Text(secilenAT ?? baslik),
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
        print("-------------------$filterKonular");
      }
    }

    // Diyalog kapandığında arama sorgusunu sıfırla.
    ref.read(query.notifier).state = '';
  }
}
