// Copyright 2025 Google LLC
// ... (라이선스 헤더)
import 'dart:async';
import 'dart:developer' as developer;

import 'package:firebase_ai/firebase_ai.dart';
import '../utils/audio_input.dart';
import '../utils/audio_output.dart';

class GeminiLiveService {
  final StreamController<bool> _isRecordingController =
  StreamController.broadcast();
  Stream<bool> get isRecordingStream => _isRecordingController.stream;

  bool _sessionOpening = false;
  late final LiveGenerativeModel _liveModel;
  late LiveSession _session;
  final AudioOutput _audioOutput = AudioOutput();
  final AudioInput _audioInput = AudioInput();

  GeminiLiveService() {
    // ✨ 1. 모든 설정을 원래 작동하던 상태로 완전히 복구
    final config = LiveGenerationConfig(
      speechConfig: SpeechConfig(voiceName: 'Fenrir'),
      responseModalities: [ResponseModalities.audio],
    );

    _liveModel = FirebaseAI.vertexAI().liveGenerativeModel(
      model: 'gemini-2.0-flash-exp',
      liveGenerationConfig: config,
      tools: [Tool.functionDeclarations([lightControlTool])],
    );
  }

  Future<void> connect() async {
    if (_sessionOpening) return;
    try {
      await _audioInput.init();
      await _audioOutput.init();
      _session = await _liveModel.connect();
      _sessionOpening = true;

      // ✨ 2. 연결 직후, 대화 언어를 설정하기 위한 첫 메시지를 자동으로 전송
      _session.send(
        input: Content.text('중요: 지금부터 모든 대화와 답변은 반드시 한국어로만 진행해줘.'),
        turnComplete: true,
      );

      _processMessagesContinuously();
      developer.log('Gemini Live session connected.');
    } catch (e) {
      developer.log('Failed to connect: $e');
    }
  }

  Future<void> startRecording() async {
    if (!_sessionOpening || _isRecordingController.isClosed) return;
    _isRecordingController.add(true);
    try {
      await _audioOutput.playStream();
      var inputStream = await _audioInput.startRecordingStream();

      if (inputStream != null) {
        final inlineDataStream = inputStream.map((data) {
          return InlineDataPart('audio/pcm', data);
        });
        await _session.sendMediaStream(inlineDataStream);
      }
    } catch (e) {
      developer.log(e.toString());
    }
  }

  Future<void> stopRecording() async {
    if (!_sessionOpening || _isRecordingController.isClosed) return;
    try {
      await _audioInput.stopRecording();
      await _audioOutput.stopStream();
    } catch (e) {
      developer.log(e.toString());
    }
    _isRecordingController.add(false);
  }

  void _processMessagesContinuously() async {
    while (_sessionOpening) {
      try {
        await for (final message in _session.receive()) {
          await _handleLiveServerMessage(message);
        }
      } catch (e) {
        developer.log('Error receiving message: $e');
        if (!_sessionOpening) {
          break;
        }
        await Future.delayed(const Duration(seconds: 1));
      }
    }
  }

  Future<void> _handleLiveServerMessage(LiveServerResponse response) async {
    final message = response.message;

    if (message is LiveServerContent) {
      if (message.modelTurn != null) {
        final partList = message.modelTurn!.parts;
        for (final part in partList) {
          if (part is TextPart) {
            developer.log('Received text: ${part.text}');
          } else if (part is InlineDataPart) {
            if (part.mimeType.startsWith('audio')) {
              _audioOutput.addAudioStream(part.bytes);
            }
          }
        }
      }
    } else if (message is LiveServerToolCall &&
        message.functionCalls != null) {
      await _handleLiveServerToolCall(message);
    }
  }

  Future<void> _handleLiveServerToolCall(LiveServerToolCall response) async {
    final functionCalls = response.functionCalls!.toList();
    if (functionCalls.isNotEmpty) {
      final functionCall = functionCalls.first;
      if (functionCall.name == 'setLightValues') {
        var color = functionCall.args['colorTemperature'] as String? ?? 'warm';
        var brightness = functionCall.args['brightness'] as int? ?? 50;
        final functionResult = await _setLightValues(
          brightness: brightness,
          colorTemperature: color,
        );
        await _session.send(
          input: Content.functionResponse(functionCall.name, functionResult),
        );
      } else {
        developer.log('Function not implemented: ${functionCall.name}');
      }
    }
  }

  Future<Map<String, Object?>> _setLightValues(
      {int? brightness, String? colorTemperature}) async {
    final apiResponse = {
      'colorTemprature': colorTemperature,
      'brightness': brightness,
    };
    developer.log('Tool call handled with response: $apiResponse');
    return apiResponse;
  }

  Future<void> dispose() async {
    _isRecordingController.close();
    if (_sessionOpening) {
      _sessionOpening = false;
      await _session.close();
    }
    _audioInput.dispose();
    await _audioOutput.dispose();
    developer.log('Gemini Live service disposed.');
  }

  // ✨ 3. Tool의 설명도 원래의 단순한 버전으로 복구
  static final lightControlTool = FunctionDeclaration(
    'setLightValues',
    'Set the brightness and color temperature of a room light.',
    parameters: {
      'brightness': Schema.integer(
          description:
          'Light level from 0 to 100. Zero is off and 100 is full brightness.'),
      'colorTemperature': Schema.string(
          description:
          'Color temperature of the light fixture, which can be `daylight`, `cool` or `warm`.'),
    },
  );
}