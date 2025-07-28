import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:unstack/models/streak_data.dart';
import 'package:unstack/models/task.model.dart';
import 'package:unstack/theme/app_theme.dart';
import 'package:unstack/widgets/streak_calendar.dart';
import 'package:unstack/widgets/streak_statistics.dart';

class StreakPage extends StatefulWidget {
  const StreakPage({super.key});

  @override
  State<StreakPage> createState() => _StreakPageState();
}

class _StreakPageState extends State<StreakPage> {
  DateTime _selectedMonth = DateTime.now();
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadStreakData();
  }

  Future<void> _loadStreakData() async {
    await streakTracker.loadFromStorage();

    // Update today's completion with sample data for demonstration
    final sampleTasks = TaskData.getSampleTasks();
    await streakTracker.updateTodayCompletion(sampleTasks);

    setState(() {
      _isLoading = false;
    });
  }

  void _onMonthChanged(DateTime month) {
    setState(() {
      _selectedMonth = month;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundPrimary,
      appBar: AppBar(
        leading: Container(
          margin: const EdgeInsets.only(
            left: AppSpacing.md,
            top: AppSpacing.sm,
            bottom: AppSpacing.sm,
          ),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColors.glassBackground,
                AppColors.glassBackground.withValues(alpha: 0.05),
              ],
            ),
            border: Border.all(
              color: AppColors.glassBorder,
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(
              CupertinoIcons.back,
              color: AppColors.textPrimary,
              size: 20,
            ),
          ),
        ),
        title: Text(
          'Streak Tracking',
          style: AppTextStyles.h2.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.3, duration: 400.ms),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(
              child: CupertinoActivityIndicator(
                color: AppColors.accentPurple,
              ),
            )
          : SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child:
                  // Content
                  Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.lg,
                  vertical: AppSpacing.lg,
                ),
                child: Column(children: [
                  // Statistics Section
                  StreakStatistics(
                    currentStreak: streakTracker.currentStreak,
                    longestStreak: streakTracker.longestStreak,
                    totalCompletedDays: streakTracker.totalCompletedDays,
                    monthCompletionPercentage: streakTracker
                        .getMonthCompletionPercentage(_selectedMonth),
                  )
                      .animate()
                      .fadeIn(delay: 300.ms)
                      .slideY(begin: 0.2, duration: 500.ms),
                  const SizedBox(height: AppSpacing.md),

                  // Calendar Section
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.xl),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          AppColors.glassBackground,
                          AppColors.glassBackground.withValues(alpha: 0.05),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(AppBorderRadius.xl),
                      border: Border.all(
                        color: AppColors.glassBorder,
                        width: 1,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.15),
                          blurRadius: 24,
                          offset: const Offset(0, 8),
                        ),
                        BoxShadow(
                          color: AppColors.accentOrange.withValues(alpha: 0.05),
                          blurRadius: 32,
                          offset: const Offset(0, 16),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(AppSpacing.sm),
                              decoration: BoxDecoration(
                                color: AppColors.accentOrange
                                    .withValues(alpha: 0.1),
                                borderRadius:
                                    BorderRadius.circular(AppBorderRadius.md),
                              ),
                              child: Icon(
                                CupertinoIcons.calendar,
                                color: AppColors.accentOrange,
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: AppSpacing.md),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Monthly Calendar',
                                    style: AppTextStyles.h3.copyWith(
                                      color: AppColors.textPrimary,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: AppSpacing.xs),
                                  Text(
                                    'Track your daily task completion streaks',
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
                        StreakCalendar(
                          selectedMonth: _selectedMonth,
                          onMonthChanged: _onMonthChanged,
                          completionData:
                              streakTracker.getMonthData(_selectedMonth),
                        ),
                      ],
                    ),
                  )
                      .animate()
                      .fadeIn(delay: 500.ms)
                      .slideY(begin: 0.2, duration: 500.ms),
                  const SizedBox(height: AppSpacing.xl),
                ]),
              ),
            ),
    );
  }
}
