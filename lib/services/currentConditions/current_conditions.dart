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

  Future<CurrentConditions> fetchCurrentConditions(String cityKey) async {
    try {
      if (_globalStore.favoriteCityDetails == null) {
        throw Exception('No favorite city selected');
      }

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
          return CurrentConditions.fromJson(jsonResponse[0]);
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

  String formatTemperature(CurrentConditions conditions) {
    return '${conditions.temperature.value}${conditions.temperature.unit}';
  }

  String formatWindSpeed(CurrentConditions conditions) {
    return '${conditions.windSpeed} km/h';
  }
}
