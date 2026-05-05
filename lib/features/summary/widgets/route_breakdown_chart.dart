import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'summary_header.dart';
import 'summary_shared.dart';
import '../models/trip_summary_model.dart';
import 'package:haribon/theme/app_colors.dart';


/// MODULE: ROUTE BREAKDOWN CHART
/// Animated horizontal bar chart showing time distribution per road segment.
class RouteBreakdownChart extends StatefulWidget {
  final List<RouteSegment> segments;

  const RouteBreakdownChart({super.key, required this.segments});

  @override
  State<RouteBreakdownChart> createState() => _RouteBreakdownChartState();
}

class _RouteBreakdownChartState extends State<RouteBreakdownChart>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeOutQuart);
    // Delay slightly so it animates after scroll reveals it
    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionLabel(label: 'ROUTE BREAKDOWN'),
          const SizedBox(height: 16),
          AnimatedBuilder(
            animation: _animation,
            builder: (_, __) => Column(
              children: widget.segments
                  .map((s) => _SegmentRow(segment: s, progress: _animation.value))
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }
}

class _SegmentRow extends StatelessWidget {
  final RouteSegment segment;
  final double progress;

  const _SegmentRow({required this.segment, required this.progress});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          // Label
          SizedBox(
            width: 110,
            child: Text(
              segment.label,
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: AppColors.greyPrimary,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),

          // Bar
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: Stack(
                children: [
                  // Track
                  Container(height: 10, color: AppColors.blueSoftBg),
                  // Fill
                  FractionallySizedBox(
                    widthFactor: segment.fraction * progress,
                    child: Container(
                      height: 10,
                      decoration: BoxDecoration(
                        color: segment.color,
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Duration label
          SizedBox(
            width: 48,
            child: Text(
              segment.durationLabel,
              textAlign: TextAlign.right,
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: segment.color,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
