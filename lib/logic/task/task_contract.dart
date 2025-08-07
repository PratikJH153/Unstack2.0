import 'package:unstack/models/tasks/task.model.dart';

abstract class ITaskManagerContract {
  Future<void> addTask(Task task);
  Future<void> updateTask(Task task);
  Future<void> deleteTask(String taskId);
  Future<List<Task>> getTasks();
  Future<void> markTaskAsCompleted(String taskId);
  Future<void> markTaskAsIncomplete(String taskId);
  Future<void> deleteAllTasks();
  Future<void> sortPriorityTasks(Task task, int newIndex);
  Future<Task> getTaskById(String taskId);
  Future<List<Task>> getCompletedTasks();
}
