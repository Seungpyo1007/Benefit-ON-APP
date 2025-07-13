import 'dart:math';
import '../models/store.dart';
import '../models/receipt.dart';
import '../constants/app_constants.dart';

class AiRecommendationService {
  static final AiRecommendationService _instance = AiRecommendationService._internal();
  factory AiRecommendationService() => _instance;
  AiRecommendationService._internal();

  /// 사용자 선호도에 따른 AI 추천 가게 목록을 생성합니다.
  Future<List<Store>> getRecommendations(String userPreferences) async {
    try {
      // 실제로는 AI 서비스를 호출하여 추천
      // 여기서는 키워드 기반 필터링으로 구현
      
      final allStores = AppConstants.stores;
      final recommendations = <Store>[];
      final random = Random();
      
      // 사용자 선호도 키워드 분석
      final preferences = userPreferences.toLowerCase();
      
      // 카테고리별 필터링
      Category? preferredCategory;
      if (preferences.contains('음식') || preferences.contains('맛집') || preferences.contains('식당')) {
        preferredCategory = Category.food;
      } else if (preferences.contains('쇼핑') || preferences.contains('옷') || preferences.contains('화장품')) {
        preferredCategory = Category.shopping;
      } else if (preferences.contains('영화') || preferences.contains('극장')) {
        preferredCategory = Category.movie;
      } else if (preferences.contains('문화') || preferences.contains('박물관') || preferences.contains('전시')) {
        preferredCategory = Category.culture;
      } else if (preferences.contains('공부') || preferences.contains('도서관') || preferences.contains('카페')) {
        preferredCategory = Category.study;
      }
      
      // 필터링된 가게 목록
      List<Store> filteredStores = allStores;
      if (preferredCategory != null) {
        filteredStores = allStores.where((store) => store.category == preferredCategory).toList();
      }
      
      // 위치 기반 필터링 (강남, 용산 등)
      if (preferences.contains('강남')) {
        filteredStores = filteredStores.where((store) => 
          store.address.contains('강남') || store.address.contains('강남구')).toList();
      } else if (preferences.contains('용산')) {
        filteredStores = filteredStores.where((store) => 
          store.address.contains('용산') || store.address.contains('용산구')).toList();
      }
      
      // 가격대 필터링
      if (preferences.contains('저렴') || preferences.contains('싼')) {
        // 할인이 많은 가게 우선
        filteredStores.sort((a, b) => (b.discounts.length).compareTo(a.discounts.length));
      } else if (preferences.contains('고급') || preferences.contains('프리미엄')) {
        // 평점이 높은 가게 우선
        filteredStores.sort((a, b) => (b.rating ?? 0).compareTo(a.rating ?? 0));
      }
      
      // 추천 목록 생성 (최대 6개)
      final maxRecommendations = 6;
      if (filteredStores.isNotEmpty) {
        // 필터링된 결과가 있으면 그 중에서 선택
        final shuffled = List<Store>.from(filteredStores);
        shuffled.shuffle(random);
        recommendations.addAll(shuffled.take(maxRecommendations));
      } else {
        // 필터링된 결과가 없으면 전체에서 랜덤 선택
        final shuffled = List<Store>.from(allStores);
        shuffled.shuffle(random);
        recommendations.addAll(shuffled.take(maxRecommendations));
      }
      
      // 추천 이유 추가
      for (final store in recommendations) {
        store.recommendationReason = _generateRecommendationReason(store, preferences);
      }
      
      return recommendations;
      
    } catch (e) {
      print('AI 추천 생성 중 오류: $e');
      // 오류 시 기본 추천 반환
      return _getDefaultRecommendations();
    }
  }

  /// 추천 이유를 생성합니다.
  String _generateRecommendationReason(Store store, String preferences) {
    final reasons = <String>[];
    
    // 카테고리 기반 이유
    switch (store.category) {
      case Category.food:
        reasons.add('맛있는 음식');
        if (preferences.contains('카페')) reasons.add('좋은 카페');
        break;
      case Category.shopping:
        reasons.add('쇼핑하기 좋은 곳');
        if (preferences.contains('화장품')) reasons.add('화장품 쇼핑');
        break;
      case Category.movie:
        reasons.add('영화 보기 좋은 곳');
        break;
      case Category.culture:
        reasons.add('문화생활하기 좋은 곳');
        break;
      case Category.study:
        reasons.add('공부하기 좋은 환경');
        break;
      case Category.free:
        reasons.add('무료 혜택');
        break;
      case Category.other:
        reasons.add('다양한 혜택');
        break;
    }
    
    // 할인 혜택 기반 이유
    if (store.discounts.isNotEmpty) {
      reasons.add('학생 할인 혜택');
    }
    
    // 평점 기반 이유
    if (store.rating != null && store.rating! >= 4.0) {
      reasons.add('높은 평점');
    }
    
    return reasons.isNotEmpty ? reasons.join(', ') : '추천 가게';
  }

  /// 기본 추천 목록을 반환합니다.
  List<Store> _getDefaultRecommendations() {
    final allStores = AppConstants.stores;
    final random = Random();
    final shuffled = List<Store>.from(allStores);
    shuffled.shuffle(random);
    
    final recommendations = shuffled.take(6).toList();
    for (final store in recommendations) {
      store.recommendationReason = '인기 가게';
    }
    
    return recommendations;
  }

  /// 영수증 데이터를 기반으로 추천을 생성합니다.
  Future<List<Store>> getRecommendationsFromReceipt(ReceiptData receiptData) async {
    try {
      final allStores = AppConstants.stores;
      final recommendations = <Store>[];
      final random = Random();
      
      // 영수증의 가게명과 유사한 가게 찾기
      final similarStores = allStores.where((store) {
        final storeName = store.name.toLowerCase();
        final receiptStoreName = receiptData.storeName.toLowerCase();
        
        // 이름 유사도 체크
        return storeName.contains(receiptStoreName) || 
               receiptStoreName.contains(storeName) ||
               _calculateSimilarity(storeName, receiptStoreName) > 0.3;
      }).toList();
      
      // 유사한 가게가 있으면 그 중에서 선택
      if (similarStores.isNotEmpty) {
        final shuffled = List<Store>.from(similarStores);
        shuffled.shuffle(random);
        recommendations.addAll(shuffled.take(3));
      }
      
      // 나머지는 랜덤으로 선택
      final remainingStores = allStores.where((store) => 
        !recommendations.contains(store)).toList();
      
      if (remainingStores.isNotEmpty) {
        final shuffled = List<Store>.from(remainingStores);
        shuffled.shuffle(random);
        recommendations.addAll(shuffled.take(6 - recommendations.length));
      }
      
      // 추천 이유 추가
      for (final store in recommendations) {
        if (similarStores.contains(store)) {
          store.recommendationReason = '${receiptData.storeName}와 유사한 가게';
        } else {
          store.recommendationReason = '추천 가게';
        }
      }
      
      return recommendations;
      
    } catch (e) {
      print('영수증 기반 추천 생성 중 오류: $e');
      return _getDefaultRecommendations();
    }
  }

  /// 문자열 유사도를 계산합니다.
  double _calculateSimilarity(String s1, String s2) {
    if (s1.isEmpty || s2.isEmpty) return 0.0;
    
    final set1 = s1.split('').toSet();
    final set2 = s2.split('').toSet();
    
    final intersection = set1.intersection(set2).length;
    final union = set1.union(set2).length;
    
    return intersection / union;
  }
} 