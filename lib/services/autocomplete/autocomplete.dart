import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dashboard_app/services/autocomplete/autocomplete_types.dart';

class AutocompleteService {
  final String _baseUrl =
      'http://dataservice.accuweather.com/locations/v1/cities/autocomplete';

  Future<List<AutocompleteCity>> fetchAutocomplete(String query) async {
    try {
      final apiKey = dotenv.env['ACCU_WEATHER_KEY'];

      if (apiKey == null) {
        throw Exception('API key not found in environment variables');
      }

      final queryParameters = {
        'apikey': apiKey,
        'q': query,
        'language': 'pl-pl',
      };

      final uri = Uri.parse(_baseUrl).replace(queryParameters: queryParameters);
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final List<dynamic> jsonResponse = jsonDecode(response.body);
        return jsonResponse
            .map((json) => AutocompleteCity.fromJson(json))
            .toList();
      } else {
        throw Exception(
            'Failed to fetch autocomplete results: ${response.statusCode}');
      }
    } catch (e) {
      rethrow;
    }
  }
}
