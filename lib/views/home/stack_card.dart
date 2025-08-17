import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:unstack/models/tasks/task.model.dart';
import 'package:unstack/routes/route.dart';
import 'package:unstack/theme/theme.dart';
import 'package:unstack/utils/app_size.dart';
import 'package:unstack/widgets/task_due_widget.dart';

class StackCard extends StatefulWidget {
  final Task task;
  final Function onTaskCompletion;
  const StackCard({
    required this.task,
    required this.onTaskCompletion,
    super.key,
  });

  @override
  State<StackCard> createState() => _StackCardState();
}

class _StackCardState extends State<StackCard> with TickerProviderStateMixin {
  bool _didHold = false;
  bool isCompleted = false;
  late AnimationController _progressController;
  late Animation<double> _progressAnimation;
  bool _isHolding = false;
  DateTime? _lastHaptic;
  static const Duration _holdDuration = Duration(milliseconds: 1200);
  static const Duration _hapticInterval = Duration(milliseconds: 150);

  void _tickHaptic() async {
    if (!_isHolding) return;
    final now = DateTime.now();
    if (_lastHaptic == null || now.difference(_lastHaptic!) > _hapticInterval) {
      HapticFeedback.selectionClick();
      _lastHaptic = now;
    }
    if (_isHolding && _progressController.isAnimating) {
      await Future.delayed(_hapticInterval);
      if (_isHolding) _tickHaptic();
    }
  }

  @override
  void initState() {
    super.initState();
    isCompleted = widget.task.isCompleted;
    _progressController = AnimationController(
      vsync: this,
      duration: _holdDuration,
      value: 0.0,
    );
    _progressAnimation = CurvedAnimation(
      parent: _progressController,
      curve: Curves.linear,
    );
    _progressController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        HapticFeedback.heavyImpact();
        setState(() {
          isCompleted = !isCompleted;
          widget.onTaskCompletion(isCompleted);
        });
        _progressController.value = 0.0;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final cardHeight = () {
      if (AppSize(context).height < 600) {
        return AppSize(context).height * 0.32;
      } else if (AppSize(context).height < 700) {
        return AppSize(context).height * 0.328;
      } else if (AppSize(context).height < 800) {
        return AppSize(context).height * 0.33;
      } else {
        return AppSize(context).height * 0.31;
      }
    }();
    return GestureDetector(
      key: Key(widget.task.id),
      onTap: () {
        // Only navigate if no hold was started and progress is at zero
        if (!_didHold && _progressController.value == 0.0) {
          HapticFeedback.lightImpact();
          RouteUtils.pushNamed(
            context,
            RoutePaths.taskDetailsPage,
            arguments: {
              'heroTag': 'task_${widget.task.id}',
              'taskID': widget.task.id,
            },
          );
        }
        // Reset _didHold for next tap
        _didHold = false;
      },
      onTapDown: (_) {
        _isHolding = true;
        _lastHaptic = DateTime.now();
        if (_progressController.value > 0.0) {
          _didHold = true;
        } else {
          _didHold = false;
        }
        _progressController.forward();
        _tickHaptic();
      },
      onTapUp: (_) {
        _isHolding = false;
        // If progress moved, mark as hold
        if (_progressController.value > 0.0) {
          _didHold = true;
        }
        _progressController.reverse();
      },
      onTapCancel: () {
        _isHolding = false;
        _progressController.reverse();
      },
      child: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppBorderRadius.xxxxl),
              color: AppColors.backgroundTertiary,
              border: Border.all(
                color: AppColors.textMuted.withValues(alpha: 0.8),
                width: 2,
              ),
            ),
            width: double.infinity,
            height: cardHeight,
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
                Text(
                  'Press & hold to complete',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                if (widget.task.isCompleted)
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
                const SizedBox(height: AppSpacing.sm),
                Text(
                  widget.task.title,
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
                  widget.task.description,
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
                    TaskDueWidget(task: widget.task),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.sm,
                        vertical: AppSpacing.xs,
                      ),
                      decoration: BoxDecoration(
                        color:
                            widget.task.priority.color.withValues(alpha: 0.2),
                        borderRadius:
                            BorderRadius.circular(AppBorderRadius.full),
                        border: Border.all(
                          color:
                              widget.task.priority.color.withValues(alpha: 0.5),
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
                          const SizedBox(width: AppSpacing.xs),
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
                  ],
                ),
                SizedBox(
                  height: AppSpacing.xs,
                ),
              ],
            ),
          ),
          Positioned.fill(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(AppBorderRadius.xxxxl),
              child: AnimatedBuilder(
                animation: _progressAnimation,
                builder: (context, child) {
                  return Align(
                    alignment: Alignment.bottomCenter,
                    child: FractionallySizedBox(
                      heightFactor: _progressAnimation.value,
                      widthFactor: 1.0,
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.vertical(
                            bottom: Radius.circular(AppBorderRadius.xxxxl),
                            top: Radius.circular(AppBorderRadius.xxxxl *
                                _progressAnimation.value),
                          ),
                          color: AppColors.accentGreen.withAlpha(
                            120,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
