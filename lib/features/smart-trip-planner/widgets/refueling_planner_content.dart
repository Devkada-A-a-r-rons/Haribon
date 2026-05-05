import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import 'package:haribon/theme/app_colors.dart';


class RefuelingPlannerContent extends StatefulWidget {
  final String origin;
  final String destination;
  final double distanceKm;
  final String fuelGrade;
  final Function(List<Map<String, dynamic>>)? onPlanGenerated;

  const RefuelingPlannerContent({
    super.key,
    required this.origin,
    required this.destination,
    required this.distanceKm,
    required this.fuelGrade,
    this.onPlanGenerated,
  });

  @override
  State<RefuelingPlannerContent> createState() => _RefuelingPlannerContentState();
}

class _RefuelingPlannerContentState extends State<RefuelingPlannerContent> {
  List<Map<String, dynamic>> _stops = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _calculatePlan();
  }

  @override
  void didUpdateWidget(RefuelingPlannerContent oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.distanceKm != widget.distanceKm || 
        oldWidget.origin != widget.origin || 
        oldWidget.destination != widget.destination) {
      _calculatePlan();
    }
  }

  Future<void> _calculatePlan() async {
    try {
      final jsonStr = await rootBundle.loadString('assets/Data/gasoline_station.geojson');
      final data = jsonDecode(jsonStr);
      final features = data['features'] as List;
      
      // Heuristic: Find stations that might be along the way
      // For this demo, we'll pick stations that have a name and are somewhat diverse
      final stations = features
          .where((f) => f['properties']['name'] != null)
          .take(50)
          .toList();
      
      stations.shuffle();
      final recommended = stations.first;
      final backup = stations[1];
      
      setState(() {
        _stops = [
          {
            'title': widget.origin,
            'subtitle': 'DEPARTURE POINT',
            'icon': Icons.adjust,
            'color': AppColors.bluePale,
            'isFirst': true
          },
          {
            'title': recommended['properties']['name'],
            'subtitle': 'Recommended ${_widgetFuelVolume()}L @ ₱63/L',
            'icon': Icons.local_gas_station,
            'color': AppColors.tealPrimary,
            'highlight': 'Optimal\nPrice'
          },
          {
            'title': backup['properties']['name'],
            'subtitle': 'Backup Station',
            'icon': Icons.circle,
            'color': AppColors.blueGreyDark,
          },
          {
            'title': widget.destination,
            'subtitle': '${widget.distanceKm.toStringAsFixed(0)}KM JOURNEY END',
            'icon': Icons.location_on,
            'color': AppColors.greenLightBg,
            'isLast': true
          },
        ];
        _isLoading = false;
      });
      
      if (widget.onPlanGenerated != null) {
        widget.onPlanGenerated!(_stops);
      }
    } catch (e) {
      debugPrint('Error planning refueling: $e');
      setState(() => _isLoading = false);
    }
  }

  String _widgetFuelVolume() {
    return (widget.distanceKm * 0.08).toStringAsFixed(1);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    if (_isLoading) return const Center(child: CircularProgressIndicator(strokeWidth: 2));
    
    return Column(
      children: _stops.map((s) => _buildTimelineItem(
        theme,
        s['title'],
        s['subtitle'],
        s['icon'],
        s['color'],
        isFirst: s['isFirst'] ?? false,
        isLast: s['isLast'] ?? false,
        highlight: s['highlight'],
      )).toList(),
    );
  }

  Widget _buildTimelineItem(ThemeData theme, String title, String subtitle, IconData icon, Color iconColor, {bool isFirst = false, bool isLast = false, String? highlight, bool isRed = false}) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            width: 32,
            child: Column(
              children: [
                Expanded(child: Container(color: isFirst ? Colors.transparent : AppColors.greyLight, width: 2)),
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    border: Border.all(color: iconColor, width: 2),
                  ),
                  child: Icon(icon, size: 12, color: iconColor),
                ),
                Expanded(child: Container(color: isLast ? Colors.transparent : AppColors.greyLight, width: 2)),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 12.0),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(title, style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold, color: AppColors.navyDarker)),
                        Text(subtitle, style: theme.textTheme.labelSmall?.copyWith(color: isRed ? AppColors.redDark : AppColors.blueGreySecondary)),
                      ],
                    ),
                  ),
                  if (highlight != null)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.blueGreyDark,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        highlight,
                        textAlign: TextAlign.center,
                        style: theme.textTheme.labelSmall?.copyWith(color: Colors.white, fontSize: 9),
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
