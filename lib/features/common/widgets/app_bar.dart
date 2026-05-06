import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../theme/app_colors.dart';
import '../screens/information_screen.dart';

class CommonAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String? title;
  final List<Widget>? actions;
  final Widget? leading;
  final bool centerTitle;
  final bool showSettings;
  final bool showInfo;

  const CommonAppBar({
    super.key,
    this.title,
    this.actions,
    this.leading,
    this.centerTitle = false,
    this.showSettings = true,
    this.showInfo = true,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.surfaceMain,
      elevation: 0,
      centerTitle: centerTitle,
      leading: leading,
      title: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          ColorFiltered(
            colorFilter: const ColorFilter.mode(AppColors.primaryMain, BlendMode.srcIn),
            child: Image.asset('assets/images/haribon_logo.png', height: 36, width: 36, fit: BoxFit.contain),
          ),
          const SizedBox(width: 8),
          Text(
            'Haribon',
            style: GoogleFonts.poppins(
              color: AppColors.primaryMain,
              fontWeight: FontWeight.w800,
              fontSize: 20,
              letterSpacing: -0.5,
            ),
          ),
          if (title != null && title!.isNotEmpty) ...[
            const SizedBox(width: 8),
            Container(
              width: 4,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.textTertiary.withValues(alpha: 0.5),
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                title!,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.poppins(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
            ),
          ],
        ],
      ),
      actions: [
        if (actions != null) ...actions!,
        if (showInfo)
          IconButton(
            icon: Icon(Icons.info_outline, color: AppColors.primaryMain),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AppInformationScreen()),
              );
            },
          ),
        if (showSettings)
          IconButton(
            icon: Icon(Icons.settings_outlined, color: AppColors.primaryMain),
            onPressed: () {
              Navigator.pushNamed(context, '/settings');
            },
          ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

