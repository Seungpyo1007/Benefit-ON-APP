import 'dart:math';
import 'dart:convert';
import 'dart:typed_data';
import 'dart:io';

class AppUtils {
  /// UUID를 생성합니다.
  static String generateUUID() {
    final random = Random();
    const chars = 'abcdefghijklmnopqrstuvwxyz0123456789';
    return String.fromCharCodes(
      Iterable.generate(8, (_) => chars.codeUnitAt(random.nextInt(chars.length))),
    );
  }

  /// 두 지점 간의 거리를 계산합니다 (Haversine 공식).
  static double calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    const double earthRadius = 6371; // 지구 반지름 (km)
    
    final double dLat = _degreesToRadians(lat2 - lat1);
    final double dLon = _degreesToRadians(lon2 - lon1);
    
    final double a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_degreesToRadians(lat1)) * cos(_degreesToRadians(lat2)) *
        sin(dLon / 2) * sin(dLon / 2);
    
    final double c = 2 * atan2(sqrt(a), sqrt(1 - a));
    
    return earthRadius * c;
  }

  /// 도를 라디안으로 변환합니다.
  static double _degreesToRadians(double degrees) {
    return degrees * (pi / 180);
  }

  /// 문자열을 안전하게 파싱합니다.
  static double? parseDouble(String? value) {
    if (value == null || value.isEmpty) return null;
    return double.tryParse(value.replaceAll(',', ''));
  }

  /// 날짜 문자열을 포맷팅합니다.
  static String formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  /// 시간을 포맷팅합니다.
  static String formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  // 문자열을 안전하게 자르는 함수
  static String truncateString(String text, int maxLength) {
    if (text.length <= maxLength) return text;
    return '${text.substring(0, maxLength)}...';
  }

  // 평점을 별점으로 변환하는 함수
  static List<bool> ratingToStars(double rating) {
    List<bool> stars = [];
    int fullStars = rating.floor();
    bool hasHalfStar = (rating - fullStars) >= 0.5;
    
    for (int i = 0; i < 5; i++) {
      if (i < fullStars) {
        stars.add(true); // 채워진 별
      } else if (i == fullStars && hasHalfStar) {
        stars.add(true); // 반별 (임시로 채워진 별로 처리)
      } else {
        stars.add(false); // 빈 별
      }
    }
    
    return stars;
  }
} 