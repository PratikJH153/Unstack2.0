import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:unstack/models/analytics_data.dart';
import 'package:unstack/models/task.dart';
import 'package:unstack/theme/app_theme.dart';
import 'package:unstack/widgets/buildScrollableWithFade.dart';
import 'package:unstack/widgets/glassmorphism_container.dart';
import 'package:unstack/widgets/home_app_bar_button.dart';

class ProgressAnalyticsPage extends StatefulWidget {
  final List<Task> tasks;

  const ProgressAnalyticsPage({
    super.key,
    required this.tasks,
  });

  @override
  State<ProgressAnalyticsPage> createState() => _ProgressAnalyticsPageState();
}

class _ProgressAnalyticsPageState extends State<ProgressAnalyticsPage> {
  late DailyAnalytics todayAnalytics;
  late WeeklyComparison weeklyComparison;

  @override
  void initState() {
    super.initState();
    _calculateAnalytics();
  }

  void _calculateAnalytics() {
    todayAnalytics = AnalyticsCalculator.calculateTodayAnalytics(widget.tasks);
    weeklyComparison =
        AnalyticsCalculator.calculateWeeklyComparison(widget.tasks);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundPrimary,
      body: Column(
        children: [
          // Header with back button
          _buildHeader(),

          // Scrollable content
          Expanded(
            child: buildScrollableWithFade(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AppSpacing.lg).copyWith(
                  bottom: 100,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Today's Summary Section
                    _buildTodaySummarySection()
                        .animate()
                        .fadeIn(delay: 100.ms, duration: 600.ms)
                        .slideY(begin: 0.3, duration: 600.ms),
                    const SizedBox(height: AppSpacing.xxl),

                    // Weekly Comparison Section
                    _buildWeeklyComparisonSection()
                        .animate()
                        .fadeIn(delay: 300.ms, duration: 600.ms)
                        .slideY(begin: 0.3, duration: 600.ms),

                    const SizedBox(height: AppSpacing.xxl),
                    _buildTaskBreakdownSection()
                        .animate()
                        .fadeIn(delay: 200.ms, duration: 600.ms)
                        .slideY(begin: 0.3, duration: 600.ms),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      margin: EdgeInsets.only(
        top: AppSpacing.xxl,
      ),
      padding: const EdgeInsets.all(
        AppSpacing.lg,
      ).copyWith(bottom: AppSpacing.md),
      child: Row(
        children: [
          // Back button
          HomeAppBarButton(
              onPressed: () => Navigator.of(context).pop(),
              icon: CupertinoIcons.back),
          const SizedBox(width: AppSpacing.md),

          // Title
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Progress Analytics',
                  style: AppTextStyles.h2.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  'Track your productivity insights',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTodaySummarySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(
          'Today\'s Summary',
          CupertinoIcons.calendar_today,
          AppColors.accentBlue,
        ),
        const SizedBox(height: AppSpacing.md),

        Row(
          children: [
            // Total Pomodoros
            Expanded(
              child: SizedBox(
                height: 175,
                child: _buildSummaryCard(
                  title: 'Pomodoros',
                  value: todayAnalytics.totalPomodoros.toString(),
                  subtitle: 'sessions',
                  icon: CupertinoIcons.timer,
                  color: AppColors.accentPurple,
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.md),

            // Total Time
            Expanded(
              child: _buildSummaryCard(
                title: 'Time Invested',
                value: todayAnalytics.formattedTotalTime,
                subtitle: 'today',
                icon: CupertinoIcons.clock,
                color: AppColors.accentGreen,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),

        // Task completion
        _buildSummaryCard(
          title: 'Task Completion',
          value:
              '${todayAnalytics.completedTasks}/${todayAnalytics.totalTasks}',
          subtitle:
              '${(todayAnalytics.taskCompletionPercentage * 100).toInt()}% completed',
          icon: CupertinoIcons.checkmark_circle,
          color: AppColors.accentOrange,
          isWide: true,
        ),
      ],
    );
  }

  Widget _buildTaskBreakdownSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(
          'Task Breakdown',
          CupertinoIcons.list_bullet,
          AppColors.accentPurple,
        ),
        const SizedBox(height: AppSpacing.md),
        if (todayAnalytics.taskBreakdown.isEmpty)
          _buildEmptyState()
        else
          ...todayAnalytics.taskBreakdown
              .map((taskAnalytics) => _buildTaskAnalyticsCard(taskAnalytics)),
      ],
    );
  }

  Widget _buildWeeklyComparisonSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(
          'Weekly Comparison',
          CupertinoIcons.chart_bar,
          AppColors.accentYellow,
        ),
        const SizedBox(height: AppSpacing.md),
        _buildComparisonCard(),
      ],
    );
  }

  Widget _buildSectionHeader(String title, IconData icon, Color color) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(AppSpacing.sm),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(AppBorderRadius.lg),
          ),
          child: Icon(
            icon,
            color: color,
            size: 20,
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Text(
          title,
          style: AppTextStyles.h3.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryCard({
    required String title,
    required String value,
    required String subtitle,
    required IconData icon,
    required Color color,
    bool isWide = false,
  }) {
    return GlassmorphismContainer(
      borderRadius: AppBorderRadius.xxl,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  icon,
                  color: color,
                  size: 24,
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    title,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              value,
              style: AppTextStyles.h1.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              subtitle,
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTaskAnalyticsCard(TaskAnalytics taskAnalytics) {
    return Stack(
      children: [
        if (taskAnalytics.isCompleted)
          Positioned(
            top: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: AppColors.statusSuccess.withValues(alpha: 0.1),
                borderRadius: BorderRadius.only(
                  topRight: Radius.circular(AppBorderRadius.xxl),
                  bottomLeft: Radius.circular(AppBorderRadius.xxl),
                ),
              ),
              child: Icon(
                CupertinoIcons.checkmark_circle,
                color: AppColors.statusSuccess,
                size: 20,
              ),
            ),
          ),
        Container(
          margin: const EdgeInsets.only(bottom: AppSpacing.md),
          child: GlassmorphismContainer(
            borderRadius: AppBorderRadius.xxl,
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Row(
                children: [
                  // Priority indicator
                  Container(
                    width: 4,
                    height: 40,
                    decoration: BoxDecoration(
                      color: taskAnalytics.priority.color,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),

                  // Task info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          taskAnalytics.taskTitle,
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Row(
                          children: [
                            Icon(
                              CupertinoIcons.timer,
                              color: AppColors.textSecondary,
                              size: 14,
                            ),
                            const SizedBox(width: AppSpacing.xs),
                            Text(
                              '${taskAnalytics.completedPomodoros} sessions',
                              style: AppTextStyles.bodySmall.copyWith(
                                color: AppColors.textSecondary,
                              ),
                            ),
                            const SizedBox(width: AppSpacing.md),
                            Icon(
                              CupertinoIcons.hourglass,
                              color: AppColors.textSecondary,
                              size: 14,
                            ),
                            const SizedBox(width: AppSpacing.xs),
                            Text(
                              '${taskAnalytics.totalTimeInMinutes} mins',
                              style: AppTextStyles.bodySmall.copyWith(
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildComparisonCard() {
    return GlassmorphismContainer(
      borderRadius: AppBorderRadius.xxl,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'This Week vs Last Week',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),

            // Pomodoro comparison
            _buildComparisonRow(
              'Pomodoros',
              weeklyComparison.currentWeek.totalPomodoros.toString(),
              weeklyComparison.previousWeek.totalPomodoros.toString(),
              weeklyComparison.pomodoroChange,
              CupertinoIcons.timer,
            ),
            const SizedBox(height: AppSpacing.md),

            // Time comparison
            _buildComparisonRow(
              'Time Invested',
              weeklyComparison.currentWeek.formattedTotalTime,
              weeklyComparison.previousWeek.formattedTotalTime,
              weeklyComparison.timeChange,
              CupertinoIcons.clock,
            ),
            const SizedBox(height: AppSpacing.md),

            // Completion rate comparison
            _buildComparisonRow(
              'Completion Rate',
              '${(weeklyComparison.currentWeek.taskCompletionPercentage * 100).toInt()}%',
              '${(weeklyComparison.previousWeek.taskCompletionPercentage * 100).toInt()}%',
              weeklyComparison.completionRateChange,
              CupertinoIcons.checkmark_circle,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildComparisonRow(
    String label,
    String currentValue,
    String previousValue,
    double changePercentage,
    IconData icon,
  ) {
    final isPositive = changePercentage > 0;
    final isNeutral = changePercentage == 0;

    return Row(
      children: [
        Icon(
          icon,
          color: AppColors.textSecondary,
          size: 16,
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Text(
            label,
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ),
        Text(
          currentValue,
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.sm,
            vertical: AppSpacing.xs,
          ),
          decoration: BoxDecoration(
            color: isNeutral
                ? AppColors.textSecondary.withValues(alpha: 0.1)
                : isPositive
                    ? AppColors.accentGreen.withValues(alpha: 0.1)
                    : AppColors.redShade.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(AppBorderRadius.sm),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (!isNeutral)
                Icon(
                  isPositive
                      ? CupertinoIcons.arrow_up
                      : CupertinoIcons.arrow_down,
                  color:
                      isPositive ? AppColors.accentGreen : AppColors.redShade,
                  size: 12,
                ),
              if (!isNeutral) const SizedBox(width: AppSpacing.xs),
              Text(
                isNeutral ? '0%' : '${changePercentage.abs().toInt()}%',
                style: AppTextStyles.bodySmall.copyWith(
                  color: isNeutral
                      ? AppColors.textSecondary
                      : isPositive
                          ? AppColors.accentGreen
                          : AppColors.redShade,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return GlassmorphismContainer(
      borderRadius: AppBorderRadius.xl,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          children: [
            Icon(
              CupertinoIcons.chart_bar,
              color: AppColors.textSecondary,
              size: 48,
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              'No task data available',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Complete some Pomodoro sessions to see your task breakdown',
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
