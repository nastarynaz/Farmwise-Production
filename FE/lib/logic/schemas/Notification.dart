import 'package:farmwise_app/logic/logicGlobal.dart';

enum NotificationType { alert, general }

typedef NotificationContentRecord =
    ({NotificationType type, String title, String body});

class NotificationContent {
  static NotificationContentRecord recordDummy = (
    type: NotificationType.alert,
    title: 'Judul',
    body: 'Kmau dalam bahaya ricorin sedang ke sini',
  );
  static NotificationContent dummy = NotificationContent(recordDummy);

  NotificationType type;
  String title;
  String body;

  NotificationContent(NotificationContentRecord notification)
    : type = notification.type,
      title = notification.title,
      body = notification.body;
}

typedef NotificationRecord =
    ({
      int nID,
      int fID,
      String uID,
      String hash,
      DateTime time,
      DateTime? lastRead,
      NotificationContentRecord content,
    });

class Notification {
  static NotificationType toNotificationType(String input) {
    switch (input) {
      case 'alert':
        return NotificationType.alert;
      default:
        return NotificationType.general;
    }
  }

  static NotificationRecord recordDummy = (
    nID: 1,
    fID: 1,
    uID: '1',
    hash: 'MYHASH',
    time: dateTimeDummy,
    lastRead: dateTimeDummy,
    content: NotificationContent.recordDummy,
  );
  static Notification dummy = Notification(recordDummy);

  int nID;
  int fID;
  String uID;
  String hash;
  DateTime time;
  DateTime? lastRead;
  NotificationContent content;

  Notification(NotificationRecord notification)
    : nID = notification.nID,
      fID = notification.fID,
      uID = notification.uID,
      hash = notification.hash,
      time = notification.time,
      lastRead = notification.lastRead,
      content = NotificationContent(notification.content);

  factory Notification.fromJson(Map<String, dynamic> json) {
    return Notification((
      nID: json['nID'] as int,
      fID: json['fID'] as int,
      uID: json['uID'] as String,
      hash: json['hash'] as String,
      time: DateTime.parse(json['time'] as String),
      lastRead:
          json['lastRead'] != null
              ? DateTime.parse(json['lastRead'] as String)
              : null,
      content: (
        type: Notification.toNotificationType(
          json['content']['type'] as String,
        ),
        title: json['content']['title'] as String,
        body: json['content']['body'] as String,
      ),
    ));
  }
}

typedef NotificationTokenRecord = ({String tID, String uID});

class NotificationToken {
  static NotificationTokenRecord recordDummy = (
    tID: 'asdg1273shdkj',
    uID: 'kpyoi80981nfv',
  );
  static NotificationToken dummy = NotificationToken(recordDummy);

  String tID;
  String uID;

  NotificationToken(NotificationTokenRecord notificationToken)
    : tID = notificationToken.tID,
      uID = notificationToken.uID;

  factory NotificationToken.fromJson(Map<String, dynamic> json) {
    return NotificationToken((
      tID: json['tID'] as String,
      uID: json['uID'] as String,
    ));
  }
}
