import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_dashboard_app/constants/firestore_constants.dart';
import 'package:flutter_dashboard_app/services/autocomplete/autocomplete_types.dart';
import 'package:flutter_dashboard_app/services/favoriteCity/favorite_city_types.dart';
import 'package:flutter_dashboard_app/store/global_store.dart';

class FavoriteCityService {
  final GlobalStore _globalStore;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  FavoriteCityService(this._globalStore);

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

      final cities = FirestoreCollections.favoriteCities
          .fromFirestore(docSnapshot.data() ?? {});

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

      final docRef = _firestore
          .collection(FirestoreCollections.favoriteCities.collectionName)
          .doc(userId);

      final docSnapshot = await docRef.get();
      final currentCities = docSnapshot.exists
          ? FirestoreCollections.favoriteCities
              .fromFirestore(docSnapshot.data() ?? {})
          : <AutocompleteCity>[];

      if (currentCities.any((c) => c.key == city.key)) {
        return FavoriteCityResponse(
          success: false,
          error: 'City already in favorites',
        );
      }

      final updatedCities = [...currentCities, city];
      await docRef
          .set(FirestoreCollections.favoriteCities.toFirestore(updatedCities));

      _globalStore.setFavoriteCities(updatedCities);
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

      final currentCities = FirestoreCollections.favoriteCities
          .fromFirestore(docSnapshot.data() ?? {});
      final updatedCities =
          currentCities.where((city) => city.key != cityKey).toList();

      await docRef
          .set(FirestoreCollections.favoriteCities.toFirestore(updatedCities));

      _globalStore.setFavoriteCities(updatedCities);
      return FavoriteCityResponse(success: true, cities: updatedCities);
    } catch (e) {
      return FavoriteCityResponse(
        success: false,
        error: e.toString(),
      );
    }
  }
}
