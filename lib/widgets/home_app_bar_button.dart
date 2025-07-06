import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:unstack/theme/app_theme.dart';

class HomeAppBarButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final IconData icon;
  final bool isPremium;

  const HomeAppBarButton({
    required this.onPressed,
    required this.icon,
    this.isPremium = false,
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
      child: Stack(
        children: [
          if (isPremium)
            Positioned(
              right: 8,
              top: -2,
              child: Image.asset(
                "assets/images/crown.png",
                height: 20,
                width: 20,
              ),
            ),
          Container(
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
        ],
      ),
    );
  }
}
