import 'package:flutter/material.dart';
import 'package:flutter_dashboard_app/theme/app_colors.dart';
import 'package:flutter_dashboard_app/widgets/app_drawer.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';
import 'package:flutter_dashboard_app/store/global_store.dart';
import 'package:flutter_dashboard_app/services/city/city_types.dart';

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  static const LatLng _defaultLocation = LatLng(52.237049, 21.017532);

  LatLng _currentLocation = _defaultLocation;
  bool _isLoading = false;
  String? _error;
  CityDetails? _selectedCity;

  @override
  void initState() {
    super.initState();
    _requestLocation();
  }

  Future<void> _requestLocation() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw 'Usługi lokalizacji są wyłączone';
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw 'Odmówiono dostępu do lokalizacji';
        }
      }

      if (permission == LocationPermission.deniedForever) {
        throw 'Dostęp do lokalizacji jest trwale zablokowany';
      }

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      setState(() {
        _currentLocation = LatLng(position.latitude, position.longitude);
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Widget _buildLocationDetails() {
    if (_selectedCity == null) return const SizedBox.shrink();

    final isDesktop = MediaQuery.of(context).size.width > 768;

    return Positioned(
      left: 16,
      right: isDesktop ? 96 : 16,
      bottom: isDesktop ? 16 : 80, // Higher on mobile to avoid FAB
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.darkGray.withOpacity(0.9),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.teal, width: 1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _selectedCity!.localizedName,
              style: TextStyle(
                color: Colors.white,
                fontSize: isDesktop ? 18 : 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '${_selectedCity!.country.localizedName}, ${_selectedCity!.region.localizedName}',
              style: TextStyle(
                color: Colors.white.withOpacity(0.7),
                fontSize: isDesktop ? 14 : 12,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Pozycja: ${_selectedCity!.latitude.toStringAsFixed(4)}, ${_selectedCity!.longitude.toStringAsFixed(4)}',
              style: TextStyle(
                color: Colors.white.withOpacity(0.5),
                fontSize: isDesktop ? 12 : 10,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMap() {
    final favoriteCities = context.watch<GlobalStore>().favoriteCities;
    final bounds = _calculateMapBounds(favoriteCities);

    return FlutterMap(
      options: MapOptions(
        initialCenter: _currentLocation,
        initialZoom: 13.0,
        onMapReady: () {
          // Center map to show all markers when ready
          if (favoriteCities.isNotEmpty) {
            Future.delayed(const Duration(milliseconds: 100), () {
              _fitBounds(bounds);
            });
          }
        },
        onTap: (_, __) {
          setState(() {
            _selectedCity = null;
          });
        },
      ),
      children: [
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'com.example.app',
          maxZoom: 19,
        ),
        MarkerLayer(
          markers: [
            // Current location marker
            Marker(
              point: _currentLocation,
              width: 40,
              height: 40,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.3),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.blue,
                    width: 2,
                  ),
                ),
                child: const Icon(
                  Icons.my_location,
                  color: Colors.blue,
                  size: 24,
                ),
              ),
            ),
            ...favoriteCities.map(
              (city) => Marker(
                point: LatLng(city.latitude, city.longitude),
                width: 40,
                height: 40,
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedCity = city;
                    });
                  },
                  child: Stack(
                    children: [
                      // Drop shadow for better visibility
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.3),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.3),
                              blurRadius: 8,
                              spreadRadius: 2,
                            )
                          ],
                        ),
                      ),
                      // Main marker container
                      Container(
                        decoration: BoxDecoration(
                          color: _selectedCity == city
                              ? AppColors.teal
                              : const Color(
                                  0xFFFF4081), // Pink color for better visibility
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.white,
                            width: 2,
                          ),
                          // Add shadow for depth
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Center(
                          child: Icon(
                            Icons.favorite,
                            color: Colors.white,
                            size: 20,
                            shadows: [
                              // Add text shadow for better contrast
                              Shadow(
                                color: Colors.black.withOpacity(0.3),
                                blurRadius: 3,
                                offset: const Offset(0, 1),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  LatLngBounds _calculateMapBounds(List<CityDetails> cities) {
    if (cities.isEmpty) {
      return LatLngBounds(
        _currentLocation,
        _currentLocation,
      );
    }

    double minLat = cities.first.latitude;
    double maxLat = cities.first.latitude;
    double minLng = cities.first.longitude;
    double maxLng = cities.first.longitude;

    for (var city in cities) {
      minLat = minLat < city.latitude ? minLat : city.latitude;
      maxLat = maxLat > city.latitude ? maxLat : city.latitude;
      minLng = minLng < city.longitude ? minLng : city.longitude;
      maxLng = maxLng > city.longitude ? maxLng : city.longitude;
    }

    // Include current location in bounds
    minLat =
        minLat < _currentLocation.latitude ? minLat : _currentLocation.latitude;
    maxLat =
        maxLat > _currentLocation.latitude ? maxLat : _currentLocation.latitude;
    minLng = minLng < _currentLocation.longitude
        ? minLng
        : _currentLocation.longitude;
    maxLng = maxLng > _currentLocation.longitude
        ? maxLng
        : _currentLocation.longitude;

    return LatLngBounds(
      LatLng(minLat, minLng),
      LatLng(maxLat, maxLng),
    );
  }

  void _fitBounds(LatLngBounds bounds) {
    // Add padding to bounds
    final latPadding =
        (bounds.northEast.latitude - bounds.southWest.latitude) * 0.1;
    final lngPadding =
        (bounds.northEast.longitude - bounds.southWest.longitude) * 0.1;

    final paddedBounds = LatLngBounds(
      LatLng(bounds.southWest.latitude - latPadding,
          bounds.southWest.longitude - lngPadding),
      LatLng(bounds.northEast.latitude + latPadding,
          bounds.northEast.longitude + lngPadding),
    );
  }

  Widget _buildContent() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          color: AppColors.teal,
        ),
      );
    }

    if (_error != null) {
      final isDesktop = MediaQuery.of(context).size.width > 768;

      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.location_off,
              size: isDesktop ? 64 : 48,
              color: Colors.white.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                _error!,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: isDesktop ? 16 : 14,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _requestLocation,
              icon: const Icon(Icons.refresh),
              label: const Text('Spróbuj ponownie'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.teal,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(
                  horizontal: isDesktop ? 24 : 16,
                  vertical: isDesktop ? 12 : 8,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Stack(
      children: [
        _buildMap(),
        _buildLocationDetails(),
        Positioned(
          right: 16,
          bottom: 16,
          child: FloatingActionButton(
            onPressed: _requestLocation,
            backgroundColor: AppColors.teal,
            child: const Icon(Icons.my_location, color: Colors.white),
          ),
        ),
      ],
    );
  }

  Widget _buildDesktopContent() {
    return Row(
      children: [
        const ResponsiveDrawer(),
        Expanded(
          child: _buildContent(),
        ),
      ],
    );
  }

  Widget _buildMobileContent() {
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
          child: _buildContent(),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width > 768;

    return Scaffold(
      backgroundColor: AppColors.darkestGray,
      drawer: isDesktop ? null : const ResponsiveDrawer(),
      body: isDesktop ? _buildDesktopContent() : _buildMobileContent(),
    );
  }
}
