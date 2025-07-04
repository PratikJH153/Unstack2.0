import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:unstack/models/task.dart';
import 'package:unstack/routes/route.dart';
import 'package:unstack/theme/app_theme.dart';
import 'package:unstack/widgets/buildScrollableWithFade.dart';
import 'package:unstack/widgets/task_card.dart';
import 'package:unstack/widgets/home_app_bar_button.dart';
import 'package:unstack/routes/route_paths.dart';

class TasksListPage extends StatefulWidget {
  const TasksListPage({super.key});

  @override
  State<TasksListPage> createState() => _TasksListPageState();
}

class _TasksListPageState extends State<TasksListPage>
    with TickerProviderStateMixin {
  late List<Task> _allTasks;
  late List<Task> _remainingTasks;
  late List<Task> _completedTasks;
  bool isAnimationDone = false;

  TaskSortOption _currentSortOption = TaskSortOption.priority;
  bool _isAscending = false;

  @override
  void initState() {
    super.initState();

    _loadTasks();
  }

  void _loadTasks() {
    _allTasks = TaskData.getSampleTasks();
    _filterAndSortTasks();
  }

  void _filterAndSortTasks() {
    // Sort tasks
    _allTasks.sort((a, b) {
      int comparison = 0;
      switch (_currentSortOption) {
        case TaskSortOption.dateCreated:
          comparison = a.createdAt.compareTo(b.createdAt);
          break;
        case TaskSortOption.dueDate:
          if (a.dueDate == null && b.dueDate == null) {
            comparison = 0;
          } else if (a.dueDate == null) {
            comparison = 1;
          } else if (b.dueDate == null) {
            comparison = -1;
          } else {
            comparison = a.dueDate!.compareTo(b.dueDate!);
          }
          break;
        case TaskSortOption.priority:
          comparison = b.priority.index.compareTo(a.priority.index);
          break;
        case TaskSortOption.alphabetical:
          comparison = a.title.toLowerCase().compareTo(b.title.toLowerCase());
          break;
        case TaskSortOption.pomodoroCount:
          comparison = b.pomodoroCount.compareTo(a.pomodoroCount);
          break;
      }
      return _isAscending ? comparison : -comparison;
    });

    _remainingTasks = _allTasks.where((task) => !task.isCompleted).toList();
    _completedTasks = _allTasks.where((task) => task.isCompleted).toList();

    setState(() {});
  }

  void _toggleTaskCompletion(Task task, bool isCompleted) {
    final updatedTask = task.copyWith(isCompleted: isCompleted);
    final index = _allTasks.indexWhere((t) => t.id == task.id);
    if (index != -1) {
      _allTasks[index] = updatedTask;
      _filterAndSortTasks();
      HapticFeedback.mediumImpact();
    }
  }

  void _deleteTask(Task task) {
    _allTasks.removeWhere((t) => t.id == task.id);
    _filterAndSortTasks();
    HapticFeedback.heavyImpact();
  }

  void _showSortOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildSortBottomSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundPrimary,
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(
              height: AppSpacing.xxl,
            ),
            // Custom App Bar
            _buildAppBar(),

            // Remaining Tasks Tab
            ExpansionTile(
              initiallyExpanded: true,
              iconColor: AppColors.accentOrange,
              shape: InputBorder.none,
              title: Text('Remaining Tasks'),
              childrenPadding: EdgeInsets.zero,
              tilePadding: EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              children: [
                SizedBox(
                    height: MediaQuery.of(context).size.height * 0.65,
                    child: _buildTaskList(_remainingTasks, false))
              ],
            ),

            ExpansionTile(
              shape: InputBorder.none,
              tilePadding: EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              iconColor: AppColors.accentOrange,
              title: Text('Completed Tasks'),
              children: [
                SizedBox(
                    height: MediaQuery.of(context).size.height * 0.7,
                    child: _buildTaskList(_completedTasks, true))
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return Padding(
      padding: const EdgeInsets.only(
        left: AppSpacing.md,
        top: AppSpacing.lg,
        right: AppSpacing.md,
        bottom: AppSpacing.sm,
      ),
      child: Row(
        children: [
          // Back button
          HomeAppBarButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: CupertinoIcons.back,
          ),

          const SizedBox(width: AppSpacing.md),

          // Title
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Tasks',
                  style: AppTextStyles.h1.copyWith(
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                Text(
                  '${_remainingTasks.length} remaining, ${_completedTasks.length} completed',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),

          // Sort button
          HomeAppBarButton(
            onPressed: _showSortOptions,
            icon: CupertinoIcons.sort_down,
          ),

          const SizedBox(width: AppSpacing.md),

          // Add button
          HomeAppBarButton(
            onPressed: () {
              RouteUtils.pushNamed(context, RoutePaths.addTaskPage);
            },
            icon: CupertinoIcons.add,
          ),
        ],
      ),
    )
        .animate()
        .slideX(
          begin: 0.3,
          duration: 400.ms,
          curve: Curves.easeOut,
        )
        .fadeIn();
  }

  Widget _buildTaskList(List<Task> tasks, bool isCompletedList) {
    if (tasks.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isCompletedList
                  ? CupertinoIcons.check_mark_circled
                  : CupertinoIcons.circle,
              size: 64,
              color: AppColors.textMuted,
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              isCompletedList ? 'No completed tasks yet' : 'No remaining tasks',
              style: AppTextStyles.h3.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              isCompletedList
                  ? 'Complete some tasks to see them here'
                  : 'All tasks completed! Great job!',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textMuted,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      )
          .animate()
          .scale(
            begin: const Offset(0.8, 0.8),
            duration: 500.ms,
            curve: Curves.easeOut,
          )
          .fadeIn(delay: 400.ms);
    }

    return buildScrollableWithFade(
      child: ClipRRect(
        borderRadius: BorderRadiusGeometry.all(Radius.circular(24)),
        child: ReorderableListView.builder(
          onReorder: (oldIndex, newIndex) {
            setState(() {
              final task = _remainingTasks.elementAt(oldIndex);
              _remainingTasks.removeAt(oldIndex);
              _remainingTasks.insert(newIndex, task);
            });
          },
          padding: const EdgeInsets.only(
            bottom: AppSpacing.lg,
            top: AppSpacing.sm,
            // left: AppSpacing.md,
            // right: AppSpacing.md,
          ),
          buildDefaultDragHandles: true,
          proxyDecorator: (child, index, animation) {
            return Container(
              // margin: EdgeInsets.all(100),
              decoration: BoxDecoration(
                color: Colors.white12,
                borderRadius: BorderRadius.all(
                  Radius.circular(24),
                ),
              ),
              child: child,
            );
          },
          itemCount: tasks.length,
          itemBuilder: (context, index) {
            final task = tasks[index];
            return Dismissible(
                key: Key(task.id),
                direction: DismissDirection.endToStart,
                background: Container(
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: AppSpacing.xl),
                  margin: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: AppSpacing.xs,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.accentRed,
                    borderRadius: BorderRadius.circular(AppBorderRadius.xl),
                  ),
                  child: Icon(
                    CupertinoIcons.delete,
                    color: AppColors.whiteColor,
                    size: 24,
                  ),
                ),
                confirmDismiss: (direction) async {
                  HapticFeedback.heavyImpact();
                  return await showDialog<bool>(
                        context: context,
                        builder: (context) => AlertDialog(
                          backgroundColor: AppColors.surfaceCard,
                          shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(AppBorderRadius.xl),
                          ),
                          title: Text(
                            'Delete Task',
                            style: AppTextStyles.h3.copyWith(
                              color: AppColors.textPrimary,
                            ),
                          ),
                          content: Text(
                            'Are you sure you want to delete "${task.title}"?',
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(false),
                              child: Text(
                                'Cancel',
                                style:
                                    TextStyle(color: AppColors.textSecondary),
                              ),
                            ),
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(true),
                              child: Text(
                                'Delete',
                                style: TextStyle(color: AppColors.statusError),
                              ),
                            ),
                          ],
                        ),
                      ) ??
                      false;
                },
                onDismissed: (direction) => _deleteTask(task),
                child: TaskCard(
                  task: task,
                  onToggleComplete: (isCompleted) =>
                      _toggleTaskCompletion(task, isCompleted),
                  onTap: () {
                    Navigator.of(context).pushNamed(
                      RoutePaths.taskDetailsPage,
                      arguments: {
                        'heroTag': 'task_${task.id}',
                        'task': task,
                      },
                    );
                  },
                )
                    .animate(
                      autoPlay: !isAnimationDone,
                      onComplete: (controller) {
                        setState(() {
                          isAnimationDone = controller.isCompleted;
                        });
                      },
                    )
                    .slideX(
                      begin: isAnimationDone ? 0 : 0.3,
                      duration: Duration(milliseconds: 300 + (index * 50)),
                      curve: Curves.easeOut,
                    ));
          },
        ),
      ),
    );
  }

  Widget _buildSortBottomSheet() {
    return Container(
      margin: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppBorderRadius.xl),
        color: AppColors.backgroundSecondary,
        border: Border.all(
          color: AppColors.glassBorder,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 30,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(AppSpacing.lg),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: AppColors.glassBorder,
                  width: 1,
                ),
              ),
            ),
            child: Row(
              children: [
                Text(
                  'Sort Tasks',
                  style: AppTextStyles.h3.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  child: Icon(
                    CupertinoIcons.xmark_circle_fill,
                    color: AppColors.textMuted,
                    size: 24,
                  ),
                ),
              ],
            ),
          ),

          // Sort options
          ...TaskSortOption.values.map((option) {
            final isSelected = _currentSortOption == option;
            return ListTile(
              leading: Icon(
                _getSortIcon(option),
                color:
                    isSelected ? AppColors.accentPurple : AppColors.textMuted,
                size: 20,
              ),
              title: Text(
                option.label,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: isSelected
                      ? AppColors.accentPurple
                      : AppColors.textPrimary,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
              trailing: isSelected
                  ? GestureDetector(
                      onTap: () {
                        setState(() {
                          _isAscending = !_isAscending;
                        });
                        _filterAndSortTasks();
                      },
                      child: Icon(
                        _isAscending
                            ? CupertinoIcons.sort_up
                            : CupertinoIcons.sort_down,
                        color: AppColors.accentPurple,
                        size: 20,
                      ),
                    )
                  : null,
              onTap: () {
                setState(() {
                  _currentSortOption = option;
                });
                _filterAndSortTasks();
                Navigator.of(context).pop();
              },
            );
          }),

          const SizedBox(height: AppSpacing.lg),
        ],
      ),
    )
        .animate()
        .slideY(
          begin: 0.3,
          duration: 300.ms,
          curve: Curves.easeOut,
        )
        .fadeIn();
  }

  IconData _getSortIcon(TaskSortOption option) {
    switch (option) {
      case TaskSortOption.dateCreated:
        return CupertinoIcons.calendar;
      case TaskSortOption.dueDate:
        return CupertinoIcons.calendar_badge_plus;
      case TaskSortOption.priority:
        return CupertinoIcons.flag;
      case TaskSortOption.alphabetical:
        return CupertinoIcons.textformat_abc;
      case TaskSortOption.pomodoroCount:
        return CupertinoIcons.timer;
    }
  }
}
