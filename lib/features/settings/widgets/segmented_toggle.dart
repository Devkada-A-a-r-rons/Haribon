import 'package:flutter/material.dart';
import 'package:haribon/theme/app_colors.dart';


class SegmentedToggle extends StatefulWidget {
  final List<String> options;
  final int initialIndex;
  final ValueChanged<int> onChanged;

  const SegmentedToggle({
    super.key,
    required this.options,
    required this.initialIndex,
    required this.onChanged,
  });

  @override
  State<SegmentedToggle> createState() => _SegmentedToggleState();
}

class _SegmentedToggleState extends State<SegmentedToggle> {
  late int _selectedIndex;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.greySoftBg,
        borderRadius: BorderRadius.circular(30),
      ),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch, // add this
          children: List.generate(widget.options.length, (index) {
            final isSelected = _selectedIndex == index;
            return Expanded(
              child: GestureDetector(
          onTap: () {
            setState(() => _selectedIndex = index);
            widget.onChanged(index);
          },
          behavior: HitTestBehavior.opaque,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 10),
            decoration: BoxDecoration(
              color: isSelected ? Colors.white : Colors.transparent,
              borderRadius: BorderRadius.circular(30), // your updated radius
              boxShadow: isSelected
                  ? [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4, offset: const Offset(0, 2))]
                  : null,
            ),
            alignment: Alignment.center,
            child: Text(
              widget.options[index],
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: isSelected ? AppColors.blueAccent : AppColors.blueGreySecondary,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                fontSize: 11,
              ),
            ),
          ),
        ),
      );
    }),
  ),
),
    );
  }
}
