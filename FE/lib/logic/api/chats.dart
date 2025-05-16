import 'dart:convert';

import 'package:farmwise_app/logic/lib/networkClient.dart';
import 'package:farmwise_app/logic/logicGlobal.dart';
import 'package:farmwise_app/logic/schemas/Chat.dart';
import 'package:farmwise_app/logic/schemas/Response.dart';

/// Returns a list of chats history
Future<NetworkResponse<List<Chat>>> getChats({int? err, int page = 1}) async {
  if (err != null) {
    switch (err) {
      case 0:
        List<Chat> dummyArr = [Chat.dummy, Chat.dummy, Chat.dummy, Chat.dummy];
        return Future.value(NetworkResponse.success(200, dummyArr));
      default:
        return Future.value(
          NetworkResponse.error(403, 'Invalid Session Token'),
        );
    }
  }

  try {
    final resp = await networkClient.get('/chats?page=$page');
    if (resp.statusCode != 200) {
      return Future.value(
        NetworkResponse.error(resp.statusCode, jsonDecode(resp.body) as String),
      );
    }

    final list = jsonDecode(resp.body) as List<Object?>;
    List<Chat> output = [];
    for (var i = 0; i < list.length; i++) {
      output.add(Chat.fromJson(list[i] as Map<String, dynamic>));
    }
    return Future.value(NetworkResponse.success(resp.statusCode, output));
  } catch (err) {
    return Future.value(NetworkResponse.error(500, 'Server Down'));
  }
}

/// Prompts to Gemini
/// Either text or image should be non-null otherwise NetworkResponse.error will be returned
Future<NetworkResponse<Chat>> prompts({
  int? err,
  String? text,
  String? image,
  int? fID,
}) async {
  if (err != null) {
    switch (err) {
      case 0:
        return Future.value(NetworkResponse.success(200, Chat.dummy));
      case 1:
        return Future.value(NetworkResponse.error(400, 'Body Can\'t be Empty'));
      case 2:
        return Future.value(NetworkResponse.error(400, 'Bad Request'));
      default:
        return Future.value(
          NetworkResponse.error(403, 'Invalid Session Token'),
        );
    }
  }

  if (!(text != null || image != null)) {
    return Future.value(NetworkResponse.error(400, 'Bad Request'));
  }

  try {
    final resp = await networkClient.post('/chats', {
      'text': text,
      'image': image,
      'fID': fID,
    });
    if (resp.statusCode != 200) {
      return Future.value(
        NetworkResponse.error(resp.statusCode, jsonDecode(resp.body) as String),
      );
    }

    return Future.value(
      NetworkResponse.success(200, Chat.fromJson(jsonDecode(resp.body))),
    );
  } catch (e) {
    return Future.value(NetworkResponse.error(500, 'Server Down'));
  }
}

Future<NetworkResponse<Chat>> scanAI(String base64Image, ScanType type) {
  switch (type) {
    case ScanType.disease:
      return prompts(image: base64Image, text: diseaseScanPrompt);
    default:
      return prompts(image: base64Image, text: infoScanPrompt);
  }
}
