import 'package:unstack/logic/task/task_contract.dart';
import 'package:unstack/models/tasks/task.model.dart';

class TaskManager implements ITaskManagerContract {
  @override
  Future<void> addTask(Task task) {
    // TODO: implement addTask
    throw UnimplementedError();
  }

  @override
  Future<void> deleteAllTasks() {
    // TODO: implement deleteAllTasks
    throw UnimplementedError();
  }

  @override
  Future<void> deleteTask(String taskId) {
    // TODO: implement deleteTask
    throw UnimplementedError();
  }

  @override
  Future<List<Task>> getTasks() {
    // TODO: implement getTasks
    throw UnimplementedError();
  }

  @override
  Future<void> markTaskAsCompleted(String taskId) {
    // TODO: implement markTaskAsCompleted
    throw UnimplementedError();
  }

  @override
  Future<void> markTaskAsIncomplete(String taskId) {
    // TODO: implement markTaskAsIncomplete
    throw UnimplementedError();
  }

  @override
  Future<void> sortPriorityTasks(Task task, int newIndex) {
    // TODO: implement sortPriorityTasks
    throw UnimplementedError();
  }

  @override
  Future<void> updateTask(Task task) {
    // TODO: implement updateTask
    throw UnimplementedError();
  }

  @override
  Future<List<Task>> getCompletedTasks() {
    // TODO: implement getCompletedTasks
    throw UnimplementedError();
  }

  @override
  Future<Task> getTaskById(String taskId) {
    // TODO: implement getTaskById
    throw UnimplementedError();
  }
}
