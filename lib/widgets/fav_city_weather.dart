import 'package:flutter/material.dart';
import 'package:flutter_dashboard_app/store/global_store.dart';
import 'package:flutter_dashboard_app/theme/app_colors.dart';
import 'package:provider/provider.dart';

class FavoriteCityWeather extends StatelessWidget {
  const FavoriteCityWeather({super.key});

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width > 768;

    return Consumer<GlobalStore>(
      builder: (context, globalStore, child) {
        return Container(
          height: isDesktop ? 200 : 160,
          padding: isDesktop
              ? const EdgeInsets.symmetric(horizontal: 32, vertical: 16)
              : const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      globalStore.favoriteCityDetails?.localizedName ?? '',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: isDesktop ? 32.0 : 24.0,
                        fontWeight: FontWeight.bold,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: isDesktop ? 4.0 : 2.0),
                    Text(
                      'Temperatura odczuwalna: ${globalStore.currentConditions?.realFeelTemperature.value} °${globalStore.currentConditions?.realFeelTemperature.unit}',
                      style: TextStyle(
                        color: AppColors.teal,
                        fontSize: isDesktop ? 16.0 : 12.0,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: isDesktop ? 36.0 : 24.0),
                    Text(
                      '${globalStore.currentConditions?.temperature.value} °${globalStore.currentConditions?.temperature.unit}',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: isDesktop ? 32.0 : 24.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                width: isDesktop ? 150.0 : 100.0,
                height: isDesktop ? 150.0 : 100.0,
                child: Image.network(
                  'https://apidev.accuweather.com/developers/Media/Default/WeatherIcons/${globalStore.currentConditions?.weatherIcon != null && globalStore.currentConditions!.weatherIcon < 10 ? "0${globalStore.currentConditions?.weatherIcon}" : globalStore.currentConditions?.weatherIcon}-s.png',
                  fit: BoxFit.contain,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
