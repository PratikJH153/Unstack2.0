import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:unstack/theme/app_theme.dart';

class HomeAppBarButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final IconData icon;
  const HomeAppBarButton({
    required this.onPressed,
    required this.icon,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        HapticFeedback.lightImpact();
        if (onPressed != null) {
          onPressed!();
        }
      },
      borderRadius: BorderRadius.all(Radius.circular(100)),
      child: Container(
        height: 50,
        width: 50,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: AppColors.textMuted,
            width: 0.5,
          ),
        ),
        child: Icon(icon),
      ),
    );
  }
}
