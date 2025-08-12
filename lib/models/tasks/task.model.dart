import 'package:flutter/material.dart';

final priorityIndex = {
  'low': 3,
  'medium': 2,
  'high': 1,
  'urgent': 0,
};

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
}

enum TaskSortOption {
  dateCreated,
  priority,
  alphabetical;

  String get label {
    switch (this) {
      case TaskSortOption.dateCreated:
        return 'Time Created';
      case TaskSortOption.priority:
        return 'Priority';
      case TaskSortOption.alphabetical:
        return 'Alphabetical';
    }
  }
}

class Task {
  final String id;
  final String title;
  final String description;
  final TaskPriority priority;
  final DateTime createdAt;
  final bool isCompleted;
  final int priorityIndex;

  const Task({
    required this.id,
    required this.title,
    required this.description,
    required this.priority,
    required this.createdAt,
    required this.priorityIndex,
    this.isCompleted = false,
  });

  Task copyWith({
    String? id,
    String? title,
    String? description,
    TaskPriority? priority,
    DateTime? createdAt,
    int? priorityIndex,
    bool? isCompleted,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      priority: priority ?? this.priority,
      createdAt: createdAt ?? this.createdAt,
      priorityIndex: priorityIndex ?? this.priorityIndex,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }

  factory Task.fromJson(Map<String, dynamic> json) {
    final id = json['id'] ?? '';
    final title = json['title'] ?? '';
    final description = json['description'] ?? '';
    final priority = TaskPriority.values.firstWhere(
      (e) => e.toString() == 'TaskPriority.${json['priority']}',
    );
    final createdAt = DateTime.parse(json['createdAt']);
    final isCompleted = json['isCompleted'] == 1 ? true : false;
    final priorityIndex = json['priorityIndex'] ?? 0;

    return Task(
      id: id,
      title: title,
      description: description,
      priority: priority,
      createdAt: createdAt,
      priorityIndex: priorityIndex,
      isCompleted: isCompleted,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'priority': priority.name,
      'createdAt': createdAt.toIso8601String(),
      'priorityIndex': priorityIndex,
      'isCompleted': isCompleted ? 1 : 0,
    };
  }

  bool get isDueToday {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final taskDueDate =
        DateTime(createdAt.year, createdAt.month, createdAt.day);
    return today.isAtSameMomentAs(taskDueDate);
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
    return 'Task(id: $id, title: $title, isCompleted: $isCompleted, priority: $priority createdAt: $createdAt priorityIndex: $priorityIndex)';
  }
}
