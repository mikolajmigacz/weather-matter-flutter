import 'package:flutter/material.dart';
import 'package:flutter_dashboard_app/services/twelveHoursForecast/twelve_hours_forecast_types.dart';
import 'package:flutter_dashboard_app/theme/app_colors.dart';

class TodayForecast extends StatelessWidget {
  final List<HourForecast> forecasts;

  const TodayForecast({
    super.key,
    required this.forecasts,
  });

  String _formatHour(DateTime dateTime) {
    return '${dateTime.hour.toString().padLeft(2, '0')}:00';
  }

  @override
  Widget build(BuildContext context) {
    // Take only first 8 forecasts
    final displayForecasts = forecasts.take(8).toList();

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.darkGray,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Today forecast',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 100,
            child: Row(
              children: List.generate(displayForecasts.length * 2 - 1, (index) {
                // Return divider for odd indices
                if (index.isOdd) {
                  return Container(
                    width: 1,
                    height: 100,
                    color: AppColors.teal,
                    margin: const EdgeInsets.symmetric(horizontal: 12),
                  );
                }

                // Return forecast item for even indices
                final forecastIndex = index ~/ 2;
                final forecast = displayForecasts[forecastIndex];

                return Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _formatHour(forecast.dateTime),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      ),
                      Image.network(
                        'https://apidev.accuweather.com/developers/Media/Default/WeatherIcons/${forecast.weatherIcon < 10 ? '0' : ''}${forecast.weatherIcon}-s.png',
                        width: 50.0,
                        height: 50.0,
                        fit: BoxFit.contain,
                      ),
                      Text(
                        '${forecast.temperature.value}${forecast.temperature.unit}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}
