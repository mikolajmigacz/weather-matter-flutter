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
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
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
                    'Temperatura odczuwalna: ${globalStore.currentConditions?.realFeelTemperature.value} °${globalStore.currentConditions?.realFeelTemperature.unit}',
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
                'https://apidev.accuweather.com/developers/Media/Default/WeatherIcons/${globalStore.currentConditions?.weatherIcon != null && globalStore.currentConditions!.weatherIcon < 10 ? "0${globalStore.currentConditions?.weatherIcon}" : globalStore.currentConditions?.weatherIcon}-s.png',
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
