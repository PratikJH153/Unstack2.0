import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:unstack/models/tasks/task.model.dart';
import 'package:unstack/providers/task_provider.dart';
import 'package:unstack/routes/route.dart';
import 'package:unstack/theme/theme.dart';
import 'package:unstack/views/tasks/task_list.dart';
import 'package:unstack/widgets/home_app_bar_button.dart';

class TasksListPage extends StatefulWidget {
  const TasksListPage({super.key});

  @override
  State<TasksListPage> createState() => _TasksListPageState();
}

class _TasksListPageState extends State<TasksListPage>
    with SingleTickerProviderStateMixin {
  TaskSortOption _currentSortOption = TaskSortOption.priority;
  late TabController _tabController;

  @override
  void initState() {
    _tabController = TabController(length: 3, vsync: this);
    super.initState();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _getSortedTasks(List<Task> tasks) {
    final sortedTasks = List<Task>.from(tasks);
    sortedTasks.sort((a, b) {
      int comparison = 0;
      switch (_currentSortOption) {
        case TaskSortOption.dateCreated:
          comparison = a.createdAt.compareTo(b.createdAt);
          break;

        case TaskSortOption.priority:
          comparison = a.priority.index.compareTo(b.priority.index);
          break;
      }
      return -comparison;
    });

    final taskProvider = Provider.of<TaskProvider>(context, listen: false);
    // Use optimized batch update method
    taskProvider.applySortOrder(sortedTasks);
  }

  void _reorderTasks(TaskProvider taskProvider, int oldIndex, int newIndex) {
    // Use the optimized reorder method from TaskProvider
    taskProvider.reorderTasks(oldIndex, newIndex);
  }

  void _showSortOptions(List<Task> remainingTasks) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildSortBottomSheet(remainingTasks),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<TaskProvider>(
      builder: (context, taskProvider, child) {
        final remainingTasks = taskProvider.remainingTasks;
        final completedTasks = taskProvider.completedTasks;
        final pendingTasks = taskProvider.pendingTasks;

        return Scaffold(
          backgroundColor: AppColors.backgroundPrimary,
          body: SafeArea(
            child: Column(
              children: [
                _buildAppBar(remainingTasks),
                Expanded(
                  child: Column(
                    children: [
                      Container(
                        margin: EdgeInsets.only(left: AppSpacing.lg),
                        alignment: Alignment.centerLeft,
                        child: TabBar(
                          isScrollable: true,
                          dividerHeight: 0,
                          tabAlignment: TabAlignment.start,
                          indicatorWeight: 5,
                          physics: const NeverScrollableScrollPhysics(),
                          controller: _tabController,
                          labelColor: AppColors.textPrimary,
                          unselectedLabelColor: AppColors.textMuted,
                          indicatorColor: AppColors.whiteColor,
                          splashBorderRadius: BorderRadius.all(
                            Radius.circular(
                              AppBorderRadius.lg,
                            ),
                          ),
                          overlayColor:
                              WidgetStateProperty.all(Colors.transparent),
                          tabs: [
                            Tab(text: 'Remaining'),
                            Tab(text: 'Completed'),
                            Stack(
                              children: [
                                Positioned(
                                  top: 5,
                                  right: 1,
                                  child: Text(
                                    pendingTasks.length.toString(),
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w900,
                                      color: AppColors.accentOrange,
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  width: 80,
                                  child: Tab(text: 'Pending'),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(
                            left: AppSpacing.lg,
                            right: AppSpacing.lg,
                            top: AppSpacing.md,
                          ),
                          child:
                              TabBarView(controller: _tabController, children: [
                            TaskList(
                              tasks: remainingTasks,
                              showEdit: true,
                              onTaskReorder: (oldIndex, newIndex) {
                                _reorderTasks(taskProvider, oldIndex, newIndex);
                              },
                              icon: CupertinoIcons.circle,
                              title: 'No remaining tasks',
                              description: 'All tasks completed! Great job!',
                              canReorder: true,
                            ),
                            TaskList(
                              tasks: completedTasks,
                              showEdit: false,
                              onTaskReorder: (oldIndex, newIndex) {},
                              canReorder: false,
                              icon: CupertinoIcons.check_mark_circled,
                              title: 'No completed tasks yet',
                              description:
                                  'Complete some tasks to see them here',
                            ),
                            TaskList(
                              tasks: pendingTasks,
                              showEdit: true,
                              onTaskReorder: (oldIndex, newIndex) {},
                              canReorder: false,
                              icon: CupertinoIcons.exclamationmark_circle,
                              title: 'No pending tasks',
                              description: 'All tasks completed! Great job!',
                            ),
                          ]),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildAppBar(List<Task> remainingTasks) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.lg).copyWith(bottom: 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Back button
          HomeAppBarButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: CupertinoIcons.back,
          ),

          // Add button
          Row(
            children: [
              HomeAppBarButton(
                onPressed: () {
                  _showSortOptions(remainingTasks);
                },
                icon: CupertinoIcons.sort_down,
              ),
              const SizedBox(width: AppSpacing.md),
              HomeAppBarButton(
                onPressed: () {
                  RouteUtils.pushNamed(context, RoutePaths.addTaskPage);
                },
                icon: CupertinoIcons.add,
              ),
            ],
          ),
        ],
      ),
    ).slideUpStandard();
  }

  Widget _buildSortBottomSheet(List<Task> remainingTasks) {
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
            return ListTile(
              leading: Icon(
                _getSortIcon(option),
                color: AppColors.textPrimary,
                size: 20,
              ),
              title: Text(
                option.label,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              onTap: () {
                setState(() {
                  _currentSortOption = option;
                });
                _getSortedTasks(remainingTasks);
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
    }
  }
}
