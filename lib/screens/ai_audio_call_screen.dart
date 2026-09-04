import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/audio_call_session_model.dart';
import '../providers/audio_call_provider.dart';
import '../widgets/audio_call_controls.dart';
import '../widgets/audio_call_orb.dart';
import '../widgets/audio_call_status.dart';
import '../widgets/panic_overlay.dart';

class AiAudioCallScreen extends StatefulWidget {
  const AiAudioCallScreen({super.key});

  @override
  State<AiAudioCallScreen> createState() => _AiAudioCallScreenState();
}

class _AiAudioCallScreenState extends State<AiAudioCallScreen> {
  final Stopwatch _sessionTimer = Stopwatch();

  /// UI ko har second refresh karta hai taake call duration
  /// live tick kare (pehle 00:00 hi atka rehta tha).
  Timer? _uiTick;

  @override
  void initState() {
    super.initState();
    _sessionTimer.start();
    _uiTick = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() {});
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AudioCallProvider>().initialize();
    });
  }

  @override
  void dispose() {
    _uiTick?.cancel();
    _sessionTimer.stop();
    super.dispose();
  }

  String _formatDuration(Duration d) {
    final minutes = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AudioCallProvider>(
      builder: (context, provider, child) {
        final state = provider.state;
        final isListening = state == AudioCallState.listening ||
            state == AudioCallState.connecting;
        final isBusy = provider.isBusy ||
            state == AudioCallState.processing ||
            state == AudioCallState.novaSpeaking;

        // ── Rule 2: Light blue background, lavender orb ──
        const bgColor = Color(0xFFD6EAF8);       // light blue
        const orbLavender = Color(0xFFB39DDB);    // lavender
        const darkText = Color(0xFF202952);
        const subText = Color(0xFF5A6A8A);

        if (kIsWeb) {
          return Scaffold(
            backgroundColor: bgColor,
            resizeToAvoidBottomInset: true,
            appBar: AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              centerTitle: true,
              title: Column(
                children: [
                  Text(
                    'NOVA',
                    style: TextStyle(
                      color: darkText,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Your AI companion for calm moments',
                    style: TextStyle(
                      color: subText,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
              leading: IconButton(
                icon: Icon(Icons.arrow_back_ios_new_rounded, color: darkText),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
            body: SafeArea(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.mic_off_rounded,
                        size: 60,
                        color: darkText,
                      ),
                      const SizedBox(height: 18),
                      Text(
                        'Voice call is not available in this browser.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: darkText,
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Use the app on mobile to enable live audio with NOVA.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: subText,
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(height: 24),
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        style: TextButton.styleFrom(
                          backgroundColor: const Color(0xFF7C3AED),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 22,
                            vertical: 12,
                          ),
                        ),
                        child: const Text('Back'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }

        return Scaffold(
          backgroundColor: bgColor,
          resizeToAvoidBottomInset: true,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            centerTitle: true,
            title: Column(
              children: [
                Text(
                  'NOVA',
                  style: TextStyle(
                    color: darkText,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Your AI companion for calm moments',
                  style: TextStyle(
                    color: subText,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
            leading: IconButton(
              icon: Icon(Icons.arrow_back_ios_new_rounded, color: darkText),
              onPressed: () {
                // Pehle pop karo, phir endCall background mein chale —
                // warna Firestore writes (summary/transcript) offline
                // hone par back button hang ho jata tha.
                final callProvider = context.read<AudioCallProvider>();
                Navigator.of(context).pop();
                callProvider.endCall();
              },
            ),
            actions: [
              // Settings toggle: manual tap mode
              Padding(
                padding: const EdgeInsets.only(right: 8, top: 8),
                child: GestureDetector(
                  onTap: () => provider.toggleManualTapMode(),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: provider.manualTapMode
                          ? orbLavender.withValues(alpha: 0.25)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      provider.manualTapMode
                          ? Icons.touch_app_rounded
                          : Icons.graphic_eq_rounded,
                      color: darkText,
                      size: 20,
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(right: 16, top: 8),
                child: Center(
                  child: Text(
                    _formatDuration(_sessionTimer.elapsed),
                    style: TextStyle(
                      color: subText,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ],
          ),
          body: LayoutBuilder(
            builder: (context, constraints) {
              final diameter = math.min(constraints.maxWidth * 0.46, 220.0);

              return Container(
                decoration: const BoxDecoration(
                  color: bgColor,
                ),
                child: SafeArea(
                  child: Stack(
                    children: [
                      Positioned.fill(
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: ConstrainedBox(
                            constraints: BoxConstraints(
                              minHeight: constraints.maxHeight,
                            ),
                            child: Column(
                              children: [
                                const SizedBox(height: 8),
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    AudioCallOrb(
                                      size: diameter,
                                      isActive: state != AudioCallState.idle,
                                      isListening: isListening,
                                    ),
                                    const SizedBox(height: 28),
                                    AudioCallStatus(
                                      label: provider.statusText,
                                      isListening: isListening,
                                      isBusy: isBusy,
                                    ),
                                    const SizedBox(height: 20),
                                    if (provider.lastNovaResponse.trim().isNotEmpty) ...[
                                      Container(
                                        width: double.infinity,
                                        padding: const EdgeInsets.all(16),
                                        decoration: BoxDecoration(
                                          color: orbLavender.withValues(alpha: 0.15),
                                          borderRadius: BorderRadius.circular(18),
                                          border: Border.all(
                                            color: orbLavender.withValues(alpha: 0.30),
                                          ),
                                        ),
                                        child: Text(
                                          provider.lastNovaResponse,
                                          style: TextStyle(
                                            color: darkText,
                                            fontSize: 14,
                                            height: 1.5,
                                          ),
                                        ),
                                      ),
                                    ],
                                    const SizedBox(height: 30),
                                    AudioCallControls(
                                      isListening: isListening,
                                      isBusy: isBusy,
                                      manualTapMode: provider.manualTapMode,
                                      onMicPressed: () async {
                                        if (state == AudioCallState.novaSpeaking ||
                                            state == AudioCallState.processing ||
                                            state == AudioCallState.ending ||
                                            state == AudioCallState.ended) {
                                          return;
                                        }

                                        await provider.startListening();
                                      },
                                      onEndPressed: () async {
                                        final navigator = Navigator.of(context);
                                        await provider.endCall();
                                        if (!mounted) {
                                          return;
                                        }
                                        navigator.pop();
                                      },
                                    ),
                                    const SizedBox(height: 10),
                                    if (provider.sttUnavailable) ...[
                                      Padding(
                                        padding: const EdgeInsets.symmetric(horizontal: 24),
                                        child: Text(
                                          'Speech-to-text is unavailable here. Please use text fallback or try another device.',
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            color: subText,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      if (provider.panicVisible)
                        PanicOverlay(
                          onResolve: () async {
                            await provider.resolvePanic();
                          },
                        ),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}
