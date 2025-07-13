import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';
import '../models/store.dart';
import '../models/receipt.dart';
import '../models/notification.dart';
import '../models/modal_state.dart';
import '../models/voice_message.dart';
import '../services/ocr_service.dart';
import '../services/location_service.dart';
import '../services/receipt_history_service.dart';
import '../services/ai_recommendation_service.dart';
import '../widgets/header_widget.dart';
import '../widgets/menu_bar_widget.dart';
import '../widgets/store_card_widget.dart';
import '../widgets/modal_widget.dart';
import '../widgets/notification_toast.dart';
import '../widgets/centered_notification.dart';
import '../widgets/animated_background.dart';
import '../widgets/footer_widget.dart';
import '../widgets/loading_spinner.dart';
import '../constants/app_constants.dart';
import '../utils/app_utils.dart';
import 'GeminiLiveService.dart';

class WebMainPage extends StatefulWidget {
  const WebMainPage({super.key});

  @override
  State<WebMainPage> createState() => _WebMainPageState();
}

class _WebMainPageState extends State<WebMainPage> {
  // 위치 관련 상태
  bool _isNearbyModeActive = false;
  bool _isLocationLoading = false;
  Position? _userLocation;
  final LocationService _locationService = LocationService();

  // 검색 및 필터링 관련 상태
  String _searchTerm = '';
  String _selectedCategory = 'all';
  List<Store> _stores = [];
  List<Store> _filteredStores = [];
  bool _isLoading = false;
  String? _error;

  // 모달 관련 상태
  bool _isHeaderScrolled = false;
  NotificationMessage? _notification;
  String? _centeredNotification;

  // 사용자 관련 상태
  List<String> _favorites = [];
  String _activeView = 'explore';
  String? _userName;
  final ScrollController _scrollController = ScrollController();

  // AI 추천 관련 상태
  String _userPreferencesInput = '';
  List<Store> _aiRecommendations = [];
  bool _isAiLoading = false;

  // 영수증 분석 관련 상태
  File? _selectedReceiptImageFile;
  String? _receiptImagePreviewUrl;
  ReceiptAnalysisResult? _analysisResult;
  bool _isReceiptImageAnalyzing = false;

  // 음성 제어 관련 상태
  bool _isVoiceControlActive = false;
  final GeminiLiveService _geminiLiveService = GeminiLiveService();
  
  // 실시간 대화 관련 상태
  List<VoiceMessage> _voiceMessages = [];
  final ScrollController _voiceChatController = ScrollController();

  // 컨트롤러들
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _aiInputController = TextEditingController();

  // 기타 상태
  Store? _currentStore;
  List<ReceiptData> _receiptHistory = [];
  String _demoLocationState = 'off';

  ModalState _modalState = ModalState(isOpen: false, type: '', data: null);

  // 서비스 인스턴스들
  final OcrService _ocrService = OcrService();
  final AiRecommendationService _aiRecommendationService = AiRecommendationService();
  final ReceiptHistoryService _receiptHistoryService = ReceiptHistoryService();

  @override
  void initState() {
    super.initState();
    _initializeData();
    _scrollController.addListener(_onScroll);
    _loadStoredData();
    _setupVoiceControl();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    _aiInputController.dispose();
    _voiceChatController.dispose();
    _geminiLiveService.dispose();
    super.dispose();
  }

  void _setupVoiceControl() {
    // GeminiLiveService 콜백 설정
    _geminiLiveService.setSearchCallback(_onSearchChanged);
    _geminiLiveService.setCategoryFilterCallback(_onCategoryChanged);
    _geminiLiveService.setLocationToggleCallback(_handleToggleNearbyMode);
    _geminiLiveService.setAiRecommendationCallback(_getAiRecommendations);
    _geminiLiveService.setReceiptAnalysisCallback(() => _handleMenuNavigate('receiptAi'));
    _geminiLiveService.setMenuNavigationCallback(_handleMenuNavigate);
    _geminiLiveService.setStoreSelectionCallback(_handleVoiceStoreSelect);
    _geminiLiveService.setFavoriteToggleCallback(_handleVoiceFavoriteToggle);
    _geminiLiveService.setNotificationCallback(_handleVoiceNotification);
    _geminiLiveService.setVoiceResponseCallback(_handleVoiceResponse);
  }

  void _initializeData() {
    setState(() {
      _stores = AppConstants.stores;
      _filteredStores = _stores;
    });
    _filterStores();
    _updateVoiceControlData();
  }

  void _updateVoiceControlData() {
    // 가게 이름 목록 업데이트
    final storeNames = _stores.map((store) => store.name).toList();
    _geminiLiveService.updateAvailableStores(storeNames);
    
    // 카테고리 목록 업데이트
    final categories = ['전체', ...Category.values.map((c) => c.displayName)];
    _geminiLiveService.updateAvailableCategories(categories);
  }

  void _loadStoredData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // 찜 목록 로드
      final favoritesList = prefs.getStringList('favorites') ?? [];
      setState(() {
        _favorites = favoritesList;
      });
      
      // 영수증 내역 로드
      final history = await _receiptHistoryService.getReceiptHistory();
      setState(() {
        _receiptHistory = history;
      });
      
      // 데모 위치 설정 (임시)
      setState(() {
        _userLocation = Position(
          latitude: 37.5665,
          longitude: 126.9780,
          timestamp: DateTime.now(),
          accuracy: 0,
          altitude: 0,
          altitudeAccuracy: 0,
          heading: 0,
          headingAccuracy: 0,
          speed: 0,
          speedAccuracy: 0,
        );
      });
      
    } catch (e) {
      debugPrint('데이터 로드 오류: $e');
    }
  }

  void _onScroll() {
    setState(() {
      _isHeaderScrolled = _scrollController.offset > 10;
    });
  }

  // 음성 제어 관련 메서드들
  void _handleVoiceStoreSelect(String storeName) {
    final store = _stores.firstWhere(
      (s) => s.name.toLowerCase().contains(storeName.toLowerCase()),
      orElse: () => _stores.first,
    );
    _handleSelectStore(store);
    _showNotification('가게를 선택했습니다: ${store.name}', NotificationType.success);
  }

  void _handleVoiceFavoriteToggle(String storeName) {
    final store = _stores.firstWhere(
      (s) => s.name.toLowerCase().contains(storeName.toLowerCase()),
      orElse: () => _stores.first,
    );
    _toggleFavorite(store.id);
  }

  void _handleVoiceNotification(String message, String type) {
    NotificationType notificationType;
    switch (type) {
      case 'success':
        notificationType = NotificationType.success;
        break;
      case 'warning':
        notificationType = NotificationType.warning;
        break;
      case 'error':
        notificationType = NotificationType.error;
        break;
      default:
        notificationType = NotificationType.info;
    }
    _showNotification(message, notificationType);
  }

  Future<void> _toggleVoiceControl() async {
    if (_isVoiceControlActive) {
      // 음성 제어 비활성화
      try {
        await _geminiLiveService.stopRecording();
        setState(() {
          _isVoiceControlActive = false;
        });
        _showNotification('음성 제어가 비활성화되었습니다.', NotificationType.info);
        debugPrint('Voice control deactivated');
      } catch (e) {
        debugPrint('Error deactivating voice control: $e');
        _showNotification('음성 제어 비활성화 중 오류가 발생했습니다.', NotificationType.error);
      }
    } else {
      // 음성 제어 활성화
      try {
        debugPrint('Starting voice control...');
        _showNotification('음성 제어를 시작합니다...', NotificationType.info);
        
        await _geminiLiveService.connect();
        debugPrint('Gemini Live connected');
        
        await _geminiLiveService.startRecording();
        debugPrint('Recording started');
        
        setState(() {
          _isVoiceControlActive = true;
        });
        
        _showNotification('음성 제어가 활성화되었습니다! 말씀해주세요!', NotificationType.success);
        debugPrint('Voice control activated successfully');
        
      } catch (e) {
        debugPrint('Error activating voice control: $e');
        _showNotification('음성 제어 활성화 중 오류가 발생했습니다: $e', NotificationType.error);
        
        // 상태 초기화
        setState(() {
          _isVoiceControlActive = false;
        });
      }
    }
  }

  Future<void> _handleToggleNearbyMode() async {
    if (_isNearbyModeActive) {
      // 주변 모드 비활성화
      setState(() {
        _isNearbyModeActive = false;
        _userLocation = null;
        _isLocationLoading = false;
      });
      _filterStores();
      _showNotification('주변 모드가 해제되었습니다.', NotificationType.info);
    } else {
      // 주변 모드 활성화
      setState(() {
        _isLocationLoading = true;
      });

      try {
        // 실제 위치 가져오기
        final position = await _locationService.getCurrentLocation();
        
        if (position != null) {
          setState(() {
            _userLocation = position;
            _isNearbyModeActive = true;
            _isLocationLoading = false;
          });
          
          // 거리 정보 추가 및 정렬
          final storesWithDistance = _locationService.addDistanceToStores(_stores, position);
          final sortedStores = storesWithDistance.where((store) => store.distance != null).toList()
            ..sort((a, b) => (a.distance ?? 0).compareTo(b.distance ?? 0));
          
          setState(() {
            _stores = sortedStores;
          });
          
          _filterStores();
          _showNotification('주변 가게를 찾았습니다!', NotificationType.success);
        } else {
          setState(() {
            _isLocationLoading = false;
          });
          _showNotification('위치를 가져올 수 없습니다. 위치 권한을 확인해주세요.', NotificationType.error);
        }
      } catch (e) {
        setState(() {
          _isLocationLoading = false;
        });
        _showNotification('위치 서비스 오류: $e', NotificationType.error);
      }
    }
  }

  void _filterStores() {
    setState(() {
      _isLoading = true;
    });

    List<Store> filtered = List.from(_stores);

    // 카테고리 필터링
    if (_selectedCategory != 'all') {
      filtered = filtered.where((store) => store.category.displayName == _selectedCategory).toList();
    }

    // 검색어 필터링
    if (_searchTerm.isNotEmpty) {
      final searchLower = _searchTerm.toLowerCase();
      filtered = filtered.where((store) {
        return store.name.toLowerCase().contains(searchLower) ||
               store.address.toLowerCase().contains(searchLower) ||
               store.discounts.any((discount) => 
                 discount.description.toLowerCase().contains(searchLower));
      }).toList();
    }

    setState(() {
      _filteredStores = filtered;
      _isLoading = false;
    });
  }

  // 음성 제어용 검색 콜백
  void _onSearchChanged(String value) {
    setState(() {
      _searchTerm = value;
      _searchController.text = value;
    });
    _filterStores();
    _showNotification('검색어가 변경되었습니다: "$value"', NotificationType.info);
  }

  // 음성 제어용 카테고리 콜백
  void _onCategoryChanged(String category) {
    setState(() {
      _selectedCategory = category;
    });
    _filterStores();
    _showNotification('카테고리가 변경되었습니다: "$category"', NotificationType.info);
  }

  void _showNotification(String message, NotificationType type) {
    setState(() {
      _notification = NotificationMessage(
        id: AppUtils.generateUUID(),
        message: message,
        type: type,
      );
    });

    // 3초 후 알림 제거
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() {
          _notification = null;
        });
      }
    });
  }

  void _showCenteredNotification(String message) {
    setState(() {
      _centeredNotification = message;
    });

    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _centeredNotification = null;
        });
      }
    });
  }

  void _handleSelectStore(Store store) {
    setState(() {
      _currentStore = store;
      _modalState = ModalState(isOpen: true, type: 'storeDetails', data: store);
    });
  }

  void _closeModal() {
    setState(() {
      _modalState = ModalState(isOpen: false, type: '', data: null);
      _currentStore = null;
    });
  }

  void _toggleFavorite(String storeId) async {
    setState(() {
      if (_favorites.contains(storeId)) {
        _favorites.remove(storeId);
      } else {
        _favorites.add(storeId);
      }
    });
    
    // SharedPreferences에 저장
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList('favorites', _favorites);
      _showNotification(
        _favorites.contains(storeId) ? '찜 목록에 추가되었습니다.' : '찜 목록에서 제거되었습니다.',
        NotificationType.success
      );
    } catch (e) {
      _showNotification('찜 목록 저장 중 오류가 발생했습니다.', NotificationType.error);
    }
  }

  void _handleMenuNavigate(String view) {
    setState(() {
      _activeView = view;
    });
    
    // 모든 메뉴를 모달로 처리
    switch (view) {
      case 'explore':
        // 메인 화면으로 돌아가기 (모달 닫기)
        _closeModal();
        break;
      case 'favorites':
        final favoriteStores = _stores.where((store) => _favorites.contains(store.id)).toList();
        setState(() {
          _modalState = ModalState(isOpen: true, type: 'favorites', data: favoriteStores);
        });
        break;
      case 'receiptHistory':
        setState(() {
          _modalState = ModalState(isOpen: true, type: 'receiptHistory', data: _receiptHistory);
        });
        break;
      case 'ai':
        setState(() {
          _modalState = ModalState(isOpen: true, type: 'aiRecommender', data: null);
        });
        break;
      case 'receiptAi':
        _showReceiptAnalysisModal();
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          const AnimatedBackground(child: SizedBox()),
          
          // Notification Toast (Stack 내부에 위치)
          if (_notification != null)
            NotificationToast(
              notification: _notification!,
              onDismiss: () => setState(() => _notification = null),
            ),
          
          Column(
            children: [
              // Header
              HeaderWidget(
                userName: _userName,
                onLogout: _handleLogout,
                onShowFavorites: () => _handleMenuNavigate('favorites'),
                onShowReceiptHistory: () => _handleMenuNavigate('receiptHistory'),
                favoriteCount: _favorites.length,
                isScrolled: _isHeaderScrolled,
                onLogoClick: () => _handleMenuNavigate('explore'),
              ),
              
              // Centered Notification
              if (_centeredNotification != null)
                CenteredNotification(
                  message: _centeredNotification!,
                  onClose: () => setState(() => _centeredNotification = null),
                ),
              
              // Main Content
              Expanded(
                child: SingleChildScrollView(
                  controller: _scrollController,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        // Main Glass Panel
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(color: Colors.white.withOpacity(0.2)),
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // Title
                              const Column(
                                children: [
                                  Text(
                                    '학생 맞춤 할인 혜택',
                                    style: TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                  SizedBox(height: 6),
                                  Text(
                                    '다양한 조건으로 할인 혜택을 찾아보세요!',
                                    style: TextStyle(
                                      color: Colors.white70,
                                      fontSize: 14,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                              
                              const SizedBox(height: 20),
                              
                              // Action Buttons
                              Row(
                                children: [
                                  Expanded(
                                    child: _buildActionButton(
                                      icon: Icons.location_on,
                                      text: '내 주변 혜택',
                                      onTap: _handleToggleNearbyMode,
                                      isActive: _isNearbyModeActive,
                                      isLoading: _isLocationLoading,
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: _buildActionButton(
                                      icon: Icons.auto_awesome,
                                      text: 'AI 추천',
                                      onTap: () => _showAiRecommendationModal(),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: _buildActionButton(
                                      icon: Icons.receipt_long,
                                      text: '영수증 분석',
                                      onTap: () => _handleMenuNavigate('receiptAi'),
                                    ),
                                  ),
                                ],
                              ),
                              
                              const SizedBox(height: 16),
                              
                              // Voice Control Button
                              Container(
                                width: double.infinity,
                                child: _buildActionButton(
                                  icon: _isVoiceControlActive ? Icons.mic : Icons.mic_off,
                                  text: _isVoiceControlActive ? '음성 제어 중...' : '음성 제어 시작',
                                  onTap: _toggleVoiceControl,
                                  isActive: _isVoiceControlActive,
                                ),
                              ),
                              
                              const SizedBox(height: 8),
                              
                              // Test Buttons
                              Row(
                                children: [
                                  Expanded(
                                    child: _buildActionButton(
                                      icon: Icons.search,
                                      text: '테스트 검색',
                                      onTap: () => _testVoiceSearch(),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: _buildActionButton(
                                      icon: Icons.category,
                                      text: '테스트 필터',
                                      onTap: () => _testVoiceFilter(),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: _buildActionButton(
                                      icon: Icons.favorite,
                                      text: '테스트 찜',
                                      onTap: () => _testVoiceFavorite(),
                                    ),
                                  ),
                                ],
                              ),
                              
                              const SizedBox(height: 8),
                              
                              // Direct Function Test Buttons
                              Row(
                                children: [
                                  Expanded(
                                    child: _buildActionButton(
                                      icon: Icons.play_arrow,
                                      text: '직접 검색',
                                      onTap: () => _directTestSearch(),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: _buildActionButton(
                                      icon: Icons.play_arrow,
                                      text: '직접 필터',
                                      onTap: () => _directTestFilter(),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: _buildActionButton(
                                      icon: Icons.play_arrow,
                                      text: '직접 AI',
                                      onTap: () => _directTestAI(),
                                    ),
                                  ),
                                ],
                              ),
                              
                              // Voice Chat UI
                              if (_isVoiceControlActive) ...[
                                const SizedBox(height: 16),
                                _buildVoiceChatUI(),
                              ],
                              
                              const SizedBox(height: 16),
                              
                              // Search Bar
                              TextField(
                                controller: _searchController,
                                onChanged: _onSearchChanged,
                                style: const TextStyle(color: Colors.white),
                                decoration: const InputDecoration(
                                  hintText: '가게 이름, 주소, 테마 검색...',
                                  hintStyle: TextStyle(color: Colors.white54),
                                  filled: true,
                                  fillColor: Colors.white10,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.all(Radius.circular(12)),
                                    borderSide: BorderSide(color: Colors.white24),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.all(Radius.circular(12)),
                                    borderSide: BorderSide(color: Colors.white24),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.all(Radius.circular(12)),
                                    borderSide: BorderSide(color: Colors.white38),
                                  ),
                                  contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                ),
                              ),
                              
                              // Location Success
                              if (_isNearbyModeActive && _userLocation != null) ...[
                                const SizedBox(height: 8),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(Icons.check_circle, color: Colors.blue, size: 16),
                                    const SizedBox(width: 4),
                                    const Text(
                                      '내 주변 기준으로 정렬되었습니다.',
                                      style: TextStyle(color: Colors.blue, fontSize: 12),
                                    ),
                                  ],
                                ),
                              ],
                            ],
                          ),
                        ),
                        
                        const SizedBox(height: 20),
                        
                        // Category Filters
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
          children: [
                              _buildCategoryButton('전체', 'all', Icons.list),
                              const SizedBox(width: 8),
                              ...Category.values.map((category) => 
                                Padding(
                                  padding: const EdgeInsets.only(right: 8),
                                  child: _buildCategoryButton(
                                    category.displayName,
                                    category.displayName,
                                    _getCategoryIcon(category),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        
                        const SizedBox(height: 20),
                        
                        // Content
                        if (_isLoading)
                          const LoadingSpinner(message: '할인 정보를 불러오는 중입니다...')
                        else if (_error != null)
                          _buildErrorWidget()
                        else if (_filteredStores.isEmpty)
                          _buildEmptyWidget()
                        else
                          _buildStoreGrid(),
                        
                        // Footer
                        const SizedBox(height: 40),
                        const FooterWidget(),
                        
                        // Menu Bar (하단 여백)
                        const SizedBox(height: 100),
                      ],
                    ),
                  ),
                ),
              ),
              
              // Menu Bar (고정 위치)
              Container(
                padding: const EdgeInsets.only(bottom: 24),
                child: MenuBarWidget(
                  activeView: _activeView,
                  onNavigate: _handleMenuNavigate,
                  favoriteCount: _favorites.length,
                ),
              ),
              
              // Modal
              if (_modalState.isOpen)
                ModalWidget(
                  isOpen: _modalState.isOpen,
                  onClose: _closeModal,
                  type: _modalState.type,
                  data: _modalState.data,
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String text,
    required VoidCallback onTap,
    bool isActive = false,
    bool isLoading = false,
  }) {
    return GestureDetector(
      onTap: isLoading ? null : onTap,
                  child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: isActive 
              ? Colors.blue.withOpacity(0.2) 
              : Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isActive 
                ? Colors.blue.withOpacity(0.3) 
                : Colors.white.withOpacity(0.2),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isLoading)
              const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            else
              Icon(
                icon,
                color: isActive ? Colors.blue.shade300 : Colors.white,
                size: 20,
              ),
            const SizedBox(height: 4),
            Text(
              text,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: isActive ? Colors.blue.shade300 : Colors.white,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryButton(String text, String value, IconData icon) {
    final isSelected = _selectedCategory == value;
    
    return GestureDetector(
      onTap: () => _onCategoryChanged(value),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected 
              ? Colors.blue.withOpacity(0.2) 
              : Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected 
                ? Colors.blue.withOpacity(0.3) 
                : Colors.white.withOpacity(0.2),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 14,
              color: isSelected ? Colors.blue.shade300 : Colors.white,
            ),
            const SizedBox(width: 4),
            Text(
              text,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: isSelected ? Colors.blue.shade300 : Colors.white,
                ),
              ),
          ],
        ),
      ),
    );
  }

  IconData _getCategoryIcon(Category category) {
    switch (category) {
      case Category.food:
        return Icons.restaurant;
      case Category.shopping:
        return Icons.shopping_bag;
      case Category.movie:
        return Icons.movie;
      case Category.culture:
        return Icons.museum;
      case Category.study:
        return Icons.school;
      case Category.free:
        return Icons.free_breakfast;
      case Category.other:
        return Icons.more_horiz;
    }
  }

  Widget _buildErrorWidget() {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          const Icon(Icons.error, color: Colors.red, size: 48),
          const SizedBox(height: 16),
          Text(
            _error!,
            style: const TextStyle(color: Colors.white, fontSize: 16),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyWidget() {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          const Icon(Icons.search_off, color: Colors.white54, size: 48),
          const SizedBox(height: 16),
          const Text(
            '선택한 조건에 맞는 할인 정보가 없습니다.',
            style: TextStyle(color: Colors.white70, fontSize: 16),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          const Text(
            '다른 카테고리나 검색어를 사용해보세요.',
            style: TextStyle(color: Colors.white54, fontSize: 14),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildStoreGrid() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = constraints.maxWidth > 600 ? 3 : 2;
        final childAspectRatio = constraints.maxWidth > 600 ? 0.8 : 0.75;
        
        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            childAspectRatio: childAspectRatio,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
          ),
          itemCount: _filteredStores.length,
          itemBuilder: (context, index) {
            final store = _filteredStores[index];
            final isFavorite = _favorites.contains(store.id);
            
            return StoreCardWidget(
              store: store,
              isFavorite: isFavorite,
              onToggleFavorite: () => _toggleFavorite(store.id),
              onSelectStore: () => _handleSelectStore(store),
              showDistance: _isNearbyModeActive,
            );
          },
        );
      },
    );
  }

  void _showReceiptAnalysisModal() async {
    final result = await showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (context) => Material(
        color: Colors.transparent,
        child: ModalWidget(
          isOpen: true,
          type: 'receiptAnalysis',
          data: null,
          onClose: () => Navigator.of(context).pop(),
        ),
      ),
    );

    if (result != null) {
      if (result == 'gallery') {
        await _pickReceiptImage();
      } else if (result == 'camera') {
        await _takeReceiptPhoto();
      }
    }
  }

  Future<void> _getAiRecommendations(String userPreferences) async {
    if (userPreferences.trim().isEmpty) {
      _showNotification('선호도를 입력해주세요.', NotificationType.warning);
      return;
    }

    setState(() {
      _isAiLoading = true;
    });

    try {
      // AI 추천 서비스를 사용하여 추천 생성
      final recommendations = await _aiRecommendationService.getRecommendations(userPreferences);
      
      setState(() {
        _aiRecommendations = recommendations;
        _isAiLoading = false;
      });

      // 모달 열기
      setState(() {
        _modalState = ModalState(
          isOpen: true,
          type: 'aiRecommender',
          data: recommendations,
        );
      });

      _showNotification('AI 추천이 완료되었습니다!', NotificationType.success);
      
    } catch (e) {
      setState(() {
        _isAiLoading = false;
      });
      _showNotification('AI 추천 생성 중 오류가 발생했습니다: $e', NotificationType.error);
    }
  }

  Future<void> _pickReceiptImage() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (image != null) {
        setState(() {
          _selectedReceiptImageFile = File(image.path);
          _receiptImagePreviewUrl = image.path;
        });
        
        _showNotification('영수증 이미지가 선택되었습니다. 분석을 시작합니다.', NotificationType.info);
        
        // 자동으로 분석 시작
        await _analyzeReceiptImage();
      }
    } catch (e) {
      _showNotification('이미지 선택 중 오류가 발생했습니다: $e', NotificationType.error);
    }
  }

  Future<void> _takeReceiptPhoto() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (image != null) {
        setState(() {
          _selectedReceiptImageFile = File(image.path);
          _receiptImagePreviewUrl = image.path;
        });
        
        _showNotification('영수증 사진이 촬영되었습니다. 분석을 시작합니다.', NotificationType.info);
        
        // 자동으로 분석 시작
        await _analyzeReceiptImage();
      }
    } catch (e) {
      _showNotification('카메라 사용 중 오류가 발생했습니다: $e', NotificationType.error);
    }
  }

  Future<void> _analyzeReceiptImage() async {
    if (_selectedReceiptImageFile == null) {
      _showNotification('분석할 영수증 이미지를 선택해주세요.', NotificationType.warning);
      return;
    }

    setState(() {
      _isReceiptImageAnalyzing = true;
    });

    try {
      // OCR 서비스를 사용하여 영수증 분석
      final analysisResult = await _ocrService.analyzeReceipt(_selectedReceiptImageFile!);
      
      setState(() {
        _analysisResult = analysisResult;
        _isReceiptImageAnalyzing = false;
      });

      if (analysisResult.isReceipt) {
        // 영수증이면 내역에 저장
        if (analysisResult.parsedData != null) {
          await _receiptHistoryService.saveReceipt(analysisResult.parsedData!);
          
          // 영수증 내역 새로고침
          final updatedHistory = await _receiptHistoryService.getReceiptHistory();
          setState(() {
            _receiptHistory = updatedHistory;
          });
        }

        // 모달 열기
        setState(() {
          _modalState = ModalState(
            isOpen: true,
            type: 'imageReceiptAnalysis',
            data: analysisResult,
          );
        });

        _showNotification('영수증 분석이 완료되었습니다!', NotificationType.success);
      } else {
        _showNotification('영수증으로 인식되지 않았습니다. 더 선명한 영수증 사진으로 다시 시도해주세요.', NotificationType.warning);
      }
      
    } catch (e) {
      setState(() {
        _isReceiptImageAnalyzing = false;
      });
      _showNotification('영수증 분석 중 오류가 발생했습니다: $e', NotificationType.error);
    }
  }

  void _handleVoiceResponse(String message, bool isUser) {
    setState(() {
      _voiceMessages.add(VoiceMessage(
        id: AppUtils.generateUUID(),
        message: message,
        isUser: isUser,
        timestamp: DateTime.now(),
      ));
    });
    
    // 대화창을 맨 아래로 스크롤
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_voiceChatController.hasClients) {
        _voiceChatController.animateTo(
          _voiceChatController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _addUserMessage(String message) {
    setState(() {
      _voiceMessages.add(VoiceMessage(
        id: AppUtils.generateUUID(),
        message: message,
        isUser: true,
        timestamp: DateTime.now(),
      ));
    });
  }

  void _clearVoiceMessages() {
    setState(() {
      _voiceMessages.clear();
    });
  }

  void _showAiRecommendationModal() {
    setState(() {
      _modalState = ModalState(isOpen: true, type: 'aiRecommender', data: null);
    });
  }

  Widget _buildVoiceChatUI() {
    final TextEditingController chatController = TextEditingController();
    
    return Container(
      height: 300,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            ),
            child: Row(
              children: [
                const Icon(Icons.chat, color: Colors.white, size: 16),
                const SizedBox(width: 8),
                const Text(
                  'AI 비서와 대화',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                GestureDetector(
                  onTap: _clearVoiceMessages,
                  child: const Icon(
                    Icons.clear_all,
                    color: Colors.white70,
                    size: 16,
                  ),
                ),
              ],
            ),
          ),
          
          // Messages
          Expanded(
            child: _voiceMessages.isEmpty
                ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.mic,
                          color: Colors.white54,
                          size: 32,
                        ),
                        SizedBox(height: 8),
                        Text(
                          '음성으로 말씀하거나\n텍스트로 입력해주세요',
                          style: TextStyle(
                            color: Colors.white54,
                            fontSize: 12,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    controller: _voiceChatController,
                    padding: const EdgeInsets.all(8),
                    itemCount: _voiceMessages.length,
                    itemBuilder: (context, index) {
                      final message = _voiceMessages[index];
                      return _buildVoiceMessage(message);
                    },
                  ),
          ),
          
          // Chat Input
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: const BorderRadius.vertical(bottom: Radius.circular(12)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: chatController,
                    style: const TextStyle(color: Colors.white, fontSize: 12),
                    decoration: const InputDecoration(
                      hintText: '메시지를 입력하세요...',
                      hintStyle: TextStyle(color: Colors.white54, fontSize: 12),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    ),
                    onSubmitted: (text) {
                      if (text.trim().isNotEmpty) {
                        _geminiLiveService.sendChatMessage(text);
                        chatController.clear();
                      }
                    },
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: () {
                    if (chatController.text.trim().isNotEmpty) {
                      _geminiLiveService.sendChatMessage(chatController.text);
                      chatController.clear();
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Icon(
                      Icons.send,
                      color: Colors.white,
                      size: 14,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVoiceMessage(VoiceMessage message) {
    final isUser = message.isUser;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isUser) ...[
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.3),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.smart_toy,
                color: Colors.white,
                size: 14,
              ),
            ),
            const SizedBox(width: 8),
          ],
          
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: isUser 
                    ? Colors.blue.withOpacity(0.2)
                    : Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isUser 
                      ? Colors.blue.withOpacity(0.3)
                      : Colors.white.withOpacity(0.2),
                ),
              ),
              child: Text(
                message.message,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                ),
              ),
            ),
          ),
          
          if (isUser) ...[
            const SizedBox(width: 8),
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.3),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.person,
                color: Colors.white,
                size: 14,
              ),
            ),
          ],
        ],
      ),
    );
  }

  void _handleLogout() {
    // 로그아웃 처리
    setState(() {
      _userName = null;
      _favorites.clear();
    });
    // Firebase 로그아웃 처리
    FirebaseAuth.instance.signOut();
  }

  void _testVoiceSearch() {
    debugPrint('Testing voice search...');
    _onSearchChanged('스타벅스');
    _showNotification('테스트: 스타벅스 검색 실행', NotificationType.success);
    
    // 채팅으로도 테스트 메시지 전송
    _geminiLiveService.sendChatMessage('스타벅스 검색해줘');
    _addUserMessage('스타벅스 검색해줘');
  }

  void _testVoiceFilter() {
    debugPrint('Testing voice filter...');
    _onCategoryChanged('음식');
    _showNotification('테스트: 음식 카테고리 필터 실행', NotificationType.success);
    
    // 채팅으로도 테스트 메시지 전송
    _geminiLiveService.sendChatMessage('음식 카테고리로 필터링해줘');
    _addUserMessage('음식 카테고리로 필터링해줘');
  }

  void _testVoiceFavorite() {
    debugPrint('Testing voice favorite...');
    if (_stores.isNotEmpty) {
      _toggleFavorite(_stores.first.id);
      _showNotification('테스트: 첫 번째 가게 찜하기 실행', NotificationType.success);
      
      // 채팅으로도 테스트 메시지 전송
      _geminiLiveService.sendChatMessage('첫 번째 가게 찜해줘');
      _addUserMessage('첫 번째 가게 찜해줘');
    }
  }

  // 직접 function tool 호출 테스트
  void _directTestSearch() {
    debugPrint('Direct test search...');
    _onSearchChanged('스타벅스');
    _showNotification('직접 테스트: 스타벅스 검색 실행', NotificationType.success);
  }

  void _directTestFilter() {
    debugPrint('Direct test filter...');
    _onCategoryChanged('음식');
    _showNotification('직접 테스트: 음식 카테고리 필터 실행', NotificationType.success);
  }

  void _directTestAI() {
    debugPrint('Direct test AI...');
    _getAiRecommendations('저렴한 음식점');
    _showNotification('직접 테스트: AI 추천 실행', NotificationType.success);
  }
}