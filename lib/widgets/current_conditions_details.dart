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
    required IconData icon,
    required String label,
    required String value,
  }) {
    return SizedBox(
      width: 200,
      child: Row(
        children: [
          Icon(
            icon,
            color: Colors.white,
            size: 24,
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 12,
                ),
              ),
              Text(
                value,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 24),
      decoration: BoxDecoration(
        color: AppColors.darkGray,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildInfoItem(
                icon: Icons.thermostat_outlined,
                label: 'Temperatura odczuwalna',
                value:
                    '${conditions.realFeelTemperature.value}°${conditions.realFeelTemperature.unit}',
              ),
              _buildInfoItem(
                icon: Icons.air,
                label: 'Wiatr',
                value: '${conditions.windSpeed.round()} km/h',
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildInfoItem(
                icon: Icons.wb_sunny_outlined,
                label: 'UV Index',
                value: '${conditions.uvIndex} - ${conditions.uvIndexText}',
              ),
              _buildInfoItem(
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
