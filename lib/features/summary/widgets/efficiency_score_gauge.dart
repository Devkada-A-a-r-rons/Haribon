import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'summary_header.dart';
import 'summary_shared.dart';
import 'package:haribon/theme/app_colors.dart';


/// MODULE: EFFICIENCY SCORE GAUGE
/// Animated blue-to-green ring showing the trip efficiency score.
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

  @override
  Widget build(BuildContext context) {
    return SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionLabel(label: 'EFFICIENCY SCORE'),
          const SizedBox(height: 20),
          Center(
            child: AnimatedBuilder(
              animation: _animation,
              builder: (_, __) => _ScoreRing(
                score: widget.score,
                progress: _animation.value,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Center(
            child: Column(
              children: [
                Text(
                  widget.rating,
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: SummaryColors.eco,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  widget.percentileLabel,
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    color: AppColors.greyAccent,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ScoreRing extends StatelessWidget {
  final int score;
  final double progress;

  const _ScoreRing({required this.score, required this.progress});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 148,
      height: 148,
      child: CustomPaint(
        painter: _RingPainter(progress: progress, score: score),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '${(score * progress).round()}',
                style: GoogleFonts.poppins(
                  fontSize: 42,
                  fontWeight: FontWeight.w800,
                  color: SummaryColors.primary,
                  letterSpacing: -1.5,
                ),
              ),
              Text(
                'out of 100',
                style: GoogleFonts.poppins(
                  fontSize: 11,
                  color: AppColors.greyAccent,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  final double progress;
  final int score;

  const _RingPainter({required this.progress, required this.score});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width / 2) - 12;
    const strokeWidth = 13.0;

    // Track ring
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..color = AppColors.primaryLight
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round,
    );

    // Gradient arc
    final rect = Rect.fromCircle(center: center, radius: radius);
    final arcPaint = Paint()
      ..shader = const SweepGradient(
        startAngle: -math.pi / 2,
        endAngle: 3 * math.pi / 2,
        colors: [AppColors.primaryMain, AppColors.success],
        stops: [0.0, 1.0],
      ).createShader(rect)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    final sweepAngle = 2 * math.pi * (score / 100) * progress;
    canvas.drawArc(rect, -math.pi / 2, sweepAngle, false, arcPaint);
  }

  @override
  bool shouldRepaint(_RingPainter old) =>
      old.progress != progress || old.score != score;
}

