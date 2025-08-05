import 'dart:typed_data';
import 'package:image/image.dart' as img;

img.Image? decodeImageInBackground(Uint8List bytes) {
  return img.decodeImage(bytes);
}
