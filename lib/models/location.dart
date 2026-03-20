class Location {
  Location({
    required this.name,
    required this.lat,
    required this.lon,
    required this.country,
  });

  final String name;
  final double lat;
  final double lon;
  final String country;

  factory Location.fromJson(Map<String, dynamic> json) {
    return Location(
      name: json['name'] as String,
      lat: (json['lat'] as num).toDouble(),
      lon: (json['lon'] as num).toDouble(),
      country: json['country'] as String,
    );
  }
}