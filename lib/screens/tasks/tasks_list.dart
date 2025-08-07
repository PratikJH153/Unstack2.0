import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:unstack/models/tasks/task.model.dart';
import 'package:unstack/routes/route.dart';
import 'package:unstack/theme/theme.dart';
import 'package:unstack/widgets/buildScrollableWithFade.dart';
import 'package:unstack/widgets/task_card.dart';
import 'package:unstack/widgets/home_app_bar_button.dart';

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

        case TaskSortOption.priority:
          comparison = a.priority.index.compareTo(b.priority.index);
          break;
        case TaskSortOption.alphabetical:
          comparison = b.title.toLowerCase().compareTo(a.title.toLowerCase());
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
      body: SafeArea(
        child: Column(
          children: [
            _buildAppBar(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                child: Column(
                  children: [
                    // Remaining Tasks Tab
                    ExpansionTile(
                      initiallyExpanded: true,
                      iconColor: AppColors.accentOrange,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppBorderRadius.lg),
                      ),
                      title: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Remaining Tasks'),
                          IconButton(
                              onPressed: () {
                                _showSortOptions();
                              },
                              icon: Icon(CupertinoIcons.sort_down))
                        ],
                      ),
                      childrenPadding: EdgeInsets.zero,
                      tilePadding: EdgeInsets.zero,
                      children: [
                        SizedBox(
                          height: MediaQuery.of(context).size.height * 0.65,
                          child: _buildTaskList(
                            _remainingTasks,
                            false,
                          ),
                        )
                      ],
                    ),

                    ExpansionTile(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppBorderRadius.lg),
                      ),
                      childrenPadding: EdgeInsets.zero,
                      tilePadding: EdgeInsets.zero,
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
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.lg).copyWith(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Back button
          HomeAppBarButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: CupertinoIcons.back,
          ),

          // Add button
          HomeAppBarButton(
            onPressed: () {
              RouteUtils.pushNamed(context, RoutePaths.addTaskPage);
            },
            icon: CupertinoIcons.add,
          ),
        ],
      ),
    ).slideUpStandard();
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
      ).scaleInStandard(
        delay: AnimationConstants.longDelay,
        scale: AnimationConstants.largeScale,
      );
    }

    return buildScrollableWithFade(
      child: ClipRRect(
        borderRadius:
            BorderRadiusGeometry.all(Radius.circular(AppBorderRadius.lg)),
        child: ReorderableListView.builder(
          onReorder: (oldIndex, newIndex) {
            // setState(() {
            //   final task = _remainingTasks.elementAt(oldIndex);
            //   _remainingTasks.removeAt(oldIndex);
            //   _remainingTasks.insert(newIndex, task);
            // });
          },
          padding: const EdgeInsets.only(
            bottom: AppSpacing.lg,
          ),
          proxyDecorator: (child, index, animation) {
            return Container(
              // margin: EdgeInsets.all(100),
              decoration: BoxDecoration(
                color: AppColors.surfaceCard,
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
            return Slidable(
                key: Key(task.id),
                endActionPane: ActionPane(
                  motion: Padding(
                    padding: const EdgeInsets.only(
                      top: 10.0,
                      bottom: 10,
                      left: 12,
                    ),
                    child: Row(
                      children: [
                        SlidableAction(
                          onPressed: (context) async {
                            HapticFeedback.heavyImpact();
                            RouteUtils.pushNamed(
                              context,
                              RoutePaths.addTaskPage,
                              arguments: {
                                'task': task,
                                'fromTaskDetails': true,
                                'edit': true,
                              },
                            );
                          },
                          backgroundColor: AppColors.backgroundSecondary,
                          foregroundColor: AppColors.whiteColor,
                          borderRadius: BorderRadius.all(Radius.circular(24)),
                          icon: CupertinoIcons.pencil,

                          // label: 'Edit',
                        ),
                        const SizedBox(
                          width: AppSpacing.xs,
                        ),
                        SlidableAction(
                          onPressed: (context) async {
                            HapticFeedback.heavyImpact();
                            final result = await showDialog<bool>(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    backgroundColor: AppColors.surfaceCard,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(
                                          AppBorderRadius.xxl),
                                    ),
                                    title: Text(
                                      'Delete Task',
                                      style: AppTextStyles.h3.copyWith(
                                        color: AppColors.textPrimary,
                                      ),
                                    ),
                                    content: Text(
                                      'Are you sure you want to delete this task?',
                                      style: AppTextStyles.bodyMedium.copyWith(
                                        color: AppColors.textSecondary,
                                      ),
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () =>
                                            Navigator.of(context).pop(false),
                                        child: Text(
                                          'Cancel',
                                          style: TextStyle(
                                              color: AppColors.textSecondary),
                                        ),
                                      ),
                                      TextButton(
                                        onPressed: () =>
                                            Navigator.of(context).pop(true),
                                        child: Text(
                                          'Delete',
                                          style: TextStyle(
                                              color: AppColors.statusError),
                                        ),
                                      ),
                                    ],
                                  ),
                                ) ??
                                false;
                            if (result) {
                              _deleteTask(task);
                            }
                          },
                          backgroundColor: AppColors.redShade,
                          foregroundColor: AppColors.whiteColor,
                          borderRadius: BorderRadius.all(Radius.circular(24)),
                          icon: CupertinoIcons.delete,
                          // label: 'Delete',
                        ),
                      ],
                    ),
                  ),
                  children: [],
                ),
                child: TaskCard(
                  task: task,
                  onToggleComplete: (isCompleted) =>
                      _toggleTaskCompletion(task, isCompleted),
                  onTap: () {
                    RouteUtils.pushNamed(
                      context,
                      RoutePaths.taskDetailsPage,
                      arguments: {
                        'heroTag': 'task_${task.id}',
                        'task': task,
                      },
                    );
                  },
                ).staggeredList(index));
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
    ).slideUpStandard();
  }

  IconData _getSortIcon(TaskSortOption option) {
    switch (option) {
      case TaskSortOption.dateCreated:
        return CupertinoIcons.calendar;
      case TaskSortOption.priority:
        return CupertinoIcons.flag;
      case TaskSortOption.alphabetical:
        return CupertinoIcons.textformat_abc;
    }
  }
}
