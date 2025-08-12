import 'package:unstack/models/streak/streak.model.dart';
import 'package:unstack/models/tasks/task.model.dart';

abstract class IStreakManagerContract {
  Future<void> updateDayCompletion(DateTime date, List<Task> tasksForDate);
  Future<List<StreakModel>> getCompletionHistory();
  Future<int> getCurrentStreak();
  Future<int> getLongestStreak();
  Future<int> getTotalCompletedDays();
  Future<void> resetStreak();
  Future<void> removeStreakForDate(DateTime date);
}
