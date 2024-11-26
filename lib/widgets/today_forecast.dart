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
    final isDesktop = MediaQuery.of(context).size.width > 768;
    final displayForecasts = forecasts.take(isDesktop ? 8 : 4).toList();

    return Container(
      width: double.infinity,
      padding: isDesktop ? const EdgeInsets.all(24) : const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.darkGray,
        borderRadius: BorderRadius.circular(isDesktop ? 16 : 12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Prognoza godzinowa',
            style: TextStyle(
              color: Colors.white,
              fontSize: isDesktop ? 20 : 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: isDesktop ? 24 : 12),
          if (isDesktop)
            SizedBox(
              height: 100,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children:
                    List.generate(displayForecasts.length * 2 - 1, (index) {
                  if (index.isOdd) {
                    return Container(
                      width: 1,
                      height: 100,
                      color: AppColors.teal,
                      margin: const EdgeInsets.symmetric(horizontal: 12),
                    );
                  }

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
            )
          else
            SizedBox(
              height: 80,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children:
                      List.generate(displayForecasts.length * 2 - 1, (index) {
                    if (index.isOdd) {
                      return Container(
                        width: 1,
                        height: 80,
                        color: AppColors.teal,
                        margin: const EdgeInsets.symmetric(horizontal: 8),
                      );
                    }

                    final forecastIndex = index ~/ 2;
                    final forecast = displayForecasts[forecastIndex];

                    return Container(
                      width: 80,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            _formatHour(forecast.dateTime),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                            ),
                          ),
                          Image.network(
                            'https://apidev.accuweather.com/developers/Media/Default/WeatherIcons/${forecast.weatherIcon < 10 ? '0' : ''}${forecast.weatherIcon}-s.png',
                            width: 40.0,
                            height: 40.0,
                            fit: BoxFit.contain,
                          ),
                          Text(
                            '${forecast.temperature.value}${forecast.temperature.unit}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
