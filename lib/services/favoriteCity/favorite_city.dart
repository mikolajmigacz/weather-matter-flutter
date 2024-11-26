import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_dashboard_app/constants/firestore_constants.dart';
import 'package:flutter_dashboard_app/services/autocomplete/autocomplete_types.dart';
import 'package:flutter_dashboard_app/services/city/city_service.dart';
import 'package:flutter_dashboard_app/services/city/city_types.dart';
import 'package:flutter_dashboard_app/services/favoriteCity/favorite_city_types.dart';
import 'package:flutter_dashboard_app/services/notification/notification.dart';
import 'package:flutter_dashboard_app/store/global_store.dart';

class FavoriteCityService {
  final GlobalStore _globalStore;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late final CityInfoService _cityInfoService;
  final PushNotificationService _pushNotificationService =
      PushNotificationService();

  FavoriteCityService(this._globalStore) {
    _cityInfoService = CityInfoService();
  }

  Future<FavoriteCityResponse> getFavoriteCities() async {
    try {
      final userId = _globalStore.userId;
      if (userId.isEmpty) {
        return FavoriteCityResponse(
          success: false,
          error: 'User not logged in',
        );
      }

      final docSnapshot = await _firestore
          .collection(FirestoreCollections.favoriteCities.collectionName)
          .doc(userId)
          .get();

      if (!docSnapshot.exists) {
        await _firestore
            .collection(FirestoreCollections.favoriteCities.collectionName)
            .doc(userId)
            .set({FirestoreCollections.favoriteCities.cities: []});

        _globalStore.setFavoriteCities([]);
        return FavoriteCityResponse(success: true, cities: []);
      }

      final cities = FirestoreCollections.citiesInfo.fromFirestoreList(
          docSnapshot.data()?[FirestoreCollections.favoriteCities.cities] ??
              []);

      _globalStore.setFavoriteCities(cities);
      return FavoriteCityResponse(success: true, cities: cities);
    } catch (e) {
      return FavoriteCityResponse(
        success: false,
        error: e.toString(),
      );
    }
  }

  Future<FavoriteCityResponse> addFavoriteCity(AutocompleteCity city) async {
    try {
      final userId = _globalStore.userId;
      if (userId.isEmpty) {
        return FavoriteCityResponse(
          success: false,
          error: 'User not logged in',
        );
      }

      final cityDetails =
          await _cityInfoService.fetchCityDetails(city.localizedName);
      if (cityDetails == null) {
        return FavoriteCityResponse(
          success: false,
          error: 'Failed to fetch city details',
        );
      }

      final docRef = _firestore
          .collection(FirestoreCollections.favoriteCities.collectionName)
          .doc(userId);

      final docSnapshot = await docRef.get();
      final currentCities = docSnapshot.exists
          ? FirestoreCollections.citiesInfo.fromFirestoreList(
              docSnapshot.data()?[FirestoreCollections.favoriteCities.cities] ??
                  [])
          : <CityDetails>[];

      if (currentCities.any((c) => c.key == cityDetails.key)) {
        return FavoriteCityResponse(
          success: false,
          error: 'City already in favorites',
        );
      }

      final updatedCities = [...currentCities, cityDetails];
      await docRef.set({
        FirestoreCollections.favoriteCities.cities: updatedCities
            .map((city) => FirestoreCollections.citiesInfo.toFirestore(city))
            .toList()
      });

      _globalStore.setFavoriteCities(updatedCities);

      // Show push notification
      await _pushNotificationService.showNotification(
        title: 'Nowe ulubione miasto',
        body: '${cityDetails.localizedName} zostało dodane do ulubionych',
      );

      return FavoriteCityResponse(success: true, cities: updatedCities);
    } catch (e) {
      return FavoriteCityResponse(
        success: false,
        error: e.toString(),
      );
    }
  }

  Future<FavoriteCityResponse> removeFavoriteCity(String cityKey) async {
    try {
      final userId = _globalStore.userId;
      if (userId.isEmpty) {
        return FavoriteCityResponse(
          success: false,
          error: 'User not logged in',
        );
      }

      final docRef = _firestore
          .collection(FirestoreCollections.favoriteCities.collectionName)
          .doc(userId);

      final docSnapshot = await docRef.get();
      if (!docSnapshot.exists) {
        return FavoriteCityResponse(
          success: false,
          error: 'No favorite cities found',
        );
      }

      final currentCities = FirestoreCollections.citiesInfo.fromFirestoreList(
          docSnapshot.data()?[FirestoreCollections.favoriteCities.cities] ??
              []);

      // Get city details before removal for notification
      final cityToRemove =
          currentCities.firstWhere((city) => city.key == cityKey);

      final updatedCities =
          currentCities.where((city) => city.key != cityKey).toList();

      await docRef.set({
        FirestoreCollections.favoriteCities.cities: updatedCities
            .map((city) => FirestoreCollections.citiesInfo.toFirestore(city))
            .toList()
      });

      _globalStore.setFavoriteCities(updatedCities);

      // Show push notification
      await _pushNotificationService.showNotification(
        title: 'Usunięto miasto z ulubionych',
        body: '${cityToRemove.localizedName} zostało usunięte z ulubionych',
      );

      return FavoriteCityResponse(success: true, cities: updatedCities);
    } catch (e) {
      return FavoriteCityResponse(
        success: false,
        error: e.toString(),
      );
    }
  }
}
