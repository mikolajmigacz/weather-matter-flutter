import 'package:flutter/material.dart';
import 'package:flutter_dashboard_app/services/autocomplete/autocomplete.dart';
import 'package:flutter_dashboard_app/services/currentConditions/current_conditions.dart';
import 'package:flutter_dashboard_app/services/city/city_types.dart'
    as city_types;
import 'package:flutter_dashboard_app/theme/app_colors.dart';
import 'package:flutter_dashboard_app/widgets/app_drawer.dart';
import 'package:flutter_dashboard_app/services/autocomplete/autocomplete_types.dart';
import 'package:flutter_dashboard_app/widgets/city_search_details.dart';
import 'package:flutter_dashboard_app/widgets/city_search_item.dart';
import 'dart:async';
import 'package:provider/provider.dart';
import 'package:flutter_dashboard_app/store/global_store.dart';

class CitiesPage extends StatefulWidget {
  const CitiesPage({super.key});

  @override
  State<CitiesPage> createState() => _CitiesPageState();
}

class _CitiesPageState extends State<CitiesPage> {
  Timer? _debounce;
  bool _isLoading = false;
  String? _error;
  List<AutocompleteCity>? _searchResults;
  late final AutocompleteService _autocompleteService;
  late final CurrentConditionsService _currentConditionsService;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final store = Provider.of<GlobalStore>(context, listen: false);
    _autocompleteService = AutocompleteService();
    _currentConditionsService = CurrentConditionsService(store);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _onSearchChanged(String query) async {
    if (_debounce?.isActive ?? false) _debounce?.cancel();

    // Reset selected city immediately when search changes
    final store = Provider.of<GlobalStore>(context, listen: false);
    store.setSelectedCity(null);

    if (query.isEmpty) {
      setState(() {
        _searchResults = null;
        _error = null;
        _isLoading = false;
      });
      return;
    }

    _debounce = Timer(const Duration(milliseconds: 500), () async {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      try {
        final results = await _autocompleteService.fetchAutocomplete(query);
        setState(() {
          _searchResults = results;
          _isLoading = false;
        });
      } catch (e) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    });
  }

  Future<void> _fetchCityConditions(
      AutocompleteCity city, GlobalStore store) async {
    try {
      store.setCityDetails(city_types.CityDetails(
        key: city.key,
        localizedName: city.localizedName,
        englishName: city.localizedName,
        region: city_types.Region(id: "", localizedName: "", englishName: ''),
        country: city_types.Country(
            id: city.country.id,
            localizedName: city.country.name,
            englishName: ''),
      ));

      final conditions =
          await _currentConditionsService.fetchCurrentConditions();
      store.setSelectedCityConditions(conditions);
    } catch (e) {
      setState(() {
        _error = e.toString();
      });
    }
  }

  Widget _buildSearchInput() {
    return Container(
      width: double.infinity, // 100% szerokości
      decoration: BoxDecoration(
        color: AppColors.darkGray,
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.all(24),
      child: TextField(
        controller: _searchController,
        onChanged: _onSearchChanged,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          hintText: 'Znajdź miasto ...',
          hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
          prefixIcon: Icon(Icons.search, color: Colors.white.withOpacity(0.5)),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: AppColors.teal),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: Colors.white.withOpacity(0.2)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: AppColors.teal),
          ),
        ),
      ),
    );
  }

  Widget _buildContent() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red,
            ),
            const SizedBox(height: 16),
            Text(
              _error!,
              style: const TextStyle(color: Colors.red),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    if (_searchResults == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_outlined,
              size: 100,
              color: Colors.white.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'Wpisz w pasku wyszukiwania, aby znaleźć miasto',
              style: TextStyle(
                color: Colors.white.withOpacity(0.5),
                fontSize: 16,
              ),
            ),
          ],
        ),
      );
    }

    if (_searchResults!.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.location_city,
              size: 64,
              color: Colors.white.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'Nie znaleziono miast',
              style: TextStyle(
                color: Colors.white.withOpacity(0.5),
                fontSize: 16,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 16),
      itemCount: _searchResults!.length,
      itemBuilder: (context, index) {
        final city = _searchResults![index];
        final store = context.watch<GlobalStore>();
        final isSelected = store.selectedCity?.key == city.key;

        return CitySearchItem(
          city: city,
          isSelected: isSelected,
          onTap: () {
            final store = Provider.of<GlobalStore>(context, listen: false);
            store.setSelectedCity(city);
            _fetchCityConditions(city, store);
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final store = context.watch<GlobalStore>();

    return Scaffold(
      backgroundColor: AppColors.darkestGray,
      body: Row(
        children: [
          const AppDrawer(),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(32.0),
              child: Column(
                children: [
                  _buildSearchInput(),
                  const SizedBox(height: 24),
                  Expanded(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Lista wyników - 70% szerokości
                        Expanded(
                          flex: 70,
                          child: _buildContent(),
                        ),
                        // Szczegóły wybranego miasta - 30% szerokości
                        if (store.selectedCity != null) ...[
                          const SizedBox(width: 24),
                          Expanded(
                            flex: 30,
                            child: CitySearchDetails(store: store),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
