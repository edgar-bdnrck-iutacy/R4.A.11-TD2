class Weather {
  Weather({
    required this.condition,
    required this.description,
    required this.icon,
    required this.temperature,
    required this.feelsLike,
    required this.tempMin,
    required this.tempMax,
    required this.humidity,
    required this.pressure,
    required this.windSpeed,
    required this.cloudiness,
    required this.visibility,
    required this.dateTime,
  });

  final String condition;
  final String description;
  final String icon;
  final double temperature;
  final double feelsLike;
  final double tempMin;
  final double tempMax;
  final int humidity;
  final int pressure;
  final double windSpeed;
  final int cloudiness;
  final int visibility;
  final DateTime dateTime;

  factory Weather.fromJson(Map<String, dynamic> json) {
    final weatherList = json['weather'] as List<dynamic>;
    final weather = weatherList.first as Map<String, dynamic>;
    final main = json['main'] as Map<String, dynamic>;
    final wind = (json['wind'] as Map<String, dynamic>?) ?? {};
    final clouds = (json['clouds'] as Map<String, dynamic>?) ?? {};

    return Weather(
      condition: weather['main'] as String,
      description: weather['description'] as String,
      icon: weather['icon'] as String,
      temperature: (main['temp'] as num).toDouble(),
      feelsLike: (main['feels_like'] as num).toDouble(),
      tempMin: (main['temp_min'] as num).toDouble(),
      tempMax: (main['temp_max'] as num).toDouble(),
      humidity: main['humidity'] as int,
      pressure: main['pressure'] as int,
      windSpeed: wind['speed'] == null ? 0 : (wind['speed'] as num).toDouble(),
      cloudiness: clouds['all'] == null ? 0 : clouds['all'] as int,
      visibility: json['visibility'] == null ? 0 : json['visibility'] as int,
      dateTime: DateTime.fromMillisecondsSinceEpoch(
        (json['dt'] as int) * 1000,
      ),
    );
  }
}