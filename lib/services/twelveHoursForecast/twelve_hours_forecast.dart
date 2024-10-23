import 'dart:convert';
import 'package:flutter_dashboard_app/services/twelveHoursForecast/twelve_hours_forecast_types.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dashboard_app/store/global_store.dart';

class TwelveHoursForecastService {
  final GlobalStore _globalStore;
  final String _baseUrl =
      'http://dataservice.accuweather.com/forecasts/v1/hourly/12hour';

  TwelveHoursForecastService(this._globalStore);

  Future<List<HourForecast>> fetchTwelveHoursForecast() async {
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
        'metric': 'true',
      };

      final uri = Uri.parse('$_baseUrl/$cityKey')
          .replace(queryParameters: queryParameters);
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final List<dynamic> jsonResponse = jsonDecode(response.body);
        return jsonResponse.map((json) => HourForecast.fromJson(json)).toList();
      } else {
        throw Exception(
            'Failed to fetch 12-hour forecast: ${response.statusCode}');
      }
    } catch (e) {
      rethrow;
    }
  }

  String getFormattedTime(DateTime dateTime) {
    return '${dateTime.hour.toString().padLeft(2, '0')}:00';
  }

  String getFormattedTemperature(HourForecast forecast) {
    return '${forecast.temperature.value}${forecast.temperature.unit}';
  }
}
