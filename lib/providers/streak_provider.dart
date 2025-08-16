import 'package:flutter/foundation.dart';
import 'package:unstack/logic/streak/streak_impl.dart';
import 'package:unstack/models/streak/streak.model.dart';
import 'package:unstack/utils/app_logger.dart';

enum StreakState {
  initial,
  loading,
  loaded,
  error,
}

class StreakProvider extends ChangeNotifier {
  final StreakManager _streakManager = StreakManager();

  List<StreakModel> _completionHistory = [];
  int _currentStreak = 0;
  int _longestStreak = 0;
  String? _errorMessage;

  // Getters
  List<StreakModel> get completionHistory =>
      List.unmodifiable(_completionHistory);
  int get currentStreak => _currentStreak;
  int get longestStreak => _longestStreak;
  String? get errorMessage => _errorMessage;

  StreakProvider() {
    _initializeStreak();
  }

  /// Initialize streak data on app start
  Future<void> _initializeStreak() async {
    // _setStreakState(StreakState.loading);

    try {
      await loadStreakData();

      // _setStreakState(StreakState.loaded);
      AppLogger.info('Streak data initialized successfully');
    } catch (e) {
      AppLogger.error('Error initializing streak data: $e');
      _setError('Failed to initialize streak data: ${e.toString()}');
    }
  }

  /// Load streak data from database
  Future<void> loadStreakData() async {
    try {
      // _setStreakState(StreakState.loading);

      final history = await _streakManager.getCompletionHistory();
      _completionHistory = history;

      final newCurrentStreak = await _streakManager.getCurrentStreak();
      final newLongestStreak = await _streakManager.getLongestStreak();

      // Update values and notify listeners
      _currentStreak = newCurrentStreak;
      _longestStreak = newLongestStreak;

      notifyListeners();

      AppLogger.info(
          'Loaded streak data: current=$_currentStreak, longest=$_longestStreak');
    } catch (e) {
      AppLogger.error('Error loading streak data: $e');
      _setError('Failed to load streak data: ${e.toString()}');
      rethrow;
    }
  }

  /// Update streak data based on task changes for today
  Future<void> updateStreak(
    int todayTasks,
    int completedTasks,
    bool allTodayTasksCompleted,
  ) async {
    try {
      await _streakManager.updateDayCompletion(
        todayTasks,
        completedTasks,
        allTodayTasksCompleted,
      );
      await loadStreakData();
    } catch (e) {
      AppLogger.error('Error updating streak for today: $e');
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
      notifyListeners();
      AppLogger.info('Streak data reset successfully');
    } catch (e) {
      AppLogger.error('Error resetting streak: $e');
      _setError('Failed to reset streak: ${e.toString()}');
    }
  }

  /// Refresh streak data from database
  Future<void> refreshStreakData() async {
    await loadStreakData();
  }

  // Helper methods
  // void _setStreakState(StreakState state) {
  //   _streakState = state;
  //   notifyListeners();
  // }

  void _setError(String message) {
    _errorMessage = message;
    notifyListeners();
  }
}
