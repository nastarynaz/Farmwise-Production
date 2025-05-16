import 'dart:async';

import 'package:farmwise_app/logic/api/iot.dart';
import 'package:farmwise_app/logic/logicGlobal.dart';
import 'package:farmwise_app/logic/schemas/IoT.dart';
import 'package:farmwise_app/logic/schemas/Weather.dart';
import 'package:flutter/material.dart';
import 'package:farmwise_app/logic/api/farms.dart';
import 'package:farmwise_app/logic/schemas/Farm.dart';
import 'package:farmwise_app/logic/schemas/WeatherResponse.dart';
import 'package:intl/intl.dart';

class LandDetailPage extends StatefulWidget {
  final int farmId;
  final String farmName;

  const LandDetailPage({
    Key? key,
    required this.farmId,
    required this.farmName,
    WeatherResponseForecast? initialWeather,
  }) : super(key: key);

  @override
  State<LandDetailPage> createState() => _LandDetailPageState();
}

class _LandDetailPageState extends State<LandDetailPage>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  late TabController _tabController;
  bool isLoading = true;
  String? errorMessage;

  Farm? farm;
  WeatherResponseCurrent? currentWeather;
  WeatherResponseForecast? forecastWeather;
  WeatherResponseAlert? alertWeather;
  IoT? iot;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _tabController = TabController(length: 3, vsync: this);
    _loadData();
    Timer.periodic(FARM_REFRESH_DURATION, (timer) {
      if (mounted) {
        _loadData(dontLoading: true);
      }
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadData({bool dontLoading = false}) async {
    if (!dontLoading) {
      setState(() {
        isLoading = true;
        errorMessage = null;
      });
    }

    try {
      // Load farm details
      final farmResponse = await getFarmDetails(fID: widget.farmId);
      if (farmResponse.statusCode != 200) {
        setState(() {
          errorMessage = farmResponse.err;
          isLoading = false;
        });
        return;
      }
      farm = farmResponse.response;

      // Load current weather
      final currentWeatherResponse = await getWeatherCurrent(
        fID: widget.farmId,
      );
      if (currentWeatherResponse.statusCode == 200) {
        currentWeather = currentWeatherResponse.response;
      }

      // Load forecast weather
      final forecastWeatherResponse = await getWeatherForecast(
        fID: widget.farmId,
      );
      if (forecastWeatherResponse.statusCode == 200) {
        forecastWeather = forecastWeatherResponse.response;
      }

      // Load weather alerts
      final alertWeatherResponse = await getWeatherAlert(fID: widget.farmId);
      if (alertWeatherResponse.statusCode == 200) {
        alertWeather = alertWeatherResponse.response;
      }

      // Load IoT data
      if (farm != null && farm!.ioID != null) {
        final iotResponse = await getIoTDetails(ioID: farm!.ioID!);
        iot = iotResponse.response;
      } else {
        iot = null;
      }

      setState(() {
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = 'Failed to load data: $e';
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFFFF),
      appBar: AppBar(
        title: Text(widget.farmName),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Overview'),
            Tab(text: 'Forecast'),
            Tab(text: 'Alerts'),
          ],
        ),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _loadData),
        ],
      ),
      body:
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : errorMessage != null
              ? Center(child: Text('Error: $errorMessage'))
              : TabBarView(
                controller: _tabController,
                children: [
                  _buildOverviewTab(),
                  _buildForecastTab(),
                  _buildAlertsTab(),
                ],
              ),
    );
  }

  Widget _buildOverviewTab() {
    if (farm == null || currentWeather == null) {
      return const Center(child: Text('No data available'));
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildFarmInfoCard(),
          const SizedBox(height: 16),
          _buildCurrentWeatherCard(),
          const SizedBox(height: 16),
          iot != null ? _buildIoTCard() : Text(''),
        ],
      ),
    );
  }

  Widget _buildFarmInfoCard() {
    return Card(
      color: Colors.green,
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Farm Information',
              style: TextStyle(
                fontSize: 20,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Divider(color: Colors.white),
            const SizedBox(height: 8),
            _buildInfoRow('Name', farm!.name),
            _buildInfoRow('Type', farm!.type),
            _buildInfoRow(
              'Location',
              '${farm!.location.$1}, ${farm!.location.$2}',
            ),
            _buildInfoRow('Farm ID', farm!.fID.toString()),
          ],
        ),
      ),
    );
  }

  Widget _buildCurrentWeatherCard() {
    final current = currentWeather!.current;
    final location = currentWeather!.location;

    return Card(
      color: Colors.white,
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Current Weather',
                  style: TextStyle(
                    fontSize: 20,
                    color: Colors.green,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Last updated: ${current.last_updated_epoch}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
            const Divider(color: Colors.green),
            const SizedBox(height: 8),
            Row(
              children: [
                if (current.condition.icon.isNotEmpty)
                  Image.network(
                    'https:${current.condition.icon}',
                    width: 64,
                    height: 64,
                    errorBuilder:
                        (context, error, stackTrace) =>
                            const Icon(Icons.image_not_supported, size: 64),
                  ),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${current.temp_c}°C',
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    Text(
                      current.condition.text,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildWeatherDetailsGrid(current),
            const SizedBox(height: 16),
            Text(
              'Location: ${location.name}, ${location.region}',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            Text(
              'Local Time: ${location.localtime}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIoTCard() {
    return Card(
      color: Colors.white,
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: const BorderSide(color: Colors.green, width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'IoT',
              style: TextStyle(
                fontSize: 20,
                color: Colors.green,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Divider(color: Colors.green),
            const SizedBox(height: 8),
            _buildInfoRow(
              'Humidity',
              '${((iot!.humidity.toDouble() - IOT_MIN_HUMIDITY.toDouble()) / IOT_MAX_HUMIDITY.toDouble() * 100.0).toStringAsFixed(1)}% (${iot!.humidity <= IOT_WET_THRESHOLD ? 'wet' : 'dry'})',
              col: Colors.black,
            ),
            _buildInfoRow('IoT ID', iot!.ioID, col: Colors.black),
          ],
        ),
      ),
    );
  }

  Widget _buildWeatherDetailsGrid(WeatherCurrent current) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      childAspectRatio: 3,
      children: [
        _buildWeatherDetailItem('Wind', '${current.wind_kph} km/h'),
        _buildWeatherDetailItem('Precipitation', '${current.precip_mm} mm'),
        _buildWeatherDetailItem('Humidity', '${current.humidity}%'),
        _buildWeatherDetailItem('UV Index', current.uv.toString()),
      ],
    );
  }

  Widget _buildWeatherDetailItem(String label, String value) {
    return Row(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: Theme.of(context).textTheme.bodySmall),
            Text(value, style: Theme.of(context).textTheme.titleSmall),
          ],
        ),
      ],
    );
  }

  Widget _buildForecastTab() {
    if (forecastWeather == null) {
      return const Center(child: Text('No forecast data available'));
    }

    final forecastDays = forecastWeather!.forecast.forecastday;

    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: forecastDays.length,
      itemBuilder: (context, index) {
        final forecast = forecastDays[index];
        return _buildForecastDayCard(forecast);
      },
    );
  }

  Widget _buildForecastDayCard(WeatherForecast forecast) {
    final day = forecast.day;
    final date = DateTime.fromMillisecondsSinceEpoch(
      forecast.date_epoch.millisecondsSinceEpoch,
    );
    final dateFormat = DateFormat('EEEE, MMM d');

    return Card(
      color: Colors.white,
      margin: const EdgeInsets.only(bottom: 16.0),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              dateFormat.format(date),
              style: TextStyle(
                fontSize: 20,
                color: Colors.green,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Divider(color: Colors.green),
            Row(
              children: [
                if (day.condition.icon.isNotEmpty)
                  Image.network(
                    'https:${day.condition.icon}',
                    width: 64,
                    height: 64,
                    errorBuilder:
                        (context, error, stackTrace) =>
                            const Icon(Icons.image_not_supported, size: 64),
                  ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        day.condition.text,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.arrow_upward, size: 16),
                          Text('${day.maxtemp_c}°C'),
                          const SizedBox(width: 16),
                          const Icon(Icons.arrow_downward, size: 16),
                          Text('${day.mintemp_c}°C'),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              childAspectRatio: 3,
              children: [
                _buildWeatherDetailItem('Humidity', '${day.avghumidity}%'),
                _buildWeatherDetailItem('UV Index', day.uv.toString()),
                _buildWeatherDetailItem(
                  'Precipitation',
                  '${day.totalprecip_mm} mm',
                ),
                _buildWeatherDetailItem(
                  'Rain Chance',
                  '${day.daily_chance_of_rain}%',
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              'Sunrise: ${forecast.astro.sunrise} | Sunset: ${forecast.astro.sunset}',
              style: TextStyle(
                fontSize: 14,
                color: Colors.green,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            ExpansionTile(
              title: Text(
                'Hourly Forecast',
                textAlign: TextAlign.left,
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.green,
                  fontWeight: FontWeight.w500,
                ),
              ),
              children: [
                SizedBox(
                  height: 180,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: forecast.hour.length,
                    itemBuilder: (context, index) {
                      final hour = forecast.hour[index];
                      final hourTime = DateTime.fromMillisecondsSinceEpoch(
                        hour.time_epoch.millisecondsSinceEpoch,
                      );
                      return Container(
                        width: 100,
                        padding: const EdgeInsets.all(8),
                        child: Column(
                          children: [
                            Text(DateFormat('h a').format(hourTime)),
                            const SizedBox(height: 4),
                            if (hour.condition.icon.isNotEmpty)
                              Image.network(
                                'https:${hour.condition.icon}',
                                width: 40,
                                height: 40,
                                errorBuilder:
                                    (context, error, stackTrace) => const Icon(
                                      Icons.image_not_supported,
                                      size: 40,
                                    ),
                              ),
                            const SizedBox(height: 4),
                            Text('${hour.temp_c}°C'),
                            Text(
                              '${hour.chance_of_rain}%',
                              style: TextStyle(color: Colors.blue),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAlertsTab() {
    if (alertWeather == null || alertWeather!.alerts.alert.isEmpty) {
      return const Center(child: Text('No weather alerts at this time'));
    }

    final alerts = alertWeather!.alerts.alert;

    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: alerts.length,
      itemBuilder: (context, index) {
        final alert = alerts[index];
        return _buildAlertCard(alert);
      },
    );
  }

  Widget _buildAlertCard(WeatherAlert alert) {
    Color severityColor;
    switch (alert.severity.toLowerCase()) {
      case 'extreme':
        severityColor = Colors.red.shade800;
        break;
      case 'severe':
        severityColor = Colors.red;
        break;
      case 'moderate':
        severityColor = Colors.orange;
        break;
      case 'minor':
        severityColor = Colors.yellow.shade700;
        break;
      default:
        severityColor = Colors.blue;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 16.0),
      elevation: 4,
      color: severityColor.withOpacity(0.1),
      shape: RoundedRectangleBorder(
        side: BorderSide(color: severityColor, width: 2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.warning_amber, color: severityColor),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    alert.headline,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: severityColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const Divider(),
            _buildInfoRow('Event', alert.event),
            _buildInfoRow('Areas', alert.areas),
            _buildInfoRow('Severity', alert.severity),
            _buildInfoRow('Effective', _formatDateTimeFromIso(alert.effective)),
            _buildInfoRow('Expires', _formatDateTimeFromIso(alert.expires)),
            const SizedBox(height: 8),
            if (alert.desc.isNotEmpty) ...[
              Text(
                'Description:',
                style: Theme.of(context).textTheme.titleSmall,
              ),
              const SizedBox(height: 4),
              Text(alert.desc),
              const SizedBox(height: 8),
            ],
            if (alert.instruction.isNotEmpty) ...[
              Text(
                'Instructions:',
                style: Theme.of(context).textTheme.titleSmall,
              ),
              const SizedBox(height: 4),
              Text(
                alert.instruction,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, {Color? col}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: TextStyle(
                color: col ?? Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            child: Text(value, style: TextStyle(color: col ?? Colors.white)),
          ),
        ],
      ),
    );
  }

  // String _formatDate(int epoch) {
  //   final date = DateTime.fromMillisecondsSinceEpoch(epoch * 1000);
  //   return DateFormat('MMM d, h:mm a').format(date);
  // }

  String _formatDateTimeFromIso(String isoString) {
    try {
      final date = DateTime.parse(isoString);
      return DateFormat('MMM d, h:mm a').format(date);
    } catch (e) {
      return isoString;
    }
  }
}
