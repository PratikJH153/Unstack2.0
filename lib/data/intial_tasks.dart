import 'package:unstack/models/tasks/task.model.dart';

final List<Task> initalTasks = [
  Task(
    id: '1',
    title: 'Complete this task and swipe up',
    description: 'Check the box above to finish and move to the next step.',
    priority: TaskPriority.urgent,
    createdAt: DateTime.now(),
    priorityIndex: priorityIndex[TaskPriority.urgent.name] ?? 0,
  ),
  Task(
    id: '2',
    title: 'Add your first task',
    description: 'Tap the + icon above to start planning your work.',
    priority: TaskPriority.medium,
    createdAt: DateTime.now().subtract(Duration(days: 2)),
    priorityIndex: priorityIndex[TaskPriority.medium.name] ?? 0,
  ),
];
