import 'package:flutter/material.dart';
import '../theme/theme.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final String? subtitle;
  final String? badgeText;
  final Color? badgeColor;
  final List<Widget>? actions;
  final Widget? leading;
  final bool centerTitle;

  const CustomAppBar({
    Key? key,
    required this.title,
    this.subtitle,
    this.badgeText,
    this.badgeColor,
    this.actions,
    this.leading,
    this.centerTitle = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final ext = theme.extension<CustomThemeExtension>();
    final primaryColor = ext?.primaryColor ?? theme.primaryColor;

    return AppBar(
      leading: leading,
      centerTitle: centerTitle,
      title: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Column(
            crossAxisAlignment: centerTitle ? CrossAxisAlignment.center : CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimaryLight,
                ),
              ),
              if (subtitle != null) ...[
                const SizedBox(height: 2),
                Text(
                  subtitle!,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.normal,
                    color: AppColors.textSecondaryLight,
                  ),
                ),
              ],
            ],
          ),
          if (badgeText != null) ...[
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: badgeColor ?? primaryColor.withOpacity(0.12),
                borderRadius: BorderRadius.circular(100),
              ),
              child: Text(
                badgeText!,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: badgeColor != null ? Colors.white : primaryColor,
                ),
              ),
            ),
          ],
        ],
      ),
      actions: actions,
      backgroundColor: Colors.white,
      elevation: 0,
      scrolledUnderElevation: 0,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
