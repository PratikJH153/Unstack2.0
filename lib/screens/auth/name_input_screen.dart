import 'dart:ui';

import 'package:chiclet/chiclet.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:provider/provider.dart';
import 'package:unstack/providers/auth_provider.dart';
import 'package:unstack/routes/paths/route_paths.dart';
import 'package:unstack/routes/utils/route_utils.dart';
import 'package:unstack/theme/theme.dart';
import 'package:unstack/utils/app_size.dart';
import 'package:unstack/widgets/loading_widget.dart';

class NameInputScreen extends StatefulWidget {
  const NameInputScreen({super.key});

  @override
  State<NameInputScreen> createState() => _NameInputScreenState();
}

class _NameInputScreenState extends State<NameInputScreen> {
  final TextEditingController _nameController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _isNameValid = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _nameController.dispose();
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
    HapticFeedback.lightImpact();
    final form = _formKey.currentState;
    if (form!.validate()) {
      final name = _nameController.text.trim();

      try {
        final authProvider = Provider.of<AuthProvider>(context, listen: false);
        final success = await authProvider.signInWithUsername(name);

        if (success) {
          // Navigate to home page
          if (mounted) {
            RouteUtils.pushReplacementNamed(context, RoutePaths.homePage);
          }
        } else {
          throw Exception('Failed to sign in with username');
        }
      } catch (e) {
        // Show error message
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to login'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: // Continue button
          !Provider.of<AuthProvider>(context).isLoading
              ? Container(
                  height: 80,
                  margin: EdgeInsets.symmetric(
                    horizontal: AppSpacing.lg,
                    vertical: AppSpacing.md,
                  ),
                  width: double.infinity,
                  child: ChicletOutlinedAnimatedButton(
                    onPressed: _saveName,
                    height: 80,
                    width: double.infinity,
                    backgroundColor: _isNameValid
                        ? AppColors.whiteColor
                        : Colors.transparent,
                    borderColor: _isNameValid
                        ? AppColors.textMuted
                        : Colors.white.withAlpha(54),
                    borderWidth: 2,
                    borderRadius: AppBorderRadius.xxl,
                    child: Container(
                      width: double.infinity,
                      height: 80,
                      decoration: BoxDecoration(
                        borderRadius: const BorderRadius.all(
                          Radius.circular(AppBorderRadius.xxl),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.white.withAlpha(51),
                            blurRadius: 15,
                            spreadRadius: -5,
                          ),
                        ],
                      ),
                      child: Center(
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
                      ),
                    ).slideUpStandard(),
                  ),
                )
              : Container(
                  margin: EdgeInsets.symmetric(
                    horizontal: AppSpacing.lg,
                    vertical: AppSpacing.md,
                  ),
                  alignment: Alignment.bottomCenter,
                  child: const LoadingWidget(),
                ),
      body: SingleChildScrollView(
        child: SizedBox(
          height: AppSize(context).height,
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
              Padding(
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
                        ).slideUpStandard(delay: AnimationConstants.shortDelay),

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
                        ).slideUpStandard(delay: AnimationConstants.longDelay),
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
                              if (!mounted) return;
                              setState(() {
                                _isNameValid =
                                    _validateName(_nameController.text) == null;
                              });
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
                          ).slideDownStandard(
                              delay: AnimationConstants.longDelay),
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
            ],
          ),
        ),
      ),
    );
  }
}
