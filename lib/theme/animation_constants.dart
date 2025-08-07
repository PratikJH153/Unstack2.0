import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

/// Centralized animation constants for consistent animations throughout the app
/// Based on the app's 3-second timing patterns and Apple design principles
class AnimationConstants {
  AnimationConstants._();

  // MARK: - Duration Constants
  /// Ultra-fast animations for micro-interactions (150ms)
  static const Duration ultraFast = Duration(milliseconds: 150);
  
  /// Fast animations for quick feedback (300ms)
  static const Duration fast = Duration(milliseconds: 300);
  
  /// Standard animations for most UI transitions (500ms)
  static const Duration standard = Duration(milliseconds: 500);
  
  /// Slow animations for emphasis and important transitions (800ms)
  static const Duration slow = Duration(milliseconds: 800);
  
  /// Breathing animations following 3-second pattern (3000ms)
  static const Duration breathing = Duration(milliseconds: 3000);
  
  /// Hold-to-complete animations (3000ms)
  static const Duration holdToComplete = Duration(milliseconds: 3000);

  // MARK: - Curve Constants
  /// Standard easing curve for most animations
  static const Curve standardCurve = Curves.easeOutCubic;
  
  /// Gentle curve for subtle animations
  static const Curve gentleCurve = Curves.easeOut;
  
  /// Bouncy curve for playful interactions
  static const Curve bouncyCurve = Curves.elasticOut;
  
  /// Back curve for emphasis
  static const Curve backCurve = Curves.easeOutBack;
  
  /// Linear curve for progress indicators
  static const Curve linearCurve = Curves.linear;

  // MARK: - Slide Animation Values
  /// Standard slide distance for slideY animations
  static const double slideDistance = 0.3;
  
  /// Small slide distance for subtle movements
  static const double slideDistanceSmall = 0.2;
  
  /// Large slide distance for dramatic entrances
  static const double slideDistanceLarge = 0.4;

  // MARK: - Delay Constants
  /// No delay
  static const Duration noDelay = Duration.zero;
  
  /// Short delay for staggered animations
  static const Duration shortDelay = Duration(milliseconds: 100);
  
  /// Medium delay for sequential animations
  static const Duration mediumDelay = Duration(milliseconds: 200);
  
  /// Long delay for dramatic timing
  static const Duration longDelay = Duration(milliseconds: 400);

  // MARK: - Scale Animation Values
  /// Standard scale for scale animations
  static const Offset standardScale = Offset(0.95, 0.95);
  
  /// Small scale for subtle effects
  static const Offset smallScale = Offset(0.98, 0.98);
  
  /// Large scale for dramatic effects
  static const Offset largeScale = Offset(0.8, 0.8);

  // MARK: - Route Transition Constants
  /// Standard route transition duration
  static const Duration routeTransition = Duration(milliseconds: 400);
  
  /// Fast route transition for quick navigation
  static const Duration routeTransitionFast = Duration(milliseconds: 300);
  
  /// Slow route transition for modal presentations
  static const Duration routeTransitionSlow = Duration(milliseconds: 500);

  // MARK: - Stagger Animation Helpers
  /// Calculate staggered delay based on index
  static Duration staggerDelay(int index, {Duration baseDelay = const Duration(milliseconds: 50)}) {
    return Duration(milliseconds: baseDelay.inMilliseconds * index);
  }

  // MARK: - Common Animation Extensions
  /// Standard slide up animation
  static Widget slideUp(Widget child, {Duration? delay}) {
    return child
        .animate()
        .slideY(
          begin: slideDistance,
          duration: standard,
          curve: standardCurve,
        )
        .fadeIn(delay: delay ?? noDelay);
  }

  /// Standard slide down animation
  static Widget slideDown(Widget child, {Duration? delay}) {
    return child
        .animate()
        .slideY(
          begin: -slideDistance,
          duration: standard,
          curve: standardCurve,
        )
        .fadeIn(delay: delay ?? noDelay);
  }

  /// Standard fade in animation
  static Widget fadeIn(Widget child, {Duration? delay, Duration? duration}) {
    return child
        .animate()
        .fadeIn(
          delay: delay ?? noDelay,
          duration: duration ?? standard,
        );
  }

  /// Standard scale animation
  static Widget scaleIn(Widget child, {Duration? delay, Offset? scale}) {
    return child
        .animate()
        .scale(
          begin: scale ?? standardScale,
          duration: standard,
          curve: standardCurve,
        )
        .fadeIn(delay: delay ?? noDelay);
  }

  /// Staggered list item animation
  static Widget staggeredListItem(Widget child, int index) {
    return child
        .animate()
        .slideY(
          begin: slideDistance,
          duration: Duration(milliseconds: standard.inMilliseconds + (index * 50)),
          curve: standardCurve,
        )
        .fadeIn();
  }

  // MARK: - Button Animation Constants
  /// Button press scale for Duolingo-style interactions
  static const Offset buttonPressScale = Offset(0.98, 0.98);
  
  /// Button animation duration
  static const Duration buttonAnimation = Duration(milliseconds: 150);

  // MARK: - Progress Animation Constants
  /// Progress indicator animation duration
  static const Duration progressAnimation = Duration(milliseconds: 800);
  
  /// Progress curve
  static const Curve progressCurve = Curves.easeOutCubic;

  // MARK: - Breathing Animation Constants
  /// Breathing in duration (3 seconds)
  static const Duration breatheIn = Duration(milliseconds: 3000);
  
  /// Hold duration (1 second)
  static const Duration breatheHold = Duration(milliseconds: 1000);
  
  /// Breathing out duration (3 seconds)
  static const Duration breatheOut = Duration(milliseconds: 3000);
  
  /// Total breathing cycle (7 seconds)
  static const Duration breathingCycle = Duration(milliseconds: 7000);
}

/// Extension methods for easier animation usage
extension AnimationExtensions on Widget {
  /// Apply standard slide up animation
  Widget slideUpStandard({Duration? delay}) {
    return AnimationConstants.slideUp(this, delay: delay);
  }

  /// Apply standard slide down animation
  Widget slideDownStandard({Duration? delay}) {
    return AnimationConstants.slideDown(this, delay: delay);
  }

  /// Apply standard fade in animation
  Widget fadeInStandard({Duration? delay, Duration? duration}) {
    return AnimationConstants.fadeIn(this, delay: delay, duration: duration);
  }

  /// Apply standard scale animation
  Widget scaleInStandard({Duration? delay, Offset? scale}) {
    return AnimationConstants.scaleIn(this, delay: delay, scale: scale);
  }

  /// Apply staggered list animation
  Widget staggeredList(int index) {
    return AnimationConstants.staggeredListItem(this, index);
  }
}
