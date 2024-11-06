import 'package:flutter/material.dart';
import 'package:flutter_dashboard_app/services/city/city_types.dart';
import 'package:flutter_dashboard_app/services/currentConditions/current_conditions.dart';
import 'package:flutter_dashboard_app/services/favoriteCity/favorite_city.dart';
import 'package:flutter_dashboard_app/services/twelveHoursForecast/twelve_hours_forecast.dart';
import 'package:flutter_dashboard_app/services/twelveHoursForecast/twelve_hours_forecast_types.dart';
import 'package:flutter_dashboard_app/services/fiveDaysForecast/five_days_forecast.dart';
import 'package:flutter_dashboard_app/services/fiveDaysForecast/five_days_forecast_types.dart';
import 'package:flutter_dashboard_app/store/global_store.dart';
import 'package:flutter_dashboard_app/theme/app_colors.dart';
import 'package:flutter_dashboard_app/widgets/app_drawer.dart';
import 'package:flutter_dashboard_app/services/city/city_service.dart';
import 'package:flutter_dashboard_app/widgets/current_conditions_details.dart';
import 'package:flutter_dashboard_app/widgets/days_forecast.dart';
import 'package:flutter_dashboard_app/widgets/fav_city_weather.dart';
import 'package:flutter_dashboard_app/widgets/today_forecast.dart';
import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late final CityInfoService _cityInfoService;
  late final CurrentConditionsService _currentConditionsService;
  late final TwelveHoursForecastService _twelveHoursForecastService;
  late final FiveDaysForecastService _fiveDaysForecastService;
  late final FavoriteCityService _favoriteCityService; // Add this
  List<HourForecast>? _forecasts;
  List<DayForecast>? _fiveDayForecasts;
  bool _isLoading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    final store = Provider.of<GlobalStore>(context, listen: false);
    _cityInfoService = CityInfoService();
    _currentConditionsService = CurrentConditionsService(store);
    _twelveHoursForecastService = TwelveHoursForecastService(store);
    _fiveDaysForecastService = FiveDaysForecastService(store);
    _favoriteCityService = FavoriteCityService(store); // Add this
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final store = Provider.of<GlobalStore>(context);

    // First load favorite cities if needed
    if (store.userId.isNotEmpty && store.favoriteCities.isEmpty) {
      _loadFavoriteCities();
    }

    // Then check if we need to fetch weather data
    if (store.favoriteCity.isNotEmpty && _shouldFetchData(store)) {
      _initializeData(store);
    }
  }

  // Add this method
  Future<void> _loadFavoriteCities() async {
    try {
      final response = await _favoriteCityService.getFavoriteCities();
      if (!response.success) {
        setState(() {
          _error = response.error;
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Failed to load favorite cities: ${e.toString()}';
      });
    }
  }

  bool _shouldFetchData(GlobalStore store) {
    return _forecasts == null ||
        (store.favoriteCityDetails == null && store.currentConditions == null);
  }

  Future<void> _initializeData(GlobalStore store) async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      if (store.favoriteCityDetails == null) {
        CityDetails? favoriteCityDetails =
            await _cityInfoService.fetchCityDetails(store.favoriteCity);
        store.setFavoriteCityDetails(favoriteCityDetails!);
      }

      if (store.favoriteCityDetails != null) {
        final currentConditions = await _currentConditionsService
            .fetchCurrentConditions(store.favoriteCityDetails!.key);
        store.setCurrentConditions(currentConditions);

        await Future.wait([
          _fetchForecast(),
          _fetchFiveDayForecast(),
        ]);
      }
    } catch (e) {
      setState(() {
        _error = e.toString();
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _fetchForecast() async {
    try {
      final forecasts =
          await _twelveHoursForecastService.fetchTwelveHoursForecast();
      setState(() {
        _forecasts = forecasts;
      });
    } catch (e) {
      setState(() {
        _error = 'Failed to load forecast: ${e.toString()}';
      });
    }
  }

  Future<void> _fetchFiveDayForecast() async {
    try {
      final forecasts = await _fiveDaysForecastService.fetchFiveDaysForecast();
      setState(() {
        _fiveDayForecasts = forecasts;
      });
    } catch (e) {
      setState(() {
        _error = 'Failed to load 5-day forecast: ${e.toString()}';
      });
    }
  }

  Widget _buildContent() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Text(
          _error!,
          style: const TextStyle(color: Colors.red),
        ),
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 75,
          child: Column(
            children: [
              const FavoriteCityWeather(),
              if (_forecasts != null) ...[
                const SizedBox(height: 24),
                TodayForecast(forecasts: _forecasts!),
                const SizedBox(height: 24),
                if (context.watch<GlobalStore>().currentConditions != null)
                  CurrentConditionsDetails(
                    conditions: context.watch<GlobalStore>().currentConditions!,
                  ),
              ],
            ],
          ),
        ),
        if (_fiveDayForecasts != null) ...[
          const SizedBox(width: 24),
          Expanded(
            flex: 25,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                DaysForecast(forecasts: _fiveDayForecasts!),
              ],
            ),
          ),
        ],
      ],
    );
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
              padding: const EdgeInsets.all(32.0),
              child: _buildContent(),
            ),
          ),
        ],
      ),
    );
  }
}
