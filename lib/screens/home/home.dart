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
import 'package:unstack/helper/date_format.dart';
import 'package:unstack/models/tasks/task.model.dart';
import 'package:unstack/providers/streak_provider.dart';
import 'package:unstack/providers/task_provider.dart';

import 'package:unstack/routes/route.dart';

import 'package:unstack/theme/theme.dart';
import 'package:unstack/utils/app_size.dart';
import 'package:unstack/screens/profile/profile_page.dart';
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
  bool isStreak = false;
  final List<String> _hiddenCompletedTaskIds =
      []; // Track tasks that have been swiped up

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: Duration(seconds: 2));

    _loadUserName();
    _initializeStreakTracking();
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  Future<void> _initializeStreakTracking() async {
    final streakProvider = Provider.of<StreakProvider>(context, listen: false);
    final taskProvider = Provider.of<TaskProvider>(context, listen: false);

    // Update today's streak with current tasks
    // await streakProvider.updateTodayStreak(taskProvider.getTodaysTasks());
    await _updateStreakData();
  }

  Future<void> _updateStreakData() async {
    final streakProvider = Provider.of<StreakProvider>(context, listen: false);
    setState(() {
      isStreak = streakProvider.currentStreak > 0;
    });
  }

  void _checkForStreakOverlay() {
    final taskProvider = Provider.of<TaskProvider>(context, listen: false);
    final streakProvider = Provider.of<StreakProvider>(context, listen: false);

    final remainingTasks = taskProvider.tasks
        .where((t) => !_hiddenCompletedTaskIds.contains(t.id))
        .toList();

    if (remainingTasks.every((t) => t.isCompleted)) {
      showStreakOverlay(
        context,
        streakProvider.currentStreak + 1,
      );
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
    final visibleTasks = taskProvider.tasks
        .where((task) => !_hiddenCompletedTaskIds.contains(task.id))
        .toList();

    visibleTasks.sort((a, b) {
      if (a.priorityIndex == b.priorityIndex) return 0;
      return a.priorityIndex.compareTo(b.priorityIndex);
    }); // Sort tasks: incomplete first, completed last
    visibleTasks.sort((a, b) {
      if (a.isCompleted == b.isCompleted) return 0;
      return a.isCompleted ? 1 : -1; // incomplete (false) comes first
    });

    return visibleTasks;
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<TaskProvider>(
      builder: (context, taskProvider, child) {
        final tasks = getTasks(taskProvider);

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
                        Center(
                          child: CircularProgressIndicator3D(
                            totalTasks: taskProvider.totalTasks,
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
                          child: tasks.isNotEmpty &&
                                  tasks.any((task) => !task.isCompleted)
                              ? CardsSwiperWidget(
                                  cardData: tasks,
                                  onCardCollectionAnimationComplete: (_) {},
                                  onCardChange: (index) {
                                    _onTaskSwipedUp(index);
                                  },
                                  cardBuilder: (context, index, visibleIndex) {
                                    var task = tasks[index];
                                    return StackCard(context, task, index);
                                  },
                                )
                              : emptyTaskCard(tasks.isEmpty),
                        ).slideUpStandard(
                          delay: AnimationConstants.mediumDelay,
                        ),

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
      },
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
              currentStreak: streakProvider.currentStreak,
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
  ) async {
    final taskProvider = Provider.of<TaskProvider>(context, listen: false);
    if (value ?? false) {
      await taskProvider.markTaskAsCompleted(task);
    } else {
      await taskProvider.markTaskAsIncomplete(task);
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

      // Check for streak overlay after completion
      if (mounted) {
        _checkForStreakOverlay();
      }
    }

    await _updateStreakData();
  }

  // ignore: non_constant_identifier_names
  Widget StackCard(BuildContext context, Task task, int index) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        RouteUtils.pushNamed(
          context,
          RoutePaths.taskDetailsPage,
          arguments: {
            'heroTag': 'task_${task.id}',
            'taskID': task.id,
          },
        );
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppBorderRadius.xxxl),
          color: AppColors.backgroundTertiary,
          border: Border.all(
            color: AppColors.textMuted,
            width: 1,
          ),
        ),
        width: double.infinity,
        height: () {
          if (AppSize(context).height < 600) {
            return AppSize(context).height * 0.32;
          } else if (AppSize(context).height < 700) {
            return AppSize(context).height * 0.328;
          } else if (AppSize(context).height < 800) {
            return AppSize(context).height * 0.33;
          } else {
            return AppSize(context).height * 0.31;
          }
        }(),
        padding: const EdgeInsets.only(
          left: AppSpacing.xl,
          right: AppSpacing.xl,
          bottom: AppSpacing.md,
          top: AppSpacing.xl,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Transform.scale(
                  scale: 2.5,
                  child: Checkbox(
                    value: task.isCompleted,
                    visualDensity: VisualDensity.compact,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6.0),
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
                    onChanged: (bool? value) => _onTaskCompletion(value, task),
                  ),
                ),
                if (task.isCompleted)
                  Padding(
                    padding: const EdgeInsets.only(
                      left: 24,
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.swipe_up_rounded,
                          color: AppColors.lightWhiteColor,
                          size: 24,
                        ),
                        const SizedBox(
                          width: AppSpacing.xs,
                        ),
                        Text(
                          'Swipe up',
                          style: TextStyle(
                            fontSize: 14,
                            color: AppColors.lightWhiteColor,
                          ),
                        )
                      ],
                    ),
                  ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              task.title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.titleText.copyWith(
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(
              height: AppSpacing.xs,
            ),
            Text(
              task.description,
              maxLines: () {
                if (AppSize(context).height < 600) {
                  return 1;
                } else if (AppSize(context).height < 700) {
                  return 1;
                } else if (AppSize(context).height < 800) {
                  return 2;
                } else {
                  return 2;
                }
              }(),
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const Spacer(),
            Row(
              children: [
                Icon(
                  CupertinoIcons.calendar,
                  color: AppColors.textPrimary,
                  size: 20,
                ),
                const SizedBox(width: AppSpacing.sm),
                Text(
                  task.isDueToday ? 'Today' : daysAgo(task.createdAt),
                  style: AppTextStyles.bodyLarge.copyWith(
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
                    color: task.priority.color.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(AppBorderRadius.full),
                    border: Border.all(
                      color: task.priority.color.withValues(alpha: 0.5),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.flag,
                        size: 12,
                        color: task.priority.color,
                      ),
                      const SizedBox(width: AppSpacing.xs),
                      Text(
                        task.priority.label,
                        style: AppTextStyles.caption.copyWith(
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
              height: AppSpacing.xs,
            ),
          ],
        ),
      ),
    );
  }
}
