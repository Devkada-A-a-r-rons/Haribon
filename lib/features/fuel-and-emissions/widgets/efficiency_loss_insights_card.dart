import 'package:flutter/material.dart';
import 'package:haribon/theme/app_colors.dart';
import '../../common/widgets/typing_text.dart';

class EfficiencyLossInsightsCard extends StatefulWidget {
  final List<String> insights;
  const EfficiencyLossInsightsCard({super.key, required this.insights});

  @override
  State<EfficiencyLossInsightsCard> createState() => _EfficiencyLossInsightsCardState();
}

class _EfficiencyLossInsightsCardState extends State<EfficiencyLossInsightsCard>
    with SingleTickerProviderStateMixin {
  bool _isExpanded = false;
  late AnimationController _controller;
  late Animation<double> _expandAnimation;
  late Animation<double> _rotateAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _expandAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );
    _rotateAnimation = Tween<double>(begin: 0, end: 0.5).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggle() {
    setState(() {
      _isExpanded = !_isExpanded;
      _isExpanded ? _controller.forward() : _controller.reverse();
    });
  }

  IconData getIcon(int index) {
    if (index == 0) return Icons.terrain;
    if (index == 1) return Icons.directions_car;
    return Icons.access_time;
  }

  Color getIconColor(int index) {
    if (index == 0) return AppColors.redDark;
    if (index == 1) return AppColors.orangePrimary;
    return AppColors.textTertiary;
  }

  Color getBgColor(int index) {
    if (index == 0) return AppColors.redSoftBg;
    if (index == 1) return AppColors.orangeSoftBg;
    return AppColors.blueGreySoftBg;
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.containerLowest,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // ── Header / tap target ──────────────────────────────
          GestureDetector(
            onTap: _toggle,
            behavior: HitTestBehavior.opaque,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'EFFICIENCY LOSS INSIGHTS',
                    style: textTheme.labelSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.2,
                      color: AppColors.textPrimary,
                      fontSize: 10,
                    ),
                  ),
                  Row(
                    children: [
                      if (widget.insights.isNotEmpty)
                        Container(
                          margin: const EdgeInsets.only(right: 8),
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.redSoftBg,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            '${widget.insights.length}',
                            style: textTheme.labelSmall?.copyWith(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: AppColors.redDark,
                            ),
                          ),
                        ),
                      RotationTransition(
                        turns: _rotateAnimation,
                        child: const Icon(
                          Icons.keyboard_arrow_down_rounded,
                          size: 20,
                          color: AppColors.textTertiary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // ── Expandable content ───────────────────────────────
          SizeTransition(
            sizeFactor: _expandAnimation,
            child: Column(
              children: [
                const Divider(height: 1, color: AppColors.greySoftBg),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
                  child: widget.insights.isEmpty
                      ? const Padding(
                          padding: EdgeInsets.symmetric(vertical: 20),
                          child: Center(child: ThinkingIndicator()),
                        )
                      : Column(
                          children: widget.insights.asMap().entries.map((entry) {
                            final idx = entry.key;
                            final text = entry.value;
                            return Padding(
                              padding: EdgeInsets.only(
                                bottom: idx == widget.insights.length - 1 ? 0 : 16,
                              ),
                              child: _buildInsightItem(
                                textTheme: textTheme,
                                icon: getIcon(idx),
                                iconColor: getIconColor(idx),
                                bgColor: getBgColor(idx),
                                text: text,
                                hideDivider: idx == widget.insights.length - 1,
                              ),
                            );
                          }).toList(),
                        ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInsightItem({
    required TextTheme textTheme,
    required IconData icon,
    required Color iconColor,
    required Color bgColor,
    required String text,
    bool hideDivider = false,
  }) {
    return Column(
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, size: 20, color: iconColor),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: TypingText(
                text: text,
                style: textTheme.bodySmall?.copyWith(
                  color: AppColors.textPrimary,
                  height: 1.4,
                ),
              ),
            ),
          ],
        ),
        if (!hideDivider) ...[
          const SizedBox(height: 16),
          const Divider(height: 1, color: AppColors.greySoftBg),
        ],
      ],
    );
  }
}