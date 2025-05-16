typedef WeatherConditionRecord =
    ({
      String text,
      String icon, // url to icon
      int code,
    });

class WeatherCondition {
  static WeatherConditionRecord recordDummy = (
    text: 'Partly cloudy',
    icon: '//cdn.weatherapi.com/weather/64x64/day/116.png',
    code: 1003,
  );
  static WeatherCondition dummy = WeatherCondition(recordDummy);

  String text;
  String icon; // url to icon
  int code;

  WeatherCondition(WeatherConditionRecord condition)
    : text = condition.text,
      icon = condition.icon,
      code = condition.code;

  WeatherConditionRecord toRecord() {
    return (text: text, icon: icon, code: code);
  }

  factory WeatherCondition.fromJson(Map<String, dynamic> json) {
    return WeatherCondition((
      text: json['text'] as String,
      icon: json['icon'] as String,
      code: json['code'] as int,
    ));
  }
}

typedef WeatherCurrentRecord =
    ({
      DateTime last_updated_epoch,
      double temp_c,
      WeatherConditionRecord condition,
      double wind_kph,
      double precip_mm,
      int humidity,
      double uv,
    });

class WeatherCurrent {
  static WeatherCurrentRecord recordDummy = (
    last_updated_epoch: DateTime.fromMillisecondsSinceEpoch(1673620200 * 1000),
    temp_c: 23.5,
    condition: WeatherCondition.recordDummy,
    wind_kph: 15.2,
    precip_mm: 0.0,
    humidity: 65,
    uv: 6.3,
  );
  static WeatherCurrent dummy = WeatherCurrent(recordDummy);

  DateTime last_updated_epoch;
  double temp_c;
  WeatherCondition condition;
  double wind_kph;
  double precip_mm;
  int humidity;
  double uv;

  WeatherCurrent(WeatherCurrentRecord current)
    : last_updated_epoch = current.last_updated_epoch,
      temp_c = current.temp_c,
      condition = WeatherCondition(current.condition),
      wind_kph = current.wind_kph,
      precip_mm = current.precip_mm,
      humidity = current.humidity,
      uv = current.uv;

  WeatherCurrentRecord toRecord() {
    return (
      last_updated_epoch: last_updated_epoch,
      temp_c: temp_c,
      condition: condition.toRecord(),
      wind_kph: wind_kph,
      precip_mm: precip_mm,
      humidity: humidity,
      uv: uv,
    );
  }

  factory WeatherCurrent.fromJson(Map<String, dynamic> json) {
    return WeatherCurrent((
      last_updated_epoch: DateTime.fromMillisecondsSinceEpoch(
        (json['last_updated_epoch'] as int) * 1000,
      ),
      temp_c: json['temp_c'].toDouble() as double,
      condition: WeatherCondition.fromJson(json['condition']).toRecord(),
      wind_kph: json['wind_kph'].toDouble() as double,
      precip_mm: json['precip_mm'].toDouble() as double,
      humidity: json['humidity'] as int,
      uv: json['uv'].toDouble() as double,
    ));
  }
}

typedef WeatherLocationRecord =
    ({
      String name,
      String region,
      String country,
      double lat,
      double lon,
      String tz_id,
      DateTime localtime_epoch,
      String localtime,
    });

class WeatherLocation {
  static WeatherLocationRecord recordDummy = (
    name: 'Boston',
    region: 'Lincolnshire',
    country: 'United Kingdom',
    lat: 40.7128,
    lon: -74.0060,
    tz_id: 'Europe/London',
    localtime_epoch: DateTime.fromMillisecondsSinceEpoch(1673620200 * 1000),
    localtime: '2023-07-20 14:22',
  );

  static WeatherLocation dummy = WeatherLocation(recordDummy);

  String name;
  String region;
  String country;
  double lat;
  double lon;
  String tz_id;
  DateTime localtime_epoch;
  String localtime;

  WeatherLocation(WeatherLocationRecord location)
    : name = location.name,
      region = location.region,
      country = location.country,
      lat = location.lat,
      lon = location.lon,
      tz_id = location.tz_id,
      localtime_epoch = location.localtime_epoch,
      localtime = location.localtime;

  WeatherLocationRecord toRecord() {
    return (
      name: name,
      region: region,
      country: country,
      lat: lat,
      lon: lon,
      tz_id: tz_id,
      localtime_epoch: localtime_epoch,
      localtime: localtime,
    );
  }

  factory WeatherLocation.fromJson(Map<String, dynamic> json) {
    return WeatherLocation((
      name: json['name'] as String,
      region: json['region'] as String,
      country: json['country'] as String,
      lat: json['lat'].toDouble() as double,
      lon: json['lon'].toDouble() as double,
      tz_id: json['tz_id'] as String,
      localtime_epoch: DateTime.fromMillisecondsSinceEpoch(
        (json['localtime_epoch'] as int) * 1000,
      ),
      localtime: json['localtime'] as String,
    ));
  }
}

typedef WeatherForecastDayRecord =
    ({
      double maxtemp_c,
      double mintemp_c,
      double totalprecip_mm,
      int avghumidity,
      int daily_chance_of_rain,
      int daily_chance_of_snow,
      WeatherConditionRecord condition,
      double uv,
    });

class WeatherForecastDay {
  static WeatherForecastDayRecord recordDummy = (
    maxtemp_c: 28.5,
    mintemp_c: 18.2,
    totalprecip_mm: 2.4,
    avghumidity: 70,
    daily_chance_of_rain: 40,
    daily_chance_of_snow: 0,
    condition: WeatherCondition.recordDummy,
    uv: 7.2,
  );

  static WeatherForecastDay dummy = WeatherForecastDay(recordDummy);

  double maxtemp_c;
  double mintemp_c;
  double totalprecip_mm;
  int avghumidity;
  int daily_chance_of_rain;
  int daily_chance_of_snow;
  WeatherCondition condition;
  double uv;

  WeatherForecastDayRecord toRecord() {
    return (
      maxtemp_c: maxtemp_c,
      mintemp_c: mintemp_c,
      totalprecip_mm: totalprecip_mm,
      avghumidity: avghumidity,
      daily_chance_of_rain: daily_chance_of_rain,
      daily_chance_of_snow: daily_chance_of_snow,
      condition: condition.toRecord(),
      uv: uv,
    );
  }

  WeatherForecastDay(WeatherForecastDayRecord day)
    : maxtemp_c = day.maxtemp_c,
      mintemp_c = day.mintemp_c,
      totalprecip_mm = day.totalprecip_mm,
      avghumidity = day.avghumidity,
      daily_chance_of_rain = day.daily_chance_of_rain,
      daily_chance_of_snow = day.daily_chance_of_snow,
      condition = WeatherCondition(day.condition),
      uv = day.uv;

  factory WeatherForecastDay.fromJson(Map<String, dynamic> json) {
    return WeatherForecastDay((
      maxtemp_c: json['maxtemp_c'].toDouble() as double,
      mintemp_c: json['mintemp_c'].toDouble() as double,
      totalprecip_mm: json['totalprecip_mm'].toDouble() as double,
      avghumidity: json['avghumidity'] as int,
      daily_chance_of_rain: json['daily_chance_of_rain'] as int,
      daily_chance_of_snow: json['daily_chance_of_snow'] as int,
      condition: WeatherCondition.fromJson(json['condition']).toRecord(),
      uv: json['uv'].toDouble() as double,
    ));
  }
}

typedef WeatherForecastAstroRecord =
    ({String sunrise, String sunset, String moon_phase});

class WeatherForecastAstro {
  static WeatherForecastAstroRecord recordDummy = (
    sunrise: '06:45 AM',
    sunset: '07:30 PM',
    moon_phase: 'Waning Crescent',
  );

  static WeatherForecastAstro dummy = WeatherForecastAstro(recordDummy);

  String sunrise;
  String sunset;
  String moon_phase;

  WeatherForecastAstro(WeatherForecastAstroRecord astro)
    : sunrise = astro.sunrise,
      sunset = astro.sunset,
      moon_phase = astro.moon_phase;

  WeatherForecastAstroRecord toRecord() {
    return (sunrise: sunrise, sunset: sunset, moon_phase: moon_phase);
  }

  factory WeatherForecastAstro.fromJson(Map<String, dynamic> json) {
    return WeatherForecastAstro((
      sunrise: json['sunrise'] as String,
      sunset: json['sunset'] as String,
      moon_phase: json['moon_phase'] as String,
    ));
  }
}

typedef WeatherForecastHourRecord =
    ({
      DateTime time_epoch,
      double temp_c,
      WeatherConditionRecord condition,
      double wind_kph,
      double precip_mm,
      int chance_of_rain,
    });

class WeatherForecastHour {
  static WeatherForecastHourRecord recordDummy = (
    time_epoch: DateTime.fromMillisecondsSinceEpoch(1673620200 * 1000),
    temp_c: 22.7,
    condition: WeatherCondition.recordDummy,
    wind_kph: 12.8,
    precip_mm: 0.5,
    chance_of_rain: 30,
  );

  static WeatherForecastHour dummy = WeatherForecastHour(recordDummy);

  DateTime time_epoch;
  double temp_c;
  WeatherCondition condition;
  double wind_kph;
  double precip_mm;
  int chance_of_rain;

  WeatherForecastHour(WeatherForecastHourRecord hour)
    : time_epoch = hour.time_epoch,
      temp_c = hour.temp_c,
      condition = WeatherCondition(hour.condition),
      wind_kph = hour.wind_kph,
      precip_mm = hour.precip_mm,
      chance_of_rain = hour.chance_of_rain;

  WeatherForecastHourRecord toRecord() {
    return (
      time_epoch: time_epoch,
      temp_c: temp_c,
      condition: condition.toRecord(),
      wind_kph: wind_kph,
      precip_mm: precip_mm,
      chance_of_rain: chance_of_rain,
    );
  }

  factory WeatherForecastHour.fromJson(Map<String, dynamic> json) {
    return WeatherForecastHour((
      time_epoch: DateTime.fromMillisecondsSinceEpoch(
        (json['time_epoch'] as int) * 1000,
      ),
      temp_c: json['temp_c'].toDouble() as double,
      condition: WeatherCondition.fromJson(json['condition']).toRecord(),
      wind_kph: json['wind_kph'].toDouble() as double,
      precip_mm: json['precip_mm'].toDouble() as double,
      chance_of_rain: json['chance_of_rain'] as int,
    ));
  }
}

typedef WeatherForecastRecord =
    ({
      DateTime date_epoch,
      WeatherForecastDayRecord day,
      WeatherForecastAstroRecord astro,
      List<WeatherForecastHourRecord> hour,
    });

class WeatherForecast {
  static WeatherForecastRecord recordDummy = (
    date_epoch: DateTime.fromMillisecondsSinceEpoch(1673620200 * 1000),
    day: WeatherForecastDay.recordDummy,
    astro: WeatherForecastAstro.recordDummy,
    hour: [WeatherForecastHour.recordDummy],
  );

  static WeatherForecast dummy = WeatherForecast(recordDummy);

  DateTime date_epoch;
  WeatherForecastDay day;
  WeatherForecastAstro astro;
  List<WeatherForecastHour> hour;

  WeatherForecast(WeatherForecastRecord forecast)
    : date_epoch = forecast.date_epoch,
      day = WeatherForecastDay(forecast.day),
      astro = WeatherForecastAstro(forecast.astro),
      hour = forecast.hour.map((h) => WeatherForecastHour(h)).toList();

  WeatherForecastRecord toRecord() {
    List<WeatherForecastHourRecord> list = [];
    for (var i = 0; i < hour.length; i++) {
      list.add(hour[i].toRecord());
    }

    return (
      date_epoch: date_epoch,
      day: day.toRecord(),
      astro: astro.toRecord(),
      hour: list,
    );
  }

  factory WeatherForecast.fromJson(Map<String, dynamic> json) {
    List<WeatherForecastHourRecord> list = [];
    for (var i = 0; i < (json['hour'] as List<dynamic>).length; i++) {
      list.add(WeatherForecastHour.fromJson(json['hour'][i]).toRecord());
    }
    print(json['date_epoch']);

    return WeatherForecast((
      date_epoch: DateTime.fromMillisecondsSinceEpoch(
        (json['date_epoch'] as int) * 1000,
      ),
      day: WeatherForecastDay.fromJson(json['day']).toRecord(),
      astro: WeatherForecastAstro.fromJson(json['astro']).toRecord(),
      hour: list,
    ));
  }
}

typedef WeatherAlertRecord =
    ({
      String headline,
      String msgtype,
      String severity,
      String urgency,
      String areas,
      String category,
      String certainty,
      String event,
      String note,
      String effective,
      String expires,
      String desc,
      String instruction,
    });

class WeatherAlert {
  static WeatherAlertRecord recordDummy = (
    headline: 'Heat Advisory',
    msgtype: 'Alert',
    severity: 'Moderate',
    urgency: 'Expected',
    areas: 'Metropolitan Area',
    category: 'Met',
    certainty: 'Likely',
    event: 'Heat Wave',
    note: 'Stay hydrated',
    effective: '2023-07-20T12:00:00',
    expires: '2023-07-22T18:00:00',
    desc: 'Prolonged period of excessive heat',
    instruction: 'Avoid prolonged sun exposure',
  );

  static WeatherAlert dummy = WeatherAlert(recordDummy);

  String headline;
  String msgtype;
  String severity;
  String urgency;
  String areas;
  String category;
  String certainty;
  String event;
  String note;
  String effective;
  String expires;
  String desc;
  String instruction;

  WeatherAlert(WeatherAlertRecord alert)
    : headline = alert.headline,
      msgtype = alert.msgtype,
      severity = alert.severity,
      urgency = alert.urgency,
      areas = alert.areas,
      category = alert.category,
      certainty = alert.certainty,
      event = alert.event,
      note = alert.note,
      effective = alert.effective,
      expires = alert.expires,
      desc = alert.desc,
      instruction = alert.instruction;

  WeatherAlertRecord toRecord() {
    return (
      headline: headline,
      msgtype: msgtype,
      severity: severity,
      urgency: urgency,
      areas: areas,
      category: category,
      certainty: certainty,
      event: event,
      note: note,
      effective: effective,
      expires: expires,
      desc: desc,
      instruction: instruction,
    );
  }

  factory WeatherAlert.fromJson(Map<String, dynamic> json) {
    return WeatherAlert((
      headline: json['headline'] as String,
      msgtype: json['msgtype'] as String,
      severity: json['severity'] as String,
      urgency: json['urgency'] as String,
      areas: json['areas'] as String,
      category: json['category'] as String,
      certainty: json['certainty'] as String,
      event: json['event'] as String,
      note: json['note'] as String,
      effective: json['effective'] as String,
      expires: json['expires'] as String,
      desc: json['desc'] as String,
      instruction: json['instruction'] as String,
    ));
  }
}
