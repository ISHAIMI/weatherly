import 'package:flutter/cupertino.dart';

class Weather with ChangeNotifier {
  final double temp;
  final double tempMax;
  final double tempMin;
  final double lat;
  final double long;
  final double feelsLike;
  final int pressure;
  final String description;
  final String weatherCategory;
  final int humidity;
  final double windSpeed;
  String city;
  final String countryCode;

  Weather({
    required this.temp,
    required this.tempMax,
    required this.tempMin,
    required this.lat,
    required this.long,
    required this.feelsLike,
    required this.pressure,
    required this.description,
    required this.weatherCategory,
    required this.humidity,
    required this.windSpeed,
    required this.city,
    required this.countryCode,
  });

  factory Weather.fromJson(Map<String, dynamic> json) {
    final mainData = json['main'] as Map<String, dynamic>? ?? {};
    final weatherData = json['weather']?.first as Map<String, dynamic>? ?? {};
    final coordData = json['coord'] as Map<String, dynamic>? ?? {};
    final sysData = json['sys'] as Map<String, dynamic>? ?? {};
    final windData = json['wind'] as Map<String, dynamic>? ?? {};
    final cloudsData = json['clouds'] as Map<String, dynamic>? ?? {};

    if (mainData.isEmpty || weatherData.isEmpty || coordData.isEmpty || sysData.isEmpty || windData.isEmpty || cloudsData.isEmpty) {
      throw Exception('Invalid JSON data');
    }

    return Weather(
      temp: mainData['temp']?.toDouble() ?? 0.0,
      tempMax: mainData['temp_max']?.toDouble() ?? 0.0,
      tempMin: mainData['temp_min']?.toDouble() ?? 0.0,
      lat: coordData['lat']?.toDouble() ?? 0.0,
      long: coordData['lon']?.toDouble() ?? 0.0,
      feelsLike: mainData['feels_like']?.toDouble() ?? 0.0,
      pressure: mainData['pressure']?.toInt() ?? 0,
      description: weatherData['description']?.toString() ?? '',
      weatherCategory: weatherData['main']?.toString() ?? '',
      humidity: mainData['humidity']?.toInt() ?? 0,
      windSpeed: windData['speed']?.toDouble() ?? 0.0,
      city: json['name']?.toString() ?? '',
      countryCode: sysData['country']?.toString() ?? '',
    );
  }

}
