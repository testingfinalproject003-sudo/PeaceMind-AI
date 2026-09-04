import '../models/audio_call_session_model.dart';

class AudioCallSessionLogic {
  const AudioCallSessionLogic();

  static bool canTransition(AudioCallState from, AudioCallState to) {
    switch (from) {
      case AudioCallState.idle:
        return to == AudioCallState.connecting;
      case AudioCallState.connecting:
        return to == AudioCallState.listening || to == AudioCallState.error;
      case AudioCallState.listening:
        return to == AudioCallState.processing ||
            to == AudioCallState.paused ||
            to == AudioCallState.error ||
            to == AudioCallState.ending;
      case AudioCallState.processing:
        return to == AudioCallState.novaSpeaking ||
            to == AudioCallState.listening ||
            to == AudioCallState.error ||
            to == AudioCallState.ending;
      case AudioCallState.novaSpeaking:
        return to == AudioCallState.listening ||
            to == AudioCallState.paused ||
            to == AudioCallState.error ||
            to == AudioCallState.ending;
      case AudioCallState.paused:
        return to == AudioCallState.listening ||
            to == AudioCallState.ending ||
            to == AudioCallState.error;
      case AudioCallState.error:
        return to == AudioCallState.listening || to == AudioCallState.ending;
      case AudioCallState.ending:
        return to == AudioCallState.ended;
      case AudioCallState.ended:
        return false;
    }
  }

  static AudioCallState applyTransition(
    AudioCallState current,
    AudioCallState next,
  ) {
    return canTransition(current, next) ? next : current;
  }
}
