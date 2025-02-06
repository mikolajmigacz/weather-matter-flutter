import 'package:flutter/material.dart';
import 'package:flutter_dashboard_app/services/autocomplete/autocomplete_types.dart';
import 'package:flutter_dashboard_app/theme/app_colors.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_dashboard_app/constants/firestore_constants.dart';
import 'package:flutter_svg/svg.dart';

class CitySearchItem extends StatefulWidget {
  final AutocompleteCity city;
  final VoidCallback onTap;
  final bool isSelected;

  const CitySearchItem({
    super.key,
    required this.city,
    required this.onTap,
    this.isSelected = false,
  });

  @override
  State<CitySearchItem> createState() => _CitySearchItemState();
}

class _CitySearchItemState extends State<CitySearchItem> {
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

  @override
  Widget build(BuildContext context) {
    final isActiveState = widget.isSelected || _isHovered;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isActiveState ? AppColors.darkestGray : AppColors.darkGray,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isActiveState ? AppColors.teal : Colors.transparent,
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
              ],
            ),
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
