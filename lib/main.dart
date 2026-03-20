import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:weather_app/config.dart';
import 'package:weather_app/services/geolocation_service.dart';
import 'package:weather_app/services/openweathermap_api.dart';
import 'package:weather_app/ui/loading_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Intl.defaultLocale = 'fr_FR';
  await initializeDateFormatting('fr_FR');

  runApp(const WeatherApp());
}

class WeatherApp extends StatelessWidget {
  const WeatherApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider(
          create: (_) => OpenWeatherMapApi(apiKey: openWeatherMapApiKey),
        ),
        Provider(
          create: (_) => GeolocationService(),
        ),
      ],
      child: MaterialApp(
        title: 'Weather App',
        theme: ThemeData.dark(),
        debugShowCheckedModeBanner: false,
        home: const LoadingScreen(),
      ),
    );
  }
}