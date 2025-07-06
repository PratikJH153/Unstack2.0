import 'package:flutter/material.dart';
import 'package:unstack/theme/app_theme.dart';

class LoadingWidget extends StatelessWidget {
  const LoadingWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: AppColors.glassBackground,
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 5,
              spreadRadius: 1,
            )
          ]),
      child: CircularProgressIndicator(
        color: AppColors.whiteColor,
        strokeWidth: 3,
      ),
    );
  }
}
