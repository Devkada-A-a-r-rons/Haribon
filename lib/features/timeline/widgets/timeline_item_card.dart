import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../theme/app_colors.dart';
import '../models/timeline_stop.dart';
import 'timeline_node.dart';

class TimelineItemCard extends StatelessWidget {
  final TimelineStop stop;
  final bool isFirst;
  final bool isLast;

  const TimelineItemCard({
    super.key,
    required this.stop,
    this.isFirst = false,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TimelineNode(
            type: stop.type,
            isFirst: isFirst,
            isLast: isLast,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 24.0, bottom: 32.0, right: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min, // To prevent infinite height in IntrinsicHeight
                children: [
                  // Time and Type Header
                  Row(
                    children: [
                      Text(
                        stop.time,
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: _getTypeColor(stop.type),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        ' • ${_getTypeString(stop.type)}',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: _getTypeColor(stop.type),
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  
                  // Location Title
                  Text(
                    stop.title,
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  
                  // Description
                  Text(
                    stop.description,
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      height: 1.5,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  
                  // Tags if any
                  if (stop.tags != null && stop.tags!.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    Row(
                      children: stop.tags!.map((tag) => _buildTag(tag)).toList(),
                    ),
                  ],
                  
                  // Action Button if any
                  if (stop.buttonText != null) ...[
                    const SizedBox(height: 16),
                    _buildActionButton(stop.buttonText!),
                  ],

                  // Arrival location icon
                  if (stop.type == TimelineStopType.arrival) ...[
                    const SizedBox(height: 16),
                    const Icon(
                      Icons.location_on_outlined,
                      color: Color(0xFF8B9B3A),
                      size: 24,
                    )
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getTypeColor(TimelineStopType type) {
    switch (type) {
      case TimelineStopType.departure:
        return AppColors.textTertiary;
      case TimelineStopType.refuel:
        return AppColors.primaryMain;
      case TimelineStopType.optional:
        return AppColors.textTertiary.withValues(alpha: 0.6);
      case TimelineStopType.arrival:
        return const Color(0xFF8B9B3A); // Olive green
    }
  }

  String _getTypeString(TimelineStopType type) {
    switch (type) {
      case TimelineStopType.departure:
        return 'DEPARTURE';
      case TimelineStopType.refuel:
        return 'REFUEL STOP';
      case TimelineStopType.optional:
        return 'OPTIONAL';
      case TimelineStopType.arrival:
        return 'ARRIVAL';
    }
  }

  Widget _buildTag(String text) {
    return Padding(
      padding: const EdgeInsets.only(right: 12.0),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.local_gas_station_outlined, // Placeholder for tag icon
            size: 16,
            color: AppColors.textTertiary,
          ),
          const SizedBox(width: 4),
          Text(
            text,
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(String text) {
    bool isPrimary = stop.type == TimelineStopType.refuel;
    return ElevatedButton(
      onPressed: () {},
      style: ElevatedButton.styleFrom(
        backgroundColor: isPrimary ? const Color(0xFF4A5568) : AppColors.surfaceDim.withValues(alpha: 0.3),
        foregroundColor: isPrimary ? Colors.white : AppColors.textSecondary,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      child: Text(
        text,
        style: GoogleFonts.poppins(
          fontWeight: FontWeight.w600,
          fontSize: 12,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}
