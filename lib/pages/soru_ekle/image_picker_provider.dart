import 'dart:io';
import 'package:flutter_riverpod/legacy.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

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
          requestFullMetadata: false, // <--- BU SATIRI EKLEYİN (Sorunu Çözer)
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
