// db_model.dart (Varsayımsal dosya)
class DenemeKayit {
  final int? id; // Benzersiz ID
  final int denemeTipi; // 2: TYT, 3: AYT
  final DateTime tarih;
  final String denemeAdi;
  final int
  toplamNet; // Bu projede hesaplanmayacak, sadece alan olarak tutulacak
  final Map<String, Map<String, int>>
  dersSonuclari; // {'Türkçe': {'D': 25, 'Y': 10}}

  DenemeKayit({
    this.id,
    required this.denemeTipi,
    required this.tarih,
    required this.denemeAdi,
    required this.toplamNet,
    required this.dersSonuclari,
  });

  Map<String, dynamic> toMap() {
    // Ders sonuçlarını JSON string'e çevirerek saklayacağız
    final Map<String, dynamic> map = {
      'denemeTipi': denemeTipi,
      'tarih': tarih.toIso8601String(),
      'denemeAdi': denemeAdi,
      'toplamNet': toplamNet,
      // Ders sonuçlarını metin olarak saklamak için basit bir yöntem:
      'dersSonuclari': dersSonuclari.entries
          .map((e) => '${e.key}|D:${e.value['D']}|Y:${e.value['Y']}')
          .join(';'),
    };
    if (id != null) {
      map['id'] = id;
    }
    return map;
  }
}
