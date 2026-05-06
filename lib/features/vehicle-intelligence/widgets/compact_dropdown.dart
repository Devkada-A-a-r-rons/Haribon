import 'package:flutter/material.dart';

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
            color: colorScheme.onSurface.withOpacity(0.6),
            fontSize: 10,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
          decoration: BoxDecoration(
            color: colorScheme.secondaryContainer,
            borderRadius: BorderRadius.circular(8),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              isExpanded: true,
              isDense: true,
              icon: Icon(
                Icons.keyboard_arrow_down,
                size: 16,
                color: colorScheme.onSecondaryContainer.withOpacity(0.6),
              ),
              hint: Text(
                hintText ?? 'Select $label',
                style: textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSecondaryContainer.withOpacity(0.4),
                  fontWeight: FontWeight.w400,
                  fontSize: 12,
                  fontFeatures: [],
                ),
              ),
              style: textTheme.bodySmall?.copyWith(
                color: colorScheme.onSecondaryContainer,
                fontWeight: FontWeight.w500,
                fontSize: 12,
                fontFeatures: [],
              ),
              dropdownColor: Colors.white,
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
