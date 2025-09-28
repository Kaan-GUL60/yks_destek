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

  File? _image;

  final ImagePicker _picker = ImagePicker();

  // Galeriden resim seçme metodu
  Future<void> pickImageFromGallery() async {
    // Fotoğraf galerisi iznini istiyoruz
    PermissionStatus status;
    if (Platform.isAndroid) {
      // Android 13+ için
      status = await Permission.photos.request();
      // Android 12 ve altı fallback
      if (!status.isGranted) {
        status = await Permission.storage.request();
      }
    } else {
      status = await Permission.photos.request();
    }

    if (status.isGranted) {
      //print("İzin verildi, galeri açılıyor...");
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
      );

      if (pickedFile != null) {
        state = File(pickedFile.path);
      } else {
        //print("Galeriden resim seçilmedi.");
      }
    } else if (status.isDenied) {
      //print("Galeri erişim izni reddedildi.");
      // Burada kullanıcıya neden izne ihtiyacınız olduğunu anlatan bir uyarı gösterebilirsiniz.
    } else if (status.isPermanentlyDenied) {
      openAppSettings();
      // Kullanıcıyı uygulama ayarlarına yönlendirebilirsiniz.
      // Örneğin: openAppSettings(); (permission_handler paketinden gelir)
    }
  }

  // Kameradan resim çekme metodu
  Future<void> pickImageFromCamera() async {
    // Kamera iznini istiyoruz
    final status = await Permission.camera.request();

    if (status.isGranted) {
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.camera,
      );

      if (pickedFile != null) {
        state = File(pickedFile.path); // Çekilen resmi state'e atıyoruz.
      }
    } else {
      // Kullanıcı izni reddederse burada bir uyarı gösterebilirsiniz.
      //print('Kamera erişim izni reddedildi.');
    }
  }

  // Seçilen resmi temizleme metodu
  void clearImage() {
    state = null;
  }
}
