// Slide transition from bottom to top
import 'package:flutter/material.dart';

class SlideRouteBuilder<T> extends PageRouteBuilder<T> {
  SlideRouteBuilder({
    required this.page,
    required this.settings,
  }) : super(
          settings: settings,
          pageBuilder: (
            BuildContext context,
            Animation<double> animation,
            Animation<double> secondaryAnimation,
          ) =>
              page,
          transitionsBuilder: (
            BuildContext context,
            Animation<double> animation,
            Animation<double> secondaryAnimation,
            Widget child,
          ) {
            const begin = Offset(0, 1);
            const end = Offset.zero;
            const curve = Curves.easeInOut;
            final tween =
                Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
            final slideAnimation = animation.drive(tween);

            return SlideTransition(
              position: slideAnimation,
              child: child,
            );
          },
          transitionDuration: const Duration(milliseconds: 300),
        );

  final Widget page;
  @override
  final RouteSettings settings;

  @override
  bool get allowSnapshotting => true;
  @override
  bool get maintainState => true;
  @override
  bool canTransitionTo(TransitionRoute<dynamic> nextRoute) => true;
  @override
  bool canTransitionFrom(TransitionRoute<dynamic> previousRoute) => true;
  @override
  bool get fullscreenDialog => false;
  @override
  bool get opaque => false;
}

// Scale transition with fade
class ScaleRouteBuilder<T> extends PageRouteBuilder<T> {
  ScaleRouteBuilder({
    required this.page,
    required this.settings,
  }) : super(
          settings: settings,
          pageBuilder: (
            BuildContext context,
            Animation<double> animation,
            Animation<double> secondaryAnimation,
          ) =>
              page,
          transitionsBuilder: (
            BuildContext context,
            Animation<double> animation,
            Animation<double> secondaryAnimation,
            Widget child,
          ) {
            const begin = 0.0;
            const end = 1.0;
            const curve = Curves.easeInOut;

            final scaleTween =
                Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
            final fadeAnimation = animation.drive(scaleTween);

            return ScaleTransition(
              scale: fadeAnimation,
              child: FadeTransition(
                opacity: animation,
                child: child,
              ),
            );
          },
          transitionDuration: const Duration(milliseconds: 300),
        );

  final Widget page;
  @override
  final RouteSettings settings;

  @override
  bool get allowSnapshotting => true;
  @override
  bool get maintainState => true;
  @override
  bool canTransitionTo(TransitionRoute<dynamic> nextRoute) => true;
  @override
  bool canTransitionFrom(TransitionRoute<dynamic> previousRoute) => true;
  @override
  bool get fullscreenDialog => false;
  @override
  bool get opaque => false;
}
