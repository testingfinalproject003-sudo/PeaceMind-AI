import 'package:flutter/material.dart';

class PasswordValidator extends StatelessWidget {
  final String password;
  const PasswordValidator({super.key, required this.password});

  bool get _hasLength => password.length >= 8;
  bool get _hasUpper => password.contains(RegExp(r'[A-Z]'));
  bool get _hasLower => password.contains(RegExp(r'[a-z]'));
  bool get _hasNumber => password.contains(RegExp(r'[0-9]'));
  bool get _hasSpecial => password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'));

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        _rule('8+ characters', _hasLength),
        _rule('1 uppercase letter', _hasUpper),
        _rule('1 lowercase letter', _hasLower),
        _rule('1 number', _hasNumber),
        _rule('1 special character', _hasSpecial),
      ],
    );
  }

  Widget _rule(String text, bool met) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 5),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 16,
            height: 16,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: met ? const Color(0xFF81C784) : Colors.white.withValues(alpha : 0.35),
              border: Border.all(
                color: met ? const Color(0xFF81C784) : const Color(0xFF90A4AE),
                width: 1.5,
              ),
            ),
            child: met
                ? const Icon(Icons.check, size: 10, color: Colors.white)
                : null,
          ),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 12,
                color: met
                    ? const Color(0xFF2E7D32)
                    : const Color(0xFF546E7A).withValues(alpha : 0.9),
                fontWeight: met ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}