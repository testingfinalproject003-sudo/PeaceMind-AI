import 'dart:ui';

import 'package:flutter/material.dart';

class PanicOverlay extends StatelessWidget {
  const PanicOverlay({
    super.key,
    required this.onResolve,
  });

  final VoidCallback onResolve;

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: ClipRRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            color: const Color(0x190D0625),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 98,
                    height: 98,
                    decoration: BoxDecoration(
                      color: const Color(0xFFEF4444).withValues(alpha: 0.18),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.favorite_rounded,
                      color: Color(0xFFFF5A7A),
                      size: 54,
                    ),
                  ),
                  const SizedBox(height: 18),
                  const Text(
                    'Please take a breath',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 32),
                    child: Text(
                      'You are not alone. Focus on one safe thing nearby and let your breath settle.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 15,
                        height: 1.5,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  GestureDetector(
                    onTap: onResolve,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 14,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF22C55E),
                        borderRadius: BorderRadius.circular(999),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF22C55E).withValues(alpha: 0.38),
                            blurRadius: 20,
                          ),
                        ],
                      ),
                      child: const Text(
                        'I\'m okay',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
