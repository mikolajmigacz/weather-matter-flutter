import 'package:flutter_dashboard_app/services/autocomplete/autocomplete_types.dart';

class FavoriteCityResponse {
  final bool success;
  final String? error;
  final List<AutocompleteCity>? cities;

  FavoriteCityResponse({
    required this.success,
    this.error,
    this.cities,
  });
}
