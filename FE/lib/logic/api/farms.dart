//logic/api/farms.dart
import 'dart:convert';

import 'package:farmwise_app/logic/lib/networkClient.dart';
import 'package:farmwise_app/logic/schemas/Farm.dart';
import 'package:farmwise_app/logic/schemas/Response.dart';
import 'package:farmwise_app/logic/schemas/WeatherResponse.dart';
import 'package:geolocator/geolocator.dart';

/// Returns all the current users farms
Future<NetworkResponse<List<Farm>>> getFarms({int? err}) async {
  if (err != null) {
    switch (err) {
      case 0:
        List<Farm> dummyArr = [Farm.dummy, Farm.dummy, Farm.dummy, Farm.dummy];
        return Future.value(NetworkResponse.success(200, dummyArr));
      default:
        return Future.value(
          NetworkResponse.error(403, 'Invalid Session Token'),
        );
    }
  }

  try {
    final resp = await networkClient.get('/farms');
    if (resp.statusCode != 200) {
      return Future.value(
        NetworkResponse.error(resp.statusCode, jsonDecode(resp.body) as String),
      );
    }

    final list = jsonDecode(resp.body) as List<Object?>;
    List<Farm> output = [];
    for (var i = 0; i < list.length; i++) {
      output.add(Farm.fromJson(list[i] as Map<String, dynamic>));
    }
    return Future.value(NetworkResponse.success(200, output));
  } catch (e) {
    print(e);
    return Future.value(NetworkResponse.error(500, 'Server Down'));
  }
}

/// Create new farm
Future<NetworkResponse<Farm>> createFarm({
  int? err,
  required (double, double) location,
  required String type,
  required String name,
  String? ioID,
}) async {
  if (err != null) {
    switch (err) {
      case 0:
        return Future.value(NetworkResponse.success(200, Farm.dummy));
      case 1:
        return Future.value(NetworkResponse.error(400, 'Bad Request'));
      default:
        return Future.value(
          NetworkResponse.error(403, 'Invalid Session Token'),
        );
    }
  }

  try {
    final resp = await networkClient.post('/farms', {
      'location': [location.$1, location.$2],
      'type': type,
      'name': name,
      'ioID': ioID,
    });
    if (resp.statusCode != 200) {
      return Future.value(
        NetworkResponse.error(resp.statusCode, jsonDecode(resp.body) as String),
      );
    }

    return Future.value(
      NetworkResponse.success(200, Farm.fromJson(jsonDecode(resp.body))),
    );
  } catch (e) {
    return Future.value(NetworkResponse.error(500, 'Server Down'));
  }
}

/// Returns the detail of a farm
/// Farms that doesn't belongs to user or invalid fID will create an error
Future<NetworkResponse<Farm>> getFarmDetails({
  int? err,
  required int fID,
}) async {
  if (err != null) {
    switch (err) {
      case 0:
        return Future.value(NetworkResponse.success(200, Farm.dummy));
      case 1:
        return Future.value(NetworkResponse.error(404, 'Not Found'));
      default:
        return Future.value(
          NetworkResponse.error(403, 'Invalid Session Token'),
        );
    }
  }

  try {
    final resp = await networkClient.get('/farms/$fID');
    if (resp.statusCode != 200) {
      return Future.value(
        NetworkResponse.error(resp.statusCode, jsonDecode(resp.body) as String),
      );
    }

    return Future.value(
      NetworkResponse.success(200, Farm.fromJson(jsonDecode(resp.body))),
    );
  } catch (e) {
    return Future.value(NetworkResponse.error(500, 'Server Down'));
  }
}

/// Update the detail of a farm
/// Farms that doesn't belongs to user or invalid fID will create an error
Future<NetworkResponse<Farm>> updateFarmDetails({
  int? err,
  int? fID,
  String? ioID,
  (double, double)? location,
  String? type,
  String? name,
}) async {
  if (err != null) {
    switch (err) {
      case 0:
        return Future.value(NetworkResponse.success(200, Farm.dummy));
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
    final resp = await networkClient.put('/farms/$fID', {
      'location': location == null ? null : [location.$1, location.$2],
      'type': type,
      'name': name,
      'ioID': ioID,
    });
    if (resp.statusCode != 200) {
      return Future.value(
        NetworkResponse.error(resp.statusCode, jsonDecode(resp.body) as String),
      );
    }

    return Future.value(
      NetworkResponse.success(200, Farm.fromJson(jsonDecode(resp.body))),
    );
  } catch (e) {
    return Future.value(NetworkResponse.error(500, 'Server Down'));
  }
}

/// Returns the detail of a farm
/// Farms that doesn't belongs to user or invalid fID will create an error
Future<NetworkResponse<Farm>> deleteFarm({int? err, required int fID}) async {
  if (err != null) {
    switch (err) {
      case 0:
        return Future.value(NetworkResponse.success(200, Farm.dummy));
      case 1:
        return Future.value(NetworkResponse.error(404, 'Not Found'));
      default:
        return Future.value(
          NetworkResponse.error(403, 'Invalid Session Token'),
        );
    }
  }

  try {
    final resp = await networkClient.delete('/farms/$fID');
    if (resp.statusCode != 200) {
      return Future.value(
        NetworkResponse.error(resp.statusCode, jsonDecode(resp.body) as String),
      );
    }

    return Future.value(
      NetworkResponse.success(200, Farm.fromJson(jsonDecode(resp.body))),
    );
  } catch (e) {
    return Future.value(NetworkResponse.error(500, 'Server Down'));
  }
}

/// Get the forecasted weather of a farm
/// Farms that doesn't belongs to user or invalid fID will create an error
Future<NetworkResponse<WeatherResponseForecast>> getWeatherForecast({
  int? err,
  required int fID,
}) async {
  if (err != null) {
    switch (err) {
      case 0:
        return Future.value(
          NetworkResponse.success(200, WeatherResponseForecast.dummy),
        );
      case 1:
        return Future.value(NetworkResponse.error(404, 'Not Found'));
      default:
        return Future.value(
          NetworkResponse.error(403, 'Invalid Session Token'),
        );
    }
  }

  try {
    final resp = await networkClient.get('/farms/$fID/weather/forecast');
    if (resp.statusCode != 200) {
      return Future.value(
        NetworkResponse.error(resp.statusCode, jsonDecode(resp.body) as String),
      );
    }

    return Future.value(
      NetworkResponse.success(
        200,
        WeatherResponseForecast.fromJson(jsonDecode(resp.body)),
      ),
    );
  } catch (e) {
    print(e);
    return Future.value(NetworkResponse.error(500, 'Server Down'));
  }
}

/// Get the current weather of a farm
/// Farms that doesn't belongs to user or invalid fID will create an error
Future<NetworkResponse<WeatherResponseCurrent>> getWeatherCurrent({
  int? err,
  required int fID,
}) async {
  if (err != null) {
    switch (err) {
      case 0:
        return Future.value(
          NetworkResponse.success(200, WeatherResponseCurrent.dummy),
        );
      case 1:
        return Future.value(NetworkResponse.error(404, 'Not Found'));
      default:
        return Future.value(
          NetworkResponse.error(403, 'Invalid Session Token'),
        );
    }
  }

  try {
    final resp = await networkClient.get('/farms/$fID/weather/current');
    if (resp.statusCode != 200) {
      return Future.value(
        NetworkResponse.error(resp.statusCode, jsonDecode(resp.body) as String),
      );
    }

    return Future.value(
      NetworkResponse.success(
        200,
        WeatherResponseCurrent.fromJson(jsonDecode(resp.body)),
      ),
    );
  } catch (e) {
    return Future.value(NetworkResponse.error(500, 'Server Down'));
  }
}

/// Get the weather alert of a farm
/// Farms that doesn't belongs to user or invalid fID will create an error
Future<NetworkResponse<WeatherResponseAlert>> getWeatherAlert({
  int? err,
  required int fID,
}) async {
  if (err != null) {
    switch (err) {
      case 0:
        return Future.value(
          NetworkResponse.success(200, WeatherResponseAlert.dummy),
        );
      case 1:
        return Future.value(NetworkResponse.error(404, 'Not Found'));
      default:
        return Future.value(
          NetworkResponse.error(403, 'Invalid Session Token'),
        );
    }
  }

  try {
    final resp = await networkClient.get('/farms/$fID/weather/alert');
    if (resp.statusCode != 200) {
      return Future.value(
        NetworkResponse.error(resp.statusCode, jsonDecode(resp.body) as String),
      );
    }

    return Future.value(
      NetworkResponse.success(
        200,
        WeatherResponseAlert.fromJson(jsonDecode(resp.body)),
      ),
    );
  } catch (e) {
    return Future.value(NetworkResponse.error(500, 'Server Down'));
  }
}

/// Get the current weather based on a location
/// Invalid location parameter would create an error
Future<NetworkResponse<WeatherResponseCurrent>> getWeatherLocationCurrent({
  int? err,
  required double lat,
  required double long,
}) async {
  if (err != null) {
    switch (err) {
      case 0:
        return Future.value(
          NetworkResponse.success(200, WeatherResponseCurrent.dummy),
        );
      case 1:
        return Future.value(NetworkResponse.error(404, 'Not Found'));
      default:
        return Future.value(
          NetworkResponse.error(403, 'Invalid Session Token'),
        );
    }
  }

  try {
    final resp = await networkClient.get('/farms/weather/current?q=$lat,$long');
    if (resp.statusCode != 200) {
      return Future.value(
        NetworkResponse.error(resp.statusCode, jsonDecode(resp.body) as String),
      );
    }

    return Future.value(
      NetworkResponse.success(
        200,
        WeatherResponseCurrent.fromJson(jsonDecode(resp.body)),
      ),
    );
  } catch (e) {
    return Future.value(NetworkResponse.error(500, 'Server Down'));
  }
}

Future<Position> getCurrentLocation() async {
  bool serviceEnabled;
  LocationPermission permission;

  serviceEnabled = await Geolocator.isLocationServiceEnabled();
  if (!serviceEnabled) {
    return Future.error('Location services are disabled.');
  }

  permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied) {
      return Future.error('Location permissions are denied');
    }
  }

  if (permission == LocationPermission.deniedForever) {
    return Future.error(
      'Location permissions are permanently denied, we cannot request permissions.',
    );
  }

  return Geolocator.getCurrentPosition();
}
