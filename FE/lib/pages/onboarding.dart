import 'package:flutter/material.dart';
import 'package:farmwise_app/layout/layout_onboarding.dart';
import 'package:go_router/go_router.dart';
import 'package:farmwise_app/routes/app_routes.dart';

class Onboarding1 extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return CustomOnboardingPage(
      imagePath: 'assets/images/onboarding-1.png',
      title: 'Know Your Land, Grow with Confidence',
      description:
          "Understand your soil's potential with real-time data on fertility, moisture, and sunlight.",
      buttonText: 'Continue',
      onNext: () => context.push(AppRoutes.onboarding_2),
      currentPage: 0,
      totalPages: 3,
      isFirstOnboarding: true,
    );
  }
}

class Onboarding2 extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return CustomOnboardingPage(
      imagePath: 'assets/images/onboarding-2.png',
      title: 'Smart Farming Starts with the Right Info',
      description:
          'Get instant insights from images — crop type, nutrition facts, and AI-powered planting tips.',
      buttonText: 'Lanjut',
      onNext: () => context.push(AppRoutes.onboarding_3),
      currentPage: 1,
      totalPages: 3,
    );
  }
}

class Onboarding3 extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return CustomOnboardingPage(
      imagePath: 'assets/images/onboarding-3.png',
      title: 'Weather-Proof Your Harvest with FarmWise',
      description: "Plan smarter with FarmWise",
      buttonText: 'Get Started',
      onNext: () => context.go('/login'),
      currentPage: 2,
      totalPages: 3,
    );
  }
}
