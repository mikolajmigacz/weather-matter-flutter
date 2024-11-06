import 'package:flutter/material.dart';
import 'package:flutter_dashboard_app/services/autocomplete/autocomplete_types.dart';
import 'package:flutter_dashboard_app/services/favoriteCity/favorite_city.dart';
import 'package:flutter_dashboard_app/theme/app_colors.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_dashboard_app/constants/firestore_constants.dart';
import 'package:flutter_svg/svg.dart';
import 'package:flutter_dashboard_app/store/global_store.dart';
import 'package:provider/provider.dart';

class FavoriteCityItem extends StatefulWidget {
  final AutocompleteCity city;

  const FavoriteCityItem({
    Key? key,
    required this.city,
  }) : super(key: key);

  @override
  State<FavoriteCityItem> createState() => _FavoriteCityItemState();
}

class _FavoriteCityItemState extends State<FavoriteCityItem> {
  bool _isHovered = false;
  String? _flagUrl;

  @override
  void initState() {
    super.initState();
    _fetchFlag();
  }

  Future<void> _fetchFlag() async {
    try {
      final DocumentSnapshot flagDoc = await FirebaseFirestore.instance
          .collection(FirestoreCollections.flags.collectionName)
          .doc(widget.city.country.id)
          .get();

      if (flagDoc.exists && mounted) {
        final flagData = flagDoc.data() as Map<String, dynamic>;
        setState(() {
          _flagUrl = flagData[FirestoreCollections.flags.flagUrl];
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _flagUrl = null;
        });
      }
    }
  }

  Future<void> _showDeleteConfirmation(BuildContext context) async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: AppColors.darkGray,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          title: const Text(
            'Usuń miasto',
            style: TextStyle(color: Colors.white),
          ),
          content: Text(
            'Czy na pewno chcesz usunąć ${widget.city.localizedName} z ulubionych?',
            style: const TextStyle(color: Colors.white70),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text(
                'Anuluj',
                style: TextStyle(color: Colors.white70),
              ),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                await _removeCity(context);
              },
              child: const Text(
                'Usuń',
                style: TextStyle(color: AppColors.teal),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _removeCity(BuildContext context) async {
    final store = Provider.of<GlobalStore>(context, listen: false);
    final favoriteCityService = FavoriteCityService(store);

    final response =
        await favoriteCityService.removeFavoriteCity(widget.city.key);
    if (!response.success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content:
              Text(response.error ?? 'Failed to remove city from favorites'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: _isHovered ? AppColors.darkestGray : AppColors.darkGray,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: _isHovered ? AppColors.teal : Colors.transparent,
            width: 1,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 30,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(4),
                  color: AppColors.darkestGray,
                ),
                clipBehavior: Clip.hardEdge,
                child: _flagUrl != null
                    ? SvgPicture.network(
                        _flagUrl!,
                        fit: BoxFit.cover,
                        placeholderBuilder: (context) =>
                            _buildFlagPlaceholder(),
                      )
                    : _buildFlagPlaceholder(),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.city.localizedName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${widget.city.country.name}, ${widget.city.administrativeArea.name}',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.6),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () => _showDeleteConfirmation(context),
                icon: Icon(
                  Icons.delete_outline,
                  color: _isHovered
                      ? AppColors.teal
                      : Colors.white.withOpacity(0.6),
                  size: 24,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFlagPlaceholder() {
    return Container(
      color: AppColors.darkestGray,
      child: Center(
        child: Icon(
          Icons.flag_outlined,
          color: Colors.white.withOpacity(0.5),
          size: 20,
        ),
      ),
    );
  }
}
