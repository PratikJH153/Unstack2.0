// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';

// import 'package:unstack/models/tasks/analytics_data.dart';
// import 'package:unstack/providers/task_provider.dart';
// import 'package:unstack/theme/theme.dart';
// import 'package:unstack/widgets/buildScrollableWithFade.dart';
// import 'package:unstack/widgets/glassmorphism_container.dart';
// import 'package:unstack/widgets/home_app_bar_button.dart';

// class ProgressAnalyticsPage extends StatefulWidget {
//   const ProgressAnalyticsPage({
//     super.key,
//   });

//   @override
//   State<ProgressAnalyticsPage> createState() => _ProgressAnalyticsPageState();
// }

// class _ProgressAnalyticsPageState extends State<ProgressAnalyticsPage> {
//   @override
//   Widget build(BuildContext context) {
//     return Consumer<TaskProvider>(
//       builder: (context, taskProvider, child) {
//         final todayAnalytics =
//             AnalyticsCalculator.calculateTodayAnalytics(taskProvider.tasks);
//         final weeklyComparison =
//             AnalyticsCalculator.calculateWeeklyComparison(taskProvider.tasks);

//         return Scaffold(
//           backgroundColor: AppColors.backgroundPrimary,
//           body: SafeArea(
//             child: Column(
//               children: [
//                 // Header with back button
//                 _buildHeader(),

//                 // Scrollable content
//                 Expanded(
//                   child: buildScrollableWithFade(
//                     child: SingleChildScrollView(
//                       padding: const EdgeInsets.all(AppSpacing.lg).copyWith(
//                         top: 0,
//                       ),
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           // Today's Summary Section
//                           _buildTodaySummarySection(todayAnalytics)
//                               .slideUpStandard(
//                                   delay: AnimationConstants.shortDelay),
//                           const SizedBox(height: AppSpacing.xl),

//                           // Weekly Comparison Section
//                           _buildWeeklyComparisonSection(weeklyComparison)
//                               .slideUpStandard(
//                                   delay: AnimationConstants.mediumDelay),

//                           // const SizedBox(height: AppSpacing.xxl),
//                           // _buildTaskBreakdownSection()
//                           //     .animate()
//                           //     .fadeIn(delay: 200.ms, duration: 600.ms)
//                           //     .slideY(begin: 0.3, duration: 600.ms),

//                           // Bottom spacing
//                           const SizedBox(height: AppSpacing.xl),
//                         ],
//                       ),
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         );
//       },
//     );
//   }

//   Widget _buildHeader() {
//     return Container(
//       width: double.infinity,
//       padding: const EdgeInsets.all(AppSpacing.lg),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           // Back button
//           HomeAppBarButton(
//               onPressed: () => Navigator.of(context).pop(),
//               icon: CupertinoIcons.back),
//           const SizedBox(height: AppSpacing.md),

//           // Title
//           Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Text(
//                 'Progress Analytics',
//                 style: AppTextStyles.h2.copyWith(
//                   color: AppColors.textPrimary,
//                   fontWeight: FontWeight.w600,
//                 ),
//               ),
//               const SizedBox(height: AppSpacing.xs),
//               Text(
//                 'Track your productivity insights',
//                 style: AppTextStyles.bodySmall.copyWith(
//                   color: AppColors.textSecondary,
//                 ),
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildTodaySummarySection(DailyAnalytics todayAnalytics) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         _buildSectionHeader(
//           'Today\'s Summary',
//           CupertinoIcons.calendar_today,
//           AppColors.accentBlue,
//         ),

//         // Pomodoro functionality has been commented out as requested
//         const SizedBox(height: AppSpacing.md),

//         // Task completion
//         _buildSummaryCard(
//           title: 'Task Completion',
//           value:
//               '${todayAnalytics.completedTasks}/${todayAnalytics.totalTasks}',
//           subtitle:
//               '${(todayAnalytics.taskCompletionPercentage * 100).toInt()}% completed',
//           icon: CupertinoIcons.checkmark_circle,
//           color: AppColors.accentOrange,
//           isWide: true,
//         ),
//       ],
//     );
//   }

//   Widget _buildWeeklyComparisonSection(WeeklyComparison weeklyComparison) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         _buildSectionHeader(
//           'Weekly Comparison',
//           CupertinoIcons.chart_bar,
//           AppColors.accentYellow,
//         ),
//         const SizedBox(height: AppSpacing.md),
//         _buildComparisonCard(weeklyComparison),
//       ],
//     );
//   }

//   Widget _buildSectionHeader(String title, IconData icon, Color color) {
//     return Row(
//       children: [
//         Container(
//           padding: const EdgeInsets.all(AppSpacing.sm),
//           decoration: BoxDecoration(
//             color: color.withValues(alpha: 0.1),
//             borderRadius: BorderRadius.circular(AppBorderRadius.lg),
//           ),
//           child: Icon(
//             icon,
//             color: color,
//             size: 20,
//           ),
//         ),
//         const SizedBox(width: AppSpacing.md),
//         Text(
//           title,
//           style: AppTextStyles.h3.copyWith(
//             color: AppColors.textPrimary,
//             fontWeight: FontWeight.w600,
//           ),
//         ),
//       ],
//     );
//   }

//   Widget _buildSummaryCard({
//     required String title,
//     required String value,
//     required String subtitle,
//     required IconData icon,
//     required Color color,
//     bool isWide = false,
//   }) {
//     return GlassmorphismContainer(
//       borderRadius: AppBorderRadius.xxxl,
//       child: Container(
//         padding: const EdgeInsets.all(AppSpacing.lg),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Row(
//               children: [
//                 Expanded(
//                   child: Text(
//                     title,
//                     style: AppTextStyles.bodyMedium.copyWith(
//                       color: AppColors.textPrimary,
//                       fontWeight: FontWeight.w600,
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//             const SizedBox(height: AppSpacing.md),
//             Text(
//               value,
//               style: AppTextStyles.h1.copyWith(
//                 color: AppColors.textPrimary,
//                 fontWeight: FontWeight.w700,
//               ),
//             ),
//             const SizedBox(height: AppSpacing.xs),
//             Text(
//               subtitle,
//               style: AppTextStyles.bodySmall.copyWith(
//                 color: AppColors.textSecondary,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildComparisonCard(WeeklyComparison weeklyComparison) {
//     return GlassmorphismContainer(
//       borderRadius: AppBorderRadius.xxxl,
//       child: Container(
//         padding: const EdgeInsets.all(AppSpacing.lg),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text(
//               'This Week vs Last Week',
//               style: AppTextStyles.bodyMedium.copyWith(
//                 color: AppColors.textPrimary,
//                 fontWeight: FontWeight.w600,
//               ),
//             ),
//             const SizedBox(height: AppSpacing.sm),

//             // Completion rate comparison
//             _buildComparisonRow(
//               'Completion Rate',
//               '${(weeklyComparison.currentWeek.taskCompletionPercentage * 100).toInt()}%',
//               '${(weeklyComparison.previousWeek.taskCompletionPercentage * 100).toInt()}%',
//               weeklyComparison.completionRateChange,
//               CupertinoIcons.checkmark_circle,
//             ),
//             const SizedBox(height: AppSpacing.sm),

//             _buildComparisonRow(
//               'Total Tasks',
//               '${weeklyComparison.currentWeek.totalTasks}',
//               '${weeklyComparison.previousWeek.totalTasks}',
//               (((weeklyComparison.currentWeek.totalTasks -
//                           weeklyComparison.previousWeek.totalTasks) /
//                       (weeklyComparison.previousWeek.totalTasks == 0
//                           ? 1
//                           : weeklyComparison.previousWeek.totalTasks)) *
//                   100),
//               CupertinoIcons.list_bullet,
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildComparisonRow(
//     String label,
//     String currentValue,
//     String previousValue,
//     double changePercentage,
//     IconData icon,
//   ) {
//     final isPositive = changePercentage > 0;
//     final isNeutral = changePercentage == 0;

//     return Row(
//       children: [
//         Expanded(
//           child: Text(
//             label,
//             style: AppTextStyles.bodySmall.copyWith(
//               color: AppColors.textSecondary,
//             ),
//           ),
//         ),
//         Text(
//           currentValue,
//           style: AppTextStyles.bodyMedium.copyWith(
//             color: AppColors.textPrimary,
//             fontWeight: FontWeight.w600,
//           ),
//         ),
//         const SizedBox(width: AppSpacing.sm),
//         Container(
//           padding: const EdgeInsets.symmetric(
//             horizontal: AppSpacing.sm,
//             vertical: AppSpacing.xs,
//           ),
//           decoration: BoxDecoration(
//             color: isNeutral
//                 ? AppColors.textSecondary.withValues(alpha: 0.1)
//                 : isPositive
//                     ? AppColors.accentGreen.withValues(alpha: 0.1)
//                     : AppColors.redShade.withValues(alpha: 0.1),
//             borderRadius: BorderRadius.circular(AppBorderRadius.sm),
//           ),
//           child: Row(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               if (!isNeutral)
//                 Icon(
//                   isPositive
//                       ? CupertinoIcons.arrow_up
//                       : CupertinoIcons.arrow_down,
//                   color:
//                       isPositive ? AppColors.accentGreen : AppColors.redShade,
//                   size: 12,
//                 ),
//               if (!isNeutral) const SizedBox(width: AppSpacing.xs),
//               Text(
//                 isNeutral ? '0%' : '${changePercentage.abs().toInt()}%',
//                 style: AppTextStyles.bodySmall.copyWith(
//                   color: isNeutral
//                       ? AppColors.textSecondary
//                       : isPositive
//                           ? AppColors.accentGreen
//                           : AppColors.redShade,
//                   fontWeight: FontWeight.w500,
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ],
//     );
//   }
// }
