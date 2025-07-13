import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/receipt.dart';

class ReceiptHistoryService {
  static const String _storageKey = 'receipt_history';
  static final ReceiptHistoryService _instance = ReceiptHistoryService._internal();
  factory ReceiptHistoryService() => _instance;
  ReceiptHistoryService._internal();

  /// 영수증 내역을 저장합니다.
  Future<void> saveReceipt(ReceiptData receipt) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final history = await getReceiptHistory();
      
      // 중복 체크 (같은 날짜, 같은 가게, 같은 총액)
      final isDuplicate = history.any((existing) =>
        existing.storeName == receipt.storeName &&
        existing.date == receipt.date &&
        existing.totalAmount == receipt.totalAmount
      );
      
      if (!isDuplicate) {
        history.add(receipt);
        
        // 최신 순으로 정렬
        history.sort((a, b) => b.date.compareTo(a.date));
        
        // 최대 50개까지만 저장
        if (history.length > 50) {
          history.removeRange(50, history.length);
        }
        
        final jsonList = history.map((r) => r.toJson()).toList();
        await prefs.setString(_storageKey, jsonEncode(jsonList));
      }
    } catch (e) {
      throw Exception('영수증 내역 저장에 실패했습니다: $e');
    }
  }

  /// 영수증 내역을 가져옵니다.
  Future<List<ReceiptData>> getReceiptHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(_storageKey);
      
      if (jsonString == null || jsonString.isEmpty) {
        return [];
      }
      
      final jsonList = jsonDecode(jsonString) as List<dynamic>;
      return jsonList.map((json) => ReceiptData.fromJson(json)).toList();
    } catch (e) {
      throw Exception('영수증 내역을 가져오는데 실패했습니다: $e');
    }
  }

  /// 영수증 내역을 삭제합니다.
  Future<void> deleteReceipt(String receiptId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final history = await getReceiptHistory();
      
      history.removeWhere((receipt) => receipt.id == receiptId);
      
      final jsonList = history.map((r) => r.toJson()).toList();
      await prefs.setString(_storageKey, jsonEncode(jsonList));
    } catch (e) {
      throw Exception('영수증 내역 삭제에 실패했습니다: $e');
    }
  }

  /// 모든 영수증 내역을 삭제합니다.
  Future<void> clearReceiptHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_storageKey);
    } catch (e) {
      throw Exception('영수증 내역 초기화에 실패했습니다: $e');
    }
  }

  /// 영수증 통계를 가져옵니다.
  Future<Map<String, dynamic>> getReceiptStats() async {
    try {
      final history = await getReceiptHistory();
      
      if (history.isEmpty) {
        return {
          'totalReceipts': 0,
          'totalAmount': 0,
          'totalDiscount': 0,
          'averageAmount': 0,
          'mostFrequentStore': null,
          'mostFrequentCategory': null,
        };
      }
      
      // 총 영수증 수
      final totalReceipts = history.length;
      
      // 총 금액 (숫자만 추출)
      double totalAmount = 0;
      double totalDiscount = 0;
      
      for (final receipt in history) {
        final amount = _extractAmount(receipt.totalAmount);
        if (amount > 0) {
          totalAmount += amount;
        }
        
        // 할인 금액 추출 (간단한 추정)
        if (receipt.discountApplied.contains('10%')) {
          totalDiscount += amount * 0.1;
        } else if (receipt.discountApplied.contains('15%')) {
          totalDiscount += amount * 0.15;
        } else if (receipt.discountApplied.contains('20%')) {
          totalDiscount += amount * 0.2;
        }
      }
      
      // 평균 금액
      final averageAmount = totalAmount / totalReceipts;
      
      // 가장 자주 방문한 가게
      final storeCounts = <String, int>{};
      for (final receipt in history) {
        storeCounts[receipt.storeName] = (storeCounts[receipt.storeName] ?? 0) + 1;
      }
      
      String? mostFrequentStore;
      int maxCount = 0;
      for (final entry in storeCounts.entries) {
        if (entry.value > maxCount) {
          maxCount = entry.value;
          mostFrequentStore = entry.key;
        }
      }
      
      // 가장 자주 방문한 카테고리
      final categoryCounts = <String, int>{};
      for (final receipt in history) {
        final category = receipt.storeCategory?.displayName ?? '기타';
        categoryCounts[category] = (categoryCounts[category] ?? 0) + 1;
      }
      
      String? mostFrequentCategory;
      maxCount = 0;
      for (final entry in categoryCounts.entries) {
        if (entry.value > maxCount) {
          maxCount = entry.value;
          mostFrequentCategory = entry.key;
        }
      }
      
      return {
        'totalReceipts': totalReceipts,
        'totalAmount': totalAmount,
        'totalDiscount': totalDiscount,
        'averageAmount': averageAmount,
        'mostFrequentStore': mostFrequentStore,
        'mostFrequentCategory': mostFrequentCategory,
      };
    } catch (e) {
      throw Exception('영수증 통계를 가져오는데 실패했습니다: $e');
    }
  }

  /// 금액 문자열에서 숫자를 추출합니다.
  double _extractAmount(String amountString) {
    try {
      // "15,000원" -> 15000
      final cleanString = amountString.replaceAll(RegExp(r'[^\d]'), '');
      return double.tryParse(cleanString) ?? 0;
    } catch (e) {
      return 0;
    }
  }
} 