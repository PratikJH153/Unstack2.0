import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:unstack/theme/theme.dart';

class CircularProgressIndicator3D extends StatefulWidget {
  final int totalTasks;
  final int completedTasks;
  final double size;
  final Duration animationDuration;
  final Color? primaryColor;
  final Color? backgroundColor;
  final double strokeWidth;
  final bool showPercentage;
  final VoidCallback? onTap;

  const CircularProgressIndicator3D({
    super.key,
    required this.totalTasks,
    required this.completedTasks,
    this.size = 200,
    this.animationDuration = const Duration(milliseconds: 1500),
    this.primaryColor,
    this.backgroundColor,
    this.strokeWidth = 12,
    this.showPercentage = false,
    this.onTap,
  });

  @override
  State<CircularProgressIndicator3D> createState() =>
      _CircularProgressIndicator3DState();
}

class _CircularProgressIndicator3DState
    extends State<CircularProgressIndicator3D> with TickerProviderStateMixin {
  late AnimationController _progressController;

  late Animation<double> _progressAnimation;

  // Cache computed values to avoid recalculation
  late Color _primaryColor;
  late Color _backgroundColor;
  late int _progressPercentage;
  late double _progressValue;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _updateCachedValues();
  }

  void _initializeAnimations() {
    // Progress animation controller - only animation we need
    _progressController = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    );

    // Create progress animation
    _progressValue =
        widget.totalTasks > 0 ? widget.completedTasks / widget.totalTasks : 0.0;

    _progressAnimation = Tween<double>(
      begin: 0.0,
      end: _progressValue,
    ).animate(CurvedAnimation(
      parent: _progressController,
      curve: AnimationConstants.progressCurve,
    ));

    // Start progress animation
    _progressController.forward();
  }

  void _updateCachedValues() {
    _primaryColor = widget.primaryColor ?? AppColors.accentPurple;
    _backgroundColor =
        widget.backgroundColor ?? const Color.fromARGB(255, 38, 38, 38);
    _progressValue =
        widget.totalTasks > 0 ? widget.completedTasks / widget.totalTasks : 0.0;
    _progressPercentage = (_progressValue * 100).round();
  }

  @override
  void dispose() {
    _progressController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(CircularProgressIndicator3D oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Check if progress-related values changed
    bool progressChanged = oldWidget.completedTasks != widget.completedTasks ||
        oldWidget.totalTasks != widget.totalTasks;

    // Check if visual properties changed
    bool visualChanged = oldWidget.primaryColor != widget.primaryColor ||
        oldWidget.backgroundColor != widget.backgroundColor;

    if (progressChanged || visualChanged) {
      _updateCachedValues();

      if (progressChanged) {
        _progressAnimation = Tween<double>(
          begin: _progressAnimation.value,
          end: _progressValue,
        ).animate(CurvedAnimation(
          parent: _progressController,
          curve: AnimationConstants.progressCurve,
        ));
        _progressController.reset();
        _progressController.forward();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: SizedBox(
        width: widget.size,
        height: widget.size,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Static glow effect - no animation to prevent repaints
            RepaintBoundary(
              child: Container(
                width: widget.size,
                height: widget.size,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: _primaryColor.withValues(alpha: 0.08),
                      blurRadius: 40,
                      spreadRadius: 20,
                    ),
                  ],
                ),
              ),
            ),

            // Static glassmorphism ring - no animation
            RepaintBoundary(
              child: Container(
                width: widget.size,
                height: widget.size,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
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
                      color: Colors.black.withValues(alpha: 0.2),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                    BoxShadow(
                      color: _primaryColor.withValues(alpha: 0.1),
                      blurRadius: 40,
                      spreadRadius: -10,
                    ),
                  ],
                ),
              ),
            ),

            // Animated progress ring - only listens to progress controller
            AnimatedBuilder(
              animation: _progressController,
              builder: (context, child) {
                return RepaintBoundary(
                  child: CustomPaint(
                    size: Size(widget.size - 20, widget.size - 20),
                    painter: CircularProgress3DPainter(
                      progress: _progressAnimation.value,
                      primaryColor: _primaryColor,
                      backgroundColor: _backgroundColor,
                      strokeWidth: widget.strokeWidth * 1.2,
                      rotationOffset: 0.0, // Static rotation offset
                    ),
                  ),
                );
              },
            ),

            // Static center content - only rebuilds when progress values change
            RepaintBoundary(
              child: _buildCenterContent(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCenterContent() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Progress percentage
        Text(
          '$_progressPercentage%',
          style: AppTextStyles.h1.copyWith(
            fontSize: widget.size * 0.15,
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
            shadows: [
              Shadow(
                color: _primaryColor.withValues(alpha: 0.3),
                blurRadius: 10,
              ),
            ],
          ),
        ),

        const SizedBox(height: 4),

        // Task count
        if (!widget.showPercentage)
          Text(
            '${widget.completedTasks}/${widget.totalTasks} tasks',
            style: AppTextStyles.bodySmall.copyWith(
              fontSize: widget.size * 0.06,
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),

        const SizedBox(height: 8),

        // Status indicator
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: _getStatusColor().withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(AppBorderRadius.full),
            border: Border.all(
              color: _getStatusColor().withValues(alpha: 0.3),
              width: 1,
            ),
          ),
          child: Text(
            _getStatusText(),
            style: AppTextStyles.caption.copyWith(
              color: _getStatusColor(),
              fontWeight: FontWeight.w600,
              fontSize: widget.size * 0.04,
            ),
          ),
        ),
      ],
    );
  }

  Color _getStatusColor() {
    if (_progressValue >= 1.0) return AppColors.statusSuccess;
    if (_progressValue >= 0.7) return AppColors.accentGreen;
    if (_progressValue >= 0.4) return AppColors.accentYellow;
    if (widget.totalTasks == 0) return AppColors.accentGreen;
    return AppColors.accentOrange;
  }

  String _getStatusText() {
    if (_progressValue >= 1.0) return 'Complete';
    if (_progressValue >= 0.7) return 'Almost there';
    if (_progressValue >= 0.4) return 'In progress';
    if (widget.totalTasks == 0) return "Let's start";
    return 'Getting started';
  }
}

class CircularProgress3DPainter extends CustomPainter {
  final double progress;
  final Color primaryColor;
  final Color backgroundColor;
  final double strokeWidth;
  final double rotationOffset;

  const CircularProgress3DPainter({
    required this.progress,
    required this.primaryColor,
    required this.backgroundColor,
    required this.strokeWidth,
    this.rotationOffset = 0.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    // Background circle with 3D effect
    final backgroundPaint = Paint()
      ..color = backgroundColor.withValues(alpha: 0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    // Add inner shadow effect for depth
    final shadowPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.2)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth + 2
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius + 1, shadowPaint);
    canvas.drawCircle(center, radius, backgroundPaint);

    // Progress arc with gradient and 3D effect
    final progressPaint = Paint()
      ..shader = SweepGradient(
        colors: [
          primaryColor,
          primaryColor.withValues(alpha: 0.7),
          primaryColor,
          primaryColor.withValues(alpha: 0.9),
        ],
        stops: const [0.0, 0.3, 0.7, 1.0],
        startAngle: rotationOffset,
        endAngle: rotationOffset + 2 * math.pi,
      ).createShader(Rect.fromCircle(center: center, radius: radius))
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    // Highlight paint for 3D effect
    final highlightPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth / 3
      ..strokeCap = StrokeCap.round;

    if (progress > 0) {
      final sweepAngle = 2 * math.pi * progress;

      // Draw main progress arc
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        -math.pi / 2,
        sweepAngle,
        false,
        progressPaint,
      );

      // Draw highlight for 3D effect
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius - strokeWidth / 4),
        -math.pi / 2,
        sweepAngle,
        false,
        highlightPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CircularProgress3DPainter oldDelegate) {
    return progress != oldDelegate.progress ||
        primaryColor != oldDelegate.primaryColor ||
        backgroundColor != oldDelegate.backgroundColor ||
        strokeWidth != oldDelegate.strokeWidth ||
        rotationOffset != oldDelegate.rotationOffset;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CircularProgress3DPainter &&
        other.progress == progress &&
        other.primaryColor == primaryColor &&
        other.backgroundColor == backgroundColor &&
        other.strokeWidth == strokeWidth &&
        other.rotationOffset == rotationOffset;
  }

  @override
  int get hashCode {
    return Object.hash(
      progress,
      primaryColor,
      backgroundColor,
      strokeWidth,
      rotationOffset,
    );
  }
}
