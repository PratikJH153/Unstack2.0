import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:provider/provider.dart';
import 'package:unstack/models/tasks/task.model.dart';
import 'package:unstack/providers/task_provider.dart';
import 'package:unstack/routes/route.dart';
import 'package:unstack/theme/theme.dart';
import 'package:unstack/widgets/buildScrollableWithFade.dart';
import 'package:unstack/widgets/delete_task_dialog.dart';
import 'package:unstack/widgets/task_card.dart';

class TaskList extends StatefulWidget {
  final List<Task> tasks;
  final bool isCompletedList;
  final Function onTaskReorder;
  const TaskList(
      {required this.tasks,
      required this.isCompletedList,
      required this.onTaskReorder,
      super.key});

  @override
  State<TaskList> createState() => _TaskListState();
}

class _TaskListState extends State<TaskList> {
  Future<void> _toggleTaskCompletion(Task task, bool isCompleted) async {
    final taskProvider = Provider.of<TaskProvider>(context, listen: false);
    if (isCompleted) {
      await taskProvider.markTaskAsCompleted(task);
    } else {
      await taskProvider.markTaskAsIncomplete(task);
    }
    HapticFeedback.mediumImpact();
  }

  Future<void> _deleteTask(Task task) async {
    final taskProvider = Provider.of<TaskProvider>(context, listen: false);
    await taskProvider.deleteTask(task.id);
    HapticFeedback.heavyImpact();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.tasks.isEmpty) {
      return noTasksWidget().scaleInStandard(
        delay: AnimationConstants.longDelay,
        scale: AnimationConstants.largeScale,
      );
    }

    return buildScrollableWithFade(
      child: ReorderableListView.builder(
        onReorder: (oldIndex, newIndex) =>
            widget.onTaskReorder(oldIndex, newIndex),
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
        itemCount: widget.tasks.length,
        itemBuilder: (context, index) {
          final task = widget.tasks[index];
          return Slidable(
            key: Key(task.id),
            startActionPane: ActionPane(
              motion: const ScrollMotion(),
              children: [
                SlidableAction(
                  onPressed: (context) async {
                    HapticFeedback.heavyImpact();
                    await _toggleTaskCompletion(task, !task.isCompleted);
                  },
                  backgroundColor: AppColors.accentGreen,
                  foregroundColor: AppColors.whiteColor,
                  borderRadius: BorderRadius.all(Radius.circular(24)),
                  icon: CupertinoIcons.check_mark,

                  // label: 'Edit',
                ),
              ],
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
                    if (!widget.isCompletedList)
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
                                _deleteTask(task);
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
                  _toggleTaskCompletion(task, isCompleted),
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
            widget.isCompletedList
                ? CupertinoIcons.check_mark_circled
                : CupertinoIcons.circle,
            size: 64,
            color: AppColors.textMuted,
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            widget.isCompletedList
                ? 'No completed tasks yet'
                : 'No remaining tasks',
            style: AppTextStyles.h3.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            widget.isCompletedList
                ? 'Complete some tasks to see them here'
                : 'All tasks completed! Great job!',
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
