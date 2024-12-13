import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_weather/models/additionalWeatherData.dart';
import 'package:flutter_weather/models/geocode.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';
import '../models/dailyWeather.dart';
import '../models/hourlyWeather.dart';
import '../models/weather.dart';
// ignore: unused_import
import 'package:geocoding/geocoding.dart';

class WeatherProvider with ChangeNotifier {
  String apiKey = '8d68117568f5f99d103b355575a0decd';
  late Weather weather;
  late AdditionalWeatherData additionalWeatherData = AdditionalWeatherData(precipitation: '', uvi: 0.0, clouds: 0);
  LatLng? currentLocation;
  List<HourlyWeather> hourlyWeather = [];
  List<DailyWeather> dailyWeather = []; // This is now redundant, since you will use the 3-hourly forecast
  bool isLoading = false;
  bool isRequestError = false;
  bool isSearchError = false;
  bool isLocationserviceEnabled = false;
  LocationPermission? locationPermission;
  bool isCelsius = true;

  String get measurementUnit => isCelsius ? '°C' : '°F';

  Future<Position?> requestLocation(BuildContext context) async {
    isLocationserviceEnabled = await Geolocator.isLocationServiceEnabled();
    notifyListeners();

    if (!isLocationserviceEnabled) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Location service disabled')),
      );
      return Future.error('Location services are disabled.');
    }

    locationPermission = await Geolocator.checkPermission();
    if (locationPermission == LocationPermission.denied) {
      isLoading = false;
      notifyListeners();
      locationPermission = await Geolocator.requestPermission();
      if (locationPermission == LocationPermission.denied) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Permission denied'),
        ));
        return Future.error('Location permissions are denied');
      }
    }

    if (locationPermission == LocationPermission.deniedForever) {
      isLoading = false;
      notifyListeners();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(
          'Location permissions are permanently denied, Please enable manually from app settings',
        ),
      ));
      return Future.error('Location permissions are permanently denied');
    }

    return await Geolocator.getCurrentPosition();
  }

  Future<void> getWeatherData(
      BuildContext context, {
        bool notify = false,
      }) async {
    isLoading = true;
    isRequestError = false;
    isSearchError = false;
    if (notify) notifyListeners();

    Position? locData = await requestLocation(context);

    if (locData == null) {
      isLoading = false;
      notifyListeners();
      return;
    }

    try {
      currentLocation = LatLng(locData.latitude, locData.longitude);
      await getCurrentWeather(currentLocation!);
      await get3HourForecast(currentLocation!); // Call the 3-hour forecast
    } catch (e) {
      print(e);
      isRequestError = true;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> getCurrentWeather(LatLng location) async {
    Uri url = Uri.parse(
      'https://api.openweathermap.org/data/2.5/weather?lat=${location.latitude}&lon=${location.longitude}&units=metric&appid=$apiKey',
    );
    try {
      final response = await http.get(url);
      final extractedData = json.decode(response.body) as Map<String, dynamic>;
      // ignore: unnecessary_null_comparison
      if (extractedData != null) {
        weather = Weather.fromJson(extractedData);
        print('Fetched Weather for: ${weather.city}/${weather.countryCode}');
      } else {
        print('Error: API response is null');
      }
    } catch (error) {
      print(error);
      isLoading = false;
      this.isRequestError = true;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> get3HourForecast(LatLng location) async {
    isLoading = true;
    notifyListeners();

    Uri forecastUrl = Uri.parse(
      'https://api.openweathermap.org/data/2.5/forecast?lat=${location.latitude}&lon=${location.longitude}&units=metric&appid=$apiKey',
    );

    try {
      final response = await http.get(forecastUrl);
      final forecastData = json.decode(response.body) as Map<String, dynamic>;

      if (forecastData.containsKey('list')) {
        // Parse the list data for 3-hour forecast
        List forecastList = forecastData['list'];
        hourlyWeather = forecastList
            .map((item) => HourlyWeather.fromJson(item))
            .toList()
            .take(24) // Limiting to 24 hours
            .toList();
        print("Fetched 3-hourly forecast data");
      } else {
        print('Error: Forecast data is missing or null');
      }
    } catch (error) {
      print("Error fetching forecast data: $error");
      isLoading = false;
      this.isRequestError = true;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<GeocodeData?> locationToLatLng(String location) async {
    try {
      Uri url = Uri.parse(
        'http://api.openweathermap.org/geo/1.0/direct?q=$location&limit=5&appid=$apiKey',
      );
      final http.Response response = await http.get(url);
      if (response.statusCode != 200) return null;
      return GeocodeData.fromJson(
        jsonDecode(response.body)[0] as Map<String, dynamic>,
      );
    } catch (e) {
      print("location error $e");
      return null;
    }
  }

  Future<void> searchWeather(String location) async {
    isLoading = true;
    notifyListeners();
    isRequestError = false;
    print('search');
    try {
      GeocodeData? geocodeData;
      geocodeData = await locationToLatLng(location);
      if (geocodeData == null) throw Exception('Unable to Find Location');
      await getCurrentWeather(geocodeData.latLng);
      await get3HourForecast(geocodeData.latLng); // Use 3-hour forecast instead of daily
      weather.city = geocodeData.name; // Replace location name with data from geocode
    } catch (e) {
      print("search weather error $e");
      isSearchError = true;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  void switchTempUnit() {
    isCelsius = !isCelsius;
    notifyListeners();
  }
}


// import 'dart:convert';
//
// import 'package:flutter/material.dart';
// import 'package:flutter_weather/models/additionalWeatherData.dart';
// import 'package:flutter_weather/models/geocode.dart';
// import 'package:geolocator/geolocator.dart';
// import 'package:http/http.dart' as http;
// import 'package:latlong2/latlong.dart';
//
// import '../models/dailyWeather.dart';
// import '../models/hourlyWeather.dart';
// import '../models/weather.dart';
// import 'package:geocoding/geocoding.dart';
//
// class WeatherProvider with ChangeNotifier {
//   String apiKey = '8d68117568f5f99d103b355575a0decd';
//   late Weather weather;
//   late AdditionalWeatherData additionalWeatherData=AdditionalWeatherData(precipitation: '', uvi: 0.0, clouds: 0);
//   LatLng? currentLocation;
//   List<HourlyWeather> hourlyWeather = [];
//   List<DailyWeather> dailyWeather = [];
//   bool isLoading = false;
//   bool isRequestError = false;
//   bool isSearchError = false;
//   bool isLocationserviceEnabled = false;
//   LocationPermission? locationPermission;
//   bool isCelsius = true;
//
//   String get measurementUnit => isCelsius ? '°C' : '°F';
//
//   Future<Position?> requestLocation(BuildContext context) async {
//     isLocationserviceEnabled = await Geolocator.isLocationServiceEnabled();
//     notifyListeners();
//
//     if (!isLocationserviceEnabled) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Location service disabled')),
//       );
//       return Future.error('Location services are disabled.');
//     }
//
//     locationPermission = await Geolocator.checkPermission();
//     if (locationPermission == LocationPermission.denied) {
//       isLoading = false;
//       notifyListeners();
//       locationPermission = await Geolocator.requestPermission();
//       if (locationPermission == LocationPermission.denied) {
//         ScaffoldMessenger.of(context).showSnackBar(SnackBar(
//           content: Text('Permission denied'),
//         ));
//         return Future.error('Location permissions are denied');
//       }
//     }
//
//     if (locationPermission == LocationPermission.deniedForever) {
//       isLoading = false;
//       notifyListeners();
//       ScaffoldMessenger.of(context).showSnackBar(SnackBar(
//         content: Text(
//           'Location permissions are permanently denied, Please enable manually from app settings',
//         ),
//       ));
//       return Future.error('Location permissions are permanently denied');
//     }
//
//     return await Geolocator.getCurrentPosition();
//   }
//
//   Future<void> getWeatherData(
//     BuildContext context, {
//     bool notify = false,
//   }) async {
//     isLoading = true;
//     isRequestError = false;
//     isSearchError = false;
//     if (notify) notifyListeners();
//
//     Position? locData = await requestLocation(context);
//
//     if (locData == null) {
//       isLoading = false;
//       notifyListeners();
//       return;
//     }
//
//     try {
//       currentLocation = LatLng(locData.latitude, locData.longitude);
//       await getCurrentWeather(currentLocation!);
//       await getDailyWeather(currentLocation!);
//     } catch (e) {
//       print(e);
//       isRequestError = true;
//     } finally {
//       isLoading = false;
//       notifyListeners();
//     }
//   }
//
//   // Future<void> getCurrentWeather(LatLng location) async {
//   //   Uri url = Uri.parse(
//   //     'https://api.openweathermap.org/data/2.5/weather?lat=${location.latitude}&lon=${location.longitude}&units=metric&appid=$apiKey',
//   //   );
//   //   try {
//   //     final response = await http.get(url);
//   //     final extractedData = json.decode(response.body) as Map<String, dynamic>;
//   //     weather = Weather.fromJson(extractedData);
//   //     print('Fetched Weather for: ${weather.city}/${weather.countryCode}');
//   //   } catch (error) {
//   //     print(error);
//   //     isLoading = false;
//   //     this.isRequestError = true;
//   //   }
//   // }
//
//   Future<void> getCurrentWeather(LatLng location) async {
//     Uri url = await Uri.parse(
//       'https://api.openweathermap.org/data/2.5/weather?lat=${location.latitude}&lon=${location.longitude}&units=metric&appid=$apiKey',
//     );
//     try {
//       final response = await http.get(url);
//       final extractedData = await json.decode(response.body) as Map<String, dynamic>;
//       if (extractedData != null) {
//         weather = await Weather.fromJson(extractedData);
//         print('Fetched Weather for: ${weather.city}/${weather.countryCode}');
//       } else {
//         // Handle the case where the API response is null
//         print('Error: API response is null');
//       }
//     } catch (error) {
//       print(error);
//       isLoading = false;
//       this.isRequestError = true;
//     } finally {
//       isLoading = false;
//       notifyListeners();
//     }
//   }
//
//   // Future<void> getDailyWeather(LatLng location) async {
//   //   isLoading = true;
//   //   notifyListeners();
//   //
//   //   Uri dailyUrl = Uri.parse(
//   //     'https://api.openweathermap.org/data/2.5/onecall?lat=${location.latitude}&lon=${location.longitude}&units=metric&exclude=minutely,current&appid=$apiKey',
//   //   );
//   //   try {
//   //     final response = await http.get(dailyUrl);
//   //     final dailyData = json.decode(response.body) as Map<String, dynamic>;
//   //     additionalWeatherData = AdditionalWeatherData.fromJson(dailyData);
//   //     List dailyList = dailyData['daily'];
//   //     List hourlyList = dailyData['hourly'];
//   //     hourlyWeather = hourlyList
//   //         .map((item) => HourlyWeather.fromJson(item))
//   //         .toList()
//   //         .take(24)
//   //         .toList();
//   //     dailyWeather =
//   //         dailyList.map((item) => DailyWeather.fromDailyJson(item)).toList();
//   //   } catch (error) {
//   //     print("daily weather error $error");
//   //     isLoading = false;
//   //     this.isRequestError = true;
//   //   }
//   // }
//
//   Future<void> getDailyWeather(LatLng location) async {
//     isLoading = true;
//     notifyListeners();
//
//     Uri dailyUrl = Uri.parse(
//       // 'https://api.openweathermap.org/data/2.5/onecall?lat=${location.latitude}&lon=${location.longitude}&units=metric&exclude=minutely,current&appid=$apiKey',
//       'https://api.openweathermap.org/data/2.5/forecast?lat=51.5085&lon=-0.1257&units=metric&appid=8d68117568f5f99d103b355575a0decd',
//     );
//     try {
//       final response = await http.get(dailyUrl);
//       final dailyData = json.decode(response.body) as Map<String, dynamic>;
//
//       // Check if 'daily' and 'hourly' keys exist and are not null
//       if (dailyData.containsKey('daily') && dailyData['daily'] != null) {
//         List dailyList = dailyData['daily'];
//         dailyWeather = dailyList
//             .map((item) => DailyWeather.fromDailyJson(item))
//             .toList();
//       } else {
//         print("Error: 'daily' data is missing or null");
//       }
//
//       if (dailyData.containsKey('hourly') && dailyData['hourly'] != null) {
//         List hourlyList = dailyData['hourly'];
//         hourlyWeather = hourlyList
//             .map((item) => HourlyWeather.fromJson(item))
//             .toList()
//             .take(24)
//             .toList();
//       } else {
//         print("Error: 'hourly' data is missing or null");
//       }
//
//     } catch (error) {
//       print("daily weather error $error");
//       isLoading = false;
//       this.isRequestError = true;
//     } finally {
//       isLoading = false;
//       notifyListeners();
//     }
//   }
//
//   Future<void> get3HourForecast(LatLng location) async {
//     isLoading = true;
//     notifyListeners();
//
//     Uri forecastUrl = Uri.parse(
//       'https://api.openweathermap.org/data/2.5/forecast?lat=${location.latitude}&lon=${location.longitude}&units=metric&appid=$apiKey',
//     );
//
//     try {
//       final response = await http.get(forecastUrl);
//       final forecastData = json.decode(response.body) as Map<String, dynamic>;
//
//       if (forecastData.containsKey('list')) {
//         // Parse the list data for 3-hour forecast
//         List forecastList = forecastData['list'];
//         // Now, process forecastList to extract the data you need
//         // For example, extracting temperature and time:
//         for (var forecast in forecastList) {
//           String time = forecast['dt_txt'];  // time for the forecast
//           double temp = forecast['main']['temp'];  // temperature
//           String weather = forecast['weather'][0]['description'];  // weather condition
//           print('Time: $time, Temp: $temp, Weather: $weather');
//         }
//       } else {
//         print('Error: Forecast data is missing or null');
//       }
//     } catch (error) {
//       print("Error fetching forecast data: $error");
//       isLoading = false;
//       this.isRequestError = true;
//     } finally {
//       isLoading = false;
//       notifyListeners();
//     }
//   }
//
//
//   Future<GeocodeData?> locationToLatLng(String location) async {
//     try {
//       Uri url = Uri.parse(
//         'http://api.openweathermap.org/geo/1.0/direct?q=$location&limit=5&appid=$apiKey',
//       );
//       final http.Response response = await http.get(url);
//       if (response.statusCode != 200) return null;
//       return GeocodeData.fromJson(
//         jsonDecode(response.body)[0] as Map<String, dynamic>,
//       );
//     } catch (e) {
//       print("location error $e");
//       return null;
//     }
//   }
//
//   Future<void> searchWeather(String location) async {
//     isLoading = true;
//     notifyListeners();
//     isRequestError = false;
//     print('search');
//     try {
//       GeocodeData? geocodeData;
//       geocodeData = await locationToLatLng(location);
//       if (geocodeData == null) throw Exception('Unable to Find Location');
//       await getCurrentWeather(geocodeData.latLng);
//       await getDailyWeather(geocodeData.latLng);
//       // replace location name with data from geocode
//       // because data from certain lat long might return local area name
//       weather.city = geocodeData.name;
//     } catch (e) {
//       print("search weather error $e");
//       isSearchError = true;
//     } finally {
//       isLoading = false;
//       notifyListeners();
//     }
//   }
//
//   void switchTempUnit() {
//     isCelsius = !isCelsius;
//     notifyListeners();
//   }
// }
