import 'package:chiclet/chiclet.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:unstack/theme/theme.dart';
import 'package:unstack/utils/app_size.dart';

class HomeAppBarButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final IconData icon;
  final Color color;
  final Color iconColor;

  const HomeAppBarButton({
    required this.onPressed,
    required this.icon,
    this.color = AppColors.backgroundPrimary,
    this.iconColor = AppColors.whiteColor,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return ChicletAnimatedButton(
      buttonType: ChicletButtonTypes.circle,
      backgroundColor: color,
      height: 52,
      width: 52,
      onPressed: () {
        HapticFeedback.lightImpact();
        if (onPressed != null) {
          onPressed!();
        }
      },
      child: Container(
        height: 52,
        width: 52,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: Border.all(
            color: color != AppColors.backgroundPrimary
                ? color
                : AppColors.backgroundSecondary,
            width: 1.2,
          ),
        ),
        child: Icon(
          icon,
          color: iconColor,
          size: 24 * AppSize(context).height * 0.00115,
        ),
      ),
    );
  }
}
