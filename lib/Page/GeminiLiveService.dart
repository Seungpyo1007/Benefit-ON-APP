// Copyright 2025 Google LLC
// ... (라이선스 헤더)
import 'dart:async';
import 'dart:developer' as developer;

import 'package:firebase_ai/firebase_ai.dart';
import '../utils/audio_input.dart';
import '../utils/audio_output.dart';

// 앱 기능 제어를 위한 콜백 타입 정의
typedef SearchCallback = void Function(String searchTerm);
typedef CategoryFilterCallback = void Function(String category);
typedef LocationToggleCallback = void Function();
typedef AiRecommendationCallback = void Function(String preferences);
typedef ReceiptAnalysisCallback = void Function();
typedef MenuNavigationCallback = void Function(String view);
typedef StoreSelectionCallback = void Function(String storeId);
typedef FavoriteToggleCallback = void Function(String storeId);
typedef NotificationCallback = void Function(String message, String type);
typedef VoiceResponseCallback = void Function(String message, bool isUser);

class GeminiLiveService {
  final StreamController<bool> _isRecordingController =
  StreamController.broadcast();
  Stream<bool> get isRecordingStream => _isRecordingController.stream;

  bool _sessionOpening = false;
  late final LiveGenerativeModel _liveModel;
  late LiveSession _session;
  final AudioOutput _audioOutput = AudioOutput();
  final AudioInput _audioInput = AudioInput();

  // 앱 기능 제어를 위한 콜백들
  SearchCallback? _onSearchChanged;
  CategoryFilterCallback? _onCategoryChanged;
  LocationToggleCallback? _onLocationToggle;
  AiRecommendationCallback? _onAiRecommendation;
  ReceiptAnalysisCallback? _onReceiptAnalysis;
  MenuNavigationCallback? _onMenuNavigate;
  StoreSelectionCallback? _onStoreSelect;
  FavoriteToggleCallback? _onFavoriteToggle;
  NotificationCallback? _onShowNotification;
  VoiceResponseCallback? _onVoiceResponse;

  // 앱 상태 정보 (음성 제어를 위해)
  List<String> _availableCategories = ['전체', '음식', '쇼핑', '영화', '문화', '학습', '무료', '기타'];
  List<String> _availableViews = ['explore', 'favorites', 'receiptHistory', 'ai', 'receiptAi'];
  List<String> _availableStores = [];

  GeminiLiveService() {
    // ✨ 1. 모든 설정을 원래 작동하던 상태로 완전히 복구
    final config = LiveGenerationConfig(
      speechConfig: SpeechConfig(voiceName: 'Fenrir'),
      responseModalities: [ResponseModalities.audio],
    );

    _liveModel = FirebaseAI.vertexAI().liveGenerativeModel(
      model: 'gemini-2.0-flash-exp',
      liveGenerationConfig: config,
      tools: [
        Tool.functionDeclarations([
          lightControlTool,
          searchStoresTool,
          filterByCategoryTool,
          toggleLocationModeTool,
          getAiRecommendationsTool,
          analyzeReceiptTool,
          navigateToViewTool,
          selectStoreTool,
          toggleFavoriteTool,
          showNotificationTool,
          getAvailableOptionsTool,
        ]),
      ],
    );
  }

  // 콜백 설정 메서드들
  void setSearchCallback(SearchCallback callback) => _onSearchChanged = callback;
  void setCategoryFilterCallback(CategoryFilterCallback callback) => _onCategoryChanged = callback;
  void setLocationToggleCallback(LocationToggleCallback callback) => _onLocationToggle = callback;
  void setAiRecommendationCallback(AiRecommendationCallback callback) => _onAiRecommendation = callback;
  void setReceiptAnalysisCallback(ReceiptAnalysisCallback callback) => _onReceiptAnalysis = callback;
  void setMenuNavigationCallback(MenuNavigationCallback callback) => _onMenuNavigate = callback;
  void setStoreSelectionCallback(StoreSelectionCallback callback) => _onStoreSelect = callback;
  void setFavoriteToggleCallback(FavoriteToggleCallback callback) => _onFavoriteToggle = callback;
  void setNotificationCallback(NotificationCallback callback) => _onShowNotification = callback;
  void setVoiceResponseCallback(VoiceResponseCallback callback) => _onVoiceResponse = callback;

  // 앱 상태 업데이트 메서드들
  void updateAvailableStores(List<String> storeNames) {
    _availableStores = storeNames;
  }

  void updateAvailableCategories(List<String> categories) {
    _availableCategories = categories;
  }

  Future<void> connect() async {
    if (_sessionOpening) return;
    try {
      developer.log('Starting Gemini Live connection...');
      await _audioInput.init();
      await _audioOutput.init();
      _session = await _liveModel.connect();
      _sessionOpening = true;

      developer.log('Gemini Live session connected successfully');

      // ✨ 2. 연결 직후, 대화 언어를 설정하기 위한 첫 메시지를 자동으로 전송
      _session.send(
        input: Content.text('''
안녕하세요! 저는 Benefit-ON 앱의 음성 비서입니다.

중요: 사용자가 요청할 때마다 반드시 적절한 function tool을 호출해서 실제 기능을 실행해주세요.

사용 가능한 기능들과 정확한 명령어:

1. 가게 검색:
   - "스타벅스 검색해줘" → searchStores("스타벅스")
   - "음식점 찾아줘" → searchStores("음식점")
   - "카페 추천해줘" → searchStores("카페")

2. 카테고리 필터:
   - "음식 카테고리로 필터링해줘" → filterByCategory("음식")
   - "쇼핑만 보여줘" → filterByCategory("쇼핑")
   - "전체 카테고리로 돌아가줘" → filterByCategory("전체")

3. 위치 기반 검색:
   - "내 주변 가게 찾아줘" → toggleLocationMode()
   - "위치 모드 켜줘" → toggleLocationMode()

4. AI 추천:
   - "AI 추천 받고 싶어" → getAiRecommendations("")
   - "저렴한 곳 추천해줘" → getAiRecommendations("저렴한 곳")

5. 영수증 분석:
   - "영수증 분석해줘" → analyzeReceipt()

6. 메뉴 이동:
   - "찜 목록 보여줘" → navigateToView("favorites")
   - "영수증 내역 보여줘" → navigateToView("receiptHistory")

7. 가게 선택:
   - "스타벅스 선택해줘" → selectStore("스타벅스")

8. 찜하기:
   - "스타벅스 찜해줘" → toggleFavorite("스타벅스")

규칙:
1. 사용자가 기능을 요청하면 반드시 해당 function tool을 호출하세요
2. 단순히 대화만 하지 말고 실제 기능을 실행하세요
3. 기능 실행 후 결과를 사용자에게 알려주세요

예시:
- 사용자: "스타벅스 찾아줘"
- AI: "네, 스타벅스를 검색해드릴게요!" (searchStores 함수 호출)

- 사용자: "음식 카테고리로 필터링해줘"
- AI: "음식 카테고리로 필터링하겠습니다!" (filterByCategory 함수 호출)

무엇을 도와드릴까요?
'''),
        turnComplete: true,
      );

      _processMessagesContinuously();
      developer.log('Gemini Live session connected and initialized.');
    } catch (e) {
      developer.log('Failed to connect: $e');
      rethrow;
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
    developer.log('Received message type: ${message.runtimeType}');

    if (message is LiveServerContent) {
      if (message.modelTurn != null) {
        final partList = message.modelTurn!.parts;
        developer.log('Model turn parts count: ${partList.length}');
        
        for (final part in partList) {
          if (part is TextPart) {
            developer.log('Received text: ${part.text}');
            // 음성 응답을 UI에 표시
            _onVoiceResponse?.call(part.text, false);
          } else if (part is InlineDataPart) {
            developer.log('Received inline data: ${part.mimeType}');
            if (part.mimeType.startsWith('audio')) {
              _audioOutput.addAudioStream(part.bytes);
            }
          }
        }
      }
    } else if (message is LiveServerToolCall &&
        message.functionCalls != null) {
      developer.log('Received tool call: ${message.functionCalls!.length} functions');
      await _handleLiveServerToolCall(message);
    } else {
      developer.log('Unknown message type: ${message.runtimeType}');
    }
  }

  // 채팅 메시지 전송 메서드 추가
  Future<void> sendChatMessage(String message) async {
    if (!_sessionOpening) {
      developer.log('Session not open');
      return;
    }

    try {
      // 사용자 메시지를 UI에 표시
      _onVoiceResponse?.call(message, true);
      
      // Gemini에 텍스트 메시지 전송
      await _session.send(
        input: Content.text(message),
        turnComplete: true,
      );
      
      developer.log('Chat message sent: $message');
    } catch (e) {
      developer.log('Error sending chat message: $e');
      _onVoiceResponse?.call('메시지 전송 중 오류가 발생했습니다.', false);
    }
  }

  Future<void> _handleLiveServerToolCall(LiveServerToolCall response) async {
    final functionCalls = response.functionCalls!.toList();
    developer.log('Processing ${functionCalls.length} function calls');
    
    if (functionCalls.isNotEmpty) {
      final functionCall = functionCalls.first;
      developer.log('Function call: ${functionCall.name} with args: ${functionCall.args}');
      
      try {
        Map<String, Object?> result = {};
        String feedbackMessage = '';
        
        switch (functionCall.name) {
          case 'searchStores':
            final searchTerm = functionCall.args['searchTerm'] as String? ?? '';
            developer.log('Executing searchStores with term: $searchTerm');
            _onSearchChanged?.call(searchTerm);
            feedbackMessage = '가게 검색을 시작했습니다: "$searchTerm"';
            result = {'success': true, 'message': feedbackMessage};
            break;
            
          case 'filterByCategory':
            final category = functionCall.args['category'] as String? ?? '전체';
            developer.log('Executing filterByCategory with category: $category');
            _onCategoryChanged?.call(category);
            feedbackMessage = '카테고리 필터를 적용했습니다: "$category"';
            result = {'success': true, 'message': feedbackMessage};
            break;
            
          case 'toggleLocationMode':
            developer.log('Executing toggleLocationMode');
            _onLocationToggle?.call();
            feedbackMessage = '위치 기반 검색 모드를 토글했습니다';
            result = {'success': true, 'message': feedbackMessage};
            break;
            
          case 'getAiRecommendations':
            final preferences = functionCall.args['preferences'] as String? ?? '';
            developer.log('Executing getAiRecommendations with preferences: $preferences');
            _onAiRecommendation?.call(preferences);
            feedbackMessage = 'AI 추천을 요청했습니다: "$preferences"';
            result = {'success': true, 'message': feedbackMessage};
            break;
            
          case 'analyzeReceipt':
            developer.log('Executing analyzeReceipt');
            _onReceiptAnalysis?.call();
            feedbackMessage = '영수증 분석을 시작했습니다';
            result = {'success': true, 'message': feedbackMessage};
            break;
            
          case 'navigateToView':
            final view = functionCall.args['view'] as String? ?? 'explore';
            developer.log('Executing navigateToView with view: $view');
            _onMenuNavigate?.call(view);
            feedbackMessage = '화면을 이동했습니다: "$view"';
            result = {'success': true, 'message': feedbackMessage};
            break;
            
          case 'selectStore':
            final storeName = functionCall.args['storeName'] as String? ?? '';
            developer.log('Executing selectStore with storeName: $storeName');
            _onStoreSelect?.call(storeName);
            feedbackMessage = '가게를 선택했습니다: "$storeName"';
            result = {'success': true, 'message': feedbackMessage};
            break;
            
          case 'toggleFavorite':
            final storeName = functionCall.args['storeName'] as String? ?? '';
            developer.log('Executing toggleFavorite with storeName: $storeName');
            _onFavoriteToggle?.call(storeName);
            feedbackMessage = '찜 상태를 변경했습니다: "$storeName"';
            result = {'success': true, 'message': feedbackMessage};
            break;
            
          case 'showNotification':
            final message = functionCall.args['message'] as String? ?? '';
            final type = functionCall.args['type'] as String? ?? 'info';
            developer.log('Executing showNotification with message: $message, type: $type');
            _onShowNotification?.call(message, type);
            feedbackMessage = '알림을 표시했습니다: "$message"';
            result = {'success': true, 'message': feedbackMessage};
            break;
            
          case 'getAvailableOptions':
            developer.log('Executing getAvailableOptions');
            result = {
              'success': true,
              'categories': _availableCategories,
              'views': _availableViews,
              'stores': _availableStores,
            };
            break;
            
          case 'setLightValues':
            var color = functionCall.args['colorTemperature'] as String? ?? 'warm';
            var brightness = functionCall.args['brightness'] as int? ?? 50;
            developer.log('Executing setLightValues with color: $color, brightness: $brightness');
            result = await _setLightValues(
              brightness: brightness,
              colorTemperature: color,
            );
            break;
            
          default:
            developer.log('Function not implemented: ${functionCall.name}');
            feedbackMessage = '지원하지 않는 기능입니다: ${functionCall.name}';
            result = {'success': false, 'message': feedbackMessage};
        }
        
        // 피드백 메시지를 UI에 표시
        if (feedbackMessage.isNotEmpty) {
          developer.log('Sending feedback: $feedbackMessage');
          _onVoiceResponse?.call(feedbackMessage, false);
        }
        
        developer.log('Sending function response: $result');
        await _session.send(
          input: Content.functionResponse(functionCall.name, result),
        );
        
      } catch (e) {
        developer.log('Error handling function call: $e');
        final errorMessage = '기능 실행 중 오류가 발생했습니다: $e';
        _onVoiceResponse?.call(errorMessage, false);
        
        await _session.send(
          input: Content.functionResponse(functionCall.name, {
            'success': false,
            'message': errorMessage
          }),
        );
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

  // 앱 기능 제어를 위한 도구들
  static final searchStoresTool = FunctionDeclaration(
    'searchStores',
    'Search for stores by name, address, or theme.',
    parameters: {
      'searchTerm': Schema.string(
        description: 'Search term for finding stores. Can be store name, address, or theme.',
      ),
    },
  );

  static final filterByCategoryTool = FunctionDeclaration(
    'filterByCategory',
    'Filter stores by category.',
    parameters: {
      'category': Schema.string(
        description: 'Category to filter by. Available categories: 전체, 음식, 쇼핑, 영화, 문화, 학습, 무료, 기타',
      ),
    },
  );

  static final toggleLocationModeTool = FunctionDeclaration(
    'toggleLocationMode',
    'Toggle location-based search mode to find nearby stores.',
    parameters: {},
  );

  static final getAiRecommendationsTool = FunctionDeclaration(
    'getAiRecommendations',
    'Get AI-powered store recommendations based on user preferences.',
    parameters: {
      'preferences': Schema.string(
        description: 'User preferences for AI recommendations (e.g., "저렴한 음식점", "조용한 카페")',
      ),
    },
  );

  static final analyzeReceiptTool = FunctionDeclaration(
    'analyzeReceipt',
    'Start receipt analysis to extract information from receipt images.',
    parameters: {},
  );

  static final navigateToViewTool = FunctionDeclaration(
    'navigateToView',
    'Navigate to different app views.',
    parameters: {
      'view': Schema.string(
        description: 'View to navigate to. Available views: explore, favorites, receiptHistory, ai, receiptAi',
      ),
    },
  );

  static final selectStoreTool = FunctionDeclaration(
    'selectStore',
    'Select a specific store to view details.',
    parameters: {
      'storeName': Schema.string(
        description: 'Name of the store to select.',
      ),
    },
  );

  static final toggleFavoriteTool = FunctionDeclaration(
    'toggleFavorite',
    'Add or remove a store from favorites.',
    parameters: {
      'storeName': Schema.string(
        description: 'Name of the store to toggle favorite status.',
      ),
    },
  );

  static final showNotificationTool = FunctionDeclaration(
    'showNotification',
    'Show a notification message to the user.',
    parameters: {
      'message': Schema.string(
        description: 'Notification message to display.',
      ),
      'type': Schema.string(
        description: 'Type of notification: info, success, warning, error',
      ),
    },
  );

  static final getAvailableOptionsTool = FunctionDeclaration(
    'getAvailableOptions',
    'Get available categories, views, and stores for reference.',
    parameters: {},
  );
}