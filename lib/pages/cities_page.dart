import 'package:flutter/material.dart';
import 'package:flutter_dashboard_app/services/autocomplete/autocomplete.dart';
import 'package:flutter_dashboard_app/services/currentConditions/current_conditions.dart';
import 'package:flutter_dashboard_app/theme/app_colors.dart';
import 'package:flutter_dashboard_app/widgets/app_drawer.dart';
import 'package:flutter_dashboard_app/services/autocomplete/autocomplete_types.dart';
import 'package:flutter_dashboard_app/widgets/city_search_details.dart';
import 'package:flutter_dashboard_app/widgets/city_search_item.dart';
import 'dart:async';
import 'package:provider/provider.dart';
import 'package:flutter_dashboard_app/store/global_store.dart';

/// A screen that allows users to search for cities and view current weather conditions.
///
/// This page integrates an autocomplete service for city search, allowing users to select a city
/// and view real-time weather conditions. The UI adapts for both desktop and mobile layouts.
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
      store.setSelectedCity(city);

      final conditions =
          await _currentConditionsService.fetchCurrentConditions(city.key);
      store.setSelectedCityConditions(conditions);
    } catch (e) {
      setState(() {
        _error = e.toString();
      });
    }
  }

  Widget _buildDesktopContent(BuildContext context, GlobalStore store) {
    return Row(
      children: [
        const ResponsiveDrawer(),
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
                      Expanded(
                        flex: 70,
                        child: _buildContent(),
                      ),
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
    );
  }

  Widget _buildMobileContent(BuildContext context, GlobalStore store) {
    return Column(
      children: [
        AppBar(
          backgroundColor: AppColors.darkGray,
          leading: Builder(
            builder: (context) => IconButton(
              icon: const Icon(Icons.menu),
              onPressed: () => Scaffold.of(context).openDrawer(),
            ),
          ),
          elevation: 0,
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                _buildSearchInput(),
                const SizedBox(height: 16),
                if (store.selectedCity != null) ...[
                  CitySearchDetails(store: store),
                  const SizedBox(height: 16),
                ],
                Expanded(
                  child: _buildContent(),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSearchInput() {
    final isDesktop = MediaQuery.of(context).size.width > 768;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.darkGray,
        borderRadius: BorderRadius.circular(isDesktop ? 16 : 12),
      ),
      padding: isDesktop ? const EdgeInsets.all(24) : const EdgeInsets.all(16),
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
    final isDesktop = MediaQuery.of(context).size.width > 768;

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
              size: isDesktop ? 100 : 80,
              color: Colors.white.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'Wpisz w pasku wyszukiwania, aby znaleźć miasto',
              style: TextStyle(
                color: Colors.white.withOpacity(0.5),
                fontSize: isDesktop ? 16 : 14,
              ),
              textAlign: TextAlign.center,
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
              size: isDesktop ? 64 : 48,
              color: Colors.white.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'Nie znaleziono miast',
              style: TextStyle(
                color: Colors.white.withOpacity(0.5),
                fontSize: isDesktop ? 16 : 14,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.symmetric(vertical: isDesktop ? 16 : 8),
      itemCount: _searchResults!.length,
      itemBuilder: (context, index) {
        final city = _searchResults![index];
        final store = context.watch<GlobalStore>();
        final isSelected = store.selectedCity?.key == city.key;

        return Padding(
          padding: EdgeInsets.only(bottom: isDesktop ? 16 : 8),
          child: CitySearchItem(
            city: city,
            isSelected: isSelected,
            onTap: () {
              final store = Provider.of<GlobalStore>(context, listen: false);
              store.setSelectedCity(city);
              _fetchCityConditions(city, store);
            },
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width > 768;
    final store = context.watch<GlobalStore>();

    return Scaffold(
      backgroundColor: AppColors.darkestGray,
      drawer: isDesktop ? null : const ResponsiveDrawer(),
      body: isDesktop
          ? _buildDesktopContent(context, store)
          : _buildMobileContent(context, store),
    );
  }
}
