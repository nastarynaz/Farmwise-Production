import 'dart:convert';

import 'package:farmwise_app/logic/lib/networkClient.dart';
import 'package:farmwise_app/logic/schemas/Notification.dart';
import 'package:farmwise_app/logic/schemas/Response.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

/// Get all of the notifications that the user received
/// Use unreadOnly = true to display only the unread notifications
/// Use page for pagination, page >= 1, if not error is Response.error is returned
Future<NetworkResponse<List<Notification>>> getNotifications({
  int? err,
  int page = 0,
  bool unreadOnly = false,
}) async {
  if (err != null) {
    switch (err) {
      case 0:
        List<Notification> dummyArr = [
          Notification.dummy,
          Notification.dummy,
          Notification.dummy,
          Notification.dummy,
        ];
        return Future.value(NetworkResponse.success(200, dummyArr));
      default:
        return Future.value(
          NetworkResponse.error(403, 'Invalid Session Token'),
        );
    }
  }

  try {
    final resp = await networkClient.get(
      '/notifications?unreadOnly=$unreadOnly',
    );
    if (resp.statusCode != 200) {
      return Future.value(
        NetworkResponse.error(resp.statusCode, jsonDecode(resp.body) as String),
      );
    }

    final list = jsonDecode(resp.body) as List<Object?>;
    List<Notification> output = [];
    for (var i = 0; i < list.length; i++) {
      output.add(Notification.fromJson(list[i] as Map<String, dynamic>));
    }
    return Future.value(NetworkResponse.success(resp.statusCode, output));
  } catch (err) {
    print(err);
    return Future.value(NetworkResponse.error(500, 'Server Down'));
  }
}

/// Read all of the notifications supplied
Future<NetworkResponse<List<Notification>>> readNotifications({
  int? err,
  required List<int> nIDs,
}) async {
  if (err != null) {
    switch (err) {
      case 0:
        List<Notification> dummyArr = [];
        for (int i = 0; i < nIDs.length; i++) {
          dummyArr.add(Notification.dummy);
        }
        return Future.value(NetworkResponse.success(200, dummyArr));
      case 1:
        return Future.value(NetworkResponse.error(404, 'Not Found'));
      case 2:
        return Future.value(NetworkResponse.error(400, 'Bad Request'));
      default:
        return Future.value(
          NetworkResponse.error(403, 'Invalid Session Token'),
        );
    }
  }

  try {
    final resp = await networkClient.put('/notifications/read', {'nID': nIDs});
    if (resp.statusCode != 200) {
      return Future.value(
        NetworkResponse.error(resp.statusCode, jsonDecode(resp.body) as String),
      );
    }

    final list = jsonDecode(resp.body) as List<Object?>;
    List<Notification> output = [];
    for (var i = 0; i < list.length; i++) {
      output.add(Notification.fromJson(list[i] as Map<String, dynamic>));
    }
    return Future.value(NetworkResponse.success(resp.statusCode, output));
  } catch (err) {
    return Future.value(NetworkResponse.error(500, 'Server Down'));
  }
}

/// Get a specific notification details
Future<NetworkResponse<Notification>> getNotificationsDetail({
  int? err,
  required int nID,
}) async {
  if (err != null) {
    switch (err) {
      case 0:
        return Future.value(NetworkResponse.success(200, Notification.dummy));
      case 1:
        return Future.value(NetworkResponse.error(404, 'Not Found'));
      default:
        return Future.value(
          NetworkResponse.error(403, 'Invalid Session Token'),
        );
    }
  }

  try {
    final resp = await networkClient.get('/notifications/$nID');
    if (resp.statusCode != 200) {
      return Future.value(
        NetworkResponse.error(resp.statusCode, jsonDecode(resp.body) as String),
      );
    }

    return Future.value(
      NetworkResponse.success(
        resp.statusCode,
        Notification.fromJson(jsonDecode(resp.body)),
      ),
    );
  } catch (err) {
    return Future.value(NetworkResponse.error(500, 'Server Down'));
  }
}

/// Register to push notification
Future<NetworkResponse<NotificationToken>> registerNotification({
  int? err,
  required String token,
}) async {
  if (err != null) {
    switch (err) {
      case 0:
        return Future.value(
          NetworkResponse.success(200, NotificationToken.dummy),
        );
      case 1:
        return Future.value(NetworkResponse.error(404, 'Bad Request'));
      default:
        return Future.value(
          NetworkResponse.error(403, 'Invalid Session Token'),
        );
    }
  }

  try {
    final resp = await networkClient.post('/notifications/register', {
      'token': token,
    });
    if (resp.statusCode != 200) {
      return Future.value(
        NetworkResponse.error(resp.statusCode, jsonDecode(resp.body) as String),
      );
    }

    return Future.value(
      NetworkResponse.success(
        resp.statusCode,
        NotificationToken.fromJson(jsonDecode(resp.body)),
      ),
    );
  } catch (err) {
    return Future.value(NetworkResponse.error(500, 'Server Down'));
  }
}

/// Register to push notification
Future<NetworkResponse<String>> unregisterNotification({
  int? err,
  required String token,
}) async {
  if (err != null) {
    switch (err) {
      case 0:
        return Future.value(NetworkResponse.success(200, 'Success'));
      case 1:
        return Future.value(NetworkResponse.error(404, 'Bad Request'));
      default:
        return Future.value(
          NetworkResponse.error(403, 'Invalid Session Token'),
        );
    }
  }

  try {
    final resp = await networkClient.post('/notifications/unregister', {
      'token': token,
    });
    if (resp.statusCode != 200) {
      return Future.value(
        NetworkResponse.error(resp.statusCode, jsonDecode(resp.body) as String),
      );
    }

    return Future.value(
      NetworkResponse.success(resp.statusCode, jsonDecode(resp.body) as String),
    );
  } catch (err) {
    return Future.value(NetworkResponse.error(500, 'Server Down'));
  }
}

bool _isPermitted = false;

Future<bool> requestNotificationPermission() async {
  NotificationSettings settings = await FirebaseMessaging.instance
      .requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );

  if (_isPermitted == false) {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('Got a message whilst in the foreground!');
      print('Message data: ${message.data}');

      if (message.notification != null) {
        print('Message also contained a notification: ${message.notification}');
      }
    });
    _isPermitted = true;
  }

  if (settings.authorizationStatus != AuthorizationStatus.authorized) {
    // TODO: FE, Show alert to user that notification is not permitted
    print('Notification is not permitted');
    _isPermitted = false;
    return Future.value(false);
  }
  return Future.value(true);
}
