import 'package:flutter/material.dart';
import 'package:flutter_dashboard_app/services/currentConditions/current_conditions.dart';
import 'package:flutter_dashboard_app/store/global_store.dart';
import 'package:flutter_dashboard_app/theme/app_colors.dart';
import 'package:flutter_dashboard_app/widgets/app_drawer.dart';
import 'package:flutter_dashboard_app/services/city/city_service.dart';
import 'package:flutter_dashboard_app/widgets/fav_city_weather.dart';
import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late final CityInfoService _cityInfoService;
  late final CurrentConditionsService _currentConditionsService;

  @override
  void initState() {
    super.initState();
    final store = Provider.of<GlobalStore>(context, listen: false);
    _cityInfoService = CityInfoService(store);
    _currentConditionsService = CurrentConditionsService(store);
  }

  Future<void> _fetchCityDetails(GlobalStore store) async {
    if (store.favoriteCity.isNotEmpty) {
      await _cityInfoService.fetchAndStoreCityDetails(store.favoriteCity);
      if (store.favoriteCityDetails != null) {
        await _currentConditionsService.fetchCurrentConditions();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkestGray,
      body: Row(
        children: [
          const AppDrawer(),
          Expanded(
              child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Expanded(
              child: Consumer<GlobalStore>(
                builder: (context, globalStore, child) {
                  if (globalStore.favoriteCity.isNotEmpty &&
                      globalStore.favoriteCityDetails == null) {
                    _fetchCityDetails(globalStore);
                  }

                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [FavoriteCityWeather()],
                    ),
                  );
                },
              ),
            ),
          )),
        ],
      ),
    );
  }
}
