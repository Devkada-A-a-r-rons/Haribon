import 'package:flutter/material.dart';

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
          color: Color(0xFFE1F5FE),
          iconColor: Color(0xFF0288D1),
        ),
        const HomeStat(
          label: 'Avg Fuel',
          value: '12.4 L',
          icon: Icons.local_gas_station_rounded,
          color: Color(0xFFE8F5E9),
          iconColor: Color(0xFF2E7D32),
        ),
        const HomeStat(
          label: 'Mo. Sav',
          value: '₱420',
          icon: Icons.savings_rounded,
          color: Color(0xFFFFF3E0),
          iconColor: Color(0xFFEF6C00),
        ),
      ],
      efficiencyTrend: [40, 50, 45, 70, 65, 90, 110],
      activities: [
        const HomeActivity(
          title: 'Next Refuel: Shell TPLEX',
          subtitle: '45km remaining',
          icon: Icons.local_gas_station_rounded,
          iconColor: Colors.blue,
          backgroundColor: Color(0xFFE3F2FD),
        ),
        const HomeActivity(
          title: 'Planned: Subic Weekend',
          subtitle: 'Sat, Oct 14 • 2h 30m',
          icon: Icons.calendar_today_rounded,
          iconColor: Colors.green,
          backgroundColor: Color(0xFFE8F5E9),
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
