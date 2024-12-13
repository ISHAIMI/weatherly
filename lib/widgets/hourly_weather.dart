import 'package:flutter/material.dart';
import 'package:flutter_weather/helper/extensions.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../helper/utils.dart';
import '../models/hourlyWeather.dart';
import '../provider/weatherProvider.dart';
import '../theme/colors.dart';
import '../theme/textStyle.dart';

class HourlyWeatherWidget extends StatelessWidget {
  final int index;
  final HourlyWeather data;

  const HourlyWeatherWidget({
    Key? key,
    required this.index,
    required this.data,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 124.0,
      child: Column(
        children: [
          Consumer<WeatherProvider>(builder: (context, weatherProv, _) {
            return Text(
              weatherProv.isCelsius
                  ? '${data.temp.toStringAsFixed(1)}°'
                  : '${data.temp.toFahrenheit().toStringAsFixed(1)}°',
              style: semiboldText,
            );
          }),
          Stack(
            children: [
              Divider(
                thickness: 2.0,
                color: primaryBlue,
              ),
              if (index == 0)
                Positioned(
                  top: 2.0,
                  left: 0,
                  right: 0,
                  child: Container(
                    width: 10.0,
                    height: 10.0,
                    decoration: BoxDecoration(
                      color: Colors.yellow,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
            ],
          ),
          SizedBox(
            height: 42.0,
            width: 42.0,
            child: Image.asset(
              getWeatherImage(data.weatherCategory),
              fit: BoxFit.cover,
            ),
          ),
          FittedBox(
            child: Text(
              data.condition?.toTitleCase() ?? 'No Description', // Handle null condition
              style: regularText.copyWith(fontSize: 12.0),
            ),
          ),
          const SizedBox(height: 2.0),
          Text(
            index == 0 ? 'Now' : DateFormat('hh:mm a').format(data.date),
            style: regularText,
          ),
        ],
      ),
    );
  }
}
