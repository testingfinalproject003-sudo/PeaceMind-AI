import 'package:flutter/material.dart';

import 'ai_audio_call_screen.dart';

class CallScreen extends StatefulWidget {
  const CallScreen({super.key});

  @override
  State<CallScreen> createState() => _CallScreenState();
}

class _CallScreenState extends State<CallScreen> {
  static const Color background = Color(0xFFF3F6E8);
  static const Color darkBlue = Color(0xFF202952);
  static const Color darkText = Color(0xFF303450);
  // static const Color greyText = Color(0xFF777B94);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const AiAudioCallScreen()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: const Color(0xFFECE8FA),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: const Icon(
                  Icons.phone_outlined,
                  color: darkBlue,
                  size: 36,
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Opening NOVA',
                style: TextStyle(
                  color: darkText,
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

}