abstract class IStreakManagerContract {
  Future<void> updateTodayCompletion();
  Future<void> getCompletionHistory();
  Future<void> getLongestStreak();
  Future<void> getTotalCompletedDays();
  Future<void> getMonthCompletionPercentage();
  Future<void> getCurrentStreak();
  Future<void> resetStreak();
}
