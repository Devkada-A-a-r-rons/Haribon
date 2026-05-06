import 'package:flutter/material.dart';
import 'package:haribon/theme/app_colors.dart';


class HomeDashboardData {
  final String userName;
  final double weeklyCo2Saved;
  final List<HomeStat> stats;
  final List<double> efficiencyTrend;
  final List<HomeActivity> activities;

  const HomeDashboardData({
    required this.userName,
    required this.weeklyCo2Saved,
    required this.stats,
    required this.efficiencyTrend,
    required this.activities,
  });

  factory HomeDashboardData.mock() {
    return HomeDashboardData(
      userName: 'Alex',
      weeklyCo2Saved: 2.5,
      stats: [
        const HomeStat(
          label: 'Avg Dist/Trip',
          value: '142 km',
          icon: Icons.route_rounded,
          color: AppColors.blueLighterBg,
          iconColor: AppColors.blueLight,
        ),
        const HomeStat(
          label: 'Avg Fuel',
          value: '12.4 L',
          icon: Icons.local_gas_station_rounded,
          color: AppColors.greenSoftBg,
          iconColor: AppColors.greenAccent,
        ),
        const HomeStat(
          label: 'Mo. Sav',
          value: '₱420',
          icon: Icons.savings_rounded,
          color: AppColors.orangeSoftBg,
          iconColor: AppColors.orangeDark,
        ),
      ],
      efficiencyTrend: [0.0, 0.0, 0.0, 11.2, 11.5, 11.8, 12.4],
      activities: [
        const HomeActivity(
          title: 'Next Refuel: Shell TPLEX',
          subtitle: '45km remaining',
          icon: Icons.local_gas_station_rounded,
          iconColor: Colors.blue,
          backgroundColor: AppColors.blueLightestBg,
        ),
        const HomeActivity(
          title: 'Planned: Subic Weekend',
          subtitle: 'Sat, Oct 14 • 2h 30m',
          icon: Icons.calendar_today_rounded,
          iconColor: Colors.green,
          backgroundColor: AppColors.greenSoftBg,
        ),
      ],
    );
  }
}

class HomeStat {
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  final Color iconColor;

  const HomeStat({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
    required this.iconColor,
  });
}

class HomeActivity {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color iconColor;
  final Color backgroundColor;

  const HomeActivity({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.iconColor,
    required this.backgroundColor,
  });
}
