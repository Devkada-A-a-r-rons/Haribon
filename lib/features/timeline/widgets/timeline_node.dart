import 'package:flutter/material.dart';
import '../../../theme/app_colors.dart';
import '../models/timeline_stop.dart';

class TimelineNode extends StatelessWidget {
  final TimelineStopType type;
  final bool isFirst;
  final bool isLast;

  const TimelineNode({
    super.key,
    required this.type,
    this.isFirst = false,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 40,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // The vertical line
          Positioned(
            top: isFirst ? 24 : 0, // start line lower for first item
            bottom: isLast ? null : 0,
            height: isLast ? 24 : null, // end line higher for last item
            child: Container(
              width: 1,
              color: AppColors.surfaceDim,
            ),
          ),
          
          // The dot
          Positioned(
            top: 24, // Fixed top position so it aligns with the first line of text
            child: _buildDot(),
          ),
        ],
      ),
    );
  }

  Widget _buildDot() {
    switch (type) {
      case TimelineStopType.departure:
      case TimelineStopType.refuel:
        return Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: AppColors.primaryMain,
            shape: BoxShape.circle,
            border: Border.all(
              color: AppColors.primaryLight,
              width: 4,
            ),
          ),
        );
      case TimelineStopType.optional:
        return Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: Colors.transparent,
            shape: BoxShape.circle,
            border: Border.all(
              color: AppColors.textTertiary.withValues(alpha: 0.3),
              width: 2,
            ),
          ),
        );
      case TimelineStopType.arrival:
        return Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: const Color(0xFF8B9B3A), // Olive green from mockup
            shape: BoxShape.circle,
            border: Border.all(
              color: const Color(0xFFF0F4E3), // Light olive ring
              width: 4,
            ),
          ),
        );
    }
  }
}
