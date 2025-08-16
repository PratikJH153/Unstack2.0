import 'package:unstack/database/sql_database.dart';
import 'package:unstack/logic/tasks/task_contract.dart';
import 'package:unstack/models/tasks/task.model.dart';

class TaskManager implements ITaskManagerContract {
  final DatabaseService _databaseService = DatabaseService.instance;

  @override
  Future<void> addTask(Task task) async {
    return await _databaseService.insertTask(task);
  }

  @override
  Future<void> deleteAllTasks() async {
    return await _databaseService.deleteAllTasks();
  }

  @override
  Future<void> deleteTask(String taskId) async {
    return await _databaseService.deleteTask(taskId);
  }

  @override
  Future<List<Task>> getRemainingTasks() async {
    return await _databaseService.getRemainingTasks();
  }

  @override
  Future<List<Task>> getPendingTasks() async {
    return await _databaseService.getPendingTasks();
  }

  @override
  Future<void> markTaskAsCompleted(Task task) async {
    return await _databaseService.updateTask(task);
  }

  @override
  Future<void> markTaskAsIncomplete(Task task) async {
    return await _databaseService.updateTask(task);
  }

  @override
  Future<void> updateTask(Task task) {
    return _databaseService.updateTask(task);
  }

  @override
  Future<List<Task>> getCompletedTasks() async {
    final tasks = await _databaseService.getCompletedTasks();
    final year = DateTime.now();
    return tasks
        .where((task) =>
            task.isCompleted &&
            task.completedAt != null &&
            task.completedAt!.year == year.year &&
            task.completedAt!.month == year.month &&
            task.completedAt!.day == year.day)
        .toList();
  }
}
