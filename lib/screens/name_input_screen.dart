import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:unstack/routes/route.dart';
import 'package:unstack/theme/app_theme.dart';
import 'package:unstack/widgets/loading_widget.dart';

class NameInputScreen extends StatefulWidget {
  const NameInputScreen({super.key});

  @override
  State<NameInputScreen> createState() => _NameInputScreenState();
}

class _NameInputScreenState extends State<NameInputScreen> {
  final TextEditingController _nameController = TextEditingController();
  final FocusNode _nameFocusNode = FocusNode();
  bool _isLoading = false;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

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
    if (value.trim().length <= 1) {
      return 'Name must be at least 2 characters';
    }
    if (value.trim().length > 30) {
      return 'Name must be less than 30 characters';
    }
    return null;
  }

  Future<void> _saveName() async {
    final form = _formKey.currentState;
    if (form!.validate()) {
      final name = _nameController.text.trim();

      setState(() {
        _isLoading = true;
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
      } catch (e) {}

      setState(() {
        _isLoading = false;
      });
    }
  }

  void _navigateToHome() {
    RouteUtils.pushReplacementNamed(
      context,
      RoutePaths.homePage,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: // Continue button
          !_isLoading
              ? Container(
                  height: 80,
                  margin: EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _nameController.text.trim().isNotEmpty
                          ? AppColors.whiteColor
                          : AppColors.whiteColor.withAlpha(50),
                      shadowColor: Colors.white.withAlpha(51),
                      shape: RoundedRectangleBorder(
                        side: BorderSide(
                          color: Colors.white.withAlpha(51),
                        ),
                        borderRadius: BorderRadius.all(
                          Radius.circular(
                            48,
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
                )
              : Align(
                  alignment: Alignment.bottomCenter,
                  child: const LoadingWidget(),
                ),
      body: SizedBox(
        height: double.infinity,
        child: Stack(
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
            SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      height: AppSpacing.xxxl + AppSpacing.md,
                    ),

                    // Welcome content
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Ready to dive in?',
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

                        // Subtitle
                        Text(
                          'Let’s make this space truly yours.\nWhat you’d like to be called?',
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
                      ],
                    ),

                    const SizedBox(height: AppSpacing.xxl),

                    // Name input section
                    Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          TextFormField(
                            controller: _nameController,
                            keyboardType: TextInputType.name,
                            onChanged: (_) {
                              setState(() {});
                            },
                            validator: _validateName,
                            cursorColor: AppColors.whiteColor,
                            style: AppTextStyles.bodyLarge.copyWith(
                              color: AppColors.textPrimary,
                              fontSize: 28,
                              fontWeight: FontWeight.w600,
                            ),
                            decoration: InputDecoration(
                              contentPadding: EdgeInsets.only(
                                bottom: 20,
                              ),
                              hintText: 'Enter your username',
                              hintStyle: AppTextStyles.bodyLarge.copyWith(
                                color: AppColors.textPrimary,
                                fontSize: 28,
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
                              .slideY(
                                begin: -0.3,
                                duration: 500.ms,
                                curve: Curves.easeOut,
                              )
                              .fadeIn(delay: 600.ms),
                          const SizedBox(height: AppSpacing.md),
                        ],
                      ),
                    ),

                    const SizedBox(
                      height: AppSpacing.lg,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
