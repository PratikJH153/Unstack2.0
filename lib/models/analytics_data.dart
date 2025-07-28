import 'package:unstack/models/task.model.dart';

/// Represents analytics data for a specific task
class TaskAnalytics {
  final String taskId;
  final String taskTitle;
  // COMMENTED OUT - Pomodoro functionality
  // final int completedPomodoros;
  final TaskPriority priority;
  final bool isCompleted;

  const TaskAnalytics({
    required this.taskId,
    required this.taskTitle,
    // COMMENTED OUT - Pomodoro functionality
    // required this.completedPomodoros,
    required this.priority,
    required this.isCompleted,
  });

  factory TaskAnalytics.fromTask(Task task) {
    return TaskAnalytics(
      taskId: task.id,
      taskTitle: task.title,
      // COMMENTED OUT - Pomodoro functionality
      // completedPomodoros: task.pomodoroCount,
      priority: task.priority,
      isCompleted: task.isCompleted,
    );
  }

  // COMMENTED OUT - Pomodoro functionality
  // /// Total time invested in minutes (25 minutes per Pomodoro)
  // int get totalTimeInMinutes => completedPomodoros * 25;

  // COMMENTED OUT - Pomodoro functionality
  // /// Total time invested in hours and minutes format
  // String get formattedTime {
  //   final hours = totalTimeInMinutes ~/ 60;
  //   final minutes = totalTimeInMinutes % 60;
  //   if (hours > 0) {
  //     return '${hours}h ${minutes}m';
  //   }
  //   return '${minutes}m';
  // }
}

/// Represents daily analytics summary
class DailyAnalytics {
  final DateTime date;
  // COMMENTED OUT - Pomodoro functionality
  // final int totalPomodoros;
  // final int totalTimeInMinutes;
  final int completedTasks;
  final int totalTasks;
  final List<TaskAnalytics> taskBreakdown;

  const DailyAnalytics({
    required this.date,
    // COMMENTED OUT - Pomodoro functionality
    // required this.totalPomodoros,
    // required this.totalTimeInMinutes,
    required this.completedTasks,
    required this.totalTasks,
    required this.taskBreakdown,
  });

  // COMMENTED OUT - Pomodoro functionality
  // /// Total time invested formatted as hours and minutes
  // String get formattedTotalTime {
  //   final hours = totalTimeInMinutes ~/ 60;
  //   final minutes = totalTimeInMinutes % 60;
  //   if (hours > 0) {
  //     return '${hours}h ${minutes}m';
  //   }
  //   return '${minutes}m';
  // }

  /// Task completion percentage
  double get taskCompletionPercentage {
    if (totalTasks == 0) return 0.0;
    return completedTasks / totalTasks;
  }
}

/// Represents weekly comparison analytics
class WeeklyComparison {
  final DailyAnalytics currentWeek;
  final DailyAnalytics previousWeek;

  const WeeklyComparison({
    required this.currentWeek,
    required this.previousWeek,
  });

  // COMMENTED OUT - Pomodoro functionality
  // /// Percentage change in total Pomodoros
  // double get pomodoroChange {
  //   if (previousWeek.totalPomodoros == 0) {
  //     return currentWeek.totalPomodoros > 0 ? 100.0 : 0.0;
  //   }
  //   return ((currentWeek.totalPomodoros - previousWeek.totalPomodoros) /
  //           previousWeek.totalPomodoros) *
  //       100;
  // }

  // /// Percentage change in total time
  // double get timeChange {
  //   if (previousWeek.totalTimeInMinutes == 0) {
  //     return currentWeek.totalTimeInMinutes > 0 ? 100.0 : 0.0;
  //   }
  //   return ((currentWeek.totalTimeInMinutes - previousWeek.totalTimeInMinutes) /
  //           previousWeek.totalTimeInMinutes) *
  //       100;
  // }

  /// Percentage change in completion rate
  double get completionRateChange {
    if (previousWeek.taskCompletionPercentage == 0) {
      return currentWeek.taskCompletionPercentage > 0 ? 100.0 : 0.0;
    }
    return ((currentWeek.taskCompletionPercentage -
                previousWeek.taskCompletionPercentage) /
            previousWeek.taskCompletionPercentage) *
        100;
  }

  /// Whether the current week shows improvement
  bool get isImproving => completionRateChange > 0;
}

/// Analytics calculator utility class
class AnalyticsCalculator {
  /// Calculate today's analytics from current tasks
  static DailyAnalytics calculateTodayAnalytics(List<Task> tasks) {
    final today = DateTime.now();
    final taskAnalytics =
        tasks.map((task) => TaskAnalytics.fromTask(task)).toList();

    final completedTasks = tasks.where((task) => task.isCompleted).length;
    taskAnalytics.sort(
        (a, b) => (a.isCompleted ? 1 : 0).compareTo((b.isCompleted ? 1 : 0)));
    return DailyAnalytics(
      date: today,
      completedTasks: completedTasks,
      totalTasks: tasks.length,
      taskBreakdown: taskAnalytics,
    );
  }

  /// Calculate weekly analytics (mock data for now - in real app would use historical data)
  static WeeklyComparison calculateWeeklyComparison(List<Task> currentTasks) {
    final currentWeek = calculateTodayAnalytics(currentTasks);

    // Mock previous week data (in real app, this would come from stored historical data)
    final previousWeekTasks = _generateMockPreviousWeekData();
    final previousWeek = DailyAnalytics(
      date: DateTime.now().subtract(const Duration(days: 7)),
      completedTasks:
          previousWeekTasks.where((task) => task.isCompleted).length,
      totalTasks: previousWeekTasks.length,
      taskBreakdown: previousWeekTasks
          .map((task) => TaskAnalytics.fromTask(task))
          .toList(),
    );

    return WeeklyComparison(
      currentWeek: currentWeek,
      previousWeek: previousWeek,
    );
  }

  /// Generate mock previous week data for demonstration
  static List<Task> _generateMockPreviousWeekData() {
    return [
      Task(
        id: 'prev_1',
        title: 'Previous Week Task 1',
        description: 'Mock task from previous week',
        priority: TaskPriority.medium,
        createdAt: DateTime.now().subtract(const Duration(days: 8)),
        // COMMENTED OUT - Pomodoro functionality
        // pomodoroCount: 1,
        isCompleted: true,
      ),
      Task(
        id: 'prev_2',
        title: 'Previous Week Task 2',
        description: 'Another mock task from previous week',
        priority: TaskPriority.high,
        createdAt: DateTime.now().subtract(const Duration(days: 9)),
        // COMMENTED OUT - Pomodoro functionality
        // pomodoroCount: 2,
        isCompleted: false,
      ),
    ];
  }
}
