import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:unstack/providers/auth_provider.dart';
import 'package:unstack/screens/auth/sign_in_page.dart';
import 'package:unstack/screens/home/home.dart';
import 'package:unstack/widgets/loading_widget.dart';

class WrapperPage extends StatelessWidget {
  const WrapperPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        switch (authProvider.authState) {
          case AuthState.loading:
          case AuthState.initial:
            return const Scaffold(
              body: Center(
                child: LoadingWidget(),
              ),
            );
          case AuthState.authenticated:
            return const HomePage();
          case AuthState.unauthenticated:
          case AuthState.error:
            return const SignInPage();
        }
      },
    );
  }
}
