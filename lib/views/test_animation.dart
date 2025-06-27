import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:math' as math;

import 'package:unstack/theme/app_theme.dart';

class FlamePainter extends CustomPainter {
  final double animationValue;

  FlamePainter(this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // Create flame particles
    for (int i = 0; i < 12; i++) {
      final angle = (i / 12) * 2 * math.pi;
      final distance = radius * 0.3 +
          (math.sin(animationValue * 2 * math.pi + i) * radius * 0.2);

      final x = center.dx + math.cos(angle) * distance;
      final y = center.dy + math.sin(angle) * distance;

      // Flame colors with opacity based on animation
      final colors = [
        Colors.orange.withOpacity(0.8 * animationValue),
        Colors.red.withOpacity(0.6 * animationValue),
        Colors.yellow.withOpacity(0.4 * animationValue),
      ];

      paint.color = colors[i % colors.length];

      // Draw flame particle with varying size
      final particleSize =
          3 + (math.sin(animationValue * 3 * math.pi + i * 0.5) * 2);
      canvas.drawCircle(Offset(x, y), particleSize, paint);
    }

    // Add some larger flame wisps
    for (int i = 0; i < 6; i++) {
      final angle = (i / 6) * 2 * math.pi + animationValue * math.pi;
      final distance = radius * 0.5 +
          (math.cos(animationValue * 1.5 * math.pi + i) * radius * 0.15);

      final x = center.dx + math.cos(angle) * distance;
      final y = center.dy + math.sin(angle) * distance;

      paint.color = Colors.deepOrange.withOpacity(0.3 * animationValue);
      canvas.drawCircle(Offset(x, y), 5, paint);
    }

    // Central flame glow
    paint.color = Colors.orange.withOpacity(0.1 * animationValue);
    canvas.drawCircle(center, radius * 0.8, paint);

    paint.color = Colors.red.withOpacity(0.05 * animationValue);
    canvas.drawCircle(center, radius * 0.6, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class StreakOverlay extends StatefulWidget {
  final int streakCount;

  const StreakOverlay({Key? key, required this.streakCount}) : super(key: key);

  @override
  _StreakOverlayState createState() => _StreakOverlayState();
}

class _StreakOverlayState extends State<StreakOverlay>
    with TickerProviderStateMixin {
  late AnimationController _mainController;
  late AnimationController _glowController;
  late AnimationController _rotationController;
  late AnimationController _flameController;

  late Animation<double> _slideAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<double> _glowAnimation;
  late Animation<double> _textSlideAnimation;
  late Animation<double> _flameAnimation;

  @override
  void initState() {
    super.initState();

    _mainController = AnimationController(
      duration: Duration(milliseconds: 1500),
      vsync: this,
    );

    _glowController = AnimationController(
      duration: Duration(milliseconds: 2000),
      vsync: this,
    );

    _rotationController = AnimationController(
      duration: Duration(milliseconds: 8000),
      vsync: this,
    );

    _flameController = AnimationController(
      duration: Duration(milliseconds: 1500),
      vsync: this,
    );

    _slideAnimation = Tween<double>(
      begin: 150.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _mainController,
      curve: Interval(0.0, 0.6, curve: Curves.easeOutCubic),
    ));

    _scaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _mainController,
      curve: Interval(0.2, 0.8, curve: Curves.elasticOut),
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _mainController,
      curve: Interval(0.5, 1.0, curve: Curves.easeInOut),
    ));

    _glowAnimation = Tween<double>(
      begin: 0.3,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _glowController,
      curve: Curves.easeInOut,
    ));

    _textSlideAnimation = Tween<double>(
      begin: 50.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _mainController,
      curve: Interval(0.6, 1.0, curve: Curves.easeOutCubic),
    ));

    _flameAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _flameController,
      curve: Curves.easeInOut,
    ));

    _startAnimations();
  }

  void _startAnimations() async {
    _mainController.forward();
    _glowController.repeat(reverse: true);
    _rotationController.repeat();
    _flameController.repeat(reverse: true);

    // Auto dismiss after 3 seconds
    await Future.delayed(Duration(seconds: 5));
    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  @override
  void dispose() {
    _mainController.dispose();
    _glowController.dispose();
    _rotationController.dispose();
    _flameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.center,
            radius: 1.2,
            colors: [
              Color(0xFF1A1A2E).withOpacity(0.1),
              Color(0xFF16213E).withOpacity(0.3),
              Color(0xFF0F0F23),
            ],
          ),
        ),
        child: Center(
          child: AnimatedBuilder(
            animation: _mainController,
            builder: (context, child) {
              return Transform.translate(
                offset: Offset(0, _slideAnimation.value),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Main Streak Container with 3D effect
                    Transform.scale(
                      scale: _scaleAnimation.value,
                      child: AnimatedBuilder(
                        animation: _glowAnimation,
                        builder: (context, child) {
                          return Container(
                            width: 200,
                            height: 200,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  AppColors.accentOrange,
                                  AppColors.accentYellow,
                                  AppColors.accentRed.withOpacity(0.8),
                                ],
                              ),
                              shape: BoxShape.circle,
                              boxShadow: [
                                // Multiple shadows for 3D depth
                                BoxShadow(
                                  color: AppColors.accentOrange
                                      .withOpacity(0.4 * _glowAnimation.value),
                                  blurRadius: 40,
                                  spreadRadius: 10,
                                ),
                                BoxShadow(
                                  color: AppColors.accentBlue
                                      .withOpacity(0.3 * _glowAnimation.value),
                                  blurRadius: 60,
                                  spreadRadius: 5,
                                ),
                                BoxShadow(
                                  color: Colors.white.withOpacity(0.1),
                                  blurRadius: 20,
                                  spreadRadius: -5,
                                  offset: Offset(-10, -10),
                                ),
                              ],
                            ),
                            child: Stack(
                              children: [
                                // Flame Animation Background
                                Positioned.fill(
                                  child: ClipOval(
                                    child: AnimatedBuilder(
                                      animation: _flameAnimation,
                                      builder: (context, child) {
                                        return CustomPaint(
                                          painter: FlamePainter(
                                              _flameAnimation.value),
                                          size: Size.infinite,
                                        );
                                      },
                                    ),
                                  ),
                                ),

                                // Gradient Overlay
                                Container(
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    gradient: LinearGradient(
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                      colors: [
                                        Colors.white.withOpacity(0.2),
                                        Colors.transparent,
                                        Colors.black.withOpacity(0.1),
                                      ],
                                    ),
                                  ),
                                ),

                                // Content
                                Positioned.fill(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      // Fire Icon with glow
                                      Container(
                                        padding: EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          gradient: RadialGradient(
                                            colors: [
                                              Colors.orange.withOpacity(0.3),
                                              Colors.transparent,
                                            ],
                                          ),
                                        ),
                                        child: Icon(
                                          CupertinoIcons.flame_fill,
                                          size: 70,
                                          color: AppColors.whiteColor,
                                        ),
                                      ),

                                      // Streak Number
                                      RichText(
                                        text: TextSpan(children: [
                                          TextSpan(
                                            text: '${widget.streakCount}',
                                            style: TextStyle(
                                              fontSize: 42,
                                              fontFamily: 'Montserrat',
                                              fontWeight: FontWeight.w800,
                                              color: AppColors.textPrimary,
                                              letterSpacing: -1,
                                              shadows: [
                                                Shadow(
                                                  color: Colors.black
                                                      .withOpacity(0.3),
                                                  offset: Offset(2, 2),
                                                  blurRadius: 8,
                                                ),
                                              ],
                                            ),
                                          ),
                                          TextSpan(
                                            text: '  Streak',
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontFamily: 'Montserrat',
                                              fontWeight: FontWeight.w700,
                                              color: AppColors.textPrimary,
                                              letterSpacing: -1,
                                              shadows: [
                                                Shadow(
                                                  color: Colors.black
                                                      .withOpacity(0.3),
                                                  offset: Offset(2, 2),
                                                  blurRadius: 8,
                                                ),
                                              ],
                                            ),
                                          ),
                                        ]),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),

                    SizedBox(height: 40),

                    // +1 Day Badge with modern design
                    Transform.scale(
                      scale: _scaleAnimation.value,
                      child: Transform.translate(
                        offset: Offset(0, _textSlideAnimation.value),
                        child: Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: 32, vertical: 16),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                AppColors.backgroundSecondary,
                                AppColors.backgroundTertiary,
                              ],
                            ),
                            borderRadius: BorderRadius.circular(50),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.accentPurple.withOpacity(0.3),
                                blurRadius: 20,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                          child: Text(
                            '+1 DAY',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                              letterSpacing: 2,
                            ),
                          ),
                        ),
                      ),
                    ),

                    SizedBox(height: 24),

                    // Streak Text with modern typography
                    Transform.translate(
                      offset: Offset(0, _textSlideAnimation.value),
                      child: Text(
                        '${widget.streakCount} DAY STREAK',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.w900,
                          color: AppColors.textPrimary,
                          letterSpacing: 4,
                          shadows: [
                            Shadow(
                              color: AppColors.accentPurple.withOpacity(0.5),
                              offset: Offset(0, 0),
                              blurRadius: 20,
                            ),
                          ],
                        ),
                      ),
                    ),

                    SizedBox(height: 60),

                    // Congratulations with fade effect
                    FadeTransition(
                      opacity: _fadeAnimation,
                      child: Transform.translate(
                        offset: Offset(0, _textSlideAnimation.value * 0.5),
                        child: Column(
                          children: [
                            Text(
                              'INCREDIBLE!',
                              style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.w800,
                                color: AppColors.textPrimary,
                                letterSpacing: 3,
                              ),
                            ),
                            SizedBox(height: 16),
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 40),
                              child: Text(
                                'You\'re absolutely crushing it!\nKeep the momentum going strong.',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w400,
                                  color: AppColors.textPrimary.withOpacity(0.8),
                                  height: 1.6,
                                  letterSpacing: 0.5,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
