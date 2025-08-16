import 'package:unstack/models/tasks/task.model.dart';

abstract class ITaskManagerContract {
  Future<void> addTask(Task task);
  Future<void> updateTask(Task task);
  Future<void> deleteTask(String taskId);
  Future<List<Task>> getRemainingTasks();
  Future<List<Task>> getPendingTasks();
  Future<List<Task>> getCompletedTasks();
  Future<void> markTaskAsCompleted(Task task);
  Future<void> markTaskAsIncomplete(Task task);
  Future<void> deleteAllTasks();
}
