import 'dart:convert';

import 'package:farmwise_app/logic/lib/networkClient.dart';
import 'package:farmwise_app/logic/schemas/IoT.dart';
import 'package:farmwise_app/logic/schemas/Response.dart';

/// Check wether IoT exists
Future<bool> checkIoT(String ioID) async {
  try {
    final resp = await networkClient.get('/iots/$ioID');
    if (resp.statusCode != 200) {
      return false;
    }
    return true;
  } catch (err) {}
  return false;
}

/// Returns the information of the IoT
Future<NetworkResponse<IoT>> getIoTDetails({
  int? err,
  required String ioID,
}) async {
  if (err != null) {
    switch (err) {
      case 0:
        return Future.value(NetworkResponse.success(200, IoT.dummy));
      case 1:
        return Future.value(NetworkResponse.error(404, 'Not Found'));
      default:
        return Future.value(
          NetworkResponse.error(403, 'Invalid Session Token'),
        );
    }
  }

  try {
    final resp = await networkClient.get('/iots/$ioID');
    if (resp.statusCode != 200) {
      return Future.value(
        NetworkResponse.error(resp.statusCode, jsonDecode(resp.body) as String),
      );
    }

    return Future.value(
      NetworkResponse.success(200, IoT.fromJson(jsonDecode(resp.body))),
    );
  } catch (e) {
    return Future.value(NetworkResponse.error(500, 'Server Down'));
  }
}
