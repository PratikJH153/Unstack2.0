import 'package:unstack/models/tasks/task.model.dart';

final List<Task> initalTasks = [
  Task(
    id: '1',
    title: 'Complete this task to start',
    description: 'Press & hold to finish and move to the next step.',
    priority: TaskPriority.urgent,
    createdAt: DateTime.now(),
    completedAt: null,
    priorityIndex: priorityIndex[TaskPriority.urgent.name] ?? 0,
  ),
  Task(
    id: '2',
    title: 'Add your first task',
    description: 'Tap the + icon above to start planning your work.',
    priority: TaskPriority.medium,
    createdAt: DateTime.now(),
    completedAt: null,
    priorityIndex: priorityIndex[TaskPriority.medium.name] ?? 0,
  ),
];
