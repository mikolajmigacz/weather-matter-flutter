import 'package:flutter/material.dart';
import 'package:flutter_dashboard_app/theme/app_colors.dart';
import 'package:flutter_dashboard_app/widgets/app_drawer.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  // Default location (Warsaw)
  static const LatLng _defaultLocation = LatLng(52.237049, 21.017532);

  LatLng _currentLocation = _defaultLocation;
  bool _isLoading = false;
  String? _error;

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
      // Check if location services are enabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw 'Usługi lokalizacji są wyłączone';
      }

      // Check for permission
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

      // Get current position
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

  Widget _buildMap() {
    return FlutterMap(
      options: MapOptions(
        initialCenter: _currentLocation,
        initialZoom: 13.0,
      ),
      children: [
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'com.example.app',
          maxZoom: 19,
        ),
        MarkerLayer(
          markers: [
            Marker(
              point: _currentLocation,
              width: 40,
              height: 40,
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.teal.withOpacity(0.3),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColors.teal,
                    width: 2,
                  ),
                ),
                child: const Icon(
                  Icons.location_on,
                  color: AppColors.teal,
                  size: 24,
                ),
              ),
            ),
          ],
        ),
      ],
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
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.location_off,
              size: 64,
              color: Colors.white.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              _error!,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _requestLocation,
              icon: const Icon(Icons.refresh),
              label: const Text('Spróbuj ponownie'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.teal,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkestGray,
      body: Row(
        children: [
          const AppDrawer(),
          Expanded(
            child: _buildContent(),
          ),
        ],
      ),
    );
  }
}
