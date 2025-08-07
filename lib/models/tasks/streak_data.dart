import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:unstack/models/tasks/task.model.dart';

/// Represents a single day's task completion data
class DayCompletionData {
  final DateTime date;
  final int totalTasks;
  final int completedTasks;
  final bool allTasksCompleted;

  const DayCompletionData({
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
  factory DayCompletionData.fromJson(Map<String, dynamic> json) {
    return DayCompletionData(
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
    return other is DayCompletionData &&
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

/// Manages streak tracking and statistics
class StreakTracker {
  static const String _storageKey = 'streak_completion_data';

  List<DayCompletionData> _completionHistory = [];

  /// Get all completion history
  List<DayCompletionData> get completionHistory =>
      List.unmodifiable(_completionHistory);

  /// Calculate current streak (consecutive days of completing all tasks)
  int get currentStreak {
    if (_completionHistory.isEmpty) return 0;

    // Sort by date descending (most recent first)
    final sortedHistory = List<DayCompletionData>.from(_completionHistory)
      ..sort((a, b) => b.date.compareTo(a.date));

    int streak = 0;
    final today = DateTime.now();

    // Check if today has all tasks completed
    final todayData = sortedHistory.firstWhere(
      (data) => _isSameDay(data.date, today),
      orElse: () => DayCompletionData(
        date: today,
        totalTasks: 0,
        completedTasks: 0,
        allTasksCompleted: false,
      ),
    );

    // Start counting from today if all tasks are completed
    if (todayData.allTasksCompleted) {
      streak = 1;

      // Count backwards for consecutive completed days
      for (int i = 1; i < sortedHistory.length; i++) {
        final currentDay = sortedHistory[i];
        final expectedDate = today.subtract(Duration(days: i));

        if (_isSameDay(currentDay.date, expectedDate) &&
            currentDay.allTasksCompleted) {
          streak++;
        } else {
          break;
        }
      }
    }

    return streak;
  }

  /// Calculate longest streak ever achieved
  int get longestStreak {
    if (_completionHistory.isEmpty) return 0;

    // Sort by date ascending
    final sortedHistory = List<DayCompletionData>.from(_completionHistory)
      ..sort((a, b) => a.date.compareTo(b.date));

    int maxStreak = 0;
    int currentStreakCount = 0;
    DateTime? lastDate;

    for (final data in sortedHistory) {
      if (data.allTasksCompleted) {
        if (lastDate == null || _isConsecutiveDay(lastDate, data.date)) {
          currentStreakCount++;
          maxStreak =
              maxStreak > currentStreakCount ? maxStreak : currentStreakCount;
        } else {
          currentStreakCount = 1;
        }
        lastDate = data.date;
      } else {
        currentStreakCount = 0;
        lastDate = null;
      }
    }

    return maxStreak;
  }

  /// Get total number of days with all tasks completed
  int get totalCompletedDays {
    return _completionHistory.where((data) => data.allTasksCompleted).length;
  }

  /// Get completion percentage for a specific month
  double getMonthCompletionPercentage(DateTime month) {
    final monthStart = DateTime(month.year, month.month, 1);
    final monthEnd = DateTime(month.year, month.month + 1, 0);

    final monthData = _completionHistory
        .where((data) =>
            data.date.isAfter(monthStart.subtract(Duration(days: 1))) &&
            data.date.isBefore(monthEnd.add(Duration(days: 1))))
        .toList();

    if (monthData.isEmpty) return 0.0;

    final completedDays =
        monthData.where((data) => data.allTasksCompleted).length;
    return completedDays / monthData.length;
  }

  /// Get completion data for a specific date
  DayCompletionData? getCompletionDataForDate(DateTime date) {
    return _completionHistory.firstWhere(
      (data) => _isSameDay(data.date, date),
      orElse: () => DayCompletionData(
        date: date,
        totalTasks: 0,
        completedTasks: 0,
        allTasksCompleted: false,
      ),
    );
  }

  /// Update completion data for today based on current tasks
  Future<void> updateTodayCompletion(List<Task> tasks) async {
    final today = DateTime.now();
    final totalTasks = tasks.length;
    final completedTasks = tasks.where((task) => task.isCompleted).length;
    final allTasksCompleted = totalTasks > 0 && completedTasks == totalTasks;

    final todayData = DayCompletionData(
      date: today,
      totalTasks: totalTasks,
      completedTasks: completedTasks,
      allTasksCompleted: allTasksCompleted,
    );

    // Remove existing data for today if it exists
    _completionHistory.removeWhere((data) => _isSameDay(data.date, today));

    // Add updated data for today
    _completionHistory.add(todayData);

    await _saveToStorage();
  }

  /// Load completion history from storage
  Future<void> loadFromStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(_storageKey);

      if (jsonString != null) {
        final List<dynamic> jsonList = json.decode(jsonString);
        _completionHistory =
            jsonList.map((json) => DayCompletionData.fromJson(json)).toList();
      }
    } catch (e) {
      // Handle error gracefully
      _completionHistory = [];
    }
  }

  /// Save completion history to storage
  Future<void> _saveToStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonList = _completionHistory.map((data) => data.toJson()).toList();
      await prefs.setString(_storageKey, json.encode(jsonList));
    } catch (e) {
      // Handle error gracefully
    }
  }

  /// Check if two dates are the same day
  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  /// Check if two dates are consecutive days
  bool _isConsecutiveDay(DateTime date1, DateTime date2) {
    final difference = date2.difference(date1).inDays;
    return difference == 1;
  }

  /// Get completion data for a specific month
  List<DayCompletionData> getMonthData(DateTime month) {
    final monthStart = DateTime(month.year, month.month, 1);
    final monthEnd = DateTime(month.year, month.month + 1, 0);

    return _completionHistory
        .where((data) =>
            data.date.isAfter(monthStart.subtract(Duration(days: 1))) &&
            data.date.isBefore(monthEnd.add(Duration(days: 1))))
        .toList();
  }
}

/// Singleton instance for global access
final streakTracker = StreakTracker();
