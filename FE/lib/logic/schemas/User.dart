import 'dart:convert';

import 'package:farmwise_app/logic/logicGlobal.dart';
import 'package:flutter/widgets.dart';

typedef MyUserRecord =
    ({String uID, String username, String email, String profilePicture});

class MyUser {
  static MyUserRecord recordDummy = (
    uID: '1',
    username: 'Ricorinas',
    email: 'ricorinas@gmail.com',
    profilePicture: base64Dummy,
  );
  static MyUser dummy = MyUser(recordDummy);

  String uID;
  String username;
  String email;
  String profilePicture;

  MyUser(MyUserRecord user)
    : uID = user.uID,
      username = user.username,
      email = user.email,
      profilePicture = user.profilePicture;

  factory MyUser.fromJson(Map<String, dynamic> json) {
    return MyUser((
      uID: json['uID'] as String,
      username: json['username'] as String,
      email: json['email'] as String,
      profilePicture: json['profilePicture'] as String,
    ));
  }

  Image getImageWidget() {
    Image output;
    if (profilePicture.startsWith('http://') ||
        profilePicture.startsWith('https://')) {
      output = Image.network(profilePicture);
    } else {
      output = Image.memory(base64Decode(profilePicture));
    }
    return output;
  }
}
