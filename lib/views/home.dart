import 'dart:math';

import 'package:confetti/confetti.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:unstack/models/task.dart';
import 'package:unstack/models/streak_data.dart';

import 'package:unstack/routes/route.dart';

import 'package:unstack/theme/app_theme.dart';
import 'package:unstack/views/task_details_page.dart';
import 'package:unstack/views/test_animation.dart';
import 'package:unstack/widgets/home_app_bar_button.dart';
import 'package:unstack/widgets/streak_widget.dart';
import 'package:unstack/widgets/todo_tile.dart';
import 'package:unstack/widgets/circular_progress_3d.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String _userName = '';
  late ConfettiController _confettiController;
  bool isStreak = false;
  late List<Task> cards;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: Duration(seconds: 2));
    cards = TaskData.getSampleTasks();
    // cards = [];
    _loadUserName();
    _initializeStreakTracking();
  }

  Future<void> _initializeStreakTracking() async {
    await streakTracker.loadFromStorage();
    await _updateStreakData();
  }

  Future<void> _updateStreakData() async {
    await streakTracker.updateTodayCompletion(cards);
    setState(() {
      isStreak = streakTracker.currentStreak > 0;
    });
  }

  Future<void> _loadUserName() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final name = prefs.getString('user_name') ?? 'User';
      setState(() {
        _userName = name;
      });
    } catch (e) {
      setState(() {
        _userName = 'User';
      });
    }
  }

  void showStreakOverlay(BuildContext context, int streakCount) {
    showGeneralDialog(
      context: context,
      barrierDismissible: false,
      barrierLabel: '',
      barrierColor: Colors.black87,
      transitionDuration: Duration(milliseconds: 400),
      pageBuilder: (context, animation, secondaryAnimation) {
        return ModernStreakOverlay(streakCount: streakCount);
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(
          opacity: animation,
          child: child,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundPrimary,
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: AppSpacing.xl),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    StreakWidget(
                      currentStreak: streakTracker.currentStreak,
                    )
                        .animate()
                        .slideX(
                          begin: -0.3,
                          duration: 500.ms,
                          curve: Curves.easeOut,
                        )
                        .fadeIn(delay: 200.ms),
                    Spacer(),
                    Row(
                      children: [
                        HomeAppBarButton(
                          onPressed: () {},
                          icon: CupertinoIcons.person,
                        ),
                        const SizedBox(width: AppSpacing.md),
                        HomeAppBarButton(
                          onPressed: () {
                            RouteUtils.pushNamed(
                              context,
                              RoutePaths.tasksListPage,
                            );
                          },
                          icon: CupertinoIcons.list_dash,
                        ),
                        const SizedBox(width: AppSpacing.md),
                        HomeAppBarButton(
                          onPressed: () {
                            RouteUtils.pushNamed(
                              context,
                              RoutePaths.addTaskPage,
                            );
                          },
                          icon: CupertinoIcons.add,
                        ),
                      ],
                    )
                        .animate()
                        .slideX(
                          begin: 0.3,
                          duration: 500.ms,
                          curve: Curves.easeOut,
                        )
                        .fadeIn(delay: 200.ms),
                  ],
                ),

                const SizedBox(height: AppSpacing.md),
                // Welcome header
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Let's get to work,",
                      style: AppTextStyles.bodyLarge.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    )
                        .animate()
                        .slideX(
                          begin: -0.3,
                          duration: 500.ms,
                          curve: Curves.easeOut,
                        )
                        .fadeIn(),
                    Text(
                      _userName,
                      style: AppTextStyles.h1.copyWith(
                        fontSize: 32,
                        fontWeight: FontWeight.w800,
                      ),
                    )
                        .animate()
                        .slideX(
                          begin: -0.3,
                          duration: 500.ms,
                          curve: Curves.easeOut,
                        )
                        .fadeIn(delay: 200.ms),
                  ],
                ),

                const SizedBox(height: AppSpacing.xl),

                // 3D Circular Progress Indicator
                Center(
                  child: CircularProgressIndicator3D(
                    totalTasks: cards.length,
                    completedTasks: cards.fold<int>(
                        0,
                        (previousValue, value) =>
                            previousValue + (value.isCompleted ? 1 : 0)),
                    size: 290,
                  ),
                )
                    .animate()
                    .scale(
                      begin: const Offset(0.8, 0.8),
                      duration: 600.ms,
                      curve: Curves.easeOutBack,
                    )
                    .fadeIn(delay: 400.ms),

                Spacer(),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: cards.isNotEmpty && cards.any((e) => !e.isCompleted)
                      ? CardsSwiperWidget(
                          cardData: cards,
                          onCardCollectionAnimationComplete: (_) {},
                          onCardChange: (index) {
                            print('Top card index: $index');
                          },
                          cardBuilder: (context, index, visibleIndex) {
                            var task = cards[index];
                            return Hero(
                              tag: 'card_$index',
                              child: GestureDetector(
                                onTap: () {
                                  // Navigator.of(context).push(
                                  //   MaterialPageRoute(
                                  //     builder: (context) {
                                  //       return TaskDetailsPage(
                                  //           heroTag: 'card_$index');
                                  //     },
                                  //   ),
                                  // );
                                  Navigator.of(context)
                                      .push(HeroDialogRoute(builder: (context) {
                                    return TaskDetailsPage(
                                      heroTag: 'card_$index',
                                    );
                                  }));
                                },
                                child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(32),
                                    color: AppColors.backgroundTertiary,
                                    border: Border.all(
                                      color: AppColors.textMuted,
                                      width: 0.5,
                                    ),
                                  ),
                                  width: 600,
                                  height: 300,
                                  padding: const EdgeInsets.only(
                                    left: AppSpacing.xl,
                                    right: AppSpacing.xl,
                                    bottom: AppSpacing.md,
                                    top: AppSpacing.xl,
                                  ),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Transform.scale(
                                        scale: 2.5,
                                        child: Checkbox(
                                          value: task.isCompleted,
                                          visualDensity: VisualDensity.compact,
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(6.0),
                                            side: BorderSide(
                                              color: AppColors.whiteColor,
                                              width: 2,
                                            ),
                                          ),
                                          side: BorderSide(
                                            color: AppColors.textMuted,
                                            width: 2,
                                          ),
                                          activeColor: AppColors.accentGreen,
                                          onChanged: (bool? value) async {
                                            setState(() {
                                              cards[index] = task.copyWith(
                                                  isCompleted: value ?? false);
                                            });
                                            if (cards
                                                .every((e) => e.isCompleted)) {
                                              if (context.mounted) {
                                                showStreakOverlay(
                                                  context,
                                                  streakTracker.currentStreak +
                                                      1,
                                                );
                                              }
                                            }
                                            if (value ?? false) {
                                              _confettiController.play();
                                            }
                                            await _updateStreakData();
                                          },
                                        ),
                                      ),
                                      const SizedBox(height: AppSpacing.md),
                                      Text(
                                        task.title,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        style: AppTextStyles.h2.copyWith(
                                          fontFamily: 'Poppins',
                                          color: AppColors.textPrimary,
                                          fontSize: 28,
                                        ),
                                      ),
                                      Text(
                                        task.description,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        style: AppTextStyles.bodySmall.copyWith(
                                          color: AppColors.textSecondary,
                                          fontSize: 16,
                                        ),
                                      ),
                                      const Spacer(),
                                      Row(
                                        children: [
                                          Icon(
                                            CupertinoIcons.hourglass,
                                            color: AppColors.textPrimary,
                                            size: 20,
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            "${task.pomodoroCount} Pomos",
                                            style: AppTextStyles.bodyLarge
                                                .copyWith(
                                              color: AppColors.textPrimary,
                                              fontSize: 16,
                                            ),
                                          ),
                                          const SizedBox(width: 16),
                                          Icon(
                                            CupertinoIcons.calendar,
                                            color: AppColors.textPrimary,
                                            size: 20,
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            "Today",
                                            style: AppTextStyles.bodyLarge
                                                .copyWith(
                                              color: AppColors.textPrimary,
                                              fontSize: 16,
                                            ),
                                          ),
                                          const Spacer(),
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: AppSpacing.sm,
                                              vertical: AppSpacing.xs,
                                            ),
                                            decoration: BoxDecoration(
                                              color: task.priority.color
                                                  .withValues(alpha: 0.2),
                                              borderRadius:
                                                  BorderRadius.circular(
                                                      AppBorderRadius.full),
                                              border: Border.all(
                                                color: task.priority.color
                                                    .withValues(alpha: 0.5),
                                                width: 1,
                                              ),
                                            ),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Icon(
                                                  task.priority.icon,
                                                  size: 12,
                                                  color: task.priority.color,
                                                ),
                                                const SizedBox(width: 4),
                                                Text(
                                                  task.priority.label,
                                                  style: AppTextStyles.caption
                                                      .copyWith(
                                                    color: task.priority.color,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                      SizedBox(
                                        height: task.isCompleted
                                            ? AppSpacing.md
                                            : AppSpacing.xl,
                                      ),
                                      if (task.isCompleted)
                                        Center(
                                          child: Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Icon(
                                                Icons.swipe_up_rounded,
                                                color: AppColors.textSecondary,
                                                size: 18,
                                              ),
                                              const SizedBox(
                                                width: AppSpacing.sm,
                                              ),
                                              Text(
                                                'Swipe up for next task',
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  color:
                                                      AppColors.textSecondary,
                                                ),
                                              )
                                            ],
                                          ),
                                        )
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        )
                      : Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(32),
                            color: AppColors.backgroundTertiary,
                            border: Border.all(
                              color: AppColors.textMuted,
                              width: 0.5,
                            ),
                          ),
                          width: 600,
                          height: 280,
                          padding: const EdgeInsets.all(AppSpacing.xl),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '🚀 Please add some task',
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: AppTextStyles.h2.copyWith(
                                  fontFamily: 'Poppins',
                                  color: AppColors.textPrimary,
                                  fontSize: 32,
                                ),
                              ),
                              Text(
                                'Click on button at top right to add some tasks!',
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: AppTextStyles.bodySmall.copyWith(
                                  color: AppColors.textSecondary,
                                  fontSize: 18,
                                ),
                              ),
                              const Spacer(),
                              Row(
                                children: [
                                  Icon(
                                    CupertinoIcons.hourglass,
                                    color: AppColors.textMuted,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    "1 Pomo",
                                    style: AppTextStyles.bodyLarge.copyWith(
                                      color: AppColors.textSecondary,
                                      fontSize: 16,
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Icon(
                                    CupertinoIcons.calendar,
                                    color: AppColors.textMuted,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    "Today",
                                    style: AppTextStyles.bodyLarge.copyWith(
                                      color: AppColors.textSecondary,
                                      fontSize: 16,
                                    ),
                                  ),
                                  const Spacer(),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: AppSpacing.sm,
                                      vertical: AppSpacing.xs,
                                    ),
                                    decoration: BoxDecoration(
                                      color: TaskPriority.urgent.color
                                          .withValues(alpha: 0.2),
                                      borderRadius: BorderRadius.circular(
                                          AppBorderRadius.full),
                                      border: Border.all(
                                        color: TaskPriority.urgent.color
                                            .withValues(alpha: 0.5),
                                        width: 1,
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          TaskPriority.urgent.icon,
                                          size: 12,
                                          color: TaskPriority.urgent.color,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          TaskPriority.urgent.label,
                                          style: AppTextStyles.caption.copyWith(
                                            color: TaskPriority.urgent.color,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                )
                    .animate()
                    .slideY(
                      begin: 0.3,
                      duration: 500.ms,
                      curve: Curves.easeOut,
                    )
                    .fadeIn(delay: 200.ms),
                const SizedBox(height: AppSpacing.xl),
              ],
            ),
          ),
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confettiController,
              blastDirectionality: BlastDirectionality.explosive,
              blastDirection: pi * 0.5, maxBlastForce: 10,
              numberOfParticles: 50,
              colors: const [
                AppColors.accentPurple,
                AppColors.accentBlue,
                AppColors.accentGreen,
                AppColors.accentYellow,
                AppColors.accentPink,
                AppColors.accentOrange,
              ], // manually specify the colors to be used
            ),
          ),
        ],
      ),
    );
  }
}
