import 'package:unstack/models/tasks/task.model.dart';

abstract class ITaskManagerContract {
  Future<void> addTask(Task task);
  Future<void> updateTask(Task task);
  Future<void> deleteTask(String taskId);
  Future<List<Task>> getTasks();
  Future<void> markTaskAsCompleted(Task task);
  Future<void> markTaskAsIncomplete(Task task);
  Future<void> deleteAllTasks();
  Future<List<Task>> getCompletedTasks();
}
