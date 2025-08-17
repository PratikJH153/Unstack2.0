import 'package:unstack/models/streak/streak.model.dart';

abstract class IStreakManagerContract {
  Future<void> updateDayCompletion(
    int todayTasks,
    int completedTasks,
    bool allTasksCompleted,
  );

  Future<void> removeStreakForDate(DateTime date);
  Future<bool> hasStreakForToday();
  Future<List<StreakModel>> getCompletionHistory();
  Future<int> getCurrentStreak();
  Future<int> getLongestStreak();
  Future<void> resetStreak();
}
