import 'package:chiclet/chiclet.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:unstack/models/tasks/task.model.dart';
import 'package:unstack/providers/task_provider.dart';
import 'package:unstack/theme/theme.dart';
import 'package:unstack/routes/route.dart';
import 'package:unstack/widgets/delete_task_dialog.dart';
import 'package:unstack/widgets/home_app_bar_button.dart';
import 'dart:math' as math;

class TaskDetailsPage extends StatefulWidget {
  final String heroTag;
  final String taskID;

  const TaskDetailsPage({
    required this.heroTag,
    required this.taskID,
    super.key,
  });

  @override
  State<TaskDetailsPage> createState() => _TaskDetailsPageState();
}

class _TaskDetailsPageState extends State<TaskDetailsPage>
    with TickerProviderStateMixin {
  late Task _currentTask;

  // Animation controllers for the completion sequence
  late AnimationController _holdProgressController;
  late AnimationController _radialExpansionController;
  late AnimationController _burstController;

  // Animations
  late Animation<double> _holdProgressAnimation;
  late Animation<double> _radialExpansionAnimation;
  late Animation<double> _burstAnimation;

  // State variables
  bool _isHolding = false;
  bool _isCompleting = false;
  bool _isCompleted = false;

  @override
  void initState() {
    super.initState();

    _initializeAnimations();
  }

  void _initializeAnimations() {
    // Hold progress animation (3 seconds)
    _holdProgressController = AnimationController(
      duration: AnimationConstants.holdToComplete,
      vsync: this,
    );

    // Radial expansion animation (1 second)
    _radialExpansionController = AnimationController(
      duration: AnimationConstants.slow,
      vsync: this,
    );

    // Burst animation (0.5 seconds)
    _burstController = AnimationController(
      duration: AnimationConstants.standard,
      vsync: this,
    );

    // Create animations with curves
    _holdProgressAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _holdProgressController,
      curve: AnimationConstants.linearCurve,
    ));

    _radialExpansionAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _radialExpansionController,
      curve: AnimationConstants.standardCurve,
    ));

    _burstAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _burstController,
      curve: AnimationConstants.standardCurve,
    ));

    // Add listeners
    _holdProgressController.addStatusListener(_onHoldProgressStatusChanged);
    _radialExpansionController
        .addStatusListener(_onRadialExpansionStatusChanged);
    _burstController.addStatusListener(_onBurstStatusChanged);
  }

  @override
  void dispose() {
    _holdProgressController.dispose();
    _radialExpansionController.dispose();
    _burstController.dispose();
    super.dispose();
  }

  // Animation status listeners
  void _onHoldProgressStatusChanged(AnimationStatus status) {
    if (status == AnimationStatus.completed && _isHolding) {
      _startRadialExpansion();
    }
  }

  void _onRadialExpansionStatusChanged(AnimationStatus status) {
    if (status == AnimationStatus.completed) {
      _startBurstAndComplete();
    }
  }

  void _onBurstStatusChanged(AnimationStatus status) {
    if (status == AnimationStatus.completed) {
      _finishCompletion();
    }
  }

  // Completion sequence methods
  void _startHoldProgress() {
    if (_currentTask.isCompleted || _isCompleting) return;

    setState(() {
      _isHolding = true;
    });

    HapticFeedback.lightImpact();
    _holdProgressController.forward();
  }

  void _cancelHoldProgress() {
    if (!_isHolding || _isCompleting) return;

    setState(() {
      _isHolding = false;
    });

    _holdProgressController.reset();
  }

  void _startRadialExpansion() {
    setState(() {
      _isCompleting = true;
    });

    HapticFeedback.mediumImpact();
    _radialExpansionController.forward();
  }

  void _startBurstAndComplete() {
    HapticFeedback.heavyImpact();
    _burstController.forward();
  }

  Future<void> _finishCompletion() async {
    // Mark task as completed
    final completedTask = _currentTask.copyWith(isCompleted: true);
    final taskProvider = Provider.of<TaskProvider>(context, listen: false);

    await taskProvider.updateTask(completedTask);

    setState(() {
      _currentTask = completedTask;
      _isCompleted = true;
    });

    // Navigate back after a short delay
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) {
        Navigator.of(context).pop(completedTask);
      }
    });
  }

  void _navigateToEditTask() async {
    final result = await RouteUtils.pushNamed(
      context,
      RoutePaths.addTaskPage,
      arguments: {
        'task': _currentTask,
        'fromTaskDetails': true,
        'edit': true,
      },
    );

    // Update task if changes were made
    if (result != null && result is Task) {
      setState(() {
        _currentTask = result;
      });
    }
  }

  void _deleteTask() async {
    final result = await showDeleteDialog(
          context: context,
          onDelete: () async {
            // Delete task using TaskProvider
            final taskProvider =
                Provider.of<TaskProvider>(context, listen: false);
            await taskProvider.deleteTask(_currentTask.id);

            // Go back to tasks list
            HapticFeedback.heavyImpact();
            if (mounted) {
              Navigator.of(context).pop(true);
              return Navigator.of(context).pop(true);
            }
          },
          title: 'Delete Task',
          description: 'Are you sure want to delete this task?',
          buttonTitle: 'Delete',
        ) ??
        false;
    if (result) {}
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundPrimary,
      body: Consumer<TaskProvider>(
        builder: (context, taskProvider, state) {
          _currentTask =
              taskProvider.getTaskById(widget.taskID) ?? _currentTask;
          return Stack(
            children: [
              SafeArea(
                child: Column(
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        child: Padding(
                          padding: EdgeInsets.all(AppSpacing.lg),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildHeader(),
                              SizedBox(height: AppSpacing.xl),
                              _buildTaskInfo(),
                              SizedBox(height: AppSpacing.xxxl),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.lg,
                        vertical: AppSpacing.lg,
                      ),
                      child: ChicletOutlinedAnimatedButton(
                        height: 70,
                        width: double.infinity,
                        onPressed: () {
                          HapticFeedback.mediumImpact();
                        },
                        backgroundColor: AppColors.whiteColor,
                        borderColor: AppColors.textMuted,
                        borderWidth: 2,
                        buttonType: ChicletButtonTypes.roundedRectangle,
                        foregroundColor: AppColors.accentPurple,
                        borderRadius: AppBorderRadius.xxl,
                        child: GestureDetector(
                          onTapDown: (_) => _startHoldProgress(),
                          onTapUp: (_) => _cancelHoldProgress(),
                          onTapCancel: () => _cancelHoldProgress(),
                          child: Stack(
                            children: [
                              // Linear progress indicator
                              AnimatedBuilder(
                                animation: _holdProgressAnimation,
                                builder: (context, child) {
                                  return Container(
                                    width: double.infinity,
                                    height: 60,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(
                                          AppBorderRadius.full),
                                    ),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(
                                          AppBorderRadius.full),
                                      child: Stack(
                                        children: [
                                          // Progress fill
                                          Positioned(
                                            left: 0,
                                            top: 0,
                                            bottom: 0,
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                _holdProgressAnimation.value,
                                            child: Container(
                                              decoration: BoxDecoration(
                                                gradient: LinearGradient(
                                                  begin: Alignment.topCenter,
                                                  end: Alignment.bottomCenter,
                                                  colors: [
                                                    const Color(0xFF4A90E2)
                                                        .withValues(alpha: 0.2),
                                                    const Color(0xFF4A90E2)
                                                        .withValues(
                                                            alpha: 0.15),
                                                    const Color(0xFF4A90E2)
                                                        .withValues(alpha: 0.1),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                              // Button content
                              Center(
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.check_circle,
                                      size: 24,
                                    ),
                                    SizedBox(width: AppSpacing.sm),
                                    Text(
                                      _isHolding
                                          ? 'Hold to Complete...'
                                          : 'Press & Hold to Finish',
                                      style: AppTextStyles.buttonLarge.copyWith(
                                        color: AppColors.accentPurple,
                                        fontWeight: FontWeight.w700,
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    // if (!_currentTask.isCompleted) _buildCompletionButton(),
                  ],
                ),
              ),
              // Radial expansion overlay
              if (_isCompleting) _buildRadialExpansionOverlay(),
              // Burst overlay
              if (_isCompleted) _buildBurstOverlay(),
            ],
          );
        },
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        HomeAppBarButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: CupertinoIcons.back,
        ),
        Spacer(),
        HomeAppBarButton(
          onPressed: _deleteTask,
          icon: CupertinoIcons.delete,
          color: AppColors.redShade,
        ),
        const SizedBox(
          width: AppSpacing.md,
        ),
        HomeAppBarButton(
          onPressed: _navigateToEditTask,
          icon: CupertinoIcons.pencil,
        ),
      ],
    );
  }

  Widget _buildTaskInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Priority Badge
        Container(
          padding: EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
          decoration: BoxDecoration(
            color: _currentTask.priority.color.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(AppBorderRadius.full),
            border: Border.all(
              color: _currentTask.priority.color.withValues(alpha: 0.5),
              width: 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.flag,
                size: 16,
                color: _currentTask.priority.color,
              ),
              SizedBox(width: 4),
              Text(
                _currentTask.priority.label,
                style: AppTextStyles.bodySmall.copyWith(
                  color: _currentTask.priority.color,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: AppSpacing.md),
        // Task Title
        Text(
          _currentTask.title,
          style: AppTextStyles.bodyLarge.copyWith(
            color: AppColors.textPrimary,
            fontSize: 32,
            fontWeight: FontWeight.w800,
          ),
        ),

        if (_currentTask.description.isNotEmpty) ...[
          SizedBox(height: AppSpacing.sm),
          Text(
            _currentTask.description,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textPrimary,
              height: 1.5,
            ),
          ),
        ],
      ],
    );
  }

  /*
  Widget _buildCompletionButton() {
    return Container(
      padding: EdgeInsets.all(AppSpacing.lg),
      child: AnimatedBuilder(
        animation: _holdProgressAnimation,
        builder: (context, child) {
          return GestureDetector(
            onTapDown: (_) => _startHoldProgress(),
            onTapUp: (_) => _cancelHoldProgress(),
            onTapCancel: () => _cancelHoldProgress(),
            child: AnimatedScale(
              scale: _isHolding ? 0.98 : 1.0,
              duration: const Duration(milliseconds: 100),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 100),
                width: double.infinity,
                height: 60,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(AppBorderRadius.xxl),
                  // Clean white background matching reference design
                  color: _isHolding
                      ? const Color(0xFFF5F5F5) // Slightly darker when pressed
                      : Colors.white,
                  // Prominent bottom shadow for lifted 3D effect (matching reference)
                  boxShadow: _isHolding
                      ? [
                          // Pressed state - reduced shadow
                          BoxShadow(
                            color:
                                const Color(0xFF4A90E2).withValues(alpha: 0.2),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.1),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : [
                          // Normal state - prominent bottom shadow like reference
                          BoxShadow(
                            color:
                                const Color(0xFF4A90E2).withValues(alpha: 0.3),
                            blurRadius: 16,
                            offset: const Offset(0, 8),
                          ),
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.15),
                            blurRadius: 12,
                            offset: const Offset(0, 6),
                          ),
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.1),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                ),
                child: Stack(
                  children: [
                    // Linear progress indicator
                    AnimatedBuilder(
                      animation: _holdProgressAnimation,
                      builder: (context, child) {
                        return Container(
                          width: double.infinity,
                          height: 60,
                          decoration: BoxDecoration(
                            borderRadius:
                                BorderRadius.circular(AppBorderRadius.full),
                          ),
                          child: ClipRRect(
                            borderRadius:
                                BorderRadius.circular(AppBorderRadius.full),
                            child: Stack(
                              children: [
                                // Progress fill
                                Positioned(
                                  left: 0,
                                  top: 0,
                                  bottom: 0,
                                  width: MediaQuery.of(context).size.width *
                                      _holdProgressAnimation.value,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        begin: Alignment.topCenter,
                                        end: Alignment.bottomCenter,
                                        colors: [
                                          const Color(0xFF4A90E2)
                                              .withValues(alpha: 0.2),
                                          const Color(0xFF4A90E2)
                                              .withValues(alpha: 0.15),
                                          const Color(0xFF4A90E2)
                                              .withValues(alpha: 0.1),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                    // Button content
                    Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.check_circle,
                            color: const Color(0xFF4A90E2),
                            size: 24,
                          ),
                          SizedBox(width: AppSpacing.sm),
                          Text(
                            _isHolding
                                ? 'Hold to Complete...'
                                : 'Press & Hold to Finish',
                            style: AppTextStyles.buttonLarge.copyWith(
                              color: const Color(0xFF4A90E2),
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
  */

  Widget _buildRadialExpansionOverlay() {
    return AnimatedBuilder(
      animation: _radialExpansionAnimation,
      builder: (context, child) {
        final screenSize = MediaQuery.of(context).size;
        final maxRadius = math.sqrt(
          math.pow(screenSize.width, 2) + math.pow(screenSize.height, 2),
        );

        return SizedBox(
          width: double.infinity,
          height: double.infinity,
          child: CustomPaint(
            painter: RadialExpansionPainter(
              progress: _radialExpansionAnimation.value,
              maxRadius: maxRadius,
              color: AppColors.accentGreen,
            ),
          ),
        );
      },
    );
  }

  Widget _buildBurstOverlay() {
    return AnimatedBuilder(
      animation: _burstAnimation,
      builder: (context, child) {
        return SizedBox(
          width: double.infinity,
          height: double.infinity,
          child: CustomPaint(
            painter: BurstPainter(
              progress: _burstAnimation.value,
              color: AppColors.accentGreen,
            ),
          ),
        );
      },
    );
  }
}

// Custom painter for radial expansion animation
class RadialExpansionPainter extends CustomPainter {
  final double progress;
  final double maxRadius;
  final Color color;

  RadialExpansionPainter({
    required this.progress,
    required this.maxRadius,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center =
        Offset(size.width / 2, size.height - 90); // Start from button area
    final radius = progress * maxRadius;

    final paint = Paint()
      ..color = color.withValues(alpha: 0.8 * (1 - progress * 0.3))
      ..style = PaintingStyle.fill;

    canvas.drawCircle(center, radius, paint);
  }

  @override
  bool shouldRepaint(RadialExpansionPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}

// Custom painter for burst animation
class BurstPainter extends CustomPainter {
  final double progress;
  final Color color;

  BurstPainter({
    required this.progress,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final paint = Paint()
      ..color = color.withValues(alpha: 0.6 * (1 - progress))
      ..style = PaintingStyle.fill;

    // Draw multiple expanding circles for burst effect
    for (int i = 0; i < 5; i++) {
      final radius = progress * (100 + i * 30);
      final alpha = (1 - progress) * (1 - i * 0.2);
      paint.color = color.withValues(alpha: alpha.clamp(0.0, 1.0));
      canvas.drawCircle(center, radius, paint);
    }
  }

  @override
  bool shouldRepaint(BurstPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
