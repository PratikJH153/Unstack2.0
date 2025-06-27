import 'package:flutter/material.dart';
import 'package:unstack/utils/app_logger.dart';

class AppRouteObserver extends RouteObserver<PageRoute<dynamic>> {
  final List<String> _routeStack = [];

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPush(route, previousRoute);
    if (route is PageRoute) {
      _routeStack.add(route.settings.name ?? 'Unknown');
      _logTransition('PUSH', route, previousRoute);
    }
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPop(route, previousRoute);
    if (route is PageRoute) {
      _routeStack.removeLast();
      _logTransition('POP', route, previousRoute);
    }
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    super.didReplace(newRoute: newRoute, oldRoute: oldRoute);
    if (newRoute is PageRoute && oldRoute is PageRoute) {
      final index =
          _routeStack.indexWhere((name) => name == oldRoute.settings.name);
      if (index != -1) {
        _routeStack[index] = newRoute.settings.name ?? 'Unknown';
      }
      _logTransition('REPLACE', newRoute, oldRoute);
    }
  }

  @override
  void didRemove(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didRemove(route, previousRoute);
    if (route is PageRoute) {
      _routeStack.remove(route.settings.name);
      _logTransition('REMOVE', route, previousRoute);
    }
  }

  void _logTransition(
    String action,
    Route<dynamic> route,
    Route<dynamic>? previousRoute,
  ) {
    AppLogger.debug(
      '🚗🚗🚗🚗 $action: ${previousRoute?.settings.name} -> ${route.settings.name}',
    );
    // _printRouteStack();
  }

  // void _printRouteStack() {
  //   AppLogger.info('Current Route Stack:');
  //   for (int i = 0; i < _routeStack.length; i++) {
  //     AppLogger.info('  ${i + 1}. ${_routeStack[i]}');
  //   }
  //   AppLogger.info('----------------------');
  // }
}
