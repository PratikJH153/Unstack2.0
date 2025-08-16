import 'package:flutter/cupertino.dart';

import 'package:unstack/helper/date_format.dart';
import 'package:unstack/models/tasks/task.model.dart';
import 'package:unstack/theme/theme.dart';

class TaskDueWidget extends StatelessWidget {
  final Task task;
  const TaskDueWidget({required this.task, super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          CupertinoIcons.calendar,
          color: AppColors.textPrimary,
          size: 20,
        ),
        const SizedBox(width: AppSpacing.sm),
        Text(
          task.isDueToday ? 'Today' : daysAgo(task.createdAt),
          style: AppTextStyles.bodyLarge.copyWith(
            color: AppColors.textPrimary,
            fontSize: 16,
          ),
        ),
      ],
    );
  }
}
