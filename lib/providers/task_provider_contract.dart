import 'package:unstack/models/tasks/task.model.dart';

abstract class ITaskProviderContract {
  List<Task> get remainingTasks;
  List<Task> get completedTasks;
  List<Task> get pendingTasks;
  List<Task> get allTasks;
  Future<void> loadTasks();
  Future<void> loadCompletedTasks();
  Future<void> loadPendingTasks();
  Future<bool> addTask(Task task);
  Future<bool> updateTask(Task updatedTask);
  Future<bool> deleteTask(String taskId);
  Future<bool> deleteAllTasks();
  Future<bool> postponeTask(Task task);
  Task? getTaskById(String taskId);
  Future<bool> markTaskAsCompleted(Task task);
  Future<bool> markTaskAsIncomplete(Task task);
  Future<void> refreshTasks();
}
