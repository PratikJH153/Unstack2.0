import 'package:flutter/material.dart';

import 'package:unstack/routes/route.dart';
import 'package:unstack/theme/theme.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _logoController;
  late AnimationController _breathingController;
  late AnimationController _textController;

  bool _showLogo = true;
  bool _showBreathingText = false;
  String _breathingText = "Breathe in";

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _startAnimationSequence();
  }

  void _initializeAnimations() {
    _logoController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );

    _breathingController = AnimationController(
      vsync: this,
      duration: AnimationConstants.breathingCycle,
    );

    // Text fade animation
    _textController = AnimationController(
      vsync: this,
      duration: AnimationConstants.fast,
    );

    _breathingController.addListener(() {
      final progress = _breathingController.value;

      if (progress <= 0.428) {
        if (_breathingText != "Breathe in") {
          setState(() {
            _breathingText = "Breathe in";
          });
        }
      } else if (progress <= 0.571) {
      } else {
        if (_breathingText != "Breathe out") {
          setState(() {
            _breathingText = "Breathe out";
          });
        }
      }
    });

    _breathingController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _initializeApp();
      }
    });
  }

  void _startAnimationSequence() async {
    await Future.delayed(const Duration(milliseconds: 800));

    if (mounted) {
      _logoController.forward();
      await Future.delayed(const Duration(milliseconds: 1500));
      setState(() {
        _showLogo = false;
        _showBreathingText = true;
      });
      _textController.forward();
    }

    if (mounted) {
      _breathingController.forward();
    }
  }

  Future<void> _initializeApp() async {
    _navigateToWrapper();
    // try {
    //   // final prefs = await SharedPreferences.getInstance();
    //   // final onboardingCompleted =
    //   //     prefs.getBool('onboarding_completed') ?? false;

    //   _navigateToWrapper();
    // } catch (e) {
    //   if (mounted) {
    //     _navigateToOnboarding();
    //   }
    // }
  }

  void _navigateToWrapper() {
    RouteUtils.pushReplacementNamed(
      context,
      RoutePaths.wrapper,
    );
  }

  @override
  void dispose() {
    _logoController.dispose();
    _breathingController.dispose();
    _textController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    return Scaffold(
      backgroundColor: AppColors.backgroundPrimary,
      body: SizedBox(
        height: double.infinity,
        width: double.infinity,
        child: Stack(
          alignment: Alignment.center,
          children: [
            if (_showLogo) LogoWidget(logoController: _logoController),
            if (_showBreathingText)
              BreathingText(
                  textController: _textController,
                  breathingText: _breathingText),
            if (_showBreathingText)
              BreathingBubble(
                  breathingController: _breathingController, height: height),
          ],
        ),
      ),
    );
  }
}

class LogoWidget extends StatelessWidget {
  const LogoWidget({
    super.key,
    required AnimationController logoController,
  }) : _logoController = logoController;

  final AnimationController _logoController;

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: Tween<double>(begin: 1.0, end: 0.0).animate(
        CurvedAnimation(
          parent: _logoController,
          curve: Curves.easeOut,
        ),
      ),
      child: Image.asset(
        'assets/logo/unstack.png',
        height: 500,
        width: 500,
      ),
    );
  }
}

class BreathingText extends StatelessWidget {
  const BreathingText({
    super.key,
    required AnimationController textController,
    required String breathingText,
  })  : _textController = textController,
        _breathingText = breathingText;

  final AnimationController _textController;
  final String _breathingText;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: MediaQuery.of(context).size.height * 0.1,
      child: FadeTransition(
        opacity: _textController,
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          child: Text(
            _breathingText,
            key: ValueKey(_breathingText),
            style: AppTextStyles.h1.copyWith(
              fontSize: 36,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
              letterSpacing: 1.2,
            ),
          ),
        ),
      ),
    );
  }
}

class BreathingBubble extends StatelessWidget {
  const BreathingBubble({
    super.key,
    required AnimationController breathingController,
    required this.height,
  }) : _breathingController = breathingController;

  final AnimationController _breathingController;
  final double height;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _breathingController,
      builder: (context, child) {
        final progress = _breathingController.value;
        double circleProgress;

        if (progress <= 0.428) {
          final normalizedProgress = (progress / 0.428).clamp(0.0, 1.0);
          circleProgress = Curves.easeInOut.transform(normalizedProgress);
        } else if (progress <= 0.571) {
          circleProgress = 1.0;
        } else {
          final outProgress = ((progress - 0.571) / 0.429).clamp(0.0, 1.0);
          circleProgress = Curves.easeInOut.transform(1.0 - outProgress);
        }

        final size = 150.0 + (100.0 * circleProgress);

        return Positioned(
          bottom: -300,
          child: Container(
            height: size * (height * 0.00265) * 1.7,
            width: size * (height * 0.00265) * 1.7,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.accentPurple,
              boxShadow: [
                BoxShadow(
                  color: AppColors.accentPurple.withValues(alpha: 0.5),
                  blurRadius: 50,
                  spreadRadius: 15,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
