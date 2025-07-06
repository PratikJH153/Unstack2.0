import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:unstack/routes/route.dart';
import 'package:unstack/theme/app_theme.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<OnboardingData> _onboardingData = [
    OnboardingData(
      title: "Master Your Tasks",
      subtitle:
          "Organize, prioritize, and conquer your to-do list with elegant simplicity",
      icon: Icons.task_alt_rounded,
      color: AppColors.accentPurple,
    ),
    OnboardingData(
      title: "Focus with Pomodoro",
      subtitle:
          "Boost productivity with scientifically-proven time management techniques",
      icon: Icons.timer_rounded,
      color: AppColors.accentBlue,
    ),
    OnboardingData(
      title: "Track Your Progress",
      subtitle: "Visualize achievements and build momentum towards your goals",
      icon: Icons.trending_up_rounded,
      color: AppColors.accentGreen,
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < _onboardingData.length - 1) {
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
      _currentPage = _onboardingData.length - 1;
    });
    _pageController.jumpToPage(_currentPage);
  }

  void _navigateToNameInput() {
    RouteUtils.pushNamed(
      context,
      RoutePaths.signInPage,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundPrimary,
      body: SafeArea(
        child: Column(
          children: [
            // Skip button
            Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
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
                itemCount: _onboardingData.length,
                itemBuilder: (context, index) {
                  return OnboardingPage(
                    data: _onboardingData[index],
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
                    count: _onboardingData.length,
                    effect: ExpandingDotsEffect(
                      activeDotColor: AppColors.whiteColor,
                      dotColor: AppColors.textMuted,
                      dotHeight: 6,
                      dotWidth: 12,
                      expansionFactor: 8,
                      spacing: 8,
                    ),
                  ).animate().fadeIn(delay: 200.ms),
                  const SizedBox(height: AppSpacing.lg),
                  SizedBox(
                    height: 80,
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            _currentPage == _onboardingData.length - 1
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
                      onPressed: _nextPage,
                      child: Text(
                        _currentPage == _onboardingData.length - 1
                            ? 'Get Started'
                            : 'Continue',
                        style: TextStyle(
                          fontWeight: _currentPage == _onboardingData.length - 1
                              ? FontWeight.w600
                              : FontWeight.w800,
                          color: _currentPage == _onboardingData.length - 1
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
      ),
    );
  }
}

class OnboardingData {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;

  OnboardingData({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
  });
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
          const SizedBox(
            height: AppSpacing.sm,
          ),
          // Icon container
          Container(
            width: 120,
            height: 120,
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
          )
              .animate(target: isActive ? 1 : 0)
              .scale(
                begin: const Offset(0.8, 0.8),
                duration: 600.ms,
                curve: Curves.elasticOut,
              )
              .fadeIn(duration: 400.ms),

          const SizedBox(height: AppSpacing.xl),

          // Title
          Text(
            data.title,
            style: AppTextStyles.h1.copyWith(
              fontSize: 50,
              fontWeight: FontWeight.w900,
              letterSpacing: -1.2,
              height: 1.1,
            ),
          )
              .animate(target: isActive ? 1 : 0)
              .slideY(
                begin: 0.3,
                duration: 500.ms,
                curve: Curves.easeOut,
              )
              .fadeIn(delay: 200.ms),

          const SizedBox(height: AppSpacing.md),

          // Subtitle
          Text(
            data.subtitle,
            style: AppTextStyles.bodyLarge.copyWith(
              color: AppColors.textSecondary,
              fontSize: 22,
              wordSpacing: 2,
              letterSpacing: 1.5,
              fontWeight: FontWeight.w400,
            ),
          )
              .animate(target: isActive ? 1 : 0)
              .slideY(
                begin: 0.3,
                duration: 500.ms,
                curve: Curves.easeOut,
              )
              .fadeIn(delay: 300.ms),
        ],
      ),
    );
  }
}
