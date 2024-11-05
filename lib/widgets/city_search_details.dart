import 'package:flutter/material.dart';
import 'package:flutter_dashboard_app/store/global_store.dart';
import 'package:flutter_dashboard_app/theme/app_colors.dart';

class CitySearchDetails extends StatelessWidget {
  final GlobalStore store;

  const CitySearchDetails({
    super.key,
    required this.store,
  });

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withOpacity(0.7),
              fontSize: 14,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeatherIcon(int? weatherIcon) {
    return Image.network(
        'https://apidev.accuweather.com/developers/Media/Default/WeatherIcons/${weatherIcon != null && weatherIcon < 10 ? "0${weatherIcon}" : weatherIcon}-s.png',
        width: 100,
        height: 100);
  }

  @override
  Widget build(BuildContext context) {
    final selectedCity = store.selectedCity;
    final conditions = store.selectedCityConditions;

    if (selectedCity == null) {
      return const SizedBox.shrink();
    }

    return Container(
      decoration: BoxDecoration(
        color: AppColors.darkGray,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    selectedCity.localizedName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${selectedCity.country.name}, ${selectedCity.administrativeArea.name}',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.7),
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
              _buildWeatherIcon(conditions?.weatherIcon),
            ],
          ),
          if (conditions != null) ...[
            const SizedBox(height: 32),
            Container(
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _buildDetailRow(
                    'Temperatura',
                    '${conditions.temperature.value}°${conditions.temperature.unit}',
                  ),
                  const Divider(color: Colors.white12),
                  _buildDetailRow(
                    'Wilgotność',
                    '${conditions.relativeHumidity}%',
                  ),
                  const Divider(color: Colors.white12),
                  _buildDetailRow(
                    'Prędkość wiatru',
                    '${conditions.windSpeed} km/h',
                  ),
                  const Divider(color: Colors.white12),
                  _buildDetailRow(
                    'UV Index',
                    conditions.uvIndex.toString(),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
