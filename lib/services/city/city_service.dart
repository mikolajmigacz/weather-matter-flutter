import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_dashboard_app/constants/firestore_constants.dart';
import 'package:flutter_dashboard_app/services/city/city_types.dart';

class CityInfoService {
  final String? _apiKey = dotenv.env['ACCU_WEATHER_KEY'];
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<CityDetails?> fetchCityDetails(String cityName) async {
    final cityDoc = await _firestore
        .collection(FirestoreCollections.citiesInfo.collectionName)
        .doc(cityName.toLowerCase())
        .get();

    if (cityDoc.exists) {
      return FirestoreCollections.citiesInfo.fromFirestore(cityDoc.data()!);
    } else {
      final cityDetails = await _fetchFromApi(cityName);
      if (cityDetails != null) {
        await _storeInFirestore(cityName, cityDetails);
        return cityDetails;
      }
    }
    return null;
  }

  Future<CityDetails?> _fetchFromApi(String cityName) async {
    final url = Uri.parse(
        'http://dataservice.accuweather.com/locations/v1/cities/search?apikey=$_apiKey&q=$cityName&language=pl');

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      if (data.isNotEmpty) {
        print(data);
        return CityDetails.fromJson(data[0]);
      }
    }
    return null;
  }

  Future<void> _storeInFirestore(
      String cityName, CityDetails cityDetails) async {
    await _firestore
        .collection(FirestoreCollections.citiesInfo.collectionName)
        .doc(cityName.toLowerCase())
        .set(FirestoreCollections.citiesInfo.toFirestore(cityDetails));
  }
}
