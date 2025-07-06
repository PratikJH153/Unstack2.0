import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:unstack/theme/app_theme.dart';

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
  late AnimationController _pulseController;
  late AnimationController _rotationController;

  late Animation<double> _progressAnimation;
  late Animation<double> _pulseAnimation;
  late Animation<double> _rotationAnimation;

  @override
  void initState() {
    super.initState();

    // Progress animation controller
    _progressController = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    );

    // Pulse animation controller for the glow effect
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    // Rotation animation controller for subtle 3D effect
    _rotationController = AnimationController(
      duration: const Duration(seconds: 60),
      vsync: this,
    );

    // Create animations
    _progressAnimation = Tween<double>(
      begin: 0.0,
      end: widget.totalTasks > 0
          ? widget.completedTasks / widget.totalTasks
          : 0.0,
    ).animate(CurvedAnimation(
      parent: _progressController,
      curve: Curves.easeOutCubic,
    ));

    _pulseAnimation = Tween<double>(
      begin: 0.7,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    _rotationAnimation = Tween<double>(
      begin: 0.0,
      end: 2 * math.pi,
    ).animate(CurvedAnimation(
      parent: _rotationController,
      curve: Curves.linear,
    ));

    // Start animations
    _progressController.forward();
    _pulseController.repeat(reverse: true);
    _rotationController.repeat();
  }

  @override
  void dispose() {
    _progressController.dispose();
    _pulseController.dispose();
    _rotationController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(CircularProgressIndicator3D oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.completedTasks != widget.completedTasks ||
        oldWidget.totalTasks != widget.totalTasks) {
      _progressAnimation = Tween<double>(
        begin: _progressAnimation.value,
        end: widget.totalTasks > 0
            ? widget.completedTasks / widget.totalTasks
            : 0.0,
      ).animate(CurvedAnimation(
        parent: _progressController,
        curve: Curves.easeOutCubic,
      ));
      _progressController.reset();
      _progressController.forward();
    }
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = widget.primaryColor ?? AppColors.accentPurple;
    final backgroundColor =
        widget.backgroundColor ?? const Color.fromARGB(255, 38, 38, 38);
    final progressPercentage = widget.totalTasks > 0
        ? (widget.completedTasks / widget.totalTasks * 100).round()
        : 0;

    return AnimatedBuilder(
      animation: Listenable.merge([
        _progressController,
        _pulseController,
        _rotationController,
      ]),
      builder: (context, child) {
        return GestureDetector(
          onTap: widget.onTap,
          child: SizedBox(
            width: widget.size,
            height: widget.size,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Background glow effect (fixed size to prevent morphing)
                Container(
                  width: widget.size,
                  height: widget.size,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: primaryColor.withValues(
                            alpha: 0.1 * _pulseAnimation.value),
                        blurRadius: 50 * _pulseAnimation.value,
                        spreadRadius: 20,
                      ),
                    ],
                  ),
                ),

                // Outer glassmorphism ring
                Container(
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
                        color: primaryColor.withValues(alpha: 0.1),
                        blurRadius: 40,
                        spreadRadius: -10,
                      ),
                    ],
                  ),
                ),

                // 3D Progress Ring (removed distorting transforms)
                CustomPaint(
                  size: Size(widget.size - 20, widget.size - 20),
                  painter: CircularProgress3DPainter(
                    progress: _progressAnimation.value,
                    primaryColor: primaryColor,
                    backgroundColor: backgroundColor,
                    strokeWidth: widget.strokeWidth * 1.2,
                    rotationOffset: _rotationAnimation.value *
                        0.05, // Subtle rotation for gradient
                  ),
                ),

                // Center content
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Progress percentage
                    if (widget.showPercentage)
                      Text(
                        '$progressPercentage%',
                        style: AppTextStyles.h1.copyWith(
                          fontSize: widget.size * 0.15,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                          shadows: [
                            Shadow(
                              color: primaryColor.withValues(alpha: 0.3),
                              blurRadius: 10,
                            ),
                          ],
                        ),
                      )
                    else
                      Text(
                        '$progressPercentage%',
                        style: AppTextStyles.h1.copyWith(
                          fontSize: widget.size * 0.15,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                          shadows: [
                            Shadow(
                              color: primaryColor.withValues(alpha: 0.3),
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
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: _getStatusColor().withValues(alpha: 0.2),
                        borderRadius:
                            BorderRadius.circular(AppBorderRadius.full),
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
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Color _getStatusColor() {
    final progress =
        widget.totalTasks > 0 ? widget.completedTasks / widget.totalTasks : 0.0;
    if (progress >= 1.0) return AppColors.statusSuccess;
    if (progress >= 0.7) return AppColors.accentGreen;
    if (progress >= 0.4) return AppColors.accentYellow;
    if (widget.totalTasks == 0) return AppColors.accentGreen;
    return AppColors.accentOrange;
  }

  String _getStatusText() {
    final progress =
        widget.totalTasks > 0 ? widget.completedTasks / widget.totalTasks : 0.0;
    if (progress >= 1.0) return 'Complete';
    if (progress >= 0.7) return 'Almost there';
    if (progress >= 0.4) return 'In progress';
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

  CircularProgress3DPainter({
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
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
