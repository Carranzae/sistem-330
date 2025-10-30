import 'package:flutter/material.dart';
import '../../domain/models/business_config.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final _pageController = PageController();
  int _currentStep = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: PageView(
          controller: _pageController,
          physics: const NeverScrollableScrollPhysics(),
          children: [
            _BusinessDataStep(),
            _BusinessTypeStep(),
            _BusinessModelStep(),
            _ConfigurationStep(),
            _OptionalModulesStep(),
            _ConfirmationStep(),
          ],
        ),
      ),
    );
  }
}
