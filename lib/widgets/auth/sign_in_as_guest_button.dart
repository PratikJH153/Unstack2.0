import 'package:chiclet/chiclet.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:unstack/theme/theme.dart';

Widget buildGetStartedButton(
  String text, {
  required VoidCallback onPressed,
}) {
  return Builder(
    builder: (context) => ChicletOutlinedAnimatedButton(
      onPressed: onPressed,
      height: 80,
      width: double.infinity,
      backgroundColor: Colors.transparent,
      borderColor: Colors.white.withAlpha(54),
      borderWidth: 2,
      borderRadius: AppBorderRadius.xxl,
      child: Container(
        width: double.infinity,
        height: 80,
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.all(
            Radius.circular(AppBorderRadius.xxl),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.white.withAlpha(51),
              blurRadius: 15,
              spreadRadius: -5,
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              CupertinoIcons.bolt_horizontal_fill,
              size: 24,
              color: AppColors.whiteColor,
            ),
            const SizedBox(
              width: 12,
            ),
            Text(
              text,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.whiteColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
