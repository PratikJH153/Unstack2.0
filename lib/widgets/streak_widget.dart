import 'package:flutter/cupertino.dart';
import 'package:unstack/routes/route.dart';
import 'package:unstack/theme/theme.dart';

class StreakWidget extends StatefulWidget {
  final int currentStreak;
  const StreakWidget({required this.currentStreak, super.key});

  @override
  State<StreakWidget> createState() => _StreakWidgetState();
}

class _StreakWidgetState extends State<StreakWidget> {
  bool get isStreak => widget.currentStreak >= 1;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        RouteUtils.pushNamed(
          context,
          RoutePaths.streakPage,
        );
      },
      child: AnimatedContainer(
        duration: Duration(seconds: 1),
        height: 48,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
        ),
        decoration: BoxDecoration(
            gradient: isStreak
                ? LinearGradient(colors: [
                    Color(0xFFff4b1f),
                    Color(0xFFff9068),
                  ])
                : LinearGradient(colors: [
                    AppColors.backgroundSecondary,
                    AppColors.backgroundTertiary,
                  ]),
            borderRadius: BorderRadius.circular(AppBorderRadius.full),
            border: Border.all(
              color: isStreak ? AppColors.accentOrange : AppColors.textMuted,
              width: 1,
            ),
            boxShadow: isStreak
                ? [
                    BoxShadow(
                      color: AppColors.accentOrange.withValues(alpha: 0.2),
                      blurRadius: 10,
                      spreadRadius: 2,
                    ),
                  ]
                : []),
        child: Row(
          children: [
            Icon(
              CupertinoIcons.flame_fill,
              color: isStreak ? AppColors.whiteColor : AppColors.textMuted,
              size: 20,
            ),
            const SizedBox(width: 4),
            Text(
              isStreak
                  ? '${widget.currentStreak} ${widget.currentStreak == 1 ? 'streak' : 'streaks'}'
                  : '0 streak',
              style: TextStyle(
                color: AppColors.whiteColor,
                fontSize: 16 * ResponsiveUtils.fontScale,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
