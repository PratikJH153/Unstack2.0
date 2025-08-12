class StreakModel {
  final DateTime date;
  final int totalTasks;
  final int completedTasks;
  final bool allTasksCompleted;

  const StreakModel({
    required this.date,
    required this.totalTasks,
    required this.completedTasks,
    required this.allTasksCompleted,
  });

  /// Completion percentage for the day (0.0 to 1.0)
  double get completionPercentage {
    if (totalTasks == 0) return 0.0;
    return completedTasks / totalTasks;
  }

  /// Convert to JSON for storage
  Map<String, dynamic> toJson() {
    return {
      'date': date.toIso8601String(),
      'totalTasks': totalTasks,
      'completedTasks': completedTasks,
      'allTasksCompleted': allTasksCompleted,
    };
  }

  /// Create from JSON
  factory StreakModel.fromJson(Map<String, dynamic> json) {
    return StreakModel(
      date: DateTime.parse(json['date']),
      totalTasks: json['totalTasks'],
      completedTasks: json['completedTasks'],
      allTasksCompleted: json['allTasksCompleted'],
    );
  }

  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is StreakModel &&
        _isSameDay(other.date, date) &&
        other.totalTasks == totalTasks &&
        other.completedTasks == completedTasks &&
        other.allTasksCompleted == allTasksCompleted;
  }

  @override
  int get hashCode {
    return Object.hash(
      date.year,
      date.month,
      date.day,
      totalTasks,
      completedTasks,
      allTasksCompleted,
    );
  }
}
