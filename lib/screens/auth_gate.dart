import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../providers/auth_provider.dart';
import 'auth_screen.dart';
import 'onboarding_screen.dart';
import 'home_screen.dart';

class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  bool _checkingOnboarding = true;
  bool _onboardingCompleted = false;

  @override
  void initState() {
    super.initState();
    _checkOnboarding();
  }

  Future<void> _checkOnboarding() async {
    final authProvider = context.read<AuthProvider>();

    /*
      AuthProvider loadUser() Firebase session check karta hai.

      Thoda wait is liye ke Firebase currentUser load ho jaye.
    */
    if (authProvider.isLoading) {
      await Future.delayed(const Duration(milliseconds: 100));
    }

    if (!mounted) return;

    final user = authProvider.currentUser;

    if (user == null) {
      setState(() {
        _checkingOnboarding = false;
        _onboardingCompleted = false;
      });
      return;
    }

    final prefs = await SharedPreferences.getInstance();

    /*
      Onboarding ko USER UID ke saath save kar rahe hain.

      Iska matlab:
      User A ka onboarding complete
      User B ka onboarding alag rahega.
    */
    final key = 'onboarding_completed_${user.uid}';

    final completed = prefs.getBool(key) ?? false;

    if (!mounted) return;

    setState(() {
      _onboardingCompleted = completed;
      _checkingOnboarding = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();

    // -------------------------------------------------------------------------
    // Firebase user load ho raha hai
    // -------------------------------------------------------------------------

    if (authProvider.isLoading || _checkingOnboarding) {
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
    // -------------------------------------------------------------------------

    if (!_onboardingCompleted) {
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