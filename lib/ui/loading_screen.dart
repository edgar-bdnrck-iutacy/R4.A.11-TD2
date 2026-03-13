import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';
import 'package:weather_app/services/geolocation_service.dart';
import 'package:weather_app/services/openweathermap_api.dart';
import 'package:weather_app/ui/search_page.dart';
import 'package:weather_app/ui/weather_page.dart';

class LoadingScreen extends StatefulWidget {
  const LoadingScreen({super.key});

  @override
  State<LoadingScreen> createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen> {
  @override
  void initState() {
    super.initState();
    getLocationData();
  }

  Future<void> getLocationData() async {
    final geolocationService = context.read<GeolocationService>();
    final openWeatherMapApi = context.read<OpenWeatherMapApi>();

    final Position? position = await geolocationService.getCurrentPosition();

    if (!mounted) {
      return;
    }

    if (position != null) {
      String locationName = 'Ma position';

      try {
        locationName = await openWeatherMapApi.getLocationNameFromCoordinates(
          position.latitude,
          position.longitude,
        );
      } catch (_) {}

      if (!mounted) {
        return;
      }

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => WeatherPage(
            locationName: locationName,
            latitude: position.latitude,
            longitude: position.longitude,
          ),
        ),
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const SearchPage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}
