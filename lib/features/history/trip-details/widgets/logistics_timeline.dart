import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../theme/app_colors.dart';

class LogisticsTimeline extends StatefulWidget {
  const LogisticsTimeline({super.key});

  @override
  State<LogisticsTimeline> createState() => _LogisticsTimelineState();
}

class _LogisticsTimelineState extends State<LogisticsTimeline> {
  bool _isExpanded = true;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: () {
            setState(() {
              _isExpanded = !_isExpanded;
            });
          },
          behavior: HitTestBehavior.opaque,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Logistics Timeline',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                AnimatedRotation(
                  turns: _isExpanded ? 0 : -0.5,
                  duration: const Duration(milliseconds: 200),
                  child: Icon(Icons.keyboard_arrow_down, color: AppColors.textPrimary),
                ),
              ],
            ),
          ),
        ),
        AnimatedSize(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          child: SizedBox(
            width: double.infinity,
            child: _isExpanded
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 8),
                      _buildTimelineItem(
                        time: '08:15',
                        location: 'ANGELES',
                        title: 'Shell Angeles â€¢ 12L',
                        trailingText: 'â‚±756',
                        trailingColor: AppColors.success,
                        isFirst: true,
                        isLast: false,
                        isPassed: true,
                      ),
                      _buildTimelineItem(
                        time: '10:30',
                        location: 'TARLAC',
                        title: 'Petron Tarlac',
                        trailingText: 'Skipped',
                        trailingColor: AppColors.textTertiary,
                        isFirst: false,
                        isLast: true,
                        isPassed: false,
                      ),
                    ],
                  )
                : const SizedBox.shrink(),
          ),
        ),
      ],
    );
  }

  Widget _buildTimelineItem({
    required String time,
    required String location,
    required String title,
    required String trailingText,
    required Color trailingColor,
    required bool isFirst,
    required bool isLast,
    required bool isPassed,
  }) {
    final dotColor = isPassed ? AppColors.textSecondary : AppColors.surfaceDim;
    final lineColor = isPassed ? AppColors.textSecondary.withOpacity(0.5) : AppColors.surfaceDim;

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            width: 24,
            child: Stack(
              alignment: Alignment.center,
              children: [
                if (!isFirst)
                  Positioned(
                    top: 0,
                    bottom: 30, // Connect to middle
                    child: Container(width: 2, color: AppColors.surfaceDim),
                  ),
                if (!isLast)
                  Positioned(
                    top: 30, // Start from middle
                    bottom: 0,
                    child: Container(width: 2, color: lineColor),
                  ),
                Positioned(
                  top: 26,
                  child: Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: dotColor,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.containerLow,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '$time â€¢ $location',
                        style: GoogleFonts.poppins(
                          fontSize: 9,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                          letterSpacing: 1,
                        ),
                      ),
                      Text(
                        trailingText,
                        style: GoogleFonts.poppins(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: trailingColor,
                          fontStyle: trailingText == 'Skipped' ? FontStyle.italic : FontStyle.normal,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    title,
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: isPassed ? AppColors.textPrimary : AppColors.textSecondary,
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

