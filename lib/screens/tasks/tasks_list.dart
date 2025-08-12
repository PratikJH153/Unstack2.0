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
  bool _isAscending = false;
  late TabController _tabController;

  @override
  void initState() {
    _tabController = TabController(length: 2, vsync: this);
    super.initState();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _getSortedTasks(List<Task> tasks) {
    final sortedTasks = tasks;
    sortedTasks.sort((a, b) {
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

    final taskProvider = Provider.of<TaskProvider>(context, listen: false);
    for (var task in sortedTasks) {
      task = task.copyWith(priorityIndex: sortedTasks.indexOf(task));
      taskProvider.updateTask(task);
    }
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
        final remainingTasks = taskProvider.tasks;
        final completedTasks = taskProvider.completedTasks;

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
                          tabs: const [
                            Tab(text: 'Remaining'),
                            Tab(text: 'Completed'),
                          ],
                        ),
                      ),
                      Expanded(
                        child:
                            TabBarView(controller: _tabController, children: [
                          Padding(
                            padding: const EdgeInsets.only(
                              left: AppSpacing.lg,
                              right: AppSpacing.lg,
                              top: AppSpacing.md,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                // IconButton(
                                //   onPressed: () {
                                //     _showSortOptions(remainingTasks);
                                //   },
                                //   icon: Icon(CupertinoIcons.sort_down),
                                // ),
                                Expanded(
                                  child: TaskList(
                                    tasks: remainingTasks,
                                    isCompletedList: false,
                                    onTaskReorder: (oldIndex, newIndex) {
                                      final task =
                                          remainingTasks.elementAt(oldIndex);
                                      setState(() {
                                        remainingTasks.removeAt(oldIndex);
                                        remainingTasks.insert(newIndex, task);
                                      });
                                      final newTasksList =
                                          remainingTasks.toList();
                                      for (var task in newTasksList) {
                                        task = task.copyWith(
                                          priorityIndex:
                                              newTasksList.indexOf(task),
                                        );
                                        taskProvider.updateTask(task);
                                      }
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(
                              left: AppSpacing.lg,
                              right: AppSpacing.lg,
                              top: AppSpacing.md,
                            ),
                            child: TaskList(
                              tasks: completedTasks,
                              isCompletedList: true,
                              onTaskReorder: (oldIndex, newIndex) {},
                            ),
                          ),
                        ]),
                      ),
                      // // Remaining Tasks Tab
                      // ExpansionTile(
                      //   initiallyExpanded: true,
                      //   iconColor: AppColors.accentOrange,
                      //   shape: RoundedRectangleBorder(
                      //     borderRadius:
                      //         BorderRadius.circular(AppBorderRadius.lg),
                      //   ),
                      //   title: Row(
                      //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      //     children: [
                      //       Text('Remaining Tasks'),
                      //       IconButton(
                      //           onPressed: () {
                      //             _showSortOptions(remainingTasks);
                      //           },
                      //           icon: Icon(CupertinoIcons.sort_down))
                      //     ],
                      //   ),
                      //   childrenPadding: EdgeInsets.zero,
                      //   tilePadding: EdgeInsets.zero,
                      //   children: [
                      //     SizedBox(
                      //       height: MediaQuery.of(context).size.height * 0.6,
                      //       child: TaskList(
                      //         tasks: remainingTasks,
                      //         isCompletedList: false,
                      //         onTaskReorder: (oldIndex, newIndex) {
                      //           final task =
                      //               remainingTasks.elementAt(oldIndex);
                      //           setState(() {
                      //             remainingTasks.removeAt(oldIndex);
                      //             remainingTasks.insert(newIndex, task);
                      //           });
                      //           final newTasksList = remainingTasks.toList();
                      //           for (var task in newTasksList) {
                      //             task = task.copyWith(
                      //               priorityIndex: newTasksList.indexOf(task),
                      //             );
                      //             taskProvider.updateTask(task);
                      //           }
                      //         },
                      //       ),
                      //     )
                      //   ],
                      // ),

                      // // Completed Tasks Tab
                      // ExpansionTile(
                      //   initiallyExpanded: false,
                      //   shape: RoundedRectangleBorder(
                      //     borderRadius:
                      //         BorderRadius.circular(AppBorderRadius.lg),
                      //   ),
                      //   childrenPadding: EdgeInsets.zero,
                      //   tilePadding: EdgeInsets.zero,
                      //   iconColor: AppColors.accentOrange,
                      //   title: Text('Completed Tasks'),
                      //   children: [
                      //     SizedBox(
                      //       height: MediaQuery.of(context).size.height * 0.65,
                      //       child: TaskList(
                      //         tasks: completedTasks,
                      //         isCompletedList: true,
                      //         onTaskReorder: (oldIndex, newIndex) {},
                      //       ),
                      //     )
                      //   ],
                      // ),
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
      case TaskSortOption.alphabetical:
        return CupertinoIcons.textformat_abc;
    }
  }
}
