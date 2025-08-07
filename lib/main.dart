import 'package:device_preview/device_preview.dart';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:unstack/providers/auth_provider.dart';
import 'package:unstack/routes/route.dart';
import 'package:unstack/theme/theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations(
      [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
  runApp(
    DevicePreview(
      enabled: kDebugMode,
      builder: (context) => const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    ResponsiveUtils.init(context);
    return ChangeNotifierProvider(
      create: (context) => AuthProvider(),
      child: MaterialApp(
        title: 'Unstack',
        debugShowCheckedModeBanner: false,
        debugShowMaterialGrid: false,
        theme: AppTheme.darkTheme,
        initialRoute: RoutePaths.splashScreen,
        onGenerateRoute: AppRouter.generateRoute,
      ),
    );
  }
}
