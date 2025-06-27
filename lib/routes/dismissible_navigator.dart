import 'package:flutter/material.dart';
import 'package:unstack/routes/dismissible_wrapper.dart';

class DismissibleNavigator extends Navigator {
  const DismissibleNavigator({
    super.key,
    super.pages,
    super.onPopPage,
    super.initialRoute,
    super.onGenerateInitialRoutes,
    super.onGenerateRoute,
    super.onUnknownRoute,
    super.transitionDelegate,
    super.reportsRouteUpdateToEngine,
    super.observers,
  });

  @override
  NavigatorState createState() => DismissibleNavigatorState();
}

class DismissibleNavigatorState extends NavigatorState {
  @override
  Widget build(BuildContext context) {
    return DismissibleWrapper(
      child: super.build(context),
    );
  }
}
