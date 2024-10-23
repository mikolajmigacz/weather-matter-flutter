import 'package:flutter/material.dart';
import 'package:flutter_dashboard_app/store/global_store.dart';
import 'package:flutter_dashboard_app/theme/app_colors.dart';
import 'package:provider/provider.dart';

class FavoriteCityWeather extends StatelessWidget {
  const FavoriteCityWeather({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<GlobalStore>(
      builder: (context, globalStore, child) {
        return Container(
          height: 200,
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: AppColors.darkGray,
            borderRadius: BorderRadius.circular(8.0),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    globalStore.favoriteCityDetails?.localizedName ?? '',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 32.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4.0),
                  Text(
                    'Real feel temperature: ${globalStore.currentConditions?.realFeelTemperature.value} °${globalStore.currentConditions?.realFeelTemperature.unit}',
                    style: const TextStyle(
                      color: AppColors.teal,
                      fontSize: 16.0,
                    ),
                  ),
                  const SizedBox(height: 36.0),
                  Text(
                    '${globalStore.currentConditions?.temperature.value} °${globalStore.currentConditions?.temperature.unit}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 32.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              Image.network(
                'https://apidev.accuweather.com/developers/Media/Default/WeatherIcons/06-s.png',
                width: 150.0,
                height: 150.0,
                fit: BoxFit.contain,
              ),
            ],
          ),
        );
      },
    );
  }
}
