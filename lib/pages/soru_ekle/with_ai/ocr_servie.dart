import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

final ocrServiceProvider = Provider<OcrService>((ref) {
  final s = OcrService();
  ref.onDispose(() => s.dispose());
  return s;
});

final ocrResultProvider = StateProvider.autoDispose<String?>((ref) => null);
final geminiResultProvider = StateProvider<String?>((ref) => null);

final ocrProcessingProvider = StateProvider.autoDispose<bool>((ref) => false);

final aiSolutionProvider = StateProvider.autoDispose<String?>((ref) => null);

class OcrService {
  final TextRecognizer _textRecognizer = TextRecognizer(
    script: TextRecognitionScript.latin,
  );

  Future<String> recognizeFromFile(File file) async {
    final inputImage = InputImage.fromFile(file);
    final RecognizedText recognizedText = await _textRecognizer.processImage(
      inputImage,
    );
    return recognizedText.text; // ocr edilmiş text dönüyor burda
  }

  void dispose() {
    _textRecognizer.close();
  }
}
