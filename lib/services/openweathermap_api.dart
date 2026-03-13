import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../models/forecast_item.dart';
import '../models/location.dart';
import '../models/weather.dart';

class OpenWeatherMapApi {
  OpenWeatherMapApi({
    required this.apiKey,
    this.units = 'metric',
    this.lang = 'fr',
  });

  static const String baseUrl = 'https://api.openweathermap.org';

  final String apiKey;
  final String units;
  final String lang;

  String getIconUrl(String icon) {
    return 'https://openweathermap.org/img/wn/$icon@4x.png';
  }

  Future<Iterable<Location>> searchLocations(
    String query, {
    int limit = 5,
  }) async {
    final response = await http.get(
      Uri.parse('$baseUrl/geo/1.0/direct?appid=$apiKey&q=$query&limit=$limit'),
    );

    if (response.statusCode == HttpStatus.ok) {
      final jsonData = jsonDecode(response.body) as List<dynamic>;

      return jsonData
          .map((item) => Location.fromJson(item as Map<String, dynamic>))
          .toList();
    }

    throw Exception(
      'Impossible de récupérer les données de localisation (HTTP ${response.statusCode})',
    );
  }

  Future<Weather> getWeather(double lat, double lon) async {
    final response = await http.get(
      Uri.parse(
        '$baseUrl/data/2.5/weather?appid=$apiKey&lat=$lat&lon=$lon&units=$units&lang=$lang',
      ),
    );

    if (response.statusCode == HttpStatus.ok) {
      final jsonData = jsonDecode(response.body) as Map<String, dynamic>;
      return Weather.fromJson(jsonData);
    }

    throw Exception(
      'Impossible de récupérer les données météo (HTTP ${response.statusCode})',
    );
  }

  Future<String> getLocationNameFromCoordinates(double lat, double lon) async {
    final response = await http.get(
      Uri.parse(
        '$baseUrl/geo/1.0/reverse?appid=$apiKey&lat=$lat&lon=$lon&limit=1',
      ),
    );

    if (response.statusCode == HttpStatus.ok) {
      final jsonData = jsonDecode(response.body) as List<dynamic>;

      if (jsonData.isEmpty) {
        return 'Ma position';
      }

      final first = jsonData.first as Map<String, dynamic>;
      return first['name'] as String? ?? 'Ma position';
    }

    throw Exception(
      'Impossible de récupérer le nom de la localisation (HTTP ${response.statusCode})',
    );
  }

  Future<List<ForecastItem>> getForecast(double lat, double lon) async {
    final response = await http.get(
      Uri.parse(
        '$baseUrl/data/2.5/forecast?appid=$apiKey&lat=$lat&lon=$lon&units=$units&lang=$lang',
      ),
    );

    if (response.statusCode == HttpStatus.ok) {
      final jsonData = jsonDecode(response.body) as Map<String, dynamic>;
      final list = jsonData['list'] as List<dynamic>;

      return list
          .map((item) => ForecastItem.fromJson(item as Map<String, dynamic>))
          .toList();
    }

    throw Exception(
      'Impossible de récupérer les prévisions météo (HTTP ${response.statusCode})',
    );
  }
}
