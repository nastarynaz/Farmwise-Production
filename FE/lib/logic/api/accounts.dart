import 'dart:convert';

import 'package:farmwise_app/logic/lib/networkClient.dart';
import 'package:farmwise_app/logic/logicGlobal.dart';
import 'package:farmwise_app/logic/schemas/User.dart';
import 'package:farmwise_app/logic/schemas/Response.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

/// Returns current user info
Future<NetworkResponse<MyUser>> getUser({int? err}) async {
  if (err != null) {
    switch (err) {
      case 0:
        return Future.value(NetworkResponse.success(200, MyUser.dummy));
      default:
        return Future.value(
          NetworkResponse.error(403, 'Invalid Session Token'),
        );
    }
  }

  try {
    final resp = await networkClient.get('/accounts');
    if (resp.statusCode != 200) {
      return Future.value(
        NetworkResponse.error(resp.statusCode, jsonDecode(resp.body) as String),
      );
    }

    return Future.value(
      NetworkResponse.success(200, MyUser.fromJson(jsonDecode(resp.body))),
    );
  } catch (e) {
    return Future.value(NetworkResponse.error(500, 'Server Down'));
  }
}

/// Update current user info
Future<NetworkResponse<MyUser>> updateUser({
  int? err,
  String? username,
  String? email,
  String? profilePicture,
}) async {
  if (err != null) {
    switch (err) {
      case 0:
        return Future.value(NetworkResponse.success(200, MyUser.dummy));
      case 1:
        return Future.value(NetworkResponse.error(400, 'Bad Request'));
      default:
        return Future.value(
          NetworkResponse.error(403, 'Invalid Session Token'),
        );
    }
  }

  try {
    final resp = await networkClient.put('/accounts', {
      'username': username,
      'email': email,
      'profilePicture': profilePicture,
    });
    if (resp.statusCode != 200) {
      return Future.value(
        NetworkResponse.error(resp.statusCode, jsonDecode(resp.body) as String),
      );
    }

    return Future.value(
      NetworkResponse.success(200, MyUser.fromJson(jsonDecode(resp.body))),
    );
  } catch (e) {
    return Future.value(NetworkResponse.error(500, 'Server Down'));
  }
}

/// Update current user info
Future<NetworkResponse<MyUser>> createUser({
  int? err,
  String? username,
  required String email,
  String? profilePicture,
}) async {
  if (err != null) {
    switch (err) {
      case 0:
        return Future.value(NetworkResponse.success(200, MyUser.dummy));
      case 1:
        return Future.value(NetworkResponse.error(400, 'Bad Request'));
      case 2:
        return Future.value(NetworkResponse.error(403, 'Email Already Exist'));
      default:
        return Future.value(
          NetworkResponse.error(403, 'Invalid Session Token'),
        );
    }
  }

  try {
    username = username ?? (FirebaseAuth.instance.currentUser)!.displayName!;
    final resp = await networkClient.post('/accounts', {
      'username': username,
      'email': email,
      'profilePicture': profilePicture,
    });
    if (resp.statusCode != 200) {
      return Future.value(
        NetworkResponse.error(resp.statusCode, jsonDecode(resp.body) as String),
      );
    }
    return Future.value(
      NetworkResponse.success(200, MyUser.fromJson(jsonDecode(resp.body))),
    );
  } catch (e) {
    print(e);
    return Future.value(NetworkResponse.error(500, 'Server Down'));
  }
}

Future<void> signOut() async {
  if (FirebaseAuth.instance.currentUser != null) {
    await FirebaseAuth.instance.signOut();
    await GoogleSignIn().signOut();
    GoogleAuthProvider().setCustomParameters({'prompt': 'select_account'});
    currentUser = null;
  }
}
