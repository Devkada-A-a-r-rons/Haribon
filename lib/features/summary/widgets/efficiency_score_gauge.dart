import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'summary_header.dart';
import 'summary_shared.dart';
import 'package:haribon/theme/app_colors.dart';


/// MODULE: EFFICIENCY SCORE GAUGE
/// Animated linear bar showing the trip efficiency score.
class EfficiencyScoreGauge extends StatefulWidget {
  final int score;
  final String rating;
  final String percentileLabel;

  const EfficiencyScoreGauge({
    super.key,
    required this.score,
    required this.rating,
    required this.percentileLabel,
  });

  @override
  State<EfficiencyScoreGauge> createState() => _EfficiencyScoreGaugeState();
}

class _EfficiencyScoreGaugeState extends State<EfficiencyScoreGauge>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );
    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic);
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Color _getScoreColor(int score) {
    if (score >= 80) return AppColors.success;
    if (score >= 60) return AppColors.orangeDark;
    return AppColors.redDark;
  }

  @override
  Widget build(BuildContext context) {
    final scoreColor = _getScoreColor(widget.score);

    return SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionLabel(label: 'EFFICIENCY SCORE'),
          const SizedBox(height: 12),

          // Score value + rating row
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              AnimatedBuilder(
                animation: _animation,
                builder: (_, __) => Text(
                  '${(widget.score * _animation.value).round()}',
                  style: GoogleFonts.poppins(
                    fontSize: 36,
                    fontWeight: FontWeight.w800,
                    color: SummaryColors.primary,
                    letterSpacing: -1.5,
                  ),
                ),
              ),
              Text(
                ' / 100',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AppColors.greyAccent,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: scoreColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  widget.rating,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: scoreColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Animated linear progress bar
          AnimatedBuilder(
            animation: _animation,
            builder: (_, __) => ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: SizedBox(
                height: 12,
                child: CustomPaint(
                  size: const Size(double.infinity, 12),
                  painter: _LinearBarPainter(
                    progress: (widget.score / 100) * _animation.value,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),

          // Percentile label
          Text(
            widget.percentileLabel,
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: AppColors.greyAccent,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _LinearBarPainter extends CustomPainter {
  final double progress;

  const _LinearBarPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final trackPaint = Paint()
      ..color = AppColors.primaryLight
      ..style = PaintingStyle.fill;

    // Draw track
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(0, 0, size.width, size.height),
        const Radius.circular(6),
      ),
      trackPaint,
    );

    // Draw gradient fill
    final fillWidth = size.width * progress;
    if (fillWidth > 0) {
      final fillPaint = Paint()
        ..shader = LinearGradient(
          colors: [AppColors.primaryMain, AppColors.success],
        ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
        ..style = PaintingStyle.fill;

      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(0, 0, fillWidth, size.height),
          const Radius.circular(6),
        ),
        fillPaint,
      );
    }
  }

  @override
  bool shouldRepaint(_LinearBarPainter old) => old.progress != progress;
}
