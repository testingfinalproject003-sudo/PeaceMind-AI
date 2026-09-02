import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import 'auth_screen.dart';
import 'onboarding_screen.dart';
import 'home_screen.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();

    // -------------------------------------------------------------------------
    // Firebase user load ho raha hai
    // -------------------------------------------------------------------------

    if (authProvider.isLoading) {
      return const _LoadingScreen();
    }

    // -------------------------------------------------------------------------
    // User logged out
    // -------------------------------------------------------------------------

    if (!authProvider.isLoggedIn) {
      return const AuthScreen();
    }

    // -------------------------------------------------------------------------
    // Logged in but onboarding not completed
    // (flag AuthProvider ke andar hai — completeOnboarding() par yahan
    //  reactive rebuild hota hai, manual navigation ki zaroorat nahi)
    // -------------------------------------------------------------------------

    if (!authProvider.onboardingCompleted) {
      return const OnboardingScreen();
    }

    // -------------------------------------------------------------------------
    // Existing user / onboarding already completed
    // -------------------------------------------------------------------------

    return const HomeScreen();
  }
}

class _LoadingScreen extends StatelessWidget {
  const _LoadingScreen();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Color(0xFFF3F6E8),
      body: Center(
        child: CircularProgressIndicator(
          color: Color(0xFF202952),
        ),
      ),
    );
  }
}
