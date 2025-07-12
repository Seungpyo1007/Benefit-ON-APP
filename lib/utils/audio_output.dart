// Copyright 2025 Google LLC
// ... (라이선스 헤더)

import 'dart:typed_data';
import 'package:flutter_soloud/flutter_soloud.dart';

class AudioOutput {
  AudioSource? stream;
  SoundHandle? handle;

  Future<void> init() async {
    if (SoLoud.instance.isInitialized) return;
    await SoLoud.instance.init(sampleRate: 24000, channels: Channels.mono);
    await setupNewStream();
  }

  Future<void> setupNewStream() async {
    if (SoLoud.instance.isInitialized) {
      await stopStream();
      stream = SoLoud.instance.setBufferStream(
        maxBufferSizeBytes: 1024 * 1024 * 10,
        bufferingType: BufferingType.released,
        bufferingTimeNeeds: 0,
        onBuffering: (isBuffering, handle, time) {},
      );
      handle = null;
    }
  }

  Future<AudioSource?> playStream() async {
    if (stream == null) await setupNewStream();
    if (handle == null) {
      handle = await SoLoud.instance.play(stream!);
    }
    return stream;
  }

  Future<void> stopStream() async {
    if (stream != null &&
        handle != null &&
        SoLoud.instance.getIsValidVoiceHandle(handle!)) {
      SoLoud.instance.setDataIsEnded(stream!);
      await SoLoud.instance.stop(handle!);
      await setupNewStream();
    }
  }

  void addAudioStream(Uint8List audioChunk) {
    if (stream != null) {
      SoLoud.instance.addAudioDataStream(stream!, audioChunk);
    }
  }

  // 리소스 정리를 위한 dispose 메서드
  Future<void> dispose() async {
    await stopStream();
    if (SoLoud.instance.isInitialized) {
      SoLoud.instance.deinit(); // 'await'를 제거하여 수정
    }
  }
}