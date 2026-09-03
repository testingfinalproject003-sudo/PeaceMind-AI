import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';

/// A small audio player that speaks text using TTS.
/// Used inside NOVA's message bubbles.
class AudioPlayerWidget extends StatefulWidget {
  /// The text to be spoken.
  final String text;

  /// Language code (e.g., 'en', 'ur', 'ur-roman').
  final String language;

  const AudioPlayerWidget({
    super.key,
    required this.text,
    this.language = 'en',
  });

  @override
  State<AudioPlayerWidget> createState() => _AudioPlayerWidgetState();
}

class _AudioPlayerWidgetState extends State<AudioPlayerWidget> {
  late final FlutterTts _tts;
  bool _isPlaying = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _tts = FlutterTts();
    _initTts();
  }

  Future<void> _initTts() async {
    try {
      await _tts.setLanguage(widget.language);
      await _tts.setSpeechRate(0.5); // Slow and calm
      await _tts.setPitch(1.0); // Normal pitch
    } catch (e) {
      // TTS initialization failed — fallback to silent mode.
    }
  }

  Future<void> _speak() async {
    // If currently playing, stop.
    if (_isPlaying) {
      await _tts.stop();
      setState(() {
        _isPlaying = false;
        _isLoading = false;
      });
      return;
    }

    // Set loading state
    setState(() => _isLoading = true);

    try {
      // Ensure language is set
      await _tts.setLanguage(widget.language);

      // Start speaking
      await _tts.speak(widget.text);

      setState(() {
        _isPlaying = true;
        _isLoading = false;
      });

      // Wait for speech to finish
      await _tts.awaitSpeakCompletion(true);

      if (mounted) {
        setState(() => _isPlaying = false);
      }
    } catch (e) {
      // TTS failed — fallback to silent mode.
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Unable to play audio. Please try again.'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _tts.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: _isLoading
          ? const SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.white70,
              ),
            )
          : Icon(
              _isPlaying ? Icons.stop : Icons.volume_up,
              size: 18,
              color: Colors.white70,
            ),
      onPressed: _speak,
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints(minWidth: 30, minHeight: 30),
      splashRadius: 18,
      tooltip: _isPlaying ? 'Stop' : 'Listen to NOVA',
    );
  }
}