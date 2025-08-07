import 'package:flutter/material.dart';
import 'package:unstack/models/auth/onboarding.dart';
import 'package:unstack/theme/theme.dart';

final List<OnboardingData> onboardingData = [
  OnboardingData(
    title: "Crush It.\nOne Task at a Time.",
    subtitle: "No noise. No chaos. Just pure focus and Everest-level energy.",
    icon: Icons.task_alt_rounded,
    color: AppColors.accentPurple,
  ),
  OnboardingData(
    title: "Daily Task Streaks",
    subtitle:
        "Not just for Snap. Earn streaks by actually getting things done.",
    icon: Icons.local_fire_department_rounded,
    color: AppColors.accentOrange,
  ),
  OnboardingData(
    title: "Track Your Progress",
    subtitle: "Watch your tiny wins stack up, day by day.",
    icon: Icons.trending_up_rounded,
    color: AppColors.accentGreen,
  ),
  OnboardingData(
    title: "Plan Without the Noise",
    subtitle: "Clean, simple, and distraction-free. No extra fluff.",
    icon: Icons.filter_vintage_rounded,
    color: AppColors.whiteColor,
  ),
];
