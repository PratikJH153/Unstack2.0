import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:unstack/helper/date_format.dart';
import 'package:unstack/models/tasks/task.model.dart';
import 'package:unstack/providers/streak_provider.dart';
import 'package:unstack/providers/task_provider.dart';
import 'package:unstack/theme/theme.dart';

class TaskCard extends StatefulWidget {
  final Task task;
  final VoidCallback? onTap;
  final ValueChanged<bool>? onToggleComplete;
  final VoidCallback? onDelete;
  final bool showProgress;
  final bool isCompact;

  const TaskCard({
    super.key,
    required this.task,
    this.onTap,
    this.onToggleComplete,
    this.onDelete,
    this.showProgress = true,
    this.isCompact = false,
  });

  @override
  State<TaskCard> createState() => _TaskCardState();
}

class _TaskCardState extends State<TaskCard> with TickerProviderStateMixin {
  late AnimationController _scaleController;
  late AnimationController _checkController;

  @override
  void initState() {
    super.initState();
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _checkController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    if (widget.task.isCompleted) {
      _checkController.value = 1.0;
    }
  }

  @override
  void dispose() {
    _scaleController.dispose();
    _checkController.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    _scaleController.forward();
    HapticFeedback.lightImpact();
  }

  void _handleTapUp(TapUpDetails details) {
    _scaleController.reverse();
  }

  void _handleTapCancel() {
    _scaleController.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: AnimatedBuilder(
        animation: _scaleController,
        builder: (context, child) {
          final scale = 1.0 - (_scaleController.value * 0.02);

          return Transform.scale(
            scale: scale,
            child: GestureDetector(
              onTapDown: _handleTapDown,
              onTapUp: _handleTapUp,
              onTapCancel: _handleTapCancel,
              onTap: widget.onTap,
              child: Container(
                margin: EdgeInsets.symmetric(
                  vertical: 6,
                ),
                padding: EdgeInsets.symmetric(
                  horizontal: AppSpacing.lg,
                  vertical: AppSpacing.lg,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(AppBorderRadius.xxl),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppColors.glassBackground,
                      AppColors.glassBackground.withValues(alpha: 0.05),
                    ],
                  ),
                  border: Border.all(
                    color: AppColors.glassBorder,
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.sm,
                            vertical: AppSpacing.xs,
                          ),
                          decoration: BoxDecoration(
                            color: widget.task.priority.color
                                .withValues(alpha: 0.2),
                            borderRadius:
                                BorderRadius.circular(AppBorderRadius.full),
                            border: Border.all(
                              color: widget.task.priority.color
                                  .withValues(alpha: 0.5),
                              width: 1,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.flag,
                                size: 12,
                                color: widget.task.priority.color,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                widget.task.priority.label,
                                style: AppTextStyles.caption.copyWith(
                                  color: widget.task.priority.color,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          widget.task.isDueToday
                              ? 'Today'
                              : daysAgo(widget.task.createdAt),
                          style: AppTextStyles.caption.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: AppSpacing.sm,
                    ),
                    Text(
                      widget.task.title,
                      style: AppTextStyles.bodyLarge.copyWith(
                        color: widget.task.isCompleted
                            ? AppColors.textMuted
                            : AppColors.textPrimary,
                        decoration: widget.task.isCompleted
                            ? TextDecoration.lineThrough
                            : null,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (widget.task.description.isNotEmpty && !widget.isCompact)
                      Padding(
                        padding: const EdgeInsets.only(top: AppSpacing.xs),
                        child: Text(
                          widget.task.description,
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.textSecondary,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    if (!widget.task.isDueToday && !widget.task.isCompleted)
                      Padding(
                        padding: const EdgeInsets.only(top: AppSpacing.sm),
                        child: GestureDetector(
                          onTap: () {
                            HapticFeedback.lightImpact();
                            final taskProvider = Provider.of<TaskProvider>(
                                context,
                                listen: false);
                            taskProvider.postponeTask(widget.task);
                            final StreakProvider streakProvider =
                                Provider.of<StreakProvider>(
                              context,
                              listen: false,
                            );

                            streakProvider.updateStreak(
                              taskProvider.totalTasksCount,
                              taskProvider.completedTasksCount,
                              taskProvider.todaysTasksCompleted,
                            );
                          },
                          child: Text(
                            'Postpone',
                            style: AppTextStyles.buttonMedium.copyWith(
                              color: AppColors.accentRed,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),

              // Priority indicator
            ),
          );
        },
      ),
    );
  }
}
