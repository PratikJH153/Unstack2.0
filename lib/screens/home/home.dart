import 'dart:async';
import 'dart:math';

import 'package:confetti/confetti.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'package:just_audio/just_audio.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:unstack/models/tasks/task.model.dart';
import 'package:unstack/providers/streak_provider.dart';
import 'package:unstack/providers/task_provider.dart';

import 'package:unstack/routes/route.dart';

import 'package:unstack/theme/theme.dart';
import 'package:unstack/utils/app_logger.dart';
import 'package:unstack/utils/app_size.dart';
import 'package:unstack/screens/profile/profile_page.dart';
import 'package:unstack/views/home/stack_card.dart';
import 'package:unstack/views/streak/streak_added_page.dart';
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

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: Duration(seconds: 2));

    _loadUserName();
    // _initializeStreakTracking();
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  Future<void> _checkAndShowStreakOverlay() async {
    final taskProvider = Provider.of<TaskProvider>(context, listen: false);
    final streakProvider = Provider.of<StreakProvider>(context, listen: false);

    await Future.delayed(Duration(milliseconds: 300));
    if (taskProvider.todaysTasksCompleted) {
      await streakProvider.refreshStreakData();

      AppLogger.info('New streak count: ${streakProvider.currentStreak}');

      if (mounted) {
        showStreakOverlay(context, streakProvider.currentStreak);
      }
    } else {
      AppLogger.info('Not all today\'s tasks are completed yet');
    }
  }

  Future<void> _onTaskSwipedUp(int newTopCardIndex) async {
    HapticFeedback.lightImpact();
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
        return ModernStreakOverlay(
          streakCount: streakCount,
          userName: _userName,
        );
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(
          opacity: animation,
          child: child,
        );
      },
    );
  }

  List<Task> getTasks(
    TaskProvider taskProvider,
  ) {
    final visibleTasks = List<Task>.from(taskProvider.remainingTasks);

    visibleTasks.sort((a, b) {
      if (a.isCompleted != b.isCompleted) {
        return a.isCompleted ? 1 : -1;
      }

      return a.priorityIndex.compareTo(b.priorityIndex);
    });

    return visibleTasks;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundPrimary,
      body: SafeArea(
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    homeAppBar(context),

                    const SizedBox(height: AppSpacing.sm),
                    // Welcome header
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Let's get to work,",
                          style: AppTextStyles.bodyLarge.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ).slideDownStandard(),
                        Text(
                          _userName,
                          style: AppTextStyles.h1.copyWith(
                            fontSize: 28,
                            fontWeight: FontWeight.w800,
                          ),
                        ).slideDownStandard(
                            delay: AnimationConstants.mediumDelay),
                      ],
                    ),

                    const SizedBox(height: AppSpacing.md),

                    // 3D Circular Progress Indicator
                    Consumer<TaskProvider>(
                        builder: (context, taskProvider, child) {
                      final tasks = getTasks(taskProvider);

                      return Column(
                        children: [
                          Center(
                            child: CircularProgressIndicator3D(
                              totalTasks: taskProvider.totalTasksCount,
                              completedTasks: taskProvider.completedTasksCount,
                              size: () {
                                if (AppSize(context).height < 600) {
                                  return AppSize(context).height * 0.28;
                                } else if (AppSize(context).height < 700) {
                                  return AppSize(context).height * 0.28;
                                } else if (AppSize(context).height < 800) {
                                  return AppSize(context).height * 0.28;
                                }
                                return AppSize(context).height * 0.30;
                              }(),
                            ),
                          ).scaleInStandard(
                            delay: AnimationConstants.longDelay,
                            scale: AnimationConstants.largeScale,
                          ),

                          // Spacer(),
                          Container(
                            margin: EdgeInsets.only(
                              top: AppSpacing.xxl,
                            ),
                            alignment: Alignment.bottomCenter,
                            child: tasks.isNotEmpty
                                ? CardsSwiperWidget(
                                    cardData: tasks,
                                    onCardCollectionAnimationComplete: (_) {},
                                    onCardChange: (index) {
                                      _onTaskSwipedUp(index);
                                    },
                                    cardBuilder:
                                        (context, index, visibleIndex) {
                                      var task = tasks[index];
                                      return StackCard(
                                        task: task,
                                        onTaskCompletion: (val) {
                                          _onTaskCompletion(val, task, index);
                                        },
                                      );
                                    },
                                  )
                                : emptyTaskCard(
                                    taskProvider.totalTasksCount == 0),
                          ).slideUpStandard(
                            delay: AnimationConstants.mediumDelay,
                          ),
                        ],
                      );
                    })
                    // Bottom spacing
                  ],
                ),
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
      ),
    );
  }

  Container emptyTaskCard(bool isEmpty) {
    return Container(
      alignment: Alignment.center,
      padding: EdgeInsets.symmetric(
        horizontal: 12,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            height: 80,
            width: 100,
            child: Lottie.asset(
              isEmpty
                  ? "assets/lottie/addTask2.json"
                  : "assets/lottie/completedTask.json",
              fit: BoxFit.cover,
            ),
          ),
          Text(
            isEmpty ? 'Have any tasks?' : 'See, you did it!',
            maxLines: 2,
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.h1.copyWith(
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(
            height: AppSpacing.xs,
          ),
          Text(
            isEmpty
                ? 'Click on button at top right to add some tasks!'
                : 'You have completed all your tasks for the day!',
            maxLines: 2,
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textSecondary,
              fontSize: 18,
            ),
          ),
        ],
      ),
    );
  }

  Row homeAppBar(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Consumer<StreakProvider>(
          builder: (context, streakProvider, child) {
            return StreakWidget(
              currentStreak: streakProvider.yesterdayStreak,
            ).slideDownStandard(
              delay: AnimationConstants.mediumDelay,
            );
          },
        ),
        Spacer(),
        Row(
          children: [
            HomeAppBarButton(
              onPressed: () {
                showProfileModal(context);
              },
              icon: CupertinoIcons.settings,
            ),
            const SizedBox(width: AppSpacing.sm),
            HomeAppBarButton(
              onPressed: () {
                RouteUtils.pushNamed(
                  context,
                  RoutePaths.tasksListPage,
                );
              },
              icon: CupertinoIcons.list_dash,
            ),
            const SizedBox(width: AppSpacing.sm),
            HomeAppBarButton(
              onPressed: () {
                RouteUtils.pushNamed(
                  context,
                  RoutePaths.addTaskPage,
                  arguments: {
                    'fromHomePage': true,
                  },
                );
              },
              icon: CupertinoIcons.add,
            ),
          ],
        ).slideUpStandard(
          delay: AnimationConstants.mediumDelay,
        ),
      ],
    );
  }

  Future<void> _onTaskCompletion(
    bool? value,
    Task task,
    int index,
  ) async {
    try {
      final taskProvider = Provider.of<TaskProvider>(context, listen: false);
      if (value ?? false) {
        await taskProvider.markTaskAsCompleted(task);
      } else {
        await taskProvider.markTaskAsIncomplete(task);
      }

      if (mounted) {
        final StreakProvider streakProvider = Provider.of<StreakProvider>(
          context,
          listen: false,
        );

        streakProvider.updateStreak(
          taskProvider.totalTasksCount,
          taskProvider.completedTasksCount,
          taskProvider.todaysTasksCompleted,
        );
      }

      HapticFeedback.mediumImpact();

      // If task is being completed, trigger completion effects
      if (value ?? false) {
        // Play completion effects (confetti, sound, etc.)
        _confettiController.play();
        final audioPlayer = AudioPlayer();
        await audioPlayer.setAsset('assets/sounds/complete.mp3');
        await audioPlayer.play().then((_) async {
          await audioPlayer.dispose();
        });

        // Check if all today's tasks are now completed and show streak overlay
        await _checkAndShowStreakOverlay();
      }
    } finally {}
  }
}
