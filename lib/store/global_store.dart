import 'package:flutter/material.dart';

class GlobalStore with ChangeNotifier {
  String _userId = "";
  String _login = "";
  String _name = "";
  String _favoriteCity = "";

  // Gettery
  String get userId => _userId;
  String get login => _login;
  String get name => _name;
  String get favoriteCity => _favoriteCity;

  // Settery
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
    _favoriteCity = favoriteCity;
    notifyListeners();
  }

  // Metoda do ustawienia wszystkich pól na raz
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

  // Czyszczenie danych podczas wylogowania
  void clearUserData() {
    _userId = "";
    _login = "";
    _name = "";
    _favoriteCity = "";
    notifyListeners();
  }
}
