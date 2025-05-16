//schemas/Farm.dart
typedef FarmRecord =
    ({
      int fID,
      String uID,
      String? ioID,
      (double, double) location, // (lat, long)
      String type,
      String name,
    });

class Farm {
  static FarmRecord recordDummy = (
    fID: 1,
    uID: '1',
    ioID: null,
    location: (37.7749, -122.4194),
    type: 'Dairy',
    name: 'Sunny Meadows Farm',
  );
  static Farm dummy = Farm(recordDummy);

  int fID;
  String uID;
  String? ioID;
  (double, double) location;
  String type;
  String name;

  Farm(FarmRecord farm)
    : fID = farm.fID,
      uID = farm.uID,
      ioID = farm.ioID,
      location = farm.location,
      type = farm.type,
      name = farm.name;

  factory Farm.fromJson(Map<String, dynamic> json) {
    return Farm((
      fID: json['fID'] as int,
      uID: json['uID'] as String,
      ioID: json['ioID'] as String?,
      location: (
        (json['location'] as List<dynamic>)[0].toDouble() as double,
        (json['location'] as List<dynamic>)[1].toDouble() as double,
      ),
      type: json['type'] as String,
      name: json['name'] as String,
    ));
  }
}
