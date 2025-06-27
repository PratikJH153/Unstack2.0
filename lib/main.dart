import 'package:flutter/material.dart';
import 'package:unstack/routes/route.dart';
import 'package:unstack/theme/app_theme.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Unstack',
      debugShowCheckedModeBanner: false,
      debugShowMaterialGrid: false,
      theme: AppTheme.darkTheme,
      initialRoute: RoutePaths.homePage,
      onGenerateRoute: AppRouter.generateRoute,
    );
  }
}
