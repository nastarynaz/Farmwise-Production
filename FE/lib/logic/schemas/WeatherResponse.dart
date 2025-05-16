//schemas/WeatherResponse.dart
import 'package:farmwise_app/logic/schemas/Weather.dart';

typedef WeatherResponseForecastRecord =
    ({
      WeatherLocationRecord location,
      WeatherCurrentRecord current,
      ({List<WeatherForecastRecord> forecastday}) forecast,
    });

class WeatherResponseForecast {
  static WeatherResponseForecastRecord recordDummy = (
    location: WeatherLocation.recordDummy,
    current: WeatherCurrent.recordDummy,
    forecast: (forecastday: [WeatherForecast.recordDummy]),
  );

  static WeatherResponseForecast dummy = WeatherResponseForecast(recordDummy);

  WeatherLocation location;
  WeatherCurrent current;
  ({List<WeatherForecast> forecastday}) forecast;

  WeatherResponseForecast(WeatherResponseForecastRecord response)
    : location = WeatherLocation(response.location),
      current = WeatherCurrent(response.current),
      forecast = (
        forecastday:
            response.forecast.forecastday
                .map((f) => WeatherForecast(f))
                .toList(),
      );

  factory WeatherResponseForecast.fromJson(Map<String, dynamic> json) {
    List<WeatherForecastRecord> forecastList = [];
    for (
      var i = 0;
      i < (json['forecast']['forecastday'] as List<dynamic>).length;
      i++
    ) {
      forecastList.add(
        WeatherForecast.fromJson(json['forecast']['forecastday'][i]).toRecord(),
      );
    }

    return WeatherResponseForecast((
      location: WeatherLocation.fromJson(json['location']).toRecord(),
      current: WeatherCurrent.fromJson(json['current']).toRecord(),
      forecast: (forecastday: forecastList),
    ));
  }
}

typedef WeatherResponseCurrentRecord =
    ({WeatherLocationRecord location, WeatherCurrentRecord current});

class WeatherResponseCurrent {
  static WeatherResponseCurrentRecord recordDummy = (
    location: WeatherLocation.recordDummy,
    current: WeatherCurrent.recordDummy,
  );

  static WeatherResponseCurrent dummy = WeatherResponseCurrent(recordDummy);

  WeatherLocation location;
  WeatherCurrent current;

  WeatherResponseCurrent(WeatherResponseCurrentRecord response)
    : location = WeatherLocation(response.location),
      current = WeatherCurrent(response.current);

  factory WeatherResponseCurrent.fromJson(Map<String, dynamic> json) {
    return WeatherResponseCurrent((
      location: WeatherLocation.fromJson(json['location']).toRecord(),
      current: WeatherCurrent.fromJson(json['current']).toRecord(),
    ),
    );
  }
}

typedef WeatherResponseAlertRecord =
    ({
      WeatherLocationRecord location,
      ({List<WeatherAlertRecord> alert}) alerts,
    });

class WeatherResponseAlert {
  static WeatherResponseAlertRecord recordDummy = (
    location: WeatherLocation.recordDummy,
    alerts: (alert: [WeatherAlert.recordDummy]),
  );

  static WeatherResponseAlert dummy = WeatherResponseAlert(recordDummy);

  WeatherLocation location;
  ({List<WeatherAlert> alert}) alerts;

  WeatherResponseAlert(WeatherResponseAlertRecord response)
    : location = WeatherLocation(response.location),
      alerts = (
        alert: response.alerts.alert.map((a) => WeatherAlert(a)).toList(),
      );

  factory WeatherResponseAlert.fromJson(Map<String, dynamic> json) {
    List<WeatherAlertRecord> alertList = [];
    for (
      var i = 0;
      i < (json['alerts']['alert'] as List<dynamic>).length;
      i++
    ) {
      alertList.add(WeatherAlert.fromJson(json['alerts']['alert']).toRecord());
    }

    return WeatherResponseAlert((
      location: WeatherLocation.fromJson(json['location']).toRecord(),
      alerts: (alert: alertList),
    ));
  }
}
