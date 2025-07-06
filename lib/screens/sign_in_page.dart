import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:unstack/routes/route.dart';
import 'package:unstack/theme/app_theme.dart';
import 'package:unstack/widgets/auth/apple_sign_in_button.dart';
import 'package:unstack/widgets/auth/google_sign_in_button.dart';
import 'package:unstack/widgets/general_info_dialog.dart';
import 'package:unstack/widgets/loading_widget.dart';

class SignInPage extends StatefulWidget {
  const SignInPage({super.key});

  @override
  State<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  bool _isLoading = false;

  void navigateToUsernamePage() {
    setState(() {
      _isLoading = true;
    });
    RouteUtils.pushNamed(context, RoutePaths.nameInputScreen);
    setState(() {
      _isLoading = false;
    });
  }

  Widget termsAndConditions(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        left: 12,
        right: 12,
        bottom: 30,
        top: 24,
      ),
      child: Column(
        children: [
          Text(
            'By signing in, you agree to our',
            textAlign: TextAlign.center,
            style: AppTextStyles.bodySmall,
          ),
          InkWell(
            onTap: () {
              GeneralInfoDialog.show(context, 'assets/files/terms.md');
            },
            child: Text(
              'Terms and Conditions',
              style: AppTextStyles.bodySmall,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned(
            top: -100,
            left: -50,
            right: -50,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 800),
              width: 600,
              height: 600,
              decoration: BoxDecoration(
                color: AppColors.accentPurple.withAlpha(100),
                shape: BoxShape.circle,
              ),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 100, sigmaY: 100),
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.accentPink.withAlpha(10),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  height: AppSpacing.xxxl + AppSpacing.md,
                ),
                Text(
                  'Welcome to Unstack',
                  style: AppTextStyles.h1.copyWith(
                    fontSize: 64,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -1.2,
                    height: 1.1,
                  ),
                )
                    .animate()
                    .slideY(
                      begin: 0.4,
                      duration: 800.ms,
                      curve: Curves.elasticOut,
                    )
                    .fadeIn(
                      delay: 100.ms,
                      duration: 600.ms,
                    ),
                const SizedBox(height: AppSpacing.md),
                Text(
                  'Transform your daily chaos into purposeful progress',
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontSize: 20,
                    fontWeight: FontWeight.w500,
                    color: AppColors.whiteColor.withAlpha(160),
                    height: 1.6,
                    letterSpacing: 0.2,
                  ),
                )
                    .animate()
                    .slideY(
                      begin: 0.3,
                      duration: 700.ms,
                      curve: Curves.easeOutCubic,
                    )
                    .fadeIn(
                      delay: 400.ms,
                      duration: 800.ms,
                    ),
                Spacer(),
                !_isLoading
                    ? Column(
                        children: [
                          buildAppleSigninButton(
                            'Sign in with Apple',
                            onPressed: navigateToUsernamePage,
                          ),
                          const SizedBox(
                            height: AppSpacing.md,
                          ),
                          buildGoogleSigninButton(
                            'Sign in with Google',
                            onPressed: navigateToUsernamePage,
                          ),
                        ],
                      )
                        .animate()
                        .slideY(
                          begin: 0.3,
                          duration: 500.ms,
                          curve: Curves.easeOut,
                        )
                        .fadeIn(delay: 200.ms)
                    : Align(
                        alignment: Alignment.bottomCenter,
                        child: const LoadingWidget(),
                      ),
                Center(child: termsAndConditions(context)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
