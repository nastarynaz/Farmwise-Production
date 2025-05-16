import 'dart:convert';

import 'package:farmwise_app/logic/lib/networkClient.dart';
import 'package:farmwise_app/logic/schemas/News.dart';
import 'package:farmwise_app/logic/schemas/Response.dart';

/// Returns a list of news
/// Use page for pagination, page >= 1, if not error is Response.error is returned
Future<NetworkResponse<List<News>>> getNews({int? err, int page = 1}) async {
  if (err != null) {
    switch (err) {
      case 0:
        List<News> dummyArr = [News.dummy, News.dummy, News.dummy, News.dummy];
        return Future.value(NetworkResponse.success(200, dummyArr));
      default:
        return Future.value(
          NetworkResponse.error(403, 'Invalid Session Token'),
        );
    }
  }

  try {
    final resp = await networkClient.get('/news?page=$page');
    if (resp.statusCode != 200) {
      return Future.value(
        NetworkResponse.error(resp.statusCode, jsonDecode(resp.body) as String),
      );
    }

    final list = jsonDecode(resp.body) as List<Object?>;
    List<News> output = [];
    for (var i = 0; i < list.length; i++) {
      output.add(News.fromJson(list[i] as Map<String, dynamic>));
    }
    return Future.value(NetworkResponse.success(resp.statusCode, output));
  } catch (err) {
    return Future.value(NetworkResponse.error(500, 'Server Down'));
  }
}
