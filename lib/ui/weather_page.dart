import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:weather_app/models/forecast_item.dart';
import 'package:weather_app/models/weather.dart';
import 'package:weather_app/services/openweathermap_api.dart';
import 'package:weather_app/ui/search_page.dart';

class WeatherPage extends StatefulWidget {
  const WeatherPage({
    required this.locationName,
    required this.latitude,
    required this.longitude,
    super.key,
  });

  final String locationName;
  final double latitude;
  final double longitude;

  @override
  State<WeatherPage> createState() => _WeatherPageState();
}

class _WeatherPageState extends State<WeatherPage> {
  final DateFormat _dateFormatter = DateFormat.MMMMEEEEd();
  final DateFormat _forecastDateFormatter = DateFormat('E dd/MM HH:mm');
  final ScrollController _horizontalScrollController = ScrollController();

  @override
  void dispose() {
    _horizontalScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final openWeatherMapApi = context.read<OpenWeatherMapApi>();

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.locationName),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute<void>(
                  builder: (context) => const SearchPage(),
                ),
              );
            },
          ),
        ],
      ),
      body: FutureBuilder<Weather>(
        future: openWeatherMapApi.getWeather(widget.latitude, widget.longitude),
        builder: (context, weatherSnapshot) {
          if (weatherSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (weatherSnapshot.hasError) {
            return Center(
              child: Text(
                'Une erreur est survenue.\n${weatherSnapshot.error}',
                textAlign: TextAlign.center,
              ),
            );
          }

          if (!weatherSnapshot.hasData) {
            return const Center(child: Text('Aucune donnée météo disponible.'));
          }

          final weather = weatherSnapshot.data!;

          return FutureBuilder<List<ForecastItem>>(
            future: openWeatherMapApi.getForecast(
              widget.latitude,
              widget.longitude,
            ),
            builder: (context, forecastSnapshot) {
              final forecastItems = forecastSnapshot.data ?? [];

              return SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildCurrentWeatherCard(weather, openWeatherMapApi),
                    const SizedBox(height: 16),
                    _buildDetailsCard(weather),
                    const SizedBox(height: 16),
                    Text(
                      'Prévisions à venir',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 12),
                    if (forecastSnapshot.connectionState ==
                        ConnectionState.waiting)
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.all(16),
                          child: CircularProgressIndicator(),
                        ),
                      )
                    else if (forecastSnapshot.hasError)
                      Text(
                        'Impossible de charger les prévisions.\n${forecastSnapshot.error}',
                        textAlign: TextAlign.center,
                      )
                    else if (forecastItems.isEmpty)
                      const Text('Aucune prévision disponible.')
                    else
                      CustomScrollbarWithSingleChildScrollView(
                        controller: _horizontalScrollController,
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: forecastItems.map((forecast) {
                            return Padding(
                              padding: const EdgeInsets.only(right: 12),
                              child: _buildForecastCard(
                                forecast,
                                openWeatherMapApi,
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildCurrentWeatherCard(
    Weather weather,
    OpenWeatherMapApi openWeatherMapApi,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Text(
              _dateFormatter.format(weather.dateTime),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              weather.condition,
              style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              weather.description,
              style: const TextStyle(fontSize: 18),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Image.network(
              openWeatherMapApi.getIconUrl(weather.icon),
              width: 100,
              height: 100,
            ),
            const SizedBox(height: 16),
            Text(
              '${weather.temperature.toStringAsFixed(1)} °C',
              style: const TextStyle(fontSize: 36, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text('Ressenti : ${weather.feelsLike.toStringAsFixed(1)} °C'),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailsCard(Weather weather) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Text(
              'Détails',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            _buildDetailRow(
              'Température min',
              '${weather.tempMin.toStringAsFixed(1)} °C',
            ),
            _buildDetailRow(
              'Température max',
              '${weather.tempMax.toStringAsFixed(1)} °C',
            ),
            _buildDetailRow('Humidité', '${weather.humidity} %'),
            _buildDetailRow('Pression', '${weather.pressure} hPa'),
            _buildDetailRow(
              'Vent',
              '${weather.windSpeed.toStringAsFixed(1)} m/s',
            ),
            _buildDetailRow('Nuages', '${weather.cloudiness} %'),
            _buildDetailRow('Visibilité', '${weather.visibility} m'),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Expanded(child: Text(label)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildForecastCard(
    ForecastItem forecast,
    OpenWeatherMapApi openWeatherMapApi,
  ) {
    return SizedBox(
      width: 170,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              Text(
                _forecastDateFormatter.format(forecast.dateTime),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Image.network(
                openWeatherMapApi.getIconUrl(forecast.icon),
                width: 70,
                height: 70,
              ),
              const SizedBox(height: 8),
              Text(
                '${forecast.temperature.toStringAsFixed(1)} °C',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 8),
              Text(forecast.description, textAlign: TextAlign.center),
            ],
          ),
        ),
      ),
    );
  }
}

class CustomScrollbarWithSingleChildScrollView extends StatelessWidget {
  const CustomScrollbarWithSingleChildScrollView({
    required this.controller,
    required this.child,
    required this.scrollDirection,
    super.key,
  });

  final ScrollController controller;
  final Widget child;
  final Axis scrollDirection;

  @override
  Widget build(BuildContext context) {
    return ScrollConfiguration(
      behavior: const CustomScrollBehavior(),
      child: Scrollbar(
        controller: controller,
        thumbVisibility: true,
        child: SingleChildScrollView(
          controller: controller,
          scrollDirection: scrollDirection,
          child: child,
        ),
      ),
    );
  }
}

class CustomScrollBehavior extends MaterialScrollBehavior {
  const CustomScrollBehavior();

  @override
  Set<PointerDeviceKind> get dragDevices => {
    PointerDeviceKind.touch,
    PointerDeviceKind.mouse,
    PointerDeviceKind.stylus,
    PointerDeviceKind.unknown,
  };
}
