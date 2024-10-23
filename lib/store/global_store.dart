import 'package:flutter/material.dart';
import 'package:flutter_dashboard_app/services/city/city_types.dart';
import 'package:flutter_dashboard_app/services/currentConditions/current_conditions_types.dart';

class GlobalStore with ChangeNotifier {
  String _userId = "";
  String _login = "";
  String _name = "";
  String _favoriteCity = "";
  CityDetails? _favoriteCityDetails;
  CurrentConditions? _currentConditions;

  // Getters
  String get userId => _userId;
  String get login => _login;
  String get name => _name;
  String get favoriteCity => _favoriteCity;
  CityDetails? get favoriteCityDetails => _favoriteCityDetails;
  CurrentConditions? get currentConditions => _currentConditions;

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

  void setCityDetails(CityDetails cityDetails) {
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
  }) {
    _userId = userId;
    _login = login;
    _name = name;
    _favoriteCity = favoriteCity;
    notifyListeners();
  }

  void clearUserData() {
    _userId = "";
    _login = "";
    _name = "";
    _favoriteCity = "";
    _favoriteCityDetails = null;
    _currentConditions = null;
    notifyListeners();
  }
}
