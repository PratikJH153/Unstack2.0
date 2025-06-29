import 'package:flutter/material.dart';

enum TaskPriority {
  low,
  medium,
  high,
  urgent;

  Color get color {
    switch (this) {
      case TaskPriority.low:
        return const Color(0xFF10B981); // Green
      case TaskPriority.medium:
        return const Color(0xFFF59E0B); // Yellow
      case TaskPriority.high:
        return const Color(0xFFF97316); // Orange
      case TaskPriority.urgent:
        return const Color(0xFFEF4444); // Red
    }
  }

  String get label {
    switch (this) {
      case TaskPriority.low:
        return 'Low';
      case TaskPriority.medium:
        return 'Medium';
      case TaskPriority.high:
        return 'High';
      case TaskPriority.urgent:
        return 'Urgent';
    }
  }

  IconData get icon {
    switch (this) {
      case TaskPriority.low:
        return Icons.flag;
      case TaskPriority.medium:
        return Icons.flag;
      case TaskPriority.high:
        return Icons.flag;
      case TaskPriority.urgent:
        return Icons.flag;
    }
  }
}

enum TaskSortOption {
  dateCreated,
  dueDate,
  priority,
  alphabetical,
  pomodoroCount;

  String get label {
    switch (this) {
      case TaskSortOption.dateCreated:
        return 'Date Created';
      case TaskSortOption.dueDate:
        return 'Due Date';
      case TaskSortOption.priority:
        return 'Priority';
      case TaskSortOption.alphabetical:
        return 'Alphabetical';
      case TaskSortOption.pomodoroCount:
        return 'Pomodoro Count';
    }
  }
}

class Task {
  final String id;
  final String title;
  final String description;
  final TaskPriority priority;
  final DateTime createdAt;
  final DateTime? dueDate;
  final bool isCompleted;
  final int pomodoroCount;
  final int estimatedPomodoros;
  final List<String> tags;
  final Color? customColor;

  const Task({
    required this.id,
    required this.title,
    required this.description,
    required this.priority,
    required this.createdAt,
    this.dueDate,
    this.isCompleted = false,
    this.pomodoroCount = 0,
    this.estimatedPomodoros = 1,
    this.tags = const [],
    this.customColor,
  });

  Task copyWith({
    String? id,
    String? title,
    String? description,
    TaskPriority? priority,
    DateTime? createdAt,
    DateTime? dueDate,
    bool? isCompleted,
    int? pomodoroCount,
    int? estimatedPomodoros,
    List<String>? tags,
    Color? customColor,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      priority: priority ?? this.priority,
      createdAt: createdAt ?? this.createdAt,
      dueDate: dueDate ?? this.dueDate,
      isCompleted: isCompleted ?? this.isCompleted,
      pomodoroCount: pomodoroCount ?? this.pomodoroCount,
      estimatedPomodoros: estimatedPomodoros ?? this.estimatedPomodoros,
      tags: tags ?? this.tags,
      customColor: customColor ?? this.customColor,
    );
  }

  bool get isOverdue {
    if (dueDate == null || isCompleted) return false;
    return DateTime.now().isAfter(dueDate!);
  }

  bool get isDueToday {
    if (dueDate == null) return false;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final taskDueDate = DateTime(dueDate!.year, dueDate!.month, dueDate!.day);
    return today.isAtSameMomentAs(taskDueDate);
  }

  bool get isDueSoon {
    if (dueDate == null || isCompleted) return false;
    final now = DateTime.now();
    final difference = dueDate!.difference(now).inDays;
    return difference <= 3 && difference >= 0;
  }

  double get progressPercentage {
    if (estimatedPomodoros == 0) return 0.0;
    return (pomodoroCount / estimatedPomodoros).clamp(0.0, 1.0);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Task && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'Task(id: $id, title: $title, isCompleted: $isCompleted, priority: $priority)';
  }
}

// Sample data for development and testing
class TaskData {
  static List<Task> getSampleTasks() {
    return [
      Task(
        id: '1',
        title: 'Build Unstack App',
        description:
            'Complete the task management and Pomodoro timer app with glassmorphism design',
        priority: TaskPriority.urgent,
        createdAt: DateTime.now().subtract(const Duration(days: 2)),
        dueDate: DateTime.now().add(const Duration(days: 1)),
        pomodoroCount: 2,
        estimatedPomodoros: 5,
        tags: ['development', 'flutter', 'urgent'],
      ),
      Task(
        id: '2',
        title: 'Design System Documentation',
        description:
            'Document the design system and component library for future reference',
        priority: TaskPriority.medium,
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
        dueDate: DateTime.now().add(const Duration(days: 3)),
        pomodoroCount: 1,
        estimatedPomodoros: 3,
        tags: ['documentation', 'design'],
      ),
      // Task(
      //   id: '3',
      //   title: 'User Testing Session',
      //   description:
      //       'Conduct user testing sessions to gather feedback on the app interface',
      //   priority: TaskPriority.high,
      //   createdAt: DateTime.now().subtract(const Duration(hours: 12)),
      //   dueDate: DateTime.now().add(const Duration(days: 2)),
      //   pomodoroCount: 0,
      //   estimatedPomodoros: 2,
      //   tags: ['testing', 'ux'],
      // ),
      // Task(
      //   id: '4',
      //   title: 'Code Review',
      //   description:
      //       'Review pull requests and provide feedback to team members',
      //   priority: TaskPriority.low,
      //   createdAt: DateTime.now().subtract(const Duration(hours: 6)),
      //   pomodoroCount: 1,
      //   estimatedPomodoros: 1,
      //   tags: ['review', 'team'],
      // ),
      // Task(
      //   id: '5',
      //   title: 'Update Dependencies',
      //   description:
      //       'Update all Flutter dependencies to latest stable versions',
      //   priority: TaskPriority.medium,
      //   createdAt: DateTime.now().subtract(const Duration(days: 3)),
      //   pomodoroCount: 1,
      //   estimatedPomodoros: 1,
      //   tags: ['maintenance', 'flutter'],
      // ),
      // Task(
      //   id: '6',
      //   title: 'Write Unit Tests',
      //   description: 'Add comprehensive unit tests for core',
      //   priority: TaskPriority.high,
      //   createdAt: DateTime.now().subtract(const Duration(days: 4)),
      //   pomodoroCount: 3,
      //   estimatedPomodoros: 3,
      //   tags: ['testing', 'quality'],
      // ),
    ];
  }
}
