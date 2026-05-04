import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../theme/app_colors.dart';

class CommonNavBar extends StatelessWidget {
  final int activeIndex;
  final ValueChanged<int>? onTabSelected;

  const CommonNavBar({
    super.key,
    required this.activeIndex,
    this.onTabSelected,
  });

  static const _tabs = [
    _NavTab(icon: Icons.home_rounded, label: 'Home'),
    _NavTab(icon: Icons.map_rounded, label: 'Planner'),
    _NavTab(icon: Icons.alt_route_rounded, label: 'Smart Trip'),
    _NavTab(icon: Icons.flag_rounded, label: 'Summary'),
    _NavTab(icon: Icons.history_rounded, label: 'History'),
    _NavTab(icon: Icons.insights_rounded, label: 'Insights'),
  ];

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).padding.bottom;
    return ClipRRect(
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.containerLowest.withValues(alpha: 0.85),
          border: Border(
            top: BorderSide(color: AppColors.surfaceDim, width: 1),
          ),
        ),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: EdgeInsets.only(
              top: 8,
              bottom: bottom > 0 ? 0 : 8,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: List.generate(
                _tabs.length,
                (i) => _NavItem(
                  tab: _tabs[i],
                  isActive: i == activeIndex,
                  onTap: () => onTabSelected?.call(i),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _NavTab {
  final IconData icon;
  final String label;
  const _NavTab({required this.icon, required this.label});
}

class _NavItem extends StatelessWidget {
  final _NavTab tab;
  final bool isActive;
  final VoidCallback onTap;

  const _NavItem({
    required this.tab,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = isActive ? AppColors.primaryMain : AppColors.textTertiary;

    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(tab.icon, color: color, size: 24),
            const SizedBox(height: 3),
            Text(
              tab.label,
              style: GoogleFonts.inter(
                fontSize: 10,
                fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                color: color,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            // Active dot indicator
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: isActive ? 4 : 0,
              height: isActive ? 4 : 0,
              decoration: BoxDecoration(
                color: AppColors.primaryMain,
                shape: BoxShape.circle,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
