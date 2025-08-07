import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:unstack/routes/utils/dismissible_wrapper.dart';

import 'package:unstack/routes/animation/slide_route_builder.dart';
import 'package:unstack/screens/auth/name_input_screen.dart';
import 'package:unstack/screens/auth/onboarding_screen.dart';
import 'package:unstack/screens/auth/sign_in_page.dart';
import 'package:unstack/screens/auth/splash_screen.dart';
import 'package:unstack/screens/auth/wrapper.dart';
import 'package:unstack/screens/tasks/add_task_page.dart';
import 'package:unstack/screens/home/home.dart';
import 'package:unstack/screens/profile/profile_page.dart';
import 'package:unstack/screens/tasks/tasks_list.dart';
import 'package:unstack/views/tasks/task_details_page.dart';
import 'package:unstack/screens/streak/streak_page.dart';
import 'package:unstack/screens/tasks/progress_analytics_page.dart';
import 'route_paths.dart';

class AppRouter {
  static Route<dynamic>? generateRoute(RouteSettings settings) {
    // Regular route handling
    switch (settings.name) {
      case RoutePaths.wrapper:
        return _buildRoute(
          settings: settings,
          page: const PopScope(
            canPop: false, // Prevents back navigation
            child: WrapperPage(),
          ),
        );
      case RoutePaths.splashScreen:
        return _buildRoute(
          settings: settings,
          page: const PopScope(
            canPop: false, // Prevents back navigation
            child: SplashScreen(),
          ),
        );
      case RoutePaths.onboardingScreen:
        return _buildRoute(
          settings: settings,
          page: const PopScope(
            canPop: false, // Prevents back navigation
            child: OnboardingScreen(),
          ),
        );
      case RoutePaths.nameInputScreen:
        return _buildRoute(
          settings: settings,
          page: NameInputScreen(),
        );
      case RoutePaths.homePage:
        return _buildRoute(
          settings: settings,
          page: const PopScope(
            canPop: false, // Prevents back navigation
            child: HomePage(),
          ),
        );
      case RoutePaths.tasksListPage:
        return _buildRoute(
          page: const TasksListPage(),
          settings: settings,
        );
      case RoutePaths.taskDetailsPage:
        final args = settings.arguments as Map<String, dynamic>?;
        return _buildRoute(
          page: TaskDetailsPage(
            heroTag: args?['heroTag'] ?? 'task_details',
            task: args?['task'],
          ),
          settings: settings,
        );
      case RoutePaths.streakPage:
        return _buildRoute(
          page: const StreakPage(),
          settings: settings,
        );
      case RoutePaths.addTaskPage:
        return _buildRoute(
          page: AddTaskPage(
            routeSettings: settings,
          ),
          settings: settings,
        );

      case RoutePaths.profilePage:
        return _buildRoute(
          page: const ProfilePage(),
          settings: settings,
        );
      case RoutePaths.signInPage:
        return _buildRoute(
          page: const SignInPage(),
          settings: settings,
        );
      case RoutePaths.progressAnalyticsPage:
        final args = settings.arguments as Map<String, dynamic>?;
        return _buildRoute(
          page: ProgressAnalyticsPage(
            tasks: args?['tasks'] ?? [],
          ),
          settings: settings,
        );
      default:
        return _buildRoute(
          settings: settings,
          page: Container(),
        );
    }
  }

  static Route<dynamic> _buildRoute({
    required Widget page,
    required RouteSettings settings,
    bool shouldFade = false,
  }) {
    final wrappedPage = DismissibleWrapper(child: page);
    if (Platform.isIOS && !shouldFade) {
      return CupertinoPageRoute(
        builder: (context) => wrappedPage,
        settings: settings,
      );
    }
    return SlideRouteBuilder(
      page: wrappedPage,
      settings: settings,
    );
  }

  // static Widget _guardedRoute(
  //   Widget page,
  //   RouteSettings settings, {
  //   BuildContext? context,
  // }) {
  //   if (!_isAuthenticated(context!)) {
  //     // Your authentication logic here
  //     return page;
  //   }
  //   return page;
  // }

  // Authentication check
  // static bool _isAuthenticated(BuildContext context) {
  //   // Replace with your actual auth check
  //   return context.read<UserBloc>().state.user != null;
  // }
}
