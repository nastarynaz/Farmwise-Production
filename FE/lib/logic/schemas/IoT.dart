typedef IoTRecord = ({String ioID, int humidity});

class IoT {
  static IoTRecord recordDummy = (ioID: 'TESTING', humidity: 432);
  static IoT dummy = IoT(recordDummy);

  String ioID;
  int humidity;

  IoT(IoTRecord IoT) : ioID = IoT.ioID, humidity = IoT.humidity;

  factory IoT.fromJson(Map<String, dynamic> json) {
    return IoT((
      ioID: json['ioID'] as String,
      humidity: json['humidity'] as int,
    ));
  }
}
