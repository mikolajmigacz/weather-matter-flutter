import 'package:flutter/material.dart';
import 'package:flutter_dashboard_app/services/currentConditions/current_conditions_types.dart';
import 'package:flutter_dashboard_app/theme/app_colors.dart';

class CurrentConditionsDetails extends StatelessWidget {
  final CurrentConditions conditions;

  const CurrentConditionsDetails({
    Key? key,
    required this.conditions,
  }) : super(key: key);

  Widget _buildInfoItem({
    required BuildContext context,
    required IconData icon,
    required String label,
    required String value,
  }) {
    final isDesktop = MediaQuery.of(context).size.width > 768;

    return SizedBox(
      width: isDesktop ? 200 : MediaQuery.of(context).size.width * 0.4,
      child: Row(
        children: [
          Icon(
            icon,
            color: Colors.white,
            size: isDesktop ? 24 : 20,
          ),
          SizedBox(width: isDesktop ? 12 : 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: isDesktop ? 12 : 10,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  value,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: isDesktop ? 14 : 12,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width > 768;

    return Container(
      padding: isDesktop
          ? const EdgeInsets.symmetric(horizontal: 48, vertical: 24)
          : const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        color: AppColors.darkGray,
        borderRadius: BorderRadius.circular(isDesktop ? 16 : 12),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildInfoItem(
                context: context,
                icon: Icons.thermostat_outlined,
                label: 'Temperatura odczuwalna',
                value:
                    '${conditions.realFeelTemperature.value}°${conditions.realFeelTemperature.unit}',
              ),
              _buildInfoItem(
                context: context,
                icon: Icons.air,
                label: 'Wiatr',
                value: '${conditions.windSpeed.round()} km/h',
              ),
            ],
          ),
          SizedBox(height: isDesktop ? 24 : 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildInfoItem(
                context: context,
                icon: Icons.wb_sunny_outlined,
                label: 'UV Index',
                value: '${conditions.uvIndex} - ${conditions.uvIndexText}',
              ),
              _buildInfoItem(
                context: context,
                icon: Icons.water_drop_outlined,
                label: 'Wilgotność',
                value: '${conditions.relativeHumidity}%',
              ),
            ],
          ),
        ],
      ),
    );
  }
}
