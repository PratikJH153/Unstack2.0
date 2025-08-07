import 'package:flutter/material.dart';
import 'package:unstack/theme/theme.dart';

class LoadingWidget extends StatelessWidget {
  const LoadingWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(6),
      decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: AppColors.glassBackground,
          border: Border.all(
            color: AppColors.glassBorder,
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 5,
              spreadRadius: 1,
            ),
            BoxShadow(
              color: Colors.white12,
              blurRadius: 5,
              spreadRadius: 1,
              offset: Offset(-1, -1),
            ),
          ]),
      child: CircularProgressIndicator(
        color: AppColors.whiteColor,
        strokeWidth: 3,
        backgroundColor: AppColors.backgroundTertiary,
      ),
    );
  }
}
