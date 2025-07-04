import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:unstack/routes/route.dart';
import 'package:unstack/theme/app_theme.dart';

class NameInputScreen extends StatefulWidget {
  const NameInputScreen({super.key});

  @override
  State<NameInputScreen> createState() => _NameInputScreenState();
}

class _NameInputScreenState extends State<NameInputScreen> {
  final TextEditingController _nameController = TextEditingController();
  final FocusNode _nameFocusNode = FocusNode();

  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    // Auto-focus the text field after a short delay
    Future.delayed(const Duration(milliseconds: 800), () {
      if (mounted) {
        _nameFocusNode.requestFocus();
      }
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _nameFocusNode.dispose();
    super.dispose();
  }

  String? _validateName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter your name';
    }
    if (value.trim().length < 2) {
      return 'Name must be at least 2 characters';
    }
    if (value.trim().length > 30) {
      return 'Name must be less than 30 characters';
    }
    return null;
  }

  Future<void> _saveName() async {
    final name = _nameController.text.trim();
    final validation = _validateName(name);

    if (validation != null) {
      setState(() {
        _errorMessage = validation;
      });
      return;
    }

    setState(() {
      _errorMessage = null;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_name', name);
      await prefs.setBool('onboarding_completed', true);

      // Add a small delay for better UX
      await Future.delayed(const Duration(milliseconds: 500));

      if (mounted) {
        _navigateToHome();
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Something went wrong. Please try again.';
      });
    }
  }

  void _navigateToHome() {
    RouteUtils.pushReplacementNamed(
      // PageRouteBuilder(
      //   pageBuilder: (context, animation, secondaryAnimation) =>
      //       const HomePage(),
      //   transitionsBuilder: (context, animation, secondaryAnimation, child) {
      //     return FadeTransition(
      //       opacity: animation.drive(
      //         CurveTween(curve: Curves.easeInOut),
      //       ),
      //       child: child,
      //     );
      //   },
      //   transitionDuration: const Duration(milliseconds: 600),
      // ),
      context,
      RoutePaths.homePage,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned(
            bottom: -100,
            left: -50,
            right: -50,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 800),
              width: 500,
              height: 500,
              decoration: BoxDecoration(
                color: _nameController.text.trim().isNotEmpty
                    ? const Color(0xFF2D8B6B).withAlpha(120)
                    : AppColors.accentPink.withAlpha(120),
                shape: BoxShape.circle,
              ),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 150, sigmaY: 150),
                child: Container(
                  decoration: BoxDecoration(
                    color: _nameController.text.trim().isNotEmpty
                        ? const Color(0xFF2D8B6B).withAlpha(10)
                        : AppColors.accentPink.withAlpha(10),
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

                // Welcome content
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Welcome to Unstack!',
                      style: AppTextStyles.h1.copyWith(
                        fontSize: 60,
                        fontWeight: FontWeight.w800,
                      ),
                    )
                        .animate()
                        .slideY(
                          begin: 0.3,
                          duration: 500.ms,
                          curve: Curves.easeOut,
                        )
                        .fadeIn(delay: 200.ms),

                    const SizedBox(height: AppSpacing.sm),

                    // Subtitle
                    Text(
                      'Let\'s personalize your experience',
                      style: AppTextStyles.bodyLarge.copyWith(
                        color: AppColors.textPrimary,
                      ),
                    )
                        .animate()
                        .slideY(
                          begin: 0.3,
                          duration: 500.ms,
                          curve: Curves.easeOut,
                        )
                        .fadeIn(delay: 300.ms),
                  ],
                ),

                const SizedBox(height: AppSpacing.xxl),

                // Name input section
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextFormField(
                      controller: _nameController,
                      keyboardType: TextInputType.name,
                      onChanged: (_) {
                        setState(() {});
                      },
                      style: AppTextStyles.bodyLarge.copyWith(
                        color: AppColors.textPrimary,
                        fontSize: 32,
                        fontWeight: FontWeight.w600,
                      ),
                      decoration: InputDecoration(
                        contentPadding: EdgeInsets.only(
                          bottom: 20,
                        ),
                        hintText: 'Enter your name',
                        hintStyle: AppTextStyles.bodyLarge.copyWith(
                          color: AppColors.textPrimary,
                          fontSize: 32,
                        ),
                        fillColor: Colors.transparent,
                        border: UnderlineInputBorder(
                          borderSide: BorderSide(
                            color: AppColors.accentPink,
                            width: 0,
                          ),
                        ),
                        enabledBorder: InputBorder.none,
                        focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(
                            color: AppColors.textPrimary,
                            width: 5,
                          ),
                        ),
                      ),
                    )
                        .animate()
                        .slideX(
                          begin: -0.3,
                          duration: 500.ms,
                          curve: Curves.easeOut,
                        )
                        .fadeIn(delay: 600.ms),

                    const SizedBox(height: AppSpacing.md),

                    // Error message
                    if (_errorMessage != null)
                      Padding(
                        padding: const EdgeInsets.only(top: AppSpacing.sm),
                        child: Text(
                          _errorMessage!,
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.statusError,
                          ),
                        )
                            .animate()
                            .slideX(
                              begin: -0.3,
                              duration: 300.ms,
                            )
                            .fadeIn(),
                      ),
                  ],
                ),

                const Spacer(),

                // Continue button
                SizedBox(
                  height: 80,
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _nameController.text.trim().isNotEmpty
                          ? AppColors.whiteColor
                          : AppColors.whiteColor.withAlpha(50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(
                          Radius.circular(
                            32,
                          ),
                        ),
                      ),
                    ),
                    onPressed: _saveName,
                    child: Text(
                      "Let's Roll In!",
                      style: TextStyle(
                        fontWeight: _nameController.text.trim().isNotEmpty
                            ? FontWeight.w600
                            : FontWeight.w800,
                        color: _nameController.text.trim().isNotEmpty
                            ? AppColors.blackColor
                            : AppColors.whiteColor,
                      ),
                    ),
                  )
                      .animate()
                      .slideY(
                        begin: 0.3,
                        duration: 400.ms,
                        curve: Curves.easeOut,
                      )
                      .fadeIn(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
