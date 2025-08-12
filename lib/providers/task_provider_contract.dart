import 'package:unstack/models/tasks/task.model.dart';

abstract class ITaskProviderContract {
  List<Task> get tasks;
  List<Task> get completedTasks;
  Future<void> loadTasks();
  Future<void> loadCompletedTasks();
  Future<bool> addTask(Task task);
  Future<bool> updateTask(Task updatedTask);
  Future<bool> deleteTask(String taskId);
  Future<bool> deleteAllTasks();
  Task? getTaskById(String taskId);
  Future<bool> markTaskAsCompleted(Task task);
  Future<bool> markTaskAsIncomplete(Task task);
  Future<bool> toggleTaskCompletion(Task task);
  Future<void> refreshTasks();
}
