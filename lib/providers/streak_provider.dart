import 'package:flutter/foundation.dart';
import 'package:unstack/logic/streak/streak_impl.dart';
import 'package:unstack/models/streak/streak.model.dart';
import 'package:unstack/models/tasks/task.model.dart';
import 'package:unstack/utils/app_logger.dart';

enum StreakState {
  initial,
  loading,
  loaded,
  error,
}

class StreakProvider extends ChangeNotifier {
  final StreakManager _streakManager = StreakManager();

  StreakState _streakState = StreakState.initial;
  List<StreakModel> _completionHistory = [];
  int _currentStreak = 0;
  int _longestStreak = 0;
  int _totalCompletedDays = 0;
  String? _errorMessage;

  // Getters
  StreakState get streakState => _streakState;
  List<StreakModel> get completionHistory =>
      List.unmodifiable(_completionHistory);
  int get currentStreak => _currentStreak;
  int get longestStreak => _longestStreak;
  int get totalCompletedDays => _totalCompletedDays;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _streakState == StreakState.loading;
  bool get hasError => _streakState == StreakState.error;

  StreakProvider() {
    _initializeStreak();
  }

  /// Initialize streak data on app start
  Future<void> _initializeStreak() async {
    _setStreakState(StreakState.loading);

    try {
      await loadStreakData();
      _setStreakState(StreakState.loaded);
      AppLogger.info('Streak data initialized successfully');
    } catch (e) {
      AppLogger.error('Error initializing streak data: $e');
      _setError('Failed to initialize streak data: ${e.toString()}');
    }
  }

  /// Load streak data from database
  Future<void> loadStreakData() async {
    try {
      final history = await _streakManager.getCompletionHistory();
      _completionHistory = history;
      _currentStreak = await _streakManager.getCurrentStreak();
      _longestStreak = await _streakManager.getLongestStreak();
      _totalCompletedDays = await _streakManager.getTotalCompletedDays();
      notifyListeners();
      AppLogger.info(
          'Loaded streak data: current=$_currentStreak, longest=$_longestStreak');
    } catch (e) {
      AppLogger.error('Error loading streak data: $e');
      rethrow;
    }
  }

  /// Update streak data based on task changes
  Future<void> updateStreakForDate(
    DateTime date,
    List<Task> tasksForDate,
  ) async {
    try {
      await _streakManager.updateDayCompletion(date, tasksForDate);
      await loadStreakData(); // Reload to get updated calculations
      AppLogger.info('Updated streak for date: ${date.toIso8601String()}');
    } catch (e) {
      AppLogger.error('Error updating streak for date: $e');
      _setError('Failed to update streak: ${e.toString()}');
    }
  }

  Future<void> removeStreakForDate(DateTime date) async {
    try {
      await _streakManager.removeStreakForDate(date);
      await loadStreakData(); // Reload to get updated calculations
      AppLogger.info('Removed streak for date: ${date.toIso8601String()}');
    } catch (e) {
      AppLogger.error('Error removing streak for date: $e');
      _setError('Failed to remove streak: ${e.toString()}');
    }
  }

  /// Update today's streak based on current tasks
  Future<void> updateTodayStreak(List<Task> todaysTasks) async {
    final today = DateTime.now();
    await updateStreakForDate(today, todaysTasks);
  }

  /// Get completion data for a specific date
  StreakModel? getCompletionDataForDate(DateTime date) {
    try {
      return _completionHistory.firstWhere(
        (data) => _isSameDay(data.date, date),
      );
    } catch (e) {
      // Return null if no data found for this date
      return null;
    }
  }

  /// Get completion data for a specific month
  List<StreakModel> getMonthData(DateTime month) {
    final monthStart = DateTime(month.year, month.month, 1);
    final monthEnd = DateTime(month.year, month.month + 1, 0);

    return _completionHistory
        .where((data) =>
            data.date.isAfter(monthStart.subtract(Duration(days: 1))) &&
            data.date.isBefore(monthEnd.add(Duration(days: 1))))
        .toList();
  }

  /// Get month completion percentage
  double getMonthCompletionPercentage(DateTime month) {
    final monthData = getMonthData(month);
    if (monthData.isEmpty) return 0.0;

    final completedDays =
        monthData.where((data) => data.allTasksCompleted).length;
    return (completedDays / monthData.length) * 100;
  }

  /// Reset all streak data
  Future<void> resetStreak() async {
    try {
      await _streakManager.resetStreak();
      _completionHistory.clear();
      _currentStreak = 0;
      _longestStreak = 0;
      _totalCompletedDays = 0;
      notifyListeners();
      AppLogger.info('Streak data reset successfully');
    } catch (e) {
      AppLogger.error('Error resetting streak: $e');
      _setError('Failed to reset streak: ${e.toString()}');
    }
  }

  /// Clear error state
  void clearError() {
    _errorMessage = null;
    if (_streakState == StreakState.error) {
      _setStreakState(StreakState.loaded);
    }
  }

  /// Refresh streak data from database
  Future<void> refreshStreakData() async {
    await loadStreakData();
  }

  // Helper methods
  void _setStreakState(StreakState state) {
    _streakState = state;
    notifyListeners();
  }

  void _setError(String message) {
    _errorMessage = message;
    _streakState = StreakState.error;
    notifyListeners();
  }

  /// Check if two dates are the same day
  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  /// Get tasks for a specific date (helper method for external use)
  List<Task> getTasksForDate(List<Task> allTasks, DateTime date) {
    return allTasks.where((task) {
      final taskDate = DateTime(
        task.createdAt.year,
        task.createdAt.month,
        task.createdAt.day,
      );
      final targetDate = DateTime(date.year, date.month, date.day);
      return taskDate.isAtSameMomentAs(targetDate);
    }).toList();
  }
}
