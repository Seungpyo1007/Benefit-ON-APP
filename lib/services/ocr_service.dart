import 'dart:io';
import 'dart:typed_data';
import 'package:google_ml_kit/google_ml_kit.dart';
import '../models/store.dart';
import '../models/receipt.dart';

class OcrService {
  static final OcrService _instance = OcrService._internal();
  factory OcrService() => _instance;
  OcrService._internal();

  final textRecognizer = GoogleMlKit.vision.textRecognizer();

  /// 이미지에서 텍스트를 추출합니다.
  Future<String> extractTextFromImage(File imageFile) async {
    try {
      final inputImage = InputImage.fromFile(imageFile);
      final RecognizedText recognizedText = await textRecognizer.processImage(inputImage);
      
      String extractedText = '';
      for (TextBlock block in recognizedText.blocks) {
        for (TextLine line in block.lines) {
          extractedText += '${line.text}\n';
        }
      }
      
      return extractedText.trim();
    } catch (e) {
      throw Exception('텍스트 추출 중 오류 발생: $e');
    }
  }

  /// 영수증 텍스트를 분석하여 구조화된 데이터로 변환합니다.
  ReceiptData analyzeReceiptText(String text) {
    final lines = text.split('\n');
    String storeName = '';
    String totalAmount = '';
    String date = '';
    List<String> items = [];
    
    // 가게명 추출 (보통 첫 번째 줄이나 "상호" 키워드 주변)
    for (int i = 0; i < lines.length && i < 5; i++) {
      final line = lines[i].trim();
      if (line.isNotEmpty && !line.contains(RegExp(r'[0-9]')) && line.length > 2) {
        storeName = line;
        break;
      }
    }
    
    // 날짜 추출 (YYYY-MM-DD 또는 YYYY/MM/DD 패턴)
    final datePattern = RegExp(r'(\d{4})[-/](\d{1,2})[-/](\d{1,2})');
    for (final line in lines) {
      final match = datePattern.firstMatch(line);
      if (match != null) {
        date = '${match.group(1)}-${match.group(2)!.padLeft(2, '0')}-${match.group(3)!.padLeft(2, '0')}';
        break;
      }
    }
    
    // 총액 추출 (숫자 + 원 패턴)
    final amountPattern = RegExp(r'(\d{1,3}(?:,\d{3})*)원');
    for (final line in lines) {
      final match = amountPattern.firstMatch(line);
      if (match != null) {
        totalAmount = match.group(0)!;
        break;
      }
    }
    
    // 상품명 추출 (일반적인 상품명 패턴)
    for (final line in lines) {
      final cleanLine = line.trim();
      if (cleanLine.isNotEmpty && 
          !cleanLine.contains(RegExp(r'[0-9]')) && 
          cleanLine.length > 1 && 
          cleanLine.length < 20 &&
          !cleanLine.contains('원') &&
          !cleanLine.contains('총') &&
          !cleanLine.contains('합계')) {
        items.add(cleanLine);
      }
    }
    
    // 중복 제거 및 필터링
    items = items.toSet().toList();
    if (items.length > 5) {
      items = items.take(5).toList();
    }
    
    return ReceiptData(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      storeName: storeName.isNotEmpty ? storeName : '알 수 없는 가게',
      totalAmount: totalAmount.isNotEmpty ? totalAmount : '0원',
      date: date.isNotEmpty ? date : DateTime.now().toString().split(' ')[0],
      items: items.isNotEmpty ? items : ['상품명을 인식할 수 없습니다'],
      discountApplied: '학생 할인 10%',
    );
  }

  /// 영수증인지 판단합니다.
  bool isReceipt(String text) {
    final receiptKeywords = [
      '영수증', 'receipt', '매출', '판매', '총액', '합계', '원', '개', '개수',
      '상호', '사업자', '주소', '전화', '날짜', '시간', '카드', '현금'
    ];
    
    final lowerText = text.toLowerCase();
    int keywordCount = 0;
    
    for (final keyword in receiptKeywords) {
      if (lowerText.contains(keyword.toLowerCase())) {
        keywordCount++;
      }
    }
    
    // 숫자와 원 기호가 있는지 확인
    final hasAmount = RegExp(r'\d+원').hasMatch(text);
    final hasNumbers = RegExp(r'\d+').hasMatch(text);
    
    return keywordCount >= 3 && hasAmount && hasNumbers;
  }

  /// 영수증 분석 결과를 생성합니다.
  Future<ReceiptAnalysisResult> analyzeReceipt(File imageFile) async {
    try {
      // 1. 텍스트 추출
      final extractedText = await extractTextFromImage(imageFile);
      
      // 2. 영수증인지 판단
      final isReceiptImage = isReceipt(extractedText);
      
      if (!isReceiptImage) {
        return ReceiptAnalysisResult(
          isReceipt: false,
          mainBenefit: "AI가 이미지를 영수증으로 인식하지 못했습니다. 더 선명한 영수증 사진으로 다시 시도해주세요.",
          recommendations: [],
          parsedData: null,
        );
      }
      
      // 3. 영수증 데이터 파싱
      final parsedData = analyzeReceiptText(extractedText);
      
      // 4. 할인 혜택 분석 (실제로는 AI 서비스를 사용)
      String mainBenefit = "이 영수증에서는 학생 할인을 찾지 못했습니다. 다음 방문 시 학생증을 제시해보세요!";
      
      // 간단한 키워드 기반 혜택 분석
      if (extractedText.toLowerCase().contains('학생') || 
          extractedText.toLowerCase().contains('할인') ||
          extractedText.toLowerCase().contains('discount')) {
        mainBenefit = "학생 할인이 적용되었습니다! 추가 혜택을 확인해보세요.";
      }
      
      // 5. 추천 가게 생성 (실제로는 AI 추천 서비스 사용)
      final recommendations = _generateRecommendations(parsedData);
      
      return ReceiptAnalysisResult(
        isReceipt: true,
        mainBenefit: mainBenefit,
        recommendations: recommendations,
        parsedData: parsedData,
      );
      
    } catch (e) {
      throw Exception('영수증 분석 중 오류 발생: $e');
    }
  }

  /// 추천 가게 목록을 생성합니다.
  List<Store> _generateRecommendations(ReceiptData parsedData) {
    // 실제로는 AI 서비스를 사용하여 추천
    // 여기서는 임시로 더미 데이터 반환
    return [
      Store(
        id: 'rec_1',
        name: '스타벅스 강남점',
        address: '서울 강남구 강남대로 123',
        category: Category.food,
        discounts: [
          DiscountInfo(
            id: 'disc_1',
            description: '학생 할인 10%',
            conditions: '학생증 제시 시',
          ),
        ],
        rating: 4.5,
        imageUrl: 'assets/images/Starbucks.png',
      ),
      Store(
        id: 'rec_2',
        name: '올리브영 강남점',
        address: '서울 강남구 강남대로 456',
        category: Category.shopping,
        discounts: [
          DiscountInfo(
            id: 'disc_2',
            description: '학생 할인 15%',
            conditions: '학생증 제시 시',
          ),
        ],
        rating: 4.2,
        imageUrl: 'assets/images/Teenculture.jpg',
      ),
    ];
  }

  void dispose() {
    textRecognizer.close();
  }
} 