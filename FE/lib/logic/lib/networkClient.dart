import 'dart:convert';
import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class NetworkClient {
  http.Client client = http.Client();
  String token = '';

  NetworkClient();

  Future<http.Response> get(String path) async {
    final resp = await client.get(
      Uri.parse(dotenv.env['API_BASE_URL']! + path),
      headers: {
        HttpHeaders.authorizationHeader: 'Bearer $token',
        HttpHeaders.contentTypeHeader: 'application/json',
      },
    );
    if (token != '' &&
        resp.statusCode == 403 &&
        jsonDecode(resp.body) == 'Invalid Session Token') {
      token = (await FirebaseAuth.instance.currentUser!.getIdToken())!;
      return get(path);
    }
    return Future.value(resp);
  }

  Future<http.Response> delete(String path) async {
    final resp = await client.delete(
      Uri.parse(dotenv.env['API_BASE_URL']! + path),
      headers: {
        HttpHeaders.authorizationHeader: 'Bearer $token',
        HttpHeaders.contentTypeHeader: 'application/json',
      },
    );
    if (token != '' &&
        resp.statusCode == 403 &&
        jsonDecode(resp.body) == 'Invalid Session Token') {
      token = (await FirebaseAuth.instance.currentUser!.getIdToken())!;
      return delete(path);
    }
    return Future.value(resp);
  }

  Future<http.Response> post(String path, Object? body) async {
    final resp = await client.post(
      Uri.parse(dotenv.env['API_BASE_URL']! + path),
      headers: {
        HttpHeaders.authorizationHeader: 'Bearer $token',
        HttpHeaders.contentTypeHeader: 'application/json',
      },
      body: jsonEncode(body),
    );
    if (token != '' &&
        resp.statusCode == 403 &&
        jsonDecode(resp.body) == 'Invalid Session Token') {
      token = (await FirebaseAuth.instance.currentUser!.getIdToken())!;
      return post(path, body);
    }
    return Future.value(resp);
  }

  Future<http.Response> put(String path, Object? body) async {
    final resp = await client.put(
      Uri.parse(dotenv.env['API_BASE_URL']! + path),
      headers: {
        HttpHeaders.authorizationHeader: 'Bearer $token',
        HttpHeaders.contentTypeHeader: 'application/json',
      },
      body: jsonEncode(body),
    );
    if (token != '' &&
        resp.statusCode == 403 &&
        jsonDecode(resp.body) == 'Invalid Session Token') {
      token = (await FirebaseAuth.instance.currentUser!.getIdToken())!;
      return put(path, body);
    }
    return Future.value(resp);
  }
}

NetworkClient networkClient = NetworkClient();
