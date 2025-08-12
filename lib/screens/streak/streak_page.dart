import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:unstack/providers/streak_provider.dart';
import 'package:unstack/theme/theme.dart';
import 'package:unstack/widgets/buildScrollableWithFade.dart';
import 'package:unstack/widgets/home_app_bar_button.dart';
import 'package:unstack/widgets/loading_widget.dart';
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
    final streakProvider = Provider.of<StreakProvider>(context, listen: false);

    // Load streak data from database
    await streakProvider.loadStreakData();

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
      body: _isLoading
          ? const Center(child: LoadingWidget())
          : SafeArea(
              child: Column(
                children: [
                  _buildHeader(),
                  Expanded(
                    child: buildScrollableWithFade(
                      child: SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                        child:
                            // Content
                            Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.lg,
                            vertical: AppBorderRadius.sm,
                          ),
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Keep the Streak Alive!',
                                      style: AppTextStyles.h2.copyWith(
                                        color: AppColors.textPrimary,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const SizedBox(height: AppSpacing.xs),
                                    Text(
                                      'One day at a time, one win at a time',
                                      style: AppTextStyles.bodySmall.copyWith(
                                        color: AppColors.textSecondary,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: AppSpacing.md),
                                // Statistics Section
                                Consumer<StreakProvider>(
                                  builder: (context, streakProvider, child) {
                                    return StreakStatistics(
                                      currentStreak:
                                          streakProvider.currentStreak,
                                      longestStreak:
                                          streakProvider.longestStreak,
                                      totalCompletedDays:
                                          streakProvider.totalCompletedDays,
                                      monthCompletionPercentage: streakProvider
                                          .getMonthCompletionPercentage(
                                              _selectedMonth),
                                    ).slideUpStandard(
                                        delay: AnimationConstants.noDelay);
                                  },
                                ),
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
                                        AppColors.glassBackground
                                            .withValues(alpha: 0.05),
                                      ],
                                    ),
                                    borderRadius: BorderRadius.circular(
                                        AppBorderRadius.xxl),
                                    border: Border.all(
                                      color: AppColors.glassBorder,
                                      width: 1,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black
                                            .withValues(alpha: 0.15),
                                        blurRadius: 24,
                                        offset: const Offset(0, 8),
                                      ),
                                      BoxShadow(
                                        color: AppColors.accentOrange
                                            .withValues(alpha: 0.05),
                                        blurRadius: 32,
                                        offset: const Offset(0, 16),
                                      ),
                                    ],
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      // Text(
                                      //   'Streak Tracker',
                                      //   style: AppTextStyles.h3.copyWith(
                                      //     color: AppColors.textPrimary,
                                      //     fontWeight: FontWeight.w600,
                                      //   ),
                                      // ),
                                      // const SizedBox(height: AppSpacing.lg),
                                      Consumer<StreakProvider>(
                                        builder:
                                            (context, streakProvider, child) {
                                          return StreakCalendar(
                                            selectedMonth: _selectedMonth,
                                            onMonthChanged: _onMonthChanged,
                                            completionData: streakProvider
                                                .getMonthData(_selectedMonth),
                                          );
                                        },
                                      ),
                                    ],
                                  ),
                                ).slideUpStandard(
                                    delay: AnimationConstants.longDelay),
                              ]),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.lg).copyWith(bottom: 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Back button
          HomeAppBarButton(
              onPressed: () => Navigator.of(context).pop(),
              icon: CupertinoIcons.back),
          const SizedBox(height: AppSpacing.md),

          // Title
        ],
      ),
    );
  }
}
