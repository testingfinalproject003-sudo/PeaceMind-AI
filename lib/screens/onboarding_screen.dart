import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import '../widgets/glass_container.dart';
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with SingleTickerProviderStateMixin {
  final PageController _pageController = PageController();
  int _currentPage = 0;
 static const Color darkBlue = Color(0xFF202952);
  late AnimationController _floatController;

  final List<Map<String, dynamic>> _pages = [
    {
      'icon': Icons.spa,
      'title': 'Your Private Sanctuary',
      'desc':
          'A judgment-free space where you can share thoughts openly. No stigma, no labels — just compassionate support whenever you need it.',
      'accent': const Color(0xFF4FC3F7),
      'blobColor': const Color(0xFF4FC3F7),
    },
    {
      'icon': Icons.favorite_border,
      'title': 'Truly Understands You',
      'desc':
          'PeaceMind learns your unique patterns through gentle conversation, responding in your language across chat and voice.',
      'accent': const Color(0xFFB39DDB),
      'blobColor': const Color(0xFFB39DDB),
    },
    {
      'icon': Icons.shield_moon_outlined,
      'title': 'Here When It Matters',
      'desc':
          'We never diagnose or judge. In moments of crisis, we prioritize your safety and guide you toward professional care.',
      'accent': const Color(0xFF81C784),
      'blobColor': const Color(0xFF81C784),
    },
    {
      'icon': Icons.health_and_safety_outlined,
      'title': 'Smarter First Aid',
      'desc':
          'We use your conversation data to provide better first-aid responses and early crisis detection. Your privacy is always our priority.',
      'accent': const Color(0xFF4DB6AC),
      'blobColor': const Color(0xFF4DB6AC),
    },
  ];

  @override
  void initState() {
    super.initState();
    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _floatController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFE0F7FA),
              Color(0xFFF3E5F5),
              Color(0xFFE8F5E9),
            ],
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              // Animated liquid blobs
              ...List.generate(6, (i) => _blob(i, size)),
              Column(
                children: [
                  SizedBox(height: size.height * 0.04),
                  // Logo with float
                  AnimatedBuilder(
                    animation: _floatController,
                    builder: (_, child) {
                      return Transform.translate(
                        offset: Offset(0, _floatController.value * 8 - 4),
                        child: child,
                      );
                    },
                    child: GlassContainer(
                      width: 72,
                      height: 72,
                      borderRadius: 22,
                      tint: Colors.white.withValues(alpha : 0.6),
                      child: const Center(
                        child: Icon(
                          Icons.spa,
                          size: 34,
                          color: Color(0xFF4FC3F7),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  const Text(
                    'PeaceMind AI',
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF2C3E50),
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Mental Wellness Companion',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF546E7A).withValues(alpha : 0.8),
                    ),
                  ),
                  SizedBox(height: size.height * 0.03),
                  // PageView - Expanded to prevent overflow
                  Expanded(
                    child: PageView.builder(
                      controller: _pageController,
                      onPageChanged: (i) => setState(() => _currentPage = i),
                      itemCount: _pages.length,
                      itemBuilder: (_, i) => _buildPage(_pages[i]),
                    ),
                  ),
                  // Indicators
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(_pages.length, (i) {
                        return AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          width: _currentPage == i ? 24 : 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: _currentPage == i
                                ? _pages[i]['accent'] as Color
                                : Colors.white.withValues(alpha : 0.6),
                            borderRadius: BorderRadius.circular(4),
                          ),
                        );
                      }),
                    ),
                  ),
                  // CTA Button
                  Padding(
                    padding: const EdgeInsets.fromLTRB(28, 0, 28, 28),
                    child: GlassContainer(
                      width: double.infinity,
                      borderRadius: 20,
                      tint: Colors.white.withValues(alpha : 0.5),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(20),
                          onTap: () {
                            if (_currentPage < _pages.length - 1) {
                              _pageController.nextPage(
                                duration: const Duration(milliseconds: 500),
                                curve: Curves.easeInOutCubic,
                              );
                            } else {
                              // Flag AuthProvider mein save hota hai —
                              // AuthGate reactive switch kar dega.
                              context.read<AuthProvider>().completeOnboarding();
                            }
                          },
                          child: Container(
  padding: const EdgeInsets.symmetric(vertical: 16),
  alignment: Alignment.center,
  decoration: BoxDecoration(
    color: darkBlue,
    borderRadius: BorderRadius.circular(16),
  ),
  child: Text(
    _currentPage == _pages.length - 1
        ? 'Begin Your Journey'
        : 'Continue',
    style: const TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w800,
      color: Colors.white,
    ),
  ),
),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPage(Map<String, dynamic> data) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Center(
        child: GlassContainer(
          borderRadius: 32,
          padding: const EdgeInsets.all(28),
          tint: Colors.white.withValues(alpha : 0.4),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [
                      (data['accent'] as Color).withValues(alpha : 0.3),
                      (data['accent'] as Color).withValues(alpha : 0.1),
                    ],
                  ),
                ),
                child: Icon(
                  data['icon'] as IconData,
                  size: 40,
                  color: data['accent'] as Color,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                data['title'] as String,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF2C3E50),
                  height: 1.2,
                ),
              ),
              const SizedBox(height: 14),
              Text(
                data['desc'] as String,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 14,
                  height: 1.55,
                  color: Color(0xFF546E7A),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _blob(int index, Size size) {
    final rnd = index * 137.5;
    return AnimatedBuilder(
      animation: _floatController,
      builder: (_, _) {
        return Positioned(
          left: ((rnd * 2) % size.width) - 40,
          top: ((rnd * 3.5) % size.height) +
              (_floatController.value * 30 - 15),
          child: Container(
            width: 80 + (index * 25),
            height: 80 + (index * 25),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  _pages[index % _pages.length]['blobColor']
                      .withValues(alpha : 0.15),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}