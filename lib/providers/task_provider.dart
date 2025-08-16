import 'package:flutter/foundation.dart';
import 'package:unstack/logic/tasks/task_impl.dart';

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

  List<Task> _remainingTasks = [];
  List<Task> _completedTasks = [];
  List<Task> _pendingTasks = [];

  @override
  List<Task> get remainingTasks => _remainingTasks;
  @override
  List<Task> get pendingTasks => _pendingTasks;
  @override
  List<Task> get allTasks =>
      [...remainingTasks, ...completedTasks, ...pendingTasks];

  List<Task> get todayTasks => [...remainingTasks, ...completedTasks];
  @override
  List<Task> get completedTasks => _completedTasks;

  // Statistics
  int get totalTasksCount => [...remainingTasks, ...completedTasks].length;
  int get completedTasksCount => completedTasks.length;

  bool get todaysTasksCompleted =>
      todayTasks.isNotEmpty && todayTasks.every((task) => task.isCompleted);

  TaskProvider() {
    loadTasks();
    loadCompletedTasks();
    loadPendingTasks();
  }

  /// Get task by id
  @override
  Task? getTaskById(String taskId) {
    try {
      return allTasks.firstWhere(
        (task) => task.id == taskId,
      );
    } catch (e) {
      AppLogger.warning('Task not found with id: $taskId');
      return null;
    }
  }

  /// Load all tasks from database
  @override
  Future<void> loadTasks() async {
    try {
      final tasks = await _taskManager.getRemainingTasks();
      // Tasks are already ordered by priorityIndex from database query
      _remainingTasks = tasks;
      notifyListeners();
      AppLogger.info('Loaded ${tasks.length} tasks');
    } catch (e) {
      AppLogger.error('Error loading tasks: $e');
      _setError('Failed to load tasks: ${e.toString()}');
    }
  }

  /// Load completed tasks from database
  @override
  Future<void> loadCompletedTasks() async {
    try {
      final completedTasks = await _taskManager.getCompletedTasks();
      _completedTasks = completedTasks;
      notifyListeners();
      AppLogger.info('Loaded ${completedTasks.length} completed tasks');
    } catch (e) {
      AppLogger.error('Error loading completed tasks: $e');
      _setError('Failed to load completed tasks: ${e.toString()}');
    }
  }

  @override
  Future<void> loadPendingTasks() async {
    try {
      final pendingTasks = await _taskManager.getPendingTasks();
      // Tasks are already ordered by priorityIndex from database query
      _pendingTasks = pendingTasks;
      notifyListeners();
      AppLogger.info('Loaded ${pendingTasks.length} pending tasks');
    } catch (e) {
      AppLogger.error('Error loading pending tasks: $e');
      _setError('Failed to load pending tasks: ${e.toString()}');
    }
  }

  /// Add a new task
  @override
  Future<bool> addTask(Task task) async {
    try {
      await _taskManager.addTask(task);
      remainingTasks.add(task);
      notifyListeners();

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
      bool taskFound = false;
      // Check in today's tasks
      final todayIndex =
          _remainingTasks.indexWhere((task) => task.id == updatedTask.id);
      if (todayIndex != -1) {
        _remainingTasks[todayIndex] = updatedTask;
        taskFound = true;
      }

      // Check in pending tasks
      final pendingIndex =
          _pendingTasks.indexWhere((task) => task.id == updatedTask.id);
      if (pendingIndex != -1) {
        _pendingTasks[pendingIndex] = updatedTask;
        taskFound = true;
      }

      // Check in completed tasks
      final completedIndex =
          _completedTasks.indexWhere((task) => task.id == updatedTask.id);
      if (completedIndex != -1) {
        _completedTasks[completedIndex] = updatedTask;
        taskFound = true;
      }

      refreshTasks();

      if (taskFound) {
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

  @override
  Future<bool> postponeTask(Task task) async {
    try {
      final postponedTask = task.copyWith(createdAt: DateTime.now());
      await _taskManager.updateTask(postponedTask);

      // Remove from pending tasks list
      _pendingTasks.removeWhere((t) => t.id == task.id);

      // Add the updated task (with new createdAt) to today's tasks
      _remainingTasks.add(postponedTask);

      notifyListeners();

      AppLogger.info('Postponed task: ${task.title} to today');
      return true;
    } catch (e) {
      AppLogger.error('Error postponing task: $e');
      _setError('Failed to postpone task: ${e.toString()}');
      return false;
    }
  }

  /// Delete a task
  @override
  Future<bool> deleteTask(String taskId) async {
    try {
      await _taskManager.deleteTask(taskId);
      _remainingTasks.removeWhere((task) => task.id == taskId);
      _completedTasks.removeWhere((task) => task.id == taskId);
      _pendingTasks.removeWhere((task) => task.id == taskId);

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
      final completedTask =
          task.copyWith(isCompleted: true, completedAt: DateTime.now());
      await _taskManager.markTaskAsCompleted(completedTask);
      _remainingTasks.removeWhere((t) => t.id == task.id);
      _pendingTasks.removeWhere((t) => t.id == task.id);
      _completedTasks.add(completedTask);
      notifyListeners();

      AppLogger.info(
          'Task completed: ${task.title}, created on: ${task.createdAt.toIso8601String().split('T')[0]}');
      AppLogger.info('Today\'s tasks completed: $todaysTasksCompleted');

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
      final incompleteTask =
          task.copyWith(isCompleted: false, completedAt: null);
      await _taskManager.markTaskAsIncomplete(incompleteTask);
      _completedTasks.removeWhere((t) => t.id == task.id);

      if (task.isDueToday) {
        _remainingTasks.add(incompleteTask);
      } else {
        _pendingTasks.add(incompleteTask);
      }
      notifyListeners();

      return true;
    } catch (e) {
      AppLogger.error('Error marking task as incomplete: $e');
      _setError('Failed to mark task as incomplete: ${e.toString()}');
      return false;
    }
  }

  /// Delete all tasks
  @override
  Future<bool> deleteAllTasks() async {
    try {
      await _taskManager.deleteAllTasks();
      _remainingTasks.clear();
      _completedTasks.clear();
      _pendingTasks.clear();
      notifyListeners();
      AppLogger.info('Deleted all tasks');
      return true;
    } catch (e) {
      AppLogger.error('Error deleting all tasks: $e');
      _setError('Failed to delete all tasks: ${e.toString()}');
      return false;
    }
  }

  /// Refresh tasks from database
  @override
  Future<void> refreshTasks() async {
    await loadTasks();
  }

  void _setError(String message) {
    notifyListeners();
  }

  /// Reorder tasks with optimized database operations
  Future<void> reorderTasks(int oldIndex, int newIndex) async {
    // Fix the index issue when dragging from lower to higher index
    if (oldIndex < newIndex) {
      newIndex -= 1;
    }

    final tasks = List<Task>.from(_remainingTasks);
    final task = tasks.removeAt(oldIndex);
    tasks.insert(newIndex, task);

    // Update priorityIndex for all tasks based on new positions
    final updatedTasks = <Task>[];
    for (int i = 0; i < tasks.length; i++) {
      updatedTasks.add(tasks[i].copyWith(priorityIndex: i));
    }

    // Update local state immediately for smooth UI
    _remainingTasks = updatedTasks;
    notifyListeners();

    // Batch database updates asynchronously
    _batchUpdateTasks(updatedTasks);
  }

  /// Apply sort order with optimized database operations
  Future<void> applySortOrder(List<Task> sortedTasks) async {
    // Update priorityIndex values based on new sort order
    final updatedTasks = <Task>[];
    for (int i = 0; i < sortedTasks.length; i++) {
      updatedTasks.add(sortedTasks[i].copyWith(priorityIndex: i));
    }

    // Update local state immediately
    _remainingTasks = updatedTasks;
    notifyListeners();

    // Batch database updates asynchronously
    _batchUpdateTasks(updatedTasks);
  }

  /// Batch update multiple tasks in database efficiently
  void _batchUpdateTasks(List<Task> tasks) {
    Future.microtask(() async {
      try {
        // Update all tasks in database without triggering UI updates
        for (final task in tasks) {
          await _taskManager.updateTask(task);
        }
        AppLogger.info('Batch updated ${tasks.length} tasks');
      } catch (e) {
        AppLogger.error('Error batch updating tasks: $e');
        // Reload tasks from database if batch update fails
        await loadTasks();
      }
    });
  }
}
