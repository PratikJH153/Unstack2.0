import 'package:chiclet/chiclet.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:unstack/constants/onboarding_data.dart';
import 'package:unstack/models/auth/onboarding.dart';
import 'package:unstack/routes/route.dart';
import 'package:unstack/theme/theme.dart';
import 'package:unstack/utils/app_size.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _nextPage() {
    HapticFeedback.lightImpact();
    if (_currentPage < onboardingData.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _navigateToNameInput();
    }
  }

  void _skipPage() {
    setState(() {
      _currentPage = onboardingData.length - 1;
    });
    _pageController.jumpToPage(_currentPage);
  }

  void _navigateToNameInput() {
    RouteUtils.pushNamed(
      context,
      RoutePaths.nameInputScreen,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundPrimary,
      body: Column(
        children: [
          // Skip button
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg,
              vertical: AppBorderRadius.xxxl,
            ),
            child: Align(
              alignment: Alignment.topRight,
              child: TextButton(
                onPressed: _skipPage,
                child: Text(
                  'Skip',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            ),
          ),

          // Page view
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              onPageChanged: (index) {
                setState(() {
                  _currentPage = index;
                });
              },
              itemCount: onboardingData.length,
              itemBuilder: (context, index) {
                return OnboardingPage(
                  data: onboardingData[index],
                  isActive: index == _currentPage,
                );
              },
            ),
          ),

          // Page indicator and button
          Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              children: [
                SmoothPageIndicator(
                  controller: _pageController,
                  count: onboardingData.length,
                  effect: ExpandingDotsEffect(
                    activeDotColor: AppColors.whiteColor,
                    dotColor: AppColors.textMuted,
                    dotHeight: 6,
                    dotWidth: 12,
                    expansionFactor: 8,
                    spacing: 8,
                  ),
                ).fadeInStandard(delay: AnimationConstants.mediumDelay),
                const SizedBox(height: AppSpacing.lg),
                SizedBox(
                  height: 80 * (AppSize(context).height / 860),
                  width: double.infinity,
                  child: ChicletOutlinedAnimatedButton(
                    onPressed: _nextPage,
                    backgroundColor: _currentPage == onboardingData.length - 1
                        ? AppColors.whiteColor
                        : AppColors.whiteColor.withAlpha(50),
                    borderColor: AppColors.textMuted,
                    buttonType: ChicletButtonTypes.roundedRectangle,
                    foregroundColor: AppColors.accentPurple,
                    borderRadius: AppBorderRadius.xxl,

                    // child: ElevatedButton(
                    // style: ElevatedButton.styleFrom(
                    //   backgroundColor:
                    //       _currentPage == onboardingData.length - 1
                    //           ? AppColors.whiteColor
                    //           : AppColors.whiteColor.withAlpha(50),
                    //   shadowColor: Colors.white.withAlpha(51),
                    //   shape: RoundedRectangleBorder(
                    //     side: BorderSide(
                    //       color: Colors.white.withAlpha(51),
                    //     ),
                    //     borderRadius: BorderRadius.all(
                    //       Radius.circular(
                    //         48,
                    //       ),
                    //     ),
                    //   ),
                    // ),
                    // onPressed: _nextPage,
                    child: Text(
                      _currentPage == onboardingData.length - 1
                          ? 'Get Started'
                          : 'Continue',
                      style: TextStyle(
                        fontWeight: _currentPage == onboardingData.length - 1
                            ? FontWeight.w600
                            : FontWeight.w800,
                        color: _currentPage == onboardingData.length - 1
                            ? AppColors.blackColor
                            : AppColors.whiteColor,
                      ),
                    ),
                  ).slideUpStandard(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class OnboardingPage extends StatelessWidget {
  final OnboardingData data;
  final bool isActive;

  const OnboardingPage({
    super.key,
    required this.data,
    required this.isActive,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icon container
          Container(
            width: 120 * (AppSize(context).height / 760),
            height: 120 * (AppSize(context).height / 760),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: data.color,
                width: 2,
              ),
              color: AppColors.surfaceCard,
            ),
            child: Icon(
              data.icon,
              size: 60,
              color: data.color,
            ),
          ).scaleInStandard(
            scale: AnimationConstants.largeScale,
          ),

          const SizedBox(height: AppSpacing.lg),

          // Title
          Text(
            data.title,
            style: AppTextStyles.largeTitle.copyWith(
              fontWeight: FontWeight.w900,
              letterSpacing: -1.2,
              height: 1.1,
            ),
          ).slideUpStandard(delay: AnimationConstants.mediumDelay),

          const SizedBox(height: AppSpacing.md),

          // Subtitle
          Text(
            data.subtitle,
            style: AppTextStyles.h2.copyWith(
              color: AppColors.textSecondary,
              wordSpacing: 2,
              letterSpacing: 1.5,
              fontWeight: FontWeight.w400,
            ),
          ).slideUpStandard(delay: AnimationConstants.mediumDelay),
        ],
      ),
    );
  }
}
