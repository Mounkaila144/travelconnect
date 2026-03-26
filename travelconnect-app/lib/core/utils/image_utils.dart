import 'dart:io';

import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';

Future<File> resizeImage(File imageFile) async {
  final bytes = await imageFile.readAsBytes();
  img.Image? image = img.decodeImage(bytes);

  if (image == null) {
    throw Exception('Unable to decode image');
  }

  // Crop to square (center crop)
  final size = image.width < image.height ? image.width : image.height;
  img.Image cropped = img.copyCrop(
    image,
    x: (image.width - size) ~/ 2,
    y: (image.height - size) ~/ 2,
    width: size,
    height: size,
  );

  // Resize to 400x400
  img.Image resized = img.copyResize(
    cropped,
    width: 400,
    height: 400,
    interpolation: img.Interpolation.average,
  );

  // Encode as JPEG with 80% quality
  final resizedBytes = img.encodeJpg(resized, quality: 80);

  // Save to temporary file
  final tempDir = await getTemporaryDirectory();
  final tempFile = File(
      '${tempDir.path}/avatar_${DateTime.now().millisecondsSinceEpoch}.jpg');
  await tempFile.writeAsBytes(resizedBytes);

  return tempFile;
}
