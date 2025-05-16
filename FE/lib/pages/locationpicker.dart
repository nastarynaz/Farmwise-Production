import 'package:farmwise_app/logic/logicGlobal.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart'; // Import Geolocator
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:go_router/go_router.dart';
import 'package:map_location_picker/map_location_picker.dart';

// Pastikan Anda telah menambahkan dependensi berikut di pubspec.yaml:
// geolocator: ^9.0.2  (atau versi terbaru)
// flutter_dotenv: ^5.1.0
// map_location_picker: ^4.0.0

class LocationPicker extends StatefulWidget {
  const LocationPicker({Key? key}) : super(key: key);

  @override
  State<LocationPicker> createState() => _LocationPickerState();
}

class _LocationPickerState extends State<LocationPicker> {
  // Fungsi untuk mendapatkan lokasi saat ini menggunakan Geolocator
  Future<Position> getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Check if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled don't continue
      // accessing the position and request users of the
      // App to enable the location services.
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Permissions are denied, next time you won't be able to
        // access the position and may also show a dialog.
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, handle appropriately.
      return Future.error(
        'Location permissions are permanently denied, we cannot access your location.',
      );
    }

    // When permissions are granted, we get the position of the device.
    return await Geolocator.getCurrentPosition();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Position>(
      future: getCurrentLocation(), // Use the function defined above
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else {
          final location = snapshot.data;
          return Scaffold(
            // Add Scaffold
            body: MapLocationPicker(
              apiKey: dotenv.env['GOOGLE_MAP_API_KEY']!,
              popOnNextButtonTaped: false,
              currentLatLng:
                  location != null
                      ? LatLng(location.latitude, location.longitude)
                      : const LatLng(29.146727, 76.464895),
              debounceDuration: const Duration(milliseconds: 500),
              onNext: (GeocodingResult? result) {
                if (result != null) {
                  // Return coordinates to previous screen
                  coordinate = LatLng(
                    result.geometry.location.lat,
                    result.geometry.location.lng,
                  );
                }
                context.pop();
                // Return nothing
              },
            ),
          );
        }
      },
    );
  }
}
