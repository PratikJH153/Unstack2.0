import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:provider/provider.dart';
import 'package:unstack/models/tasks/task.model.dart';
import 'package:unstack/providers/streak_provider.dart';
import 'package:unstack/providers/task_provider.dart';
import 'package:unstack/routes/route.dart';
import 'package:unstack/theme/theme.dart';
import 'package:unstack/widgets/buildScrollableWithFade.dart';
import 'package:unstack/widgets/delete_task_dialog.dart';
import 'package:unstack/widgets/task_card.dart';

class TaskList extends StatelessWidget {
  final List<Task> tasks;
  final IconData icon;
  final String title;
  final String description;
  final bool canReorder;
  final Function onTaskReorder;
  final bool showEdit;
  final bool updateStreak;

  const TaskList({
    required this.tasks,
    required this.icon,
    required this.title,
    required this.description,
    required this.canReorder,
    required this.onTaskReorder,
    required this.showEdit,
    this.updateStreak = true,
    super.key,
  });

  Future<void> _toggleTaskCompletion(
      BuildContext context, Task task, bool isCompleted) async {
    final taskProvider = Provider.of<TaskProvider>(context, listen: false);
    if (isCompleted) {
      await taskProvider.markTaskAsCompleted(task);
    } else {
      await taskProvider.markTaskAsIncomplete(task);
    }
    if (context.mounted && updateStreak) {
      final StreakProvider streakProvider =
          Provider.of<StreakProvider>(context, listen: false);

      streakProvider.updateStreak(
        taskProvider.totalTasksCount,
        taskProvider.completedTasksCount,
        taskProvider.todaysTasksCompleted,
      );
    }
    HapticFeedback.mediumImpact();
  }

  Future<void> _deleteTask(BuildContext context, Task task) async {
    final taskProvider = Provider.of<TaskProvider>(context, listen: false);
    await taskProvider.deleteTask(task.id);
    HapticFeedback.heavyImpact();
  }

  @override
  Widget build(BuildContext context) {
    if (tasks.isEmpty) {
      return noTasksWidget().scaleInStandard(
        delay: AnimationConstants.longDelay,
        scale: AnimationConstants.largeScale,
      );
    }

    return buildScrollableWithFade(
      child: ReorderableListView.builder(
        onReorder: (oldIndex, newIndex) => onTaskReorder(oldIndex, newIndex),
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
            startActionPane: ActionPane(
              motion: Padding(
                padding: const EdgeInsets.only(
                  top: 10.0,
                  bottom: 10,
                  right: 12,
                ),
                child: Row(
                  children: [
                    SlidableAction(
                      onPressed: (context) async {
                        HapticFeedback.heavyImpact();
                        await _toggleTaskCompletion(
                            context, task, !task.isCompleted);
                      },
                      backgroundColor: AppColors.accentGreen,
                      foregroundColor: AppColors.whiteColor,
                      borderRadius: BorderRadius.all(Radius.circular(24)),
                      icon: CupertinoIcons.check_mark,

                      // label: 'Edit',
                    ),
                  ],
                ),
              ),
              children: [],
            ),
            endActionPane: ActionPane(
              motion: Padding(
                padding: const EdgeInsets.only(
                  top: 10.0,
                  bottom: 10,
                  left: 12,
                ),
                child: Row(
                  children: [
                    if (showEdit)
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
                      onPressed: (_) async {
                        HapticFeedback.heavyImpact();
                        await showDeleteDialog(
                              context: context,
                              onDelete: () async {
                                _deleteTask(context, task);
                                if (context.mounted) {
                                  Navigator.of(context).pop(true);
                                }
                              },
                              title: 'Delete Task',
                              description:
                                  'Are you sure want to delete this task?',
                              buttonTitle: 'Delete',
                            ) ??
                            false;
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
                  _toggleTaskCompletion(context, task, isCompleted),
              onTap: () {
                RouteUtils.pushNamed(
                  context,
                  RoutePaths.taskDetailsPage,
                  arguments: {
                    'heroTag': 'task_${task.id}',
                    'taskID': task.id,
                  },
                );
              },
            ).slideUpStandard(),
          );
        },
      ),
    );
  }

  Center noTasksWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 64,
            color: AppColors.textMuted,
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            title,
            style: AppTextStyles.h3.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            description,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textMuted,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
