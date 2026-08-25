import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../widgets/glass_container.dart';
import '../widgets/password_validator.dart';
import '../providers/auth_provider.dart';

// 🔴 YEHAN APNAY HOME SCREEN KA IMPORT LAGAO
import '../screens/home_screen.dart';
import 'onboarding_screen.dart';
class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen>
    with TickerProviderStateMixin {
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _nameCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();

  final _signInKey = GlobalKey<FormState>();
  final _signUpKey = GlobalKey<FormState>();

  bool _obscure = true;
  bool _obscureConfirm = true;
  bool _loading = false;
  String? _error;
  String? _success;

  late final AnimationController _float;
  late final AnimationController _flip;

  @override
  void initState() {
    super.initState();
    _float = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    )..repeat(reverse: true);

    _flip = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 750),
    );

    _passCtrl.addListener(() {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _float.dispose();
    _flip.dispose();
    _emailCtrl.dispose();
    _passCtrl.dispose();
    _nameCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  bool get _isSignUp => _flip.value > 0.5;

  void _toggleMode() {
    if (_flip.isAnimating) return;
    setState(() {
      _error = null;
      _success = null;
    });
    _flip.value == 0 ? _flip.forward() : _flip.reverse();
  }

  // ===========================================================================
  // REAL FIREBASE SIGN IN
  // ===========================================================================

 Future<void> _signIn() async {
  FocusManager.instance.primaryFocus?.unfocus();

  if (!(_signInKey.currentState?.validate() ?? false)) return;

  setState(() {
    _loading = true;
    _error = null;
    _success = null;
  });

  final auth = context.read<AuthProvider>();

  final success = await auth.login(
    email: _emailCtrl.text.trim(),
    password: _passCtrl.text,
  );

  if (!mounted) return;

  if (success) {
    setState(() {
      _loading = false;
      _success = 'Sign in successful!';
    });

    await Future.delayed(const Duration(milliseconds: 500));

    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => const HomeScreen(),
      ),
    );
  } else {
    setState(() {
      _loading = false;
      _error = auth.errorMessage ?? 'Sign in failed. Please try again.';
    });
  }
}

  // void _goToHome() {
  //   Navigator.of(context).pushReplacement(
  //     PageRouteBuilder(
  //       pageBuilder: (_, _, _) => const HomeScreen(),
  //       transitionsBuilder: (_, anim, _, child) =>
  //           FadeTransition(opacity: anim, child: child),
  //     ),
  //   );
  // }

  // ===========================================================================
  // REAL FIREBASE SIGN UP
  // ===========================================================================

 Future<void> _signUp() async {
  FocusManager.instance.primaryFocus?.unfocus();

  if (!(_signUpKey.currentState?.validate() ?? false)) return;

  if (_passCtrl.text != _confirmCtrl.text) {
    setState(() => _error = 'Passwords do not match');
    return;
  }

  setState(() {
    _loading = true;
    _error = null;
  });

  final auth = context.read<AuthProvider>();

  final success = await auth.signUp(
    name: _nameCtrl.text.trim(),
    email: _emailCtrl.text.trim(),
    password: _passCtrl.text,
  );

  if (!mounted) return;

  if (success) {
    setState(() {
      _loading = false;
      _success = 'Account created! Let’s get you started...';
    });

    Future.delayed(const Duration(seconds: 1), () {
      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => const OnboardingScreen(),
        ),
      );
    });
  } else {
    setState(() {
      _loading = false;
      _error = auth.errorMessage ?? 'Sign up failed. Please try again.';
    });
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
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
              ...List.generate(8, (i) => _blob(i)),
              GestureDetector(
                onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    return SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          minHeight: constraints.maxHeight,
                        ),
                        child: IntrinsicHeight(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const SizedBox(height: 24),
                              AnimatedBuilder(
                                animation: _float,
                                builder: (_, child) {
                                  return Transform.translate(
                                    offset: Offset(0, _float.value * 10 - 5),
                                    child: child,
                                  );
                                },
                                child: GlassContainer(
                                  width: 80,
                                  height: 80,
                                  borderRadius: 24,
                                  tint: Colors.white.withValues(alpha: 0.65),
                                  child: const Center(
                                    child: Icon(
                                      Icons.spa,
                                      size: 38,
                                      color: Color(0xFF4FC3F7),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 20),
                              AnimatedSwitcher(
                                duration: const Duration(milliseconds: 300),
                                child: Text(
                                  _isSignUp ? 'Create Account' : 'Welcome Back',
                                  key: ValueKey(_isSignUp),
                                  style: const TextStyle(
                                    fontSize: 28,
                                    fontWeight: FontWeight.w800,
                                    color: Color(0xFF2C3E50),
                                    letterSpacing: -0.5,
                                    height: 1.2,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 6),
                              AnimatedSwitcher(
                                duration: const Duration(milliseconds: 300),
                                child: Text(
                                  _isSignUp
                                      ? 'Start your wellness journey today'
                                      : 'Sign in to continue your journey',
                                  key: ValueKey('sub_$_isSignUp'),
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    color: const Color(0xFF546E7A)
                                        .withValues(alpha: 0.85),
                                    height: 1.3,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 32),
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 24),
                                child: AnimatedBuilder(
                                  animation: _flip,
                                  builder: (_, _) {
                                    final angle = _flip.value * math.pi;
                                    final isFront = angle < math.pi / 2;

                                    return Transform(
                                      alignment: Alignment.center,
                                      transform: Matrix4.identity()
                                        ..setEntry(3, 2, 0.001)
                                        ..rotateY(angle),
                                      child: isFront
                                          ? _buildFrontCard()
                                          : Transform(
                                              alignment: Alignment.center,
                                              transform: Matrix4.identity()
                                                ..rotateY(math.pi),
                                              child: _buildBackCard(),
                                            ),
                                    );
                                  },
                                ),
                              ),
                              const SizedBox(height: 20),
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 24),
                                child: GlassContainer(
                                  borderRadius: 16,
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 12),
                                  tint: Colors.white.withValues(alpha: 0.45),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Flexible(
                                        child: Text(
                                          _isSignUp
                                              ? 'Already have an account? '
                                              : 'New here? ',
                                          style: TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w600,
                                            color: const Color(0xFF546E7A)
                                                .withValues(alpha: 0.9),
                                          ),
                                        ),
                                      ),
                                      GestureDetector(
                                        onTap: _toggleMode,
                                        child: Text(
                                          _isSignUp ? 'Sign In' : 'Sign Up',
                                          style: const TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w800,
                                            color: Color(0xFF29B6F6),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(height: 32),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFrontCard() {
    return GlassContainer(
      borderRadius: 32,
      padding: const EdgeInsets.all(28),
      tint: Colors.white.withValues(alpha: 0.5),
      child: Form(
        key: _signInKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_error != null) ...[
              _buildBanner(isError: true),
              const SizedBox(height: 16),
            ],
            if (_success != null) ...[
              _buildBanner(isError: false),
              const SizedBox(height: 16),
            ],
            _buildLabel('Email'),
            const SizedBox(height: 8),
            _buildField(
              controller: _emailCtrl,
              hint: 'jane@example.com',
              icon: Icons.email_outlined,
              keyboardType: TextInputType.emailAddress,
              validator: (v) {
                if (v == null || v.trim().isEmpty) return 'Email is required';
                if (!v.contains('@')) return 'Enter a valid email';
                return null;
              },
            ),
            const SizedBox(height: 20),
            _buildLabel('Password'),
            const SizedBox(height: 8),
            _buildField(
              controller: _passCtrl,
              hint: '••••••••',
              icon: Icons.lock_outline,
              obscure: _obscure,
              suffix: IconButton(
                icon: Icon(
                  _obscure
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                  size: 20,
                  color: const Color(0xFF90A4AE),
                ),
                onPressed: () => setState(() => _obscure = !_obscure),
              ),
              validator: (v) {
                if (v == null || v.isEmpty) return 'Password is required';
                return null;
              },
            ),
            const SizedBox(height: 28),
            _buildSubmitButton(
              label: 'Sign In',
              onTap: _loading ? null : _signIn,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBackCard() {
    return GlassContainer(
      borderRadius: 32,
      padding: const EdgeInsets.all(28),
      tint: Colors.white.withValues(alpha: 0.5),
      child: Form(
        key: _signUpKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_error != null) ...[
              _buildBanner(isError: true),
              const SizedBox(height: 16),
            ],
            if (_success != null) ...[
              _buildBanner(isError: false),
              const SizedBox(height: 16),
            ],
            _buildLabel('Full Name'),
            const SizedBox(height: 8),
            _buildField(
              controller: _nameCtrl,
              hint: 'Jane Doe',
              icon: Icons.person_outline,
              validator: (v) {
                if (v == null || v.trim().isEmpty) return 'Name is required';
                if (v.trim().length < 2) return 'Name too short';
                return null;
              },
            ),
            const SizedBox(height: 16),
            _buildLabel('Email'),
            const SizedBox(height: 8),
            _buildField(
              controller: _emailCtrl,
              hint: 'jane@example.com',
              icon: Icons.email_outlined,
              keyboardType: TextInputType.emailAddress,
              validator: (v) {
                if (v == null || v.trim().isEmpty) return 'Email is required';
                if (!v.contains('@')) return 'Enter a valid email';
                return null;
              },
            ),
            const SizedBox(height: 16),
            _buildLabel('Password'),
            const SizedBox(height: 8),
            _buildField(
              controller: _passCtrl,
              hint: '••••••••',
              icon: Icons.lock_outline,
              obscure: _obscure,
              suffix: IconButton(
                icon: Icon(
                  _obscure
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                  size: 20,
                  color: const Color(0xFF90A4AE),
                ),
                onPressed: () => setState(() => _obscure = !_obscure),
              ),
              validator: (v) {
                if (v == null || v.length < 6) {
                  return 'Password must be 6+ characters';
                }
                return null;
              },
            ),
            const SizedBox(height: 12),
            PasswordValidator(password: _passCtrl.text),
            const SizedBox(height: 16),
            _buildLabel('Confirm Password'),
            const SizedBox(height: 8),
            _buildField(
              controller: _confirmCtrl,
              hint: '••••••••',
              icon: Icons.lock_outline,
              obscure: _obscureConfirm,
              suffix: IconButton(
                icon: Icon(
                  _obscureConfirm
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                  size: 20,
                  color: const Color(0xFF90A4AE),
                ),
                onPressed: () =>
                    setState(() => _obscureConfirm = !_obscureConfirm),
              ),
              validator: (v) {
                if (v == null || v.isEmpty) return 'Confirm your password';
                return null;
              },
            ),
            const SizedBox(height: 28),
            _buildSubmitButton(
              label: 'Create Account',
              onTap: _loading ? null : _signUp,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBanner({required bool isError}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: isError
            ? const Color(0xFFFFEBEE).withValues(alpha: 0.85)
            : const Color(0xFFE8F5E9).withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isError
              ? const Color(0xFFEF9A9A).withValues(alpha: 0.5)
              : const Color(0xFFA5D6A7).withValues(alpha: 0.5),
          width: 1,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            isError ? Icons.error_outline : Icons.check_circle_outline,
            color: isError ? const Color(0xFFC62828) : const Color(0xFF2E7D32),
            size: 18,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              isError ? _error! : _success!,
              style: TextStyle(
                color: isError
                    ? const Color(0xFFB71C1C)
                    : const Color(0xFF1B5E20),
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
                height: 1.4,
              ),
            ),
          ),
          if (isError)
            GestureDetector(
              onTap: () => setState(() => _error = null),
              child: const Icon(
                Icons.close,
                color: Color(0xFF9E9E9E),
                size: 16,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w700,
        color: Color(0xFF455A64),
        letterSpacing: 0.3,
        height: 1.2,
      ),
    );
  }

  Widget _buildField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    TextInputType? keyboardType,
    bool obscure = false,
    Widget? suffix,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscure,
      keyboardType: keyboardType,
      validator: validator,
      style: const TextStyle(
        fontSize: 15,
        color: Color(0xFF2C3E50),
        fontWeight: FontWeight.w600,
        height: 1.3,
      ),
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: const Color(0xFF90A4AE), size: 20),
        suffixIcon: suffix,
        hintText: hint,
        hintStyle: TextStyle(
          color: const Color(0xFF90A4AE).withValues(alpha: 0.65),
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
        filled: true,
        fillColor: Colors.white.withValues(alpha: 0.4),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(
            color: Colors.white.withValues(alpha: 0.6),
            width: 1,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(
            color: Color(0xFF4FC3F7),
            width: 1.5,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(
            color: Color(0xFFEF9A9A),
            width: 1.2,
          ),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(
            color: Color(0xFFE57373),
            width: 1.5,
          ),
        ),
        errorStyle: const TextStyle(
          fontSize: 11.5,
          fontWeight: FontWeight.w600,
          color: Color(0xFFC62828),
          height: 1.2,
        ),
      ),
    );
  }

  Widget _buildSubmitButton({
    required String label,
    required VoidCallback? onTap,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: const LinearGradient(
                colors: [
                  Color(0xFF202952),
                  Color(0xFF202952),
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF4FC3F7).withValues(alpha: 0.35),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            alignment: Alignment.center,
            child: _loading
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      valueColor: AlwaysStoppedAnimation(Colors.white),
                    ),
                  )
                : Text(
                    label,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      letterSpacing: 0.5,
                    ),
                  ),
          ),
        ),
      ),
    );
  }

  Widget _blob(int index) {
    final rnd = index * 137.5;
    final size = MediaQuery.of(context).size;

    final List<Color> blobColors = [
      const Color(0xFF4FC3F7),
      const Color(0xFFB39DDB),
      const Color(0xFF81C784),
      const Color(0xFF4DB6AC),
      const Color(0xFFFFB74D),
      const Color(0xFFF06292),
      const Color(0xFF7986CB),
      const Color(0xFF4DD0E1),
    ];

    final color = blobColors[index % blobColors.length];

    return AnimatedBuilder(
      animation: _float,
      builder: (_, _) {
        return Positioned(
          left: ((rnd * 2.3) % size.width) - 60,
          top: ((rnd * 4.1) % size.height) + (_float.value * 40 - 20),
          child: Container(
            width: 100 + (index * 35),
            height: 100 + (index * 35),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  color.withValues(alpha: 0.22),
                  color.withValues(alpha: 0.08),
                  Colors.transparent,
                ],
                stops: const [0.0, 0.4, 1.0],
              ),
            ),
          ),
        );
      },
    );
  }
}