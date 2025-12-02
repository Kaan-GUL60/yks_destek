import 'dart:io';
import 'package:flutter_riverpod/legacy.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

// Bu provider, seçilen resim dosyasının durumunu tutar.
// Başlangıçta null (resim seçilmemiş).
final imagePickerProvider =
    StateNotifierProvider.autoDispose<ImagePickerNotifier, File?>((ref) {
      return ImagePickerNotifier();
    });

class ImagePickerNotifier extends StateNotifier<File?> {
  // Başlangıç durumunu null olarak ayarlıyoruz.
  ImagePickerNotifier() : super(null);

  //File? _image;

  final ImagePicker _picker = ImagePicker();

  // Galeriden resim seçme metodu
  Future<void> pickImageFromGallery() async {
    bool hasPermission = false;

    // 1. Platforma Göre İzin Kontrolü
    if (Platform.isAndroid) {
      // Android 13+ (SDK 33) için 'photos', eskiler için 'storage'
      // permission_handler bunu genellikle otomatik yönetir ama manuel kontrol ekledik
      final statusPhotos = await Permission.photos.status;

      if (statusPhotos.isGranted || statusPhotos.isLimited) {
        hasPermission = true;
      } else {
        // İzin yoksa iste
        final requestPhotos = await Permission.photos.request();
        if (requestPhotos.isGranted || requestPhotos.isLimited) {
          hasPermission = true;
        } else {
          // Android 12 ve altı için Storage denemesi
          final statusStorage = await Permission.storage.request();
          if (statusStorage.isGranted) {
            hasPermission = true;
          }
        }
      }

      if (!hasPermission) {
        // İzin verilmediyse ayarlara yönlendir
        await openAppSettings();
        return;
      }
    }
    // İYİLEŞTİRME: iOS için izin sormuyoruz.
    // image_picker, iOS'te sistem seçicisini açar ve kullanıcı sadece seçtiği
    // fotoğrafı uygulamaya verir. Ekstra "Tüm galeriye eriş" iznine gerek yoktur.

    // 2. Resmi Seç
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80, // Performans için kalite optimizasyonu
      );

      if (pickedFile != null) {
        state = File(pickedFile.path);
      }
    } catch (e) {
      // Hata durumunda (örneğin iOS'te kullanıcı iptal ederse veya kısıtlama varsa)
      // print("Resim seçme hatası: $e");
    }
  }

  // --- KAMERADAN ÇEKME ---
  Future<void> pickImageFromCamera() async {
    // Kamera için her iki platformda da izin şarttır
    var status = await Permission.camera.status;

    if (!status.isGranted) {
      status = await Permission.camera.request();
    }

    if (status.isGranted) {
      try {
        final XFile? pickedFile = await _picker.pickImage(
          source: ImageSource.camera,
          imageQuality: 80,
        );

        if (pickedFile != null) {
          state = File(pickedFile.path);
        }
      } catch (e) {
        // print("Kamera hatası: $e");
      }
    } else if (status.isPermanentlyDenied) {
      // Kullanıcı kalıcı olarak reddettiyse ayarlara yolla
      await openAppSettings();
    }
  }

  // Seçilen resmi temizleme metodu
  void clearImage() {
    state = null;
  }
}
