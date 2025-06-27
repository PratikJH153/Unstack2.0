import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:unstack/theme/app_theme.dart';
import 'package:unstack/widgets/circular_progress_3d.dart';

class StreakStatistics extends StatelessWidget {
  final int currentStreak;
  final int longestStreak;
  final int totalCompletedDays;
  final double monthCompletionPercentage;

  const StreakStatistics({
    super.key,
    required this.currentStreak,
    required this.longestStreak,
    required this.totalCompletedDays,
    required this.monthCompletionPercentage,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header Section
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(AppSpacing.sm),
              decoration: BoxDecoration(
                color: AppColors.accentPurple.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppBorderRadius.md),
              ),
              child: Icon(
                CupertinoIcons.chart_bar_alt_fill,
                color: AppColors.accentPurple,
                size: 20,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Streak Statistics',
                    style: AppTextStyles.h3.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    'Track your consistency and progress',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.xl),

        // Main Statistics Grid
        Column(
          children: [
            // Current Streak (Featured)
            Container(
              height: 180,
              child: _StreakCard(
                title: 'Current Streak',
                value: currentStreak.toString(),
                subtitle: currentStreak == 1 ? 'day' : 'days',
                icon: CupertinoIcons.flame_fill,
                color: AppColors.accentOrange,
                isLarge: true,
              ),
            ),
            const SizedBox(height: AppSpacing.md),

            // Side Statistics
            Row(
              children: [
                Expanded(
                  child: _StreakCard(
                    title: 'Longest',
                    value: longestStreak.toString(),
                    subtitle: longestStreak == 1 ? 'day' : 'days',
                    icon: CupertinoIcons.star_fill,
                    color: AppColors.accentYellow,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: _StreakCard(
                    title: 'Total Days',
                    value: totalCompletedDays.toString(),
                    subtitle: 'completed',
                    icon: CupertinoIcons.checkmark_circle_fill,
                    color: AppColors.accentGreen,
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }
}

class _StreakCard extends StatelessWidget {
  final String title;
  final String value;
  final String subtitle;
  final IconData icon;
  final Color color;
  final bool isLarge;

  const _StreakCard({
    required this.title,
    required this.value,
    required this.subtitle,
    required this.icon,
    required this.color,
    this.isLarge = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(isLarge ? AppSpacing.lg : AppSpacing.md),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            color.withValues(alpha: 0.1),
            color.withValues(alpha: 0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(AppBorderRadius.lg),
        border: Border.all(
          color: color.withValues(alpha: 0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Icon(
                icon,
                color: color,
                size: isLarge ? 24 : 20,
              ),
              const Spacer(),
              if (isLarge)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm,
                    vertical: AppSpacing.xs,
                  ),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(AppBorderRadius.full),
                  ),
                  child: Text(
                    'ACTIVE',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: color,
                      fontWeight: FontWeight.w600,
                      fontSize: 10,
                    ),
                  ),
                ),
            ],
          ),
          SizedBox(height: isLarge ? AppSpacing.md : AppSpacing.sm),
          Text(
            value,
            style: (isLarge ? AppTextStyles.h1 : AppTextStyles.h2).copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            subtitle,
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            title,
            style: AppTextStyles.bodySmall.copyWith(
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    )
        .animate()
        .fadeIn(delay: Duration(milliseconds: isLarge ? 200 : 400))
        .slideY(begin: 0.3, duration: 600.ms)
        .scale(begin: const Offset(0.9, 0.9), duration: 600.ms);
  }
}
