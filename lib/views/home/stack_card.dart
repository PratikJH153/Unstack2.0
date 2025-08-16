import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:unstack/models/tasks/task.model.dart';
import 'package:unstack/routes/route.dart';
import 'package:unstack/theme/theme.dart';
import 'package:unstack/utils/app_size.dart';
import 'package:unstack/widgets/task_due_widget.dart';

class StackCard extends StatelessWidget {
  final Task task;
  final Function onTaskCompletion;
  const StackCard({
    required this.task,
    required this.onTaskCompletion,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        RouteUtils.pushNamed(
          context,
          RoutePaths.taskDetailsPage,
          arguments: {
            'heroTag': 'task_${task.id}',
            'taskID': task.id,
          },
        );
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppBorderRadius.xxxl),
          color: AppColors.backgroundTertiary,
          border: Border.all(
            color: AppColors.textMuted,
            width: 1,
          ),
        ),
        width: double.infinity,
        height: () {
          if (AppSize(context).height < 600) {
            return AppSize(context).height * 0.32;
          } else if (AppSize(context).height < 700) {
            return AppSize(context).height * 0.328;
          } else if (AppSize(context).height < 800) {
            return AppSize(context).height * 0.33;
          } else {
            return AppSize(context).height * 0.31;
          }
        }(),
        padding: const EdgeInsets.only(
          left: AppSpacing.xl,
          right: AppSpacing.xl,
          bottom: AppSpacing.md,
          top: AppSpacing.xl,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Transform.scale(
                  scale: 2.5,
                  child: Checkbox(
                    value: task.isCompleted,
                    visualDensity: VisualDensity.compact,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6.0),
                      side: BorderSide(
                        color: AppColors.whiteColor,
                        width: 2,
                      ),
                    ),
                    side: BorderSide(
                      color: AppColors.textMuted,
                      width: 2,
                    ),
                    activeColor: AppColors.accentGreen,
                    onChanged: (bool? value) => onTaskCompletion(value),
                  ),
                ),
                if (task.isCompleted)
                  Padding(
                    padding: const EdgeInsets.only(
                      left: 24,
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.swipe_up_rounded,
                          color: AppColors.lightWhiteColor,
                          size: 24,
                        ),
                        const SizedBox(
                          width: AppSpacing.xs,
                        ),
                        Text(
                          'Swipe up',
                          style: TextStyle(
                            fontSize: 14,
                            color: AppColors.lightWhiteColor,
                          ),
                        )
                      ],
                    ),
                  ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              task.title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.titleText.copyWith(
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(
              height: AppSpacing.xs,
            ),
            Text(
              task.description,
              maxLines: () {
                if (AppSize(context).height < 600) {
                  return 1;
                } else if (AppSize(context).height < 700) {
                  return 1;
                } else if (AppSize(context).height < 800) {
                  return 2;
                } else {
                  return 2;
                }
              }(),
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const Spacer(),
            Row(
              children: [
                TaskDueWidget(task: task),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm,
                    vertical: AppSpacing.xs,
                  ),
                  decoration: BoxDecoration(
                    color: task.priority.color.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(AppBorderRadius.full),
                    border: Border.all(
                      color: task.priority.color.withValues(alpha: 0.5),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.flag,
                        size: 12,
                        color: task.priority.color,
                      ),
                      const SizedBox(width: AppSpacing.xs),
                      Text(
                        task.priority.label,
                        style: AppTextStyles.caption.copyWith(
                          color: task.priority.color,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(
              height: AppSpacing.xs,
            ),
          ],
        ),
      ),
    );
  }
}
