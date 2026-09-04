import 'package:flutter/material.dart';

class AudioCallControls extends StatelessWidget {
  const AudioCallControls({
    super.key,
    required this.isListening,
    required this.isBusy,
    required this.onMicPressed,
    required this.onEndPressed,
    this.manualTapMode = false,
  });

  final bool isListening;
  final bool isBusy;
  final bool manualTapMode;
  final VoidCallback onMicPressed;
  final VoidCallback onEndPressed;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _glassCircle(
          icon: Icons.call_end_rounded,
          color: const Color(0xFF7C3AED),
          onTap: onEndPressed,
        ),
        // Only show mic button in manual tap-to-speak mode.
        // Default = continuous VAD listening, no tap needed.
        if (manualTapMode) ...[
          const SizedBox(width: 24),
          GestureDetector(
            onTap: isBusy ? null : onMicPressed,
            child: Container(
              width: 96,
              height: 96,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0xFFB39DDB), Color(0xFF9575CD)],
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFB39DDB).withValues(alpha: 0.35),
                    blurRadius: 22,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Center(
                child: Icon(
                  isListening ? Icons.mic_rounded : Icons.mic_none_rounded,
                  color: Colors.white,
                  size: 38,
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _glassCircle({
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 62,
        height: 62,
        decoration: BoxDecoration(
          color: const Color(0xFFB39DDB).withValues(alpha: 0.18),
          border: Border.all(
            color: const Color(0xFFB39DDB).withValues(alpha: 0.30),
          ),
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          color: color,
          size: 28,
        ),
      ),
    );
  }
}
