import 'dart:io';
import 'dart:typed_data';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image/image.dart' as img;

Future<InputImage> prepareInputImage(String path, Uint8List bytes) async {
  try {
    img.Image? image = img.decodeImage(bytes);
    if (image != null) {
      image = img.grayscale(image);
      image = img.contrast(image, contrast: 120);

      final tempFile = File('${Directory.systemTemp.path}/proc.jpg');
      tempFile.writeAsBytesSync(img.encodeJpg(image));
      return InputImage.fromFilePath(tempFile.path);
    }
  } catch (e) {
    print('預處理失敗: $e');
  }
  return InputImage.fromFilePath(path);
}
