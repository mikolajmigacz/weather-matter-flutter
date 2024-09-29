import 'package:flutter/material.dart';
import 'package:flutter_dashboard_app/services/city/city_types.dart';
import 'package:flutter_dashboard_app/store/global_store.dart';
import 'package:flutter_dashboard_app/widgets/app_drawer.dart';
import 'package:flutter_dashboard_app/services/city/city_service.dart';
import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late final CityInfoService _cityInfoService;

  @override
  void initState() {
    super.initState();
    final store = Provider.of<GlobalStore>(context, listen: false);
    _cityInfoService = CityInfoService(store);
  }

  Future<void> _fetchCityDetails(GlobalStore store) async {
    if (store.favoriteCity.isNotEmpty) {
      await _cityInfoService.fetchAndStoreCityDetails(store.favoriteCity);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          const AppDrawer(),
          Expanded(
            child: Consumer<GlobalStore>(
              builder: (context, globalStore, child) {
                if (globalStore.favoriteCity.isNotEmpty &&
                    globalStore.favoriteCityDetails == null) {
                  _fetchCityDetails(globalStore);
                }

                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildUserInfo(globalStore),
                      if (globalStore.favoriteCityDetails != null) ...[
                        const SizedBox(height: 16),
                        const Text(
                          'City Details:',
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        _buildCityDetails(globalStore.favoriteCityDetails!),
                      ],
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserInfo(GlobalStore store) {
    return Column(
      children: [
        Text('User ID: ${store.userId}', style: const TextStyle(fontSize: 18)),
        const SizedBox(height: 8),
        Text('Login: ${store.login}', style: const TextStyle(fontSize: 18)),
        const SizedBox(height: 8),
        Text('Name: ${store.name}', style: const TextStyle(fontSize: 18)),
        const SizedBox(height: 8),
        Text('Favorite City: ${store.favoriteCity}',
            style: const TextStyle(fontSize: 18)),
      ],
    );
  }

  Widget _buildCityDetails(CityDetails details) {
    return Column(
      children: [
        Text('Key: ${details.key}', style: const TextStyle(fontSize: 18)),
        Text('Name (PL): ${details.localizedName}',
            style: const TextStyle(fontSize: 18)),
        Text('Name (EN): ${details.englishName}',
            style: const TextStyle(fontSize: 18)),
        Text('country (EN): ${details.country?.localizedName}',
            style: const TextStyle(fontSize: 18)),
        Text('country (EN): ${details.country?.id}',
            style: const TextStyle(fontSize: 18)),
        Text('country (EN): ${details.region.id}',
            style: const TextStyle(fontSize: 18)),
      ],
    );
  }

  Widget _buildCountryDetails(CityDetails details) {
    return Column(
      children: [
        Text('Key: ${details.key}', style: const TextStyle(fontSize: 18)),
        Text('Name (PL): ${details.localizedName}',
            style: const TextStyle(fontSize: 18)),
        Text('Name (EN): ${details.englishName}',
            style: const TextStyle(fontSize: 18)),
      ],
    );
  }
}
