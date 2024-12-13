class HourlyWeather {
  final double temp;
  final String weatherCategory;
  final String? condition;
  final DateTime date;

  HourlyWeather({
    required this.temp,
    required this.weatherCategory,
    this.condition,
    required this.date,
  });

  static HourlyWeather fromJson(dynamic json) {
    return HourlyWeather(
      temp: (json['temp'] != null) ? (json['temp']).toDouble() : 0.0, // Handle null value
      weatherCategory: json['weather'][0]['main'] ?? 'Unknown',
      condition: json['weather'][0]['description'],
      date: DateTime.fromMillisecondsSinceEpoch(json['dt'] * 1000),
    );
  }

  // Method to filter data every 3rd hour
  static List<HourlyWeather> filterThreeHourForecast(List<HourlyWeather> weatherData) {
    List<HourlyWeather> filteredData = [];
    for (int i = 0; i < weatherData.length; i++) {
      if (i % 3 == 0) {
        filteredData.add(weatherData[i]);
      }
    }
    return filteredData;
  }
}




// // ignore_for_file: public_member_api_docs, sort_constructors_first
// class HourlyWeather {
//   final double temp;
//   final String weatherCategory;
//   final String? condition;
//   final DateTime date;
//
//   HourlyWeather({
//     required this.temp,
//     required this.weatherCategory,
//     this.condition,
//     required this.date,
//   });
//
//   static HourlyWeather fromJson(dynamic json) {
//     return HourlyWeather(
//       temp: (json['temp']).toDouble(),
//       weatherCategory: json['weather'][0]['main'],
//       condition: json['weather'][0]['description'],
//       date: DateTime.fromMillisecondsSinceEpoch(json['dt'] * 1000),
//     );
//   }
// }
