// current_conditions_service.dart

import 'dart:convert';
import 'package:flutter_dashboard_app/store/global_store.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dashboard_app/services/currentConditions/current_conditions_types.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class CurrentConditionsService {
  final GlobalStore _globalStore;
  final String _baseUrl =
      'http://dataservice.accuweather.com/currentconditions/v1';

  CurrentConditionsService(this._globalStore);

  Future<void> fetchCurrentConditions() async {
    try {
      if (_globalStore.favoriteCityDetails == null) {
        throw Exception('No favorite city selected');
      }

      final cityKey = _globalStore.favoriteCityDetails!.key;
      final apiKey = dotenv.env['ACCU_WEATHER_KEY'];

      if (apiKey == null) {
        throw Exception('API key not found in environment variables');
      }

      final queryParameters = {
        'apikey': apiKey,
        'language': 'pl-pl',
        'details': 'true',
      };

      final uri = Uri.parse('$_baseUrl/$cityKey')
          .replace(queryParameters: queryParameters);
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final List<dynamic> jsonResponse = jsonDecode(response.body);
        if (jsonResponse.isNotEmpty) {
          final currentConditions = CurrentConditions.fromJson(jsonResponse[0]);
          _globalStore.setCurrentConditions(currentConditions);
        } else {
          throw Exception('Empty response from API');
        }
      } else {
        throw Exception(
            'Failed to fetch current conditions: ${response.statusCode}');
      }
    } catch (e) {
      rethrow;
    }
  }

  String getFormattedTemperature() {
    final conditions = _globalStore.currentConditions;
    if (conditions == null) return 'N/A';
    return '${conditions.temperature.value}${conditions.temperature.unit}';
  }

  String getFormattedWindSpeed() {
    final conditions = _globalStore.currentConditions;
    if (conditions == null) return 'N/A';
    return '${conditions.windSpeed} km/h';
  }

  bool hasCurrentConditions() {
    return _globalStore.currentConditions != null;
  }
}
