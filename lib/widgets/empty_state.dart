import 'package:flutter/material.dart';
import 'app_styles.dart';

class EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;

  const EmptyState({
    Key? key,
    required this.icon,
    required this.title,
    required this.message,
    this.actionLabel,
    this.onAction,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: AppStyles.screenPadding,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 80,
              color: AppColors.lightText.withOpacity(0.5),
            ),
            const SizedBox(height: AppStyles.spacingL),
            Text(
              title,
              style: AppTextStyles.h3.copyWith(
                color: AppColors.lightText,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppStyles.spacingS),
            Text(
              message,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.lightText,
              ),
              textAlign: TextAlign.center,
            ),
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: AppStyles.spacingL),
              ElevatedButton(
                onPressed: onAction,
                style: AppStyles.primaryButton,
                child: Text(actionLabel!),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
