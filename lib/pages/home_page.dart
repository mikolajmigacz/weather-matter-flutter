import 'package:flutter/material.dart';
import 'package:flutter_dashboard_app/services/currentConditions/current_conditions.dart';
import 'package:flutter_dashboard_app/services/twelveHoursForecast/twelve_hours_forecast.dart';
import 'package:flutter_dashboard_app/services/twelveHoursForecast/twelve_hours_forecast_types.dart';
import 'package:flutter_dashboard_app/store/global_store.dart';
import 'package:flutter_dashboard_app/theme/app_colors.dart';
import 'package:flutter_dashboard_app/widgets/app_drawer.dart';
import 'package:flutter_dashboard_app/services/city/city_service.dart';
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
  List<HourForecast>? _forecasts;
  bool _isLoading = false;
  String? _error;
  String? _lastFetchedCity;

  @override
  void initState() {
    super.initState();
    final store = Provider.of<GlobalStore>(context, listen: false);
    _cityInfoService = CityInfoService(store);
    _currentConditionsService = CurrentConditionsService(store);
    _twelveHoursForecastService = TwelveHoursForecastService(store);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final store = Provider.of<GlobalStore>(context);

    if (store.favoriteCity.isNotEmpty &&
        store.favoriteCityDetails == null &&
        _lastFetchedCity != store.favoriteCity) {
      _lastFetchedCity = store.favoriteCity;
      _fetchCityDetails(store);
    }
  }

  Future<void> _fetchCityDetails(GlobalStore store) async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      await _cityInfoService.fetchAndStoreCityDetails(store.favoriteCity);
      if (store.favoriteCityDetails != null) {
        await Future.wait([
          _currentConditionsService.fetchCurrentConditions(),
          _fetchForecast(),
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

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const FavoriteCityWeather(),
        if (_forecasts != null) ...[
          const SizedBox(height: 24),
          TodayForecast(forecasts: _forecasts!),
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
              padding: const EdgeInsets.all(16.0),
              child: Center(
                child: _buildContent(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
