import 'package:audio_service/audio_service.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:moments/core/services/audio_handler_service.dart';

/// Global provider for the initialized OS [MomentsAudioHandler].
final audioHandlerProvider = Provider<MomentsAudioHandler?>((ref) {
  return _globalAudioHandler;
});

MomentsAudioHandler? _globalAudioHandler;

/// Initializes the OS audio service proxy during app boot.
///
/// Returns null gracefully on platforms or environments (e.g. headless unit tests)
/// where the native audio service is unavailable.
Future<MomentsAudioHandler?> initAudioService() async {
  if (_globalAudioHandler != null) return _globalAudioHandler;

  try {
    _globalAudioHandler = await AudioService.init(
      builder: () => MomentsAudioHandler(),
      config: const AudioServiceConfig(
        androidNotificationChannelId: 'com.moments.moments.channel.audio',
        androidNotificationChannelName: 'Moments Music Playback',
        androidNotificationOngoing: true,
        androidStopForegroundOnPause: true,
        androidNotificationIcon: 'mipmap/ic_launcher',
      ),
    );
    debugPrint('[AudioService] Initialized OS proxy media session successfully');
  } catch (e, st) {
    debugPrint('[AudioService] Native audio service initialization bypassed (likely test/unsupported): $e\n$st');
    // In headless test environments, fallback to a local in-memory handler
    _globalAudioHandler = MomentsAudioHandler();
  }

  return _globalAudioHandler;
}
