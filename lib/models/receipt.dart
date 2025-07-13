import 'store.dart';

class ReceiptData {
  final String id;
  final String storeName;
  final List<String> items;
  final String discountApplied;
  final String totalAmount;
  final String date;
  final Category? storeCategory;

  ReceiptData({
    required this.id,
    required this.storeName,
    required this.items,
    required this.discountApplied,
    required this.totalAmount,
    required this.date,
    this.storeCategory,
  });

  factory ReceiptData.fromJson(Map<String, dynamic> json) {
    return ReceiptData(
      id: json['id'] as String,
      storeName: json['storeName'] as String,
      items: (json['items'] as List<dynamic>).cast<String>(),
      discountApplied: json['discountApplied'] as String,
      totalAmount: json['totalAmount'] as String,
      date: json['date'] as String,
      storeCategory: json['storeCategory'] != null
          ? Category.values.firstWhere(
              (e) => e.displayName == json['storeCategory'],
              orElse: () => Category.other,
            )
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'storeName': storeName,
      'items': items,
      'discountApplied': discountApplied,
      'totalAmount': totalAmount,
      'date': date,
      'storeCategory': storeCategory?.displayName,
    };
  }
}

class ReceiptAnalysisResult {
  final bool isReceipt;
  final String? mainBenefit;
  final List<Store> recommendations;
  final ReceiptData? parsedData;

  ReceiptAnalysisResult({
    required this.isReceipt,
    this.mainBenefit,
    required this.recommendations,
    this.parsedData,
  });

  factory ReceiptAnalysisResult.fromJson(Map<String, dynamic> json) {
    return ReceiptAnalysisResult(
      isReceipt: json['isReceipt'] as bool,
      mainBenefit: json['mainBenefit'] as String?,
      recommendations: (json['recommendations'] as List<dynamic>)
          .map((e) => Store.fromJson(e as Map<String, dynamic>))
          .toList(),
      parsedData: json['parsedData'] != null
          ? ReceiptData.fromJson(json['parsedData'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'isReceipt': isReceipt,
      'mainBenefit': mainBenefit,
      'recommendations': recommendations.map((e) => e.toJson()).toList(),
      'parsedData': parsedData?.toJson(),
    };
  }
} 