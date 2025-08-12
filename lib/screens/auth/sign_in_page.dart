import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:unstack/routes/paths/route_paths.dart';
import 'package:unstack/routes/utils/route_utils.dart';
import 'package:unstack/theme/theme.dart';
import 'package:unstack/widgets/auth/sign_in_as_guest_button.dart';

class SignInPage extends StatefulWidget {
  const SignInPage({super.key});

  @override
  State<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  Future<void> _signInAsGuest() async {
    HapticFeedback.lightImpact();
    RouteUtils.pushNamed(
      context,
      RoutePaths.nameInputScreen,
    );
  }

  // void _showErrorToast(String message) {
  //   Fluttertoast.showToast(
  //     msg: message,
  //     toastLength: Toast.LENGTH_LONG,
  //     gravity: ToastGravity.BOTTOM,
  //     backgroundColor: Colors.red.withOpacity(0.8),
  //     textColor: Colors.white,
  //     fontSize: 14.0,
  //   );
  // }

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
            'By getting started, you agree to our',
            textAlign: TextAlign.center,
            style: AppTextStyles.bodySmall,
          ),
          InkWell(
            onTap: () {},
            child: Text(
              'Terms & Conditions',
              style: AppTextStyles.bodySmall.copyWith(
                color: Colors.white,
              ),
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
                  height: AppSpacing.xxxl,
                ),
                Text(
                  'Welcome to Unstack',
                  style: AppTextStyles.xlargeTitle.copyWith(
                    fontWeight: FontWeight.w900,
                    letterSpacing: -1.2,
                    height: 1.1,
                  ),
                ).slideUpStandard(delay: AnimationConstants.shortDelay),
                const SizedBox(height: AppSpacing.md),
                Text(
                  'Transform your daily chaos into purposeful progress',
                  style: AppTextStyles.bodyLarge.copyWith(
                    fontWeight: FontWeight.w500,
                    color: AppColors.whiteColor.withAlpha(160),
                    height: 1.6,
                    letterSpacing: 0.2,
                  ),
                ).slideUpStandard(delay: AnimationConstants.longDelay),
                Spacer(),
                Column(
                  children: [
                    buildGetStartedButton(
                      "Let's Get Started",
                      onPressed: _signInAsGuest,
                    ),
                  ],
                ).slideUpStandard(delay: AnimationConstants.mediumDelay),
                // Center(child: termsAndConditions(context)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
