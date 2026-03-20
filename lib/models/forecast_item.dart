class ForecastItem {
  ForecastItem({
    required this.dateTime,
    required this.temperature,
    required this.description,
    required this.icon,
  });

  final DateTime dateTime;
  final double temperature;
  final String description;
  final String icon;

  factory ForecastItem.fromJson(Map<String, dynamic> json) {
    final main = json['main'] as Map<String, dynamic>;
    final weatherList = json['weather'] as List<dynamic>;
    final weather = weatherList.first as Map<String, dynamic>;

    return ForecastItem(
      dateTime: DateTime.fromMillisecondsSinceEpoch(
        (json['dt'] as int) * 1000,
      ),
      temperature: (main['temp'] as num).toDouble(),
      description: weather['description'] as String,
      icon: weather['icon'] as String,
    );
  }
}