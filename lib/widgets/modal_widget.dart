import 'package:flutter/material.dart';
import '../models/store.dart';
import '../models/receipt.dart';
import '../utils/app_utils.dart';
import '../constants/app_constants.dart';

class ModalWidget extends StatelessWidget {
  final bool isOpen;
  final String type;
  final dynamic data;
  final VoidCallback onClose;

  const ModalWidget({
    super.key,
    required this.isOpen,
    required this.type,
    this.data,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    if (!isOpen) return const SizedBox.shrink();
    
    return Material(
      color: Colors.transparent,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        color: Colors.black.withOpacity(0.7),
        child: Center(
          child: TweenAnimationBuilder<double>(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOutBack,
            tween: Tween(begin: 0.0, end: 1.0),
            builder: (context, value, child) {
              // opacity 값을 0~1 범위로 제한
              final clampedValue = value.clamp(0.0, 1.0);
              return Transform.scale(
                scale: clampedValue,
                child: Opacity(
                  opacity: clampedValue,
                  child: Container(
                    margin: const EdgeInsets.all(16),
                    constraints: const BoxConstraints(maxWidth: 500, maxHeight: 700),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Colors.white.withOpacity(0.2),
                          Colors.white.withOpacity(0.1),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.3),
                        width: 1.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.4),
                          blurRadius: 30,
                          offset: const Offset(0, 15),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Header
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.topRight,
                              colors: [
                                Colors.white.withOpacity(0.15),
                                Colors.white.withOpacity(0.05),
                              ],
                            ),
                            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                            border: Border(
                              bottom: BorderSide(
                                color: Colors.white.withOpacity(0.2),
                                width: 1,
                              ),
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Icon(
                                  _getModalIcon(),
                                  color: Colors.white,
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      _getModalTitle(),
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      _getModalSubtitle(),
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.white.withOpacity(0.7),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              GestureDetector(
                                onTap: onClose,
                                child: Container(
                                  width: 32,
                                  height: 32,
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                      color: Colors.white.withOpacity(0.3),
                                      width: 1,
                                    ),
                                  ),
                                  child: const Icon(
                                    Icons.close,
                                    color: Colors.white,
                                    size: 18,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        
                        // Content
                        Flexible(
                          child: SingleChildScrollView(
                            padding: const EdgeInsets.all(20),
                            child: _buildModalContent(),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  String _getModalTitle() {
    switch (type) {
      case 'storeDetails':
        return '가게 상세 정보';
      case 'aiRecommender':
        return 'AI 추천';
      case 'receiptHistory':
        return '영수증 내역';
      case 'favorites':
        return '찜 목록';
      case 'imageReceiptAnalysis':
        return '영수증 분석 결과';
      case 'receiptAnalysis':
        return '영수증 분석';
      default:
        return '상세 정보';
    }
  }

  String _getModalSubtitle() {
    switch (type) {
      case 'storeDetails':
        return '가게 정보와 할인 혜택을 확인하세요';
      case 'aiRecommender':
        return '개인 맞춤형 추천을 받아보세요';
      case 'receiptHistory':
        return '분석한 영수증 내역을 확인하세요';
      case 'favorites':
        return '저장한 가게 목록을 관리하세요';
      case 'imageReceiptAnalysis':
        return '영수증 분석 결과를 확인하세요';
      case 'receiptAnalysis':
        return '영수증을 분석하여 혜택을 찾아보세요';
      default:
        return '상세 정보를 확인하세요';
    }
  }

  IconData _getModalIcon() {
    switch (type) {
      case 'storeDetails':
        return Icons.store;
      case 'aiRecommender':
        return Icons.lightbulb;
      case 'receiptHistory':
        return Icons.receipt_long;
      case 'favorites':
        return Icons.favorite;
      case 'imageReceiptAnalysis':
        return Icons.camera_alt;
      case 'receiptAnalysis':
        return Icons.auto_awesome;
      default:
        return Icons.info;
    }
  }

  Widget _buildModalContent() {
    try {
      switch (type) {
        case 'storeDetails':
          return _buildStoreDetails();
        case 'aiRecommender':
          return _buildAiRecommender();
        case 'receiptHistory':
          return _buildReceiptHistory();
        case 'favorites':
          return _buildFavorites();
        case 'imageReceiptAnalysis':
          return _buildImageReceiptAnalysis();
        case 'receiptAnalysis':
          return _buildReceiptAnalysis();
        default:
          return const Text(
            '모달 내용을 불러올 수 없습니다.',
            style: TextStyle(color: Colors.white),
          );
      }
    } catch (e) {
      return Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.error,
              color: Colors.red,
              size: 48,
            ),
            const SizedBox(height: 16),
            Text(
              '오류가 발생했습니다: $e',
              style: const TextStyle(color: Colors.white),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }
  }

  Widget _buildStoreDetails() {
    if (data == null) {
      return const Text(
        '가게 정보를 불러올 수 없습니다.',
        style: TextStyle(color: Colors.white),
      );
    }

    final store = data as Store;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Store Image
        Container(
          width: double.infinity,
          height: 200,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: Colors.grey.shade800,
          ),
          child: store.imageUrl != null
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.asset(
                    store.imageUrl!,
                    fit: BoxFit.cover,
                  ),
                )
              : Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: Colors.grey.shade700,
                  ),
                  child: const Icon(
                    Icons.store,
                    size: 48,
                    color: Colors.white,
                  ),
                ),
        ),
        
        const SizedBox(height: 16),
        
        // Store Info
        Text(
          store.name,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        
        const SizedBox(height: 8),
        
        Row(
          children: [
            Icon(
              Icons.location_on,
              size: 16,
              color: Colors.white.withOpacity(0.7),
            ),
            const SizedBox(width: 4),
            Expanded(
              child: Text(
                store.address,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.white.withOpacity(0.7),
                ),
              ),
            ),
          ],
        ),
        
        if (store.rating != null) ...[
          const SizedBox(height: 8),
          Row(
            children: [
              ...AppUtils.ratingToStars(store.rating!).map((isFilled) => 
                Icon(
                  isFilled ? Icons.star : Icons.star_border,
                  color: Colors.amber,
                  size: 16,
                ),
              ),
              const SizedBox(width: 4),
              Text(
                '(${store.rating!.toStringAsFixed(1)})',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.white.withOpacity(0.7),
                ),
              ),
            ],
          ),
        ],
        
        const SizedBox(height: 16),
        
        // Discounts
        const Text(
          '할인 혜택',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        
        const SizedBox(height: 8),
        
        ...store.discounts.map((discount) => Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.blue.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: Colors.blue.withOpacity(0.3),
              width: 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                discount.description,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.blue,
                ),
              ),
              if (discount.conditions.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(
                  discount.conditions,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white.withOpacity(0.6),
                  ),
                ),
              ],
            ],
          ),
        )),
      ],
    );
  }

  Widget _buildAiRecommender() {
    return StatefulBuilder(
      builder: (context, setState) {
        final TextEditingController inputController = TextEditingController();
        bool isLoading = false;
        List<Store> recommendations = [];
        
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.blue.withOpacity(0.2),
                    Colors.purple.withOpacity(0.1),
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: Colors.blue.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.blue.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.auto_awesome,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Text(
                          'AI 추천 시스템',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    '사용자의 선호도를 입력하면 맞춤형 할인 혜택을 추천해드립니다.',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 16),
            
            // 입력 필드
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.white.withOpacity(0.15),
                    Colors.white.withOpacity(0.05),
                  ],
                ),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.white.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: TextField(
                controller: inputController,
                style: const TextStyle(color: Colors.white, fontSize: 14),
                decoration: const InputDecoration(
                  hintText: '예: 저렴한 음식점, 조용한 카페, 영화관...',
                  hintStyle: TextStyle(color: Colors.white54, fontSize: 14),
                  filled: false,
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  prefixIcon: Icon(
                    Icons.search,
                    color: Colors.white54,
                    size: 20,
                  ),
                ),
              ),
            ),
            
            const SizedBox(height: 12),
            
            // 추천 버튼
            Container(
              width: double.infinity,
              height: 50,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: isLoading 
                      ? [Colors.grey.withOpacity(0.3), Colors.grey.withOpacity(0.2)]
                      : [Colors.blue.withOpacity(0.8), Colors.purple.withOpacity(0.6)],
                ),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: isLoading 
                        ? Colors.transparent
                        : Colors.blue.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ElevatedButton(
                onPressed: isLoading ? null : () async {
                  if (inputController.text.trim().isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('선호도를 입력해주세요.'),
                        backgroundColor: Colors.red,
                      ),
                    );
                    return;
                  }
                  
                  setState(() {
                    isLoading = true;
                  });
                  
                  // AI 추천 로직 (실제로는 WebMainPage에서 처리)
                  await Future.delayed(const Duration(seconds: 2));
                  
                  setState(() {
                    isLoading = false;
                    recommendations = [
                      // 임시 추천 데이터
                      Store(
                        id: 'temp1',
                        name: '스타벅스 강남점',
                        address: '서울 강남구 강남대로 123',
                        category: Category.food,
                        discounts: [
                          DiscountInfo(
                            id: 'discount1',
                            description: '학생 할인 20%',
                            conditions: '학생증 제시 시',
                          ),
                        ],
                        rating: 4.5,
                        imageUrl: 'images/Starbucks.png',
                      ),
                      Store(
                        id: 'temp2',
                        name: 'CGV 강남점',
                        address: '서울 강남구 강남대로 456',
                        category: Category.movie,
                        discounts: [
                          DiscountInfo(
                            id: 'discount2',
                            description: '학생 할인 30%',
                            conditions: '학생증 제시 시',
                          ),
                        ],
                        rating: 4.3,
                        imageUrl: 'images/CGVgang.jpg',
                      ),
                    ];
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  foregroundColor: Colors.white,
                  shadowColor: Colors.transparent,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: isLoading
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Text('AI 추천 받기'),
              ),
            ),
            
            if (recommendations.isNotEmpty) ...[
              const SizedBox(height: 16),
              const Text(
                '추천 결과',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              ...recommendations.map((store) => Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.white.withOpacity(0.2)),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        color: Colors.grey.shade700,
                      ),
                      child: store.imageUrl != null
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.asset(
                                store.imageUrl!,
                                fit: BoxFit.cover,
                              ),
                            )
                          : const Icon(
                              Icons.store,
                              color: Colors.white,
                            ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            store.name,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            store.address,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.white.withOpacity(0.7),
                            ),
                          ),
                          if (store.discounts.isNotEmpty) ...[
                            const SizedBox(height: 4),
                            Text(
                              store.discounts.first.description,
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.blue,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              )),
            ],
          ],
        );
      },
    );
  }

  Widget _buildImageReceiptAnalysis() {
    if (data == null) {
      return const Text(
        '분석 결과를 불러올 수 없습니다.',
        style: TextStyle(color: Colors.white),
      );
    }

    final analysisResult = data as ReceiptAnalysisResult;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          analysisResult.isReceipt ? '영수증 인식 성공' : '영수증 인식 실패',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: analysisResult.isReceipt ? Colors.green : Colors.red,
          ),
        ),
        
        const SizedBox(height: 12),
        
        if (analysisResult.mainBenefit != null) ...[
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: Colors.green.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  '추천 혜택',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.green,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  analysisResult.mainBenefit!,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),
        ],
        
        if (analysisResult.parsedData != null) ...[
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: Colors.blue.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  '분석된 정보',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.blue,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '가게명: ${analysisResult.parsedData!.storeName}\n'
                  '총액: ${analysisResult.parsedData!.totalAmount}원\n'
                  '날짜: ${analysisResult.parsedData!.date}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildReceiptHistory() {
    if (data == null || (data as List).isEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            '영수증 분석 내역',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          
          const SizedBox(height: 12),
          
          const Text(
            '분석한 영수증 내역이 없습니다.',
            style: TextStyle(
              fontSize: 14,
              color: Colors.white70,
            ),
          ),
        ],
      );
    }

    final history = data as List<ReceiptData>;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          '영수증 분석 내역 (${history.length}건)',
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        
        const SizedBox(height: 12),
        
        ...history.map((receipt) => Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: Colors.white.withOpacity(0.2),
              width: 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                receipt.storeName,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${receipt.totalAmount}원 • ${receipt.date}',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.white.withOpacity(0.7),
                ),
              ),
            ],
          ),
        )),
      ],
    );
  }

  Widget _buildFavorites() {
    if (data == null || (data as List).isEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            '찜한 가게',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          
          const SizedBox(height: 12),
          
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white.withOpacity(0.2)),
            ),
            child: const Column(
              children: [
                Icon(
                  Icons.favorite_border,
                  color: Colors.white54,
                  size: 48,
                ),
                SizedBox(height: 12),
                Text(
                  '찜한 가게가 없습니다.',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white70,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  '가게를 찜하면 여기에 표시됩니다.',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white54,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ],
      );
    }

    final favoriteStores = data as List<Store>;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          '찜한 가게 (${favoriteStores.length}개)',
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        
        const SizedBox(height: 12),
        
        ...favoriteStores.map((store) => Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: Colors.white.withOpacity(0.2),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: Colors.grey.shade700,
                ),
                child: store.imageUrl != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.asset(
                          store.imageUrl!,
                          fit: BoxFit.cover,
                        ),
                      )
                    : const Icon(
                        Icons.store,
                        color: Colors.white,
                        size: 20,
                      ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      store.name,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      store.address,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.white.withOpacity(0.7),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.favorite,
                color: Colors.red,
                size: 20,
              ),
            ],
          ),
        )),
      ],
    );
  }

  Widget _buildReceiptAnalysis() {
    return Builder(
      builder: (context) => Material(
        color: Colors.transparent,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              '영수증 분석',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              '영수증 이미지를 업로드하거나 텍스트를 입력해 분석할 수 있습니다.',
              style: TextStyle(
                fontSize: 14,
                color: Colors.white70,
              ),
            ),
            const SizedBox(height: 16),
            // 갤러리에서 선택
            Container(
              width: double.infinity,
              margin: const EdgeInsets.only(bottom: 12),
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.of(context).pop('gallery');
                },
                icon: const Icon(Icons.photo_library, color: Colors.white),
                label: const Text(
                  '갤러리에서 선택',
                  style: TextStyle(color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue.withOpacity(0.2),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
            // 카메라로 촬영
            Container(
              width: double.infinity,
              margin: const EdgeInsets.only(bottom: 12),
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.of(context).pop('camera');
                },
                icon: const Icon(Icons.camera_alt, color: Colors.white),
                label: const Text(
                  '카메라로 촬영',
                  style: TextStyle(color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green.withOpacity(0.2),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
            // 텍스트 입력
            Container(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.of(context).pop('text');
                },
                icon: const Icon(Icons.edit, color: Colors.white),
                label: const Text(
                  '텍스트로 입력',
                  style: TextStyle(color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange.withOpacity(0.2),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
} 