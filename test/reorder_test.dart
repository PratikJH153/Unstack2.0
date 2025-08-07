import 'package:flutter_test/flutter_test.dart';
import 'package:unstack/models/tasks/task.model.dart';

void main() {
  group('ReorderableListView Logic Tests', () {
    late List<Task> testTasks;

    setUp(() {
      testTasks = [
        Task(
          id: '1',
          title: 'Task 1',
          description: 'First task',
          priority: TaskPriority.low,
          createdAt: DateTime.now(),
        ),
        Task(
          id: '2',
          title: 'Task 2',
          description: 'Second task',
          priority: TaskPriority.medium,
          createdAt: DateTime.now(),
        ),
        Task(
          id: '3',
          title: 'Task 3',
          description: 'Third task',
          priority: TaskPriority.high,
          createdAt: DateTime.now(),
        ),
      ];
    });

    test('should correctly reorder tasks when moving down', () {
      // Simulate moving task from index 0 to index 2
      int oldIndex = 0;
      int newIndex = 2;

      // Apply the same logic as in the ReorderableListView
      if (newIndex > oldIndex) {
        newIndex -= 1;
      }

      final task = testTasks.removeAt(oldIndex);
      testTasks.insert(newIndex, task);

      // Verify the new order
      expect(testTasks[0].id, '2');
      expect(testTasks[1].id, '1');
      expect(testTasks[2].id, '3');
    });

    test('should correctly reorder tasks when moving up', () {
      // Simulate moving task from index 2 to index 0
      int oldIndex = 2;
      int newIndex = 0;

      // Apply the same logic as in the ReorderableListView
      if (newIndex > oldIndex) {
        newIndex -= 1;
      }

      final task = testTasks.removeAt(oldIndex);
      testTasks.insert(newIndex, task);

      // Verify the new order
      expect(testTasks[0].id, '3');
      expect(testTasks[1].id, '1');
      expect(testTasks[2].id, '2');
    });

    test('should correctly reorder tasks when moving to adjacent position', () {
      // Simulate moving task from index 0 to index 2 (which becomes index 1 after adjustment)
      int oldIndex = 0;
      int newIndex = 2;

      // Apply the same logic as in the ReorderableListView
      if (newIndex > oldIndex) {
        newIndex -= 1;
      }

      final task = testTasks.removeAt(oldIndex);
      testTasks.insert(newIndex, task);

      // Verify the new order - Task 1 should now be at position 1
      expect(testTasks[0].id, '2');
      expect(testTasks[1].id, '1');
      expect(testTasks[2].id, '3');
    });
  });
}
