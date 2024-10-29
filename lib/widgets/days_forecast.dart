import 'package:flutter/material.dart';
import 'package:flutter_dashboard_app/services/fiveDaysForecast/five_days_forecast_types.dart';
import 'package:flutter_dashboard_app/theme/app_colors.dart';

class DaysForecast extends StatelessWidget {
  final List<DayForecast> forecasts;

  const DaysForecast({
    super.key,
    required this.forecasts,
  });

  String _formatDate(DateTime date) {
    final days = ['Pon', 'Wt', 'Śr', 'Czw', 'Pt', 'Sob', 'Niedz'];
    return days[date.weekday % 7];
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.2,
      height: MediaQuery.of(context).size.height * 0.6,
      decoration: BoxDecoration(
        color: AppColors.darkGray,
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            'Prognoza 7-dniowa',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 32),
          Expanded(
            child: ListView.separated(
              itemCount: forecasts.length,
              separatorBuilder: (context, index) => const Divider(
                color: AppColors.teal,
                height: 24,
                thickness: 1,
              ),
              itemBuilder: (context, index) {
                final forecast = forecasts[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 40,
                        child: Text(
                          _formatDate(forecast.date),
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Image.network(
                        'https://apidev.accuweather.com/developers/Media/Default/WeatherIcons/${forecast.icon < 10 ? '0' : ''}${forecast.icon}-s.png',
                        width: 24,
                        height: 24,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          forecast.iconPhrase,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                          ),
                        ),
                      ),
                      const SizedBox(width: 24), // Added spacing here
                      RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: '${forecast.temperature.maximum.round()}°',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                              ),
                            ),
                            TextSpan(
                              text: '/${forecast.temperature.minimum.round()}°',
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
