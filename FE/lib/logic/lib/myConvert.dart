import 'dart:convert';

import 'package:camera/camera.dart';

Future<String> imageToBase64(XFile image) async {
  List<int> imageBytes = await image.readAsBytes();
  return Future.value(base64Encode(imageBytes));
}
