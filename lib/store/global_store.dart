import 'package:flutter/material.dart';
import 'package:flutter_dashboard_app/services/autocomplete/autocomplete_types.dart';
import 'package:flutter_dashboard_app/services/city/city_types.dart';
import 'package:flutter_dashboard_app/services/currentConditions/current_conditions_types.dart';

class GlobalStore with ChangeNotifier {
  String _userId = "";
  String _login = "";
  String _name = "";
  String _favoriteCity = "";
  String _fcmToken = "";
  CityDetails? _favoriteCityDetails;
  CurrentConditions? _currentConditions;
  AutocompleteCity? _selectedCity;
  CurrentConditions? _selectedCityConditions;
  List<CityDetails> _favoriteCities = [];

  // Getters
  String get userId => _userId;
  String get login => _login;
  String get name => _name;
  String get favoriteCity => _favoriteCity;
  CityDetails? get favoriteCityDetails => _favoriteCityDetails;
  CurrentConditions? get currentConditions => _currentConditions;
  AutocompleteCity? get selectedCity => _selectedCity;
  CurrentConditions? get selectedCityConditions => _selectedCityConditions;
  List<CityDetails> get favoriteCities => _favoriteCities;

  String get fcmToken => _fcmToken;

  void setFcmToken(String token) {
    _fcmToken = token;
    notifyListeners();
  }

  // Setters
  void setUserId(String userId) {
    _userId = userId;
    notifyListeners();
  }

  void setLogin(String login) {
    _login = login;
    notifyListeners();
  }

  void setName(String name) {
    _name = name;
    notifyListeners();
  }

  void setFavoriteCity(String favoriteCity) {
    if (_favoriteCity != favoriteCity) {
      _favoriteCity = favoriteCity;
      notifyListeners();
    }
  }

  void setFavoriteCityDetails(CityDetails cityDetails) {
    _favoriteCityDetails = cityDetails;
    notifyListeners();
  }

  void setCurrentConditions(CurrentConditions currentConditions) {
    _currentConditions = currentConditions;
    notifyListeners();
  }

  void setUserData({
    required String userId,
    required String login,
    required String name,
    required String favoriteCity,
    String? fcmToken,
  }) {
    _userId = userId;
    _login = login;
    _name = name;
    _favoriteCity = favoriteCity;
    if (fcmToken != null) _fcmToken = fcmToken;
    notifyListeners();
  }

  void clearUserData() {
    _userId = "";
    _login = "";
    _name = "";
    _favoriteCity = "";
    _fcmToken = "";
    _favoriteCityDetails = null;
    _currentConditions = null;
    _selectedCity = null;
    _selectedCityConditions = null;
    _favoriteCities = [];
    notifyListeners();
  }

  void setSelectedCity(AutocompleteCity? city) {
    _selectedCity = city;
    _selectedCityConditions = null;
    notifyListeners();
  }

  void setSelectedCityConditions(CurrentConditions? conditions) {
    _selectedCityConditions = conditions;
    notifyListeners();
  }

  void setFavoriteCities(List<CityDetails> cities) {
    _favoriteCities = cities;
    notifyListeners();
  }
}
