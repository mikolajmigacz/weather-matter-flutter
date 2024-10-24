import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dashboard_app/store/global_store.dart';
import 'package:flutter_dashboard_app/services/fiveDaysForecast/five_days_forecast_types.dart';

class FiveDaysForecastService {
  final GlobalStore _globalStore;
  final String _baseUrl =
      'http://dataservice.accuweather.com/forecasts/v1/daily/5day';

  FiveDaysForecastService(this._globalStore);

  Future<List<DayForecast>> fetchFiveDaysForecast() async {
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
        'metric': 'true',
        'details': 'false',
      };

      final uri = Uri.parse('$_baseUrl/$cityKey')
          .replace(queryParameters: queryParameters);
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
        final List<dynamic> dailyForecasts = jsonResponse['DailyForecasts'];
        return dailyForecasts
            .map((json) => DayForecast.fromJson(json))
            .toList();
      } else {
        throw Exception(
            'Failed to fetch 5-day forecast: ${response.statusCode}');
      }
    } catch (e) {
      rethrow;
    }
  }

  String getFormattedDate(DateTime dateTime) {
    // You can customize this method based on your date formatting needs
    return '${dateTime.day}.${dateTime.month}';
  }

  String getFormattedTemperature(double temp, String unit) {
    return '${temp.round()}°$unit';
  }
}
