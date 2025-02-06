import 'package:flutter/material.dart';
import 'package:flutter_dashboard_app/services/fiveDaysForecast/five_days_forecast_types.dart';
import 'package:flutter_dashboard_app/theme/app_colors.dart';

/// A widget that displays a 7-day weather forecast.
///
/// The [DaysForecast] widget takes a list of [DayForecast] objects
/// and renders them in a scrollable list with day names, weather icons,
/// temperature ranges, and descriptive phrases.
///
/// This widget adapts its size based on the screen width
/// (desktop or mobile layout).
class DaysForecast extends StatelessWidget {
  /// A list of daily weather forecasts to display.
  final List<DayForecast> forecasts;

  /// Creates a [DaysForecast] widget.
  ///
  /// The [forecasts] parameter must not be null and must contain a list of
  /// [DayForecast] objects.
  const DaysForecast({
    super.key,
    required this.forecasts,
  });

  /// Formats a [DateTime] object to a short weekday name.
  ///
  /// Returns the name of the day in Polish, e.g., "Pon" for Monday.
  String _formatDate(DateTime date) {
    final days = ['Pon', 'Wt', 'Śr', 'Czw', 'Pt', 'Sob', 'Niedz'];
    return days[date.weekday % 7];
  }

  @override
  Widget build(BuildContext context) {
    // Determine if the screen is in desktop mode based on its width.
    final isDesktop = MediaQuery.of(context).size.width > 768;

    return Container(
      width: MediaQuery.of(context).size.width * 0.2,
      height: MediaQuery.of(context).size.height * (isDesktop ? 0.6 : 0.4),
      decoration: BoxDecoration(
        color: AppColors.darkGray,
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Title of the forecast section.
          const Text(
            'Prognoza 7-dniowa',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 32),
          // List of daily weather forecasts.
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
                      // Display the short day name.
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
                      // Weather icon from a network URL.
                      Image.network(
                        'https://apidev.accuweather.com/developers/Media/Default/WeatherIcons/${forecast.icon < 10 ? '0' : ''}${forecast.icon}-s.png',
                        width: 24,
                        height: 24,
                      ),
                      const SizedBox(width: 12),
                      // Weather description (e.g., "Sunny").
                      Expanded(
                        child: Text(
                          forecast.iconPhrase,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                          ),
                        ),
                      ),
                      const SizedBox(width: 24),
                      // Temperature range: maximum and minimum.
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
