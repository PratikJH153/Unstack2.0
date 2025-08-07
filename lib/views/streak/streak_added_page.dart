import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:unstack/constants/cheers.dart';
import 'dart:math' as math;
import 'dart:ui';

import 'package:unstack/theme/theme.dart';
import 'package:unstack/utils/app_size.dart';

class ModernFlamePainter extends CustomPainter {
  final double animationValue;

  ModernFlamePainter(this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 1;

    // Create subtle 3D flame particles with depth
    for (int i = 0; i < 8; i++) {
      final angle = (i / 8) * 2 * math.pi;
      final distance = radius * 0.25 +
          (math.sin(animationValue * 1.5 * math.pi + i) * radius * 0.15);

      final x = center.dx + math.cos(angle) * distance;
      final y = center.dy + math.sin(angle) * distance;

      // Minimalist flame colors with subtle opacity
      final colors = [
        Color(0xFFFF6B35).withAlpha((255 * 0.3 * animationValue).toInt()),
        Color(0xFFFF8E53).withAlpha((255 * 0.2 * animationValue).toInt()),
        Color(0xFFFFA726).withAlpha((255 * 0.15 * animationValue).toInt()),
      ];

      paint.color = colors[i % colors.length];

      // Smaller, more refined particles
      final particleSize =
          2 + (math.sin(animationValue * 2 * math.pi + i * 0.3) * 1);
      canvas.drawCircle(Offset(x, y), particleSize, paint);
    }

    // Subtle central glow
    paint.color =
        Color(0xFFFF6B35).withAlpha((255 * 0.05 * animationValue).toInt());
    canvas.drawCircle(center, radius * 0.6, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class ModernStreakOverlay extends StatefulWidget {
  final int streakCount;
  final String userName;

  const ModernStreakOverlay({
    super.key,
    required this.streakCount,
    required this.userName,
  });

  @override
  State<ModernStreakOverlay> createState() => _ModernStreakOverlayState();
}

class _ModernStreakOverlayState extends State<ModernStreakOverlay>
    with TickerProviderStateMixin {
  late AnimationController _mainController;
  late AnimationController _glowController;
  late AnimationController _flameController;

  late Animation<double> _slideAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<double> _glowAnimation;
  late Animation<double> _textSlideAnimation;
  late Animation<double> _flameAnimation;

  late String title;
  late String subtitle;

  @override
  void initState() {
    super.initState();

    final random = math.Random();
    final randomIndex = random.nextInt(cheers.length);
    title = cheers[randomIndex]['title']!;
    subtitle = cheers[randomIndex]['subtitle']!;

    _mainController = AnimationController(
      duration: Duration(milliseconds: 1200),
      vsync: this,
    );

    _glowController = AnimationController(
      duration: Duration(milliseconds: 3000),
      vsync: this,
    );

    _flameController = AnimationController(
      duration: Duration(milliseconds: 2000),
      vsync: this,
    );

    _slideAnimation = Tween<double>(
      begin: 80.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _mainController,
      curve: Interval(0.0, 0.7, curve: Curves.easeOutCubic),
    ));

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _mainController,
      curve: Interval(0.2, 0.8, curve: Curves.easeOutBack),
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _mainController,
      curve: Interval(0.4, 1.0, curve: Curves.easeInOut),
    ));

    _glowAnimation = Tween<double>(
      begin: 0.4,
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
    _flameController.repeat(reverse: true);

    await Future.delayed(Duration(seconds: 6));
    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  @override
  void dispose() {
    _mainController.dispose();
    _glowController.dispose();
    _flameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color.fromARGB(255, 49, 49, 49).withAlpha((255 * 0.1).toInt()),
              Color.fromARGB(255, 46, 46, 46).withAlpha((255 * 0.2).toInt()),
              Color.fromARGB(255, 34, 34, 34).withAlpha((255 * 0.3).toInt()),
              Color.fromARGB(255, 25, 25, 25).withAlpha((255 * 0.4).toInt()),
            ],
          ),
        ),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.white.withAlpha((255 * 0.1).toInt()),
                  Colors.white.withAlpha((255 * 0.05).toInt()),
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
                        // Modern 3D Streak Container
                        Transform.scale(
                          scale: _scaleAnimation.value,
                          child: AnimatedBuilder(
                            animation: _glowAnimation,
                            builder: (context, child) {
                              return Container(
                                width: () {
                                  return AppSize(context).height * 0.28;
                                }(),
                                height: () {
                                  return AppSize(context).height * 0.28;
                                }(),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [
                                      Color(0xFF1A1A1A),
                                      Color(0xFF0D0D0D),
                                    ],
                                  ),
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    // 3D depth shadow
                                    BoxShadow(
                                      color: Colors.black
                                          .withAlpha((255 * 0.6).toInt()),
                                      blurRadius: 30,
                                      spreadRadius: 5,
                                      offset: Offset(8, 8),
                                    ),
                                    // Inner highlight
                                    BoxShadow(
                                      color: Color(0xFF2A2A2A)
                                          .withAlpha((255 * 0.3).toInt()),
                                      blurRadius: 15,
                                      spreadRadius: -5,
                                      offset: Offset(-4, -4),
                                    ),
                                    // Accent glow
                                    BoxShadow(
                                      color: AppColors.accentOrange.withAlpha(
                                          (255 * 0.2 * (_glowAnimation.value))
                                              .toInt()),
                                      blurRadius: 80 * _glowAnimation.value,
                                      spreadRadius:
                                          1 * _glowAnimation.value * 5,
                                    ),
                                  ],
                                ),
                                child: Stack(
                                  children: [
                                    // Subtle flame animation
                                    Positioned.fill(
                                      child: ClipOval(
                                        child: AnimatedBuilder(
                                          animation: _flameAnimation,
                                          builder: (context, child) {
                                            return CustomPaint(
                                              painter: ModernFlamePainter(
                                                  _flameAnimation.value * 2),
                                              size: Size.infinite,
                                            );
                                          },
                                        ),
                                      ),
                                    ),

                                    // 3D surface gradient
                                    Container(
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        gradient: LinearGradient(
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                          colors: [
                                            Color(0xFF2A2A2A)
                                                .withAlpha((255 * 0.3).toInt()),
                                            Colors.transparent,
                                            Color(0xFF000000)
                                                .withAlpha((255 * 0.2).toInt()),
                                          ],
                                        ),
                                      ),
                                    ),

                                    // Content
                                    Positioned.fill(
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          // Minimalist fire icon
                                          Container(
                                            padding: EdgeInsets.all(6),
                                            child: Icon(
                                              CupertinoIcons.flame_fill,
                                              size: 60 *
                                                  AppSize(context).height *
                                                  0.00115,
                                              color: Color(0xFFFF6B35),
                                            ),
                                          ),

                                          SizedBox(height: 2),

                                          // Clean streak number
                                          Text(
                                            '${widget.streakCount}',
                                            style: TextStyle(
                                              fontSize: 42 *
                                                  ResponsiveUtils.fontScale,
                                              fontWeight: FontWeight.w900,
                                              color: Colors.white,
                                              letterSpacing: -0.5,
                                            ),
                                          ),

                                          // Subtle label
                                          Text(
                                            'STREAK',
                                            style: TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w600,
                                              color: Color(0xFF999999),
                                              letterSpacing: 1.2,
                                            ),
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

                        SizedBox(height: 32),

                        // Minimalist achievement text
                        FadeTransition(
                          opacity: _fadeAnimation,
                          child: Column(
                            children: [
                              Text(
                                'Streak Updated',
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                  letterSpacing: 0.3,
                                ),
                              ),
                              SizedBox(height: 8),
                              Container(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 24, vertical: 12),
                                decoration: BoxDecoration(
                                  color: Color(0xFF1A1A1A),
                                  borderRadius: BorderRadius.circular(24),
                                  border: Border.all(
                                    color: Color(0xFF333333),
                                    width: 1,
                                  ),
                                ),
                                child: Text(
                                  '+1 Day',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w800,
                                    color: Color(0xFFFF6B35),
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        SizedBox(height: AppSpacing.xxl),

                        // Congratulations with fade effect
                        FadeTransition(
                          opacity: _fadeAnimation,
                          child: Transform.translate(
                            offset: Offset(0, _textSlideAnimation.value * 0.5),
                            child: Column(
                              children: [
                                Text(
                                  title.toUpperCase(),
                                  style: AppTextStyles.h2.copyWith(
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.textPrimary,
                                    letterSpacing: 3,
                                  ),
                                ),
                                SizedBox(height: AppSpacing.sm),
                                Container(
                                  padding: EdgeInsets.symmetric(horizontal: 40),
                                  child: Text(
                                    "${widget.userName}, $subtitle",
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w400,
                                      color: AppColors.textPrimary
                                          .withAlpha((255 * 0.8).toInt()),
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
        ),
      ),
    );
  }
}
