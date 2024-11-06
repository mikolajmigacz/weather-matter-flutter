import 'package:flutter/material.dart';
import 'package:flutter_dashboard_app/services/favoriteCity/favorite_city.dart';
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
        width: 75,
        height: 75);
  }

  Widget _buildFavoriteButton(BuildContext context, bool isFavorite) {
    return IconButton(
      icon: Icon(
        isFavorite ? Icons.favorite : Icons.favorite_border,
        color: isFavorite ? AppColors.teal : Colors.white,
        size: 28,
      ),
      onPressed: () async {
        final favoriteService = FavoriteCityService(store);

        if (isFavorite) {
          final response =
              await favoriteService.removeFavoriteCity(store.selectedCity!.key);
          if (!response.success) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                  content: Text(
                      response.error ?? 'Failed to remove from favorites')),
            );
          }
        } else {
          final response =
              await favoriteService.addFavoriteCity(store.selectedCity!);
          if (!response.success) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                  content:
                      Text(response.error ?? 'Failed to add to favorites')),
            );
          }
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final selectedCity = store.selectedCity;
    final conditions = store.selectedCityConditions;

    if (selectedCity == null) {
      return const SizedBox.shrink();
    }

    final isFavorite =
        store.favoriteCities.any((city) => city.key == selectedCity.key);

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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Left side: City info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // City name and favorite button in one row
                    Row(
                      children: [
                        Text(
                          selectedCity.localizedName,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 8),
                        _buildFavoriteButton(context, isFavorite),
                      ],
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
              ),
              // Right side: Weather icon
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
