import 'package:flutter/material.dart';
import 'package:unstack/theme/theme.dart';

Future<bool?> showDeleteDialog({
  required BuildContext context,
  required VoidCallback onDelete,
  required String title,
  required String description,
  required String buttonTitle,
}) async {
  return showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      backgroundColor: AppColors.surfaceCard,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppBorderRadius.xxl),
      ),
      title: Text(
        title,
        style: AppTextStyles.h3.copyWith(
          color: AppColors.textPrimary,
        ),
      ),
      content: Text(
        description,
        style: AppTextStyles.bodyMedium.copyWith(
          color: AppColors.textSecondary,
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: Text(
            'Cancel',
            style: TextStyle(color: AppColors.textSecondary),
          ),
        ),
        TextButton(
          onPressed: onDelete,
          child: Text(
            buttonTitle,
            style: TextStyle(color: AppColors.statusError),
          ),
        ),
      ],
    ),
  );
}
