import 'package:unstack/database/sql_database.dart';
import 'package:unstack/logic/streak/streak_contract.dart';
import 'package:unstack/models/streak/streak.model.dart';
import 'package:unstack/utils/app_logger.dart';

class StreakManager implements IStreakManagerContract {
  final DatabaseService _databaseService = DatabaseService.instance;

  @override
  Future<void> updateDayCompletion(
    int todayTasks,
    int completedTasks,
    bool allTodayTasksCompleted,
  ) async {
    final today = DateTime.now();
    final yesterday = today.subtract(Duration(days: 1));
    try {
      final yesterdayData = await _databaseService
          .getStreakDataForDate(yesterday.toIso8601String().split('T')[0]);
      // Calculate current and longest streaks based on the new completion status
      final currentStreak = await _databaseService.getCurrentStreakFromDB();
      final existingLongestStreak =
          await _databaseService.getLongestStreakFromDB();

      final newStreak = allTodayTasksCompleted
          ? (yesterdayData != null ? yesterdayData['currentStreak'] + 1 : 1)
          : 0;

      int longestStreak;
      if (allTodayTasksCompleted) {
        // Did we set a new record?
        longestStreak = newStreak > existingLongestStreak
            ? newStreak
            : existingLongestStreak;
      } else {
        // Broke streak today
        longestStreak = (currentStreak == existingLongestStreak)
            ? existingLongestStreak - 1
            : existingLongestStreak;
      }

      longestStreak = longestStreak < 0 ? 0 : longestStreak;

      final streakData = {
        'date': today.toIso8601String().split('T')[0],
        'totalTasks': todayTasks, // Only today's tasks
        'completedTasks': completedTasks, // Only today's completed tasks
        'allTasksCompleted': allTodayTasksCompleted ? 1 : 0,
        'currentStreak': newStreak,
        'longestStreak': longestStreak,
      };

      await _databaseService.insertOrUpdateStreakData(streakData);
      AppLogger.info(
          'Updated streak for ${today.toIso8601String().split('T')[0]}: '
          'tasks=$todayTasks, completed=$completedTasks, allCompleted=$allTodayTasksCompleted, streak=${currentStreak + 1}');
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

  @override
  Future<bool> hasStreakForToday() async {
    try {
      final today = DateTime.now().toIso8601String().split('T')[0];
      final Map<String, dynamic>? streakData =
          await _databaseService.getStreakDataForDate(today);
      if (streakData == null) {
        return Future.value(false);
      } else {
        return Future.value(
          (streakData['allTasksCompleted'] as int) == 1,
        );
      }
    } catch (e) {
      AppLogger.error('Error checking streak for today: $e');
      return Future.value(false);
    }
  }

  Future<Map<String, dynamic>?> getStreakDataForDate(DateTime date) async {
    try {
      final dateString = date.toIso8601String().split('T')[0];
      return await _databaseService.getStreakDataForDate(dateString);
    } catch (e) {
      AppLogger.error('Error getting streak data for date $date: $e');
      return null;
    }
  }
}
