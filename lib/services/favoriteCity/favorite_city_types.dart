import 'package:flutter_dashboard_app/services/city/city_types.dart';

class FavoriteCityResponse {
  final bool success;
  final String? error;
  final List<CityDetails>? cities;

  FavoriteCityResponse({
    required this.success,
    this.error,
    this.cities,
  });
}
