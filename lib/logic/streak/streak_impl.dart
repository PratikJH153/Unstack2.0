import 'package:unstack/database/sql_database.dart';
import 'package:unstack/logic/streak/streak_contract.dart';
import 'package:unstack/models/streak/streak.model.dart';
import 'package:unstack/models/tasks/task.model.dart';
import 'package:unstack/utils/app_logger.dart';

class StreakManager implements IStreakManagerContract {
  final DatabaseService _databaseService = DatabaseService.instance;

  @override
  Future<void> updateDayCompletion(
    DateTime date,
    List<Task> tasksForDate,
  ) async {
    try {
      final totalTasks = tasksForDate.length;
      final completedTasks =
          tasksForDate.where((task) => task.isCompleted).length;
      final allTasksCompleted = totalTasks > 0 && completedTasks == totalTasks;

      // Calculate current and longest streaks
      final currentStreak =
          await _calculateCurrentStreak(date, allTasksCompleted);
      final longestStreak = await _calculateLongestStreak(currentStreak);

      final streakData = {
        'date': date.toIso8601String().split('T')[0],
        'totalTasks': totalTasks,
        'completedTasks': completedTasks,
        'allTasksCompleted': allTasksCompleted ? 1 : 0,
        'currentStreak': currentStreak,
        'longestStreak': longestStreak,
      };

      await _databaseService.insertOrUpdateStreakData(streakData);
      AppLogger.info(
          'Updated streak for ${date.toIso8601String().split('T')[0]}: '
          'tasks=$totalTasks, completed=$completedTasks, streak=$currentStreak');
    } catch (e) {
      AppLogger.error('Error updating day completion: $e');
      rethrow;
    }
  }

  @override
  Future<List<StreakModel>> getCompletionHistory() async {
    try {
      final streakHistory = await _databaseService.getStreakHistory();
      return streakHistory.map((data) {
        return StreakModel(
          date: DateTime.parse(data['date']),
          totalTasks: data['totalTasks'] as int,
          completedTasks: data['completedTasks'] as int,
          allTasksCompleted: (data['allTasksCompleted'] as int) == 1,
        );
      }).toList();
    } catch (e) {
      AppLogger.error('Error getting completion history: $e');
      return [];
    }
  }

  @override
  Future<int> getCurrentStreak() async {
    try {
      return await _databaseService.getCurrentStreakFromDB();
    } catch (e) {
      AppLogger.error('Error getting current streak: $e');
      return 0;
    }
  }

  @override
  Future<int> getLongestStreak() async {
    try {
      return await _databaseService.getLongestStreakFromDB();
    } catch (e) {
      AppLogger.error('Error getting longest streak: $e');
      return 0;
    }
  }

  @override
  Future<int> getTotalCompletedDays() async {
    try {
      return await _databaseService.getTotalCompletedDaysFromDB();
    } catch (e) {
      AppLogger.error('Error getting total completed days: $e');
      return 0;
    }
  }

  @override
  Future<void> resetStreak() async {
    try {
      await _databaseService.deleteStreakData();
      AppLogger.info('Streak data reset successfully');
    } catch (e) {
      AppLogger.error('Error resetting streak: $e');
      rethrow;
    }
  }

  @override
  Future<void> removeStreakForDate(DateTime date) async {
    try {
      final dateString = date.toIso8601String().split('T')[0];
      await _databaseService.deleteStreakDataForDate(dateString);
      AppLogger.info('Removed streak for date: $dateString');
    } catch (e) {
      AppLogger.error('Error removing streak for date: $e');
      rethrow;
    }
  }

  /// Calculate current streak based on consecutive completed days
  Future<int> _calculateCurrentStreak(
      DateTime targetDate, bool isCompleted) async {
    if (!isCompleted) return 0;

    try {
      final history = await getCompletionHistory();
      if (history.isEmpty) return 1;

      // Sort by date descending (most recent first)
      final sortedHistory = List<StreakModel>.from(history)
        ..sort((a, b) => b.date.compareTo(a.date));

      int streak = 1; // Start with 1 for the current day if completed
      final today = DateTime(targetDate.year, targetDate.month, targetDate.day);

      // Count backwards for consecutive completed days
      for (int i = 0; i < sortedHistory.length; i++) {
        final currentDay = sortedHistory[i];
        final expectedDate = today.subtract(Duration(days: i + 1));
        final currentDayNormalized = DateTime(
          currentDay.date.year,
          currentDay.date.month,
          currentDay.date.day,
        );

        if (_isSameDay(currentDayNormalized, expectedDate) &&
            currentDay.allTasksCompleted) {
          streak++;
        } else {
          break;
        }
      }

      return streak;
    } catch (e) {
      AppLogger.error('Error calculating current streak: $e');
      return isCompleted ? 1 : 0;
    }
  }

  /// Calculate longest streak, updating if current streak is higher
  Future<int> _calculateLongestStreak(int currentStreak) async {
    try {
      final existingLongest = await getLongestStreak();
      return currentStreak > existingLongest ? currentStreak : existingLongest;
    } catch (e) {
      AppLogger.error('Error calculating longest streak: $e');
      return currentStreak;
    }
  }

  /// Check if two dates are the same day
  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }
}
