import 'package:flutter/material.dart';
import 'package:haribon/theme/app_colors.dart';

class CompactDropdown extends StatelessWidget {
  final String label;
  final String? value;
  final List<String> items;
  final String? hintText;
  final ValueChanged<String?>? onChanged;

  const CompactDropdown({
    super.key,
    required this.label,
    this.value,
    this.items = const [],
    this.hintText,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: textTheme.labelSmall?.copyWith(
            color: AppColors.primaryMain,
            fontSize: 10,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
          decoration: BoxDecoration(
            color: AppColors.containerLowest,
            borderRadius: BorderRadius.circular(30),
            border: Border.all(color: AppColors.primaryMain, width: 1.2),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              isExpanded: true,
              isDense: true,
              icon: const Icon(Icons.keyboard_arrow_down, size: 16, color: AppColors.primaryMain),
              hint: Text(
                hintText ?? 'Select $label',
                style: textTheme.bodySmall?.copyWith(
                  color: AppColors.primaryMain.withValues(alpha: 0.5),
                  fontWeight: FontWeight.w400,
                  fontSize: 12,
                ),
              ),
              style: textTheme.bodySmall?.copyWith(
                color: AppColors.primaryMain,
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
              dropdownColor: AppColors.containerLowest,
              padding: const EdgeInsets.symmetric(vertical: 6),
              items: items.map((item) {
                return DropdownMenuItem<String>(
                  value: item,
                  child: Text(item),
                );
              }).toList(),
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }
}
