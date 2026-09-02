import 'package:flutter/material.dart';

class AudioCallStatus extends StatelessWidget {
  const AudioCallStatus({
    super.key,
    required this.label,
    required this.isListening,
    required this.isBusy,
  });

  final String label;
  final bool isListening;
  final bool isBusy;

  @override
  Widget build(BuildContext context) {
    final indicatorColor = isBusy || isListening
        ? const Color(0xFF4CAF50)
        : const Color(0xFFB39DDB);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 9,
              height: 9,
              decoration: BoxDecoration(
                color: indicatorColor,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: indicatorColor.withValues(alpha: 0.55),
                    blurRadius: 12,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Color(0xFF202952),
                fontSize: 18,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.2,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
