import 'package:flutter/material.dart';
import '../theme/theme.dart';
import 'primary_button.dart';

class EmptyStateWidget extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final String? ctaText;
  final VoidCallback? onCtaPressed;

  const EmptyStateWidget({
    Key? key,
    required this.icon,
    required this.title,
    required this.description,
    this.ctaText,
    this.onCtaPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(AppSpacing.s20),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 44,
                color: Colors.grey.shade400,
              ),
            ),
            AppSpacing.v20,
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimaryLight,
              ),
              textAlign: TextAlign.center,
            ),
            AppSpacing.v8,
            Text(
              description,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textSecondaryLight,
              ),
              textAlign: TextAlign.center,
            ),
            if (ctaText != null && onCtaPressed != null) ...[
              AppSpacing.v24,
              SizedBox(
                width: 200,
                child: PrimaryButton(
                  text: ctaText!,
                  onPressed: onCtaPressed,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
