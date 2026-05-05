import 'package:flutter/material.dart';
import 'package:haribon/theme/app_colors.dart';


class ExpandableCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color subtitleColor;
  final Widget content;
  final bool initiallyExpanded;

  const ExpandableCard({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.subtitleColor,
    required this.content,
    this.initiallyExpanded = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Theme(
        data: theme.copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          initiallyExpanded: initiallyExpanded,
          tilePadding: const EdgeInsets.all(16),
          iconColor: AppColors.navyDarker,
          collapsedIconColor: AppColors.navyDarker,
          title: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, color: AppColors.blueGreyDark, size: 20),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: AppColors.navyDarker,
                        fontWeight: FontWeight.w700,
                        height: 1.2,
                      ),
                    ),
                  ],
                ),
              ),
              if (subtitle.isNotEmpty)
                Text(
                  subtitle,
                  textAlign: TextAlign.right,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: subtitleColor,
                    fontWeight: FontWeight.w500,
                    fontSize: 10,
                  ),
                ),
            ],
          ),
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
              child: content,
            ),
          ],
        ),
      ),
    );
  }
}
