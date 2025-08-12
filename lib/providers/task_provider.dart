import 'package:flutter/foundation.dart';
import 'package:unstack/logic/tasks/task_impl.dart';
import 'package:unstack/logic/streak/streak_impl.dart';
import 'package:unstack/models/tasks/task.model.dart';
import 'package:unstack/providers/task_provider_contract.dart';
import 'package:unstack/utils/app_logger.dart';

enum TaskState {
  initial,
  loading,
  loaded,
  error,
}

class TaskProvider extends ChangeNotifier implements ITaskProviderContract {
  final TaskManager _taskManager = TaskManager();
  final StreakManager _streakManager = StreakManager();

  TaskState _taskState = TaskState.initial;
  List<Task> _tasks = [];
  List<Task> _completedTasks = [];
  String? _errorMessage;

  // Getters
  TaskState get taskState => _taskState;

  @override
  List<Task> get tasks => _tasks;

  @override
  List<Task> get completedTasks => _completedTasks;

  String? get errorMessage => _errorMessage;

  bool get isLoading => _taskState == TaskState.loading;
  bool get hasError => _taskState == TaskState.error;

  // Statistics
  int get totalTasks => _tasks.length;
  int get completedTasksCount => completedTasks.length;
  double get completionPercentage =>
      totalTasks > 0 ? (completedTasksCount / totalTasks) * 100 : 0.0;

  TaskProvider() {
    loadTasks();
    loadCompletedTasks();
  }

  /// Get task by id
  @override
  Task? getTaskById(String taskId) {
    return _tasks.firstWhere(
      (task) => task.id == taskId,
    );
  }

  /// Load all tasks from database
  @override
  Future<void> loadTasks() async {
    _setTaskState(TaskState.loading);

    try {
      final tasks = await _taskManager.getTasks();
      _tasks = tasks;
      _setTaskState(TaskState.loaded);
      AppLogger.info('Loaded ${tasks.length} tasks');
    } catch (e) {
      AppLogger.error('Error loading tasks: $e');
      _setError('Failed to load tasks: ${e.toString()}');
    }
  }

  /// Load completed tasks from database
  @override
  Future<void> loadCompletedTasks() async {
    _setTaskState(TaskState.loading);

    try {
      final completedTasks = await _taskManager.getCompletedTasks();
      _completedTasks = completedTasks;
      _setTaskState(TaskState.loaded);
      AppLogger.info('Loaded ${completedTasks.length} completed tasks');
    } catch (e) {
      AppLogger.error('Error loading completed tasks: $e');
      _setError('Failed to load completed tasks: ${e.toString()}');
    }
  }

  /// Add a new task
  @override
  Future<bool> addTask(Task task) async {
    try {
      await _taskManager.addTask(task);
      _tasks.add(task);
      notifyListeners();

      _streakManager.removeStreakForDate(task.createdAt);

      AppLogger.info('Added task: ${task.title}');
      return true;
    } catch (e) {
      AppLogger.error('Error adding task: $e');
      _setError('Failed to add task: ${e.toString()}');
      return false;
    }
  }

  /// Update an existing task
  @override
  Future<bool> updateTask(Task updatedTask) async {
    try {
      await _taskManager.updateTask(updatedTask);

      final index = _tasks.indexWhere((task) => task.id == updatedTask.id);
      if (index != -1) {
        _tasks[index] = updatedTask;
        notifyListeners();

        AppLogger.info('Updated task: ${updatedTask.title}');
        return true;
      } else {
        AppLogger.warning('Task not found for update: ${updatedTask.id}');
        return false;
      }
    } catch (e) {
      AppLogger.error('Error updating task: $e');
      _setError('Failed to update task: ${e.toString()}');
      return false;
    }
  }

  /// Delete a task
  @override
  Future<bool> deleteTask(String taskId) async {
    try {
      await _taskManager.deleteTask(taskId);
      _tasks.removeWhere((task) => task.id == taskId);
      _completedTasks.removeWhere((task) => task.id == taskId);

      notifyListeners();

      AppLogger.info('Deleted task: $taskId');
      return true;
    } catch (e) {
      AppLogger.error('Error deleting task: $e');
      _setError('Failed to delete task: ${e.toString()}');
      return false;
    }
  }

  /// Mark task as completed
  @override
  Future<bool> markTaskAsCompleted(Task task) async {
    try {
      final completedTask = task.copyWith(isCompleted: true);
      await _taskManager.markTaskAsCompleted(completedTask);
      _tasks.removeWhere((t) => t.id == task.id);
      _completedTasks.add(completedTask);
      notifyListeners();
      return true;
    } catch (e) {
      AppLogger.error('Error marking task as completed: $e');
      _setError('Failed to mark task as completed: ${e.toString()}');
      return false;
    }
  }

  /// Mark task as incomplete
  @override
  Future<bool> markTaskAsIncomplete(Task task) async {
    try {
      final incompleteTask = task.copyWith(isCompleted: false);
      await _taskManager.markTaskAsIncomplete(incompleteTask);
      _completedTasks.removeWhere((t) => t.id == task.id);
      _tasks.add(incompleteTask);
      notifyListeners();
      return true;
    } catch (e) {
      AppLogger.error('Error marking task as completed: $e');
      _setError('Failed to mark task as completed: ${e.toString()}');
      return false;
    }
  }

  /// Toggle task completion status
  @override
  Future<bool> toggleTaskCompletion(Task task) async {
    if (task.isCompleted) {
      return await markTaskAsIncomplete(task);
    } else {
      return await markTaskAsCompleted(task);
    }
  }

  /// Delete all tasks
  @override
  Future<bool> deleteAllTasks() async {
    try {
      await _taskManager.deleteAllTasks();
      _tasks.clear();
      notifyListeners();
      AppLogger.info('Deleted all tasks');
      return true;
    } catch (e) {
      AppLogger.error('Error deleting all tasks: $e');
      _setError('Failed to delete all tasks: ${e.toString()}');
      return false;
    }
  }

  /// Clear error state
  void clearError() {
    _errorMessage = null;
    if (_taskState == TaskState.error) {
      _setTaskState(TaskState.loaded);
    }
  }

  /// Refresh tasks from database
  @override
  Future<void> refreshTasks() async {
    await loadTasks();
  }

  // Helper methods
  void _setTaskState(TaskState state) {
    _taskState = state;
    notifyListeners();
  }

  void _setError(String message) {
    _errorMessage = message;
    _taskState = TaskState.error;
    notifyListeners();
  }

  /// Update streak data for a specific date based on tasks for that date

  // Future<void> _updateStreakForTaskDate(DateTime date) async {
  //   try {
  //     // Get all tasks for the specific date
  //     final tasksForDate = _tasks.where((task) {
  //       final taskDate = DateTime(
  //         task.createdAt.year,
  //         task.createdAt.month,
  //         task.createdAt.day,
  //       );
  //       final targetDate = DateTime(date.year, date.month, date.day);
  //       return taskDate.isAtSameMomentAs(targetDate);
  //     }).toList();

  //     // Update streak data for this date
  //     await _streakManager.updateDayCompletion(date, tasksForDate);

  //     AppLogger.info(
  //         'Updated streak for date: ${date.toIso8601String().split('T')[0]} '
  //         'with ${tasksForDate.length} tasks');
  //   } catch (e) {
  //     AppLogger.error('Error updating streak for date: $e');
  //     // Don't rethrow to avoid breaking task operations
  //   }
  // }
}
