import 'dart:math';
import 'package:geolocator/geolocator.dart';
import '../models/store.dart';

class LocationService {
  static final LocationService _instance = LocationService._internal();
  factory LocationService() => _instance;
  LocationService._internal();

  /// 현재 위치를 가져옵니다.
  Future<Position?> getCurrentLocation() async {
    try {
      // 위치 권한 확인
      LocationPermission permission = await Geolocator.checkPermission();
      
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw Exception('위치 권한이 거부되었습니다.');
        }
      }
      
      if (permission == LocationPermission.deniedForever) {
        throw Exception('위치 권한이 영구적으로 거부되었습니다. 설정에서 권한을 허용해주세요.');
      }
      
      // 위치 서비스 활성화 확인
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw Exception('위치 서비스가 비활성화되어 있습니다.');
      }
      
      // 현재 위치 가져오기
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 10),
      );
      
      return position;
      
    } catch (e) {
      print('위치 가져오기 오류: $e');
      return null;
    }
  }

  /// 두 지점 간의 거리를 계산합니다 (km).
  double calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    return Geolocator.distanceBetween(lat1, lon1, lat2, lon2) / 1000;
  }

  /// 가게 목록에 거리 정보를 추가합니다.
  List<Store> addDistanceToStores(List<Store> stores, Position userLocation) {
    return stores.map((store) {
      // 가게의 위도/경도 정보가 있으면 거리 계산
      if (store.latitude != null && store.longitude != null) {
        final distance = calculateDistance(
          userLocation.latitude,
          userLocation.longitude,
          store.latitude!,
          store.longitude!,
        );
        return store.copyWith(distance: distance);
      }
      
      // 위도/경도 정보가 없으면 주소 기반으로 대략적인 거리 추정
      final estimatedDistance = _estimateDistanceFromAddress(store.address, userLocation);
      return store.copyWith(distance: estimatedDistance);
    }).toList();
  }

  /// 주소 기반으로 대략적인 거리를 추정합니다.
  double _estimateDistanceFromAddress(String address, Position userLocation) {
    // 서울 주요 지역의 대략적인 좌표
    final Map<String, Map<String, double>> seoulAreas = {
      '강남': {'lat': 37.4979, 'lon': 127.0276},
      '용산': {'lat': 37.5298, 'lon': 126.9648},
      '송파': {'lat': 37.5125, 'lon': 127.1025},
      '광진': {'lat': 37.5407, 'lon': 127.0794},
      '중구': {'lat': 37.5641, 'lon': 126.9979},
      '서초': {'lat': 37.4837, 'lon': 127.0324},
    };
    
    // 주소에서 지역명 추출
    for (final area in seoulAreas.keys) {
      if (address.contains(area)) {
        final areaCoords = seoulAreas[area]!;
        return calculateDistance(
          userLocation.latitude,
          userLocation.longitude,
          areaCoords['lat']!,
          areaCoords['lon']!,
        );
      }
    }
    
    // 기본값: 서울시청 기준
    return calculateDistance(
      userLocation.latitude,
      userLocation.longitude,
      37.5665,
      126.9780,
    );
  }

  /// 위치 권한 상태를 확인합니다.
  Future<bool> hasLocationPermission() async {
    LocationPermission permission = await Geolocator.checkPermission();
    return permission == LocationPermission.whileInUse || 
           permission == LocationPermission.always;
  }

  /// 위치 서비스 상태를 확인합니다.
  Future<bool> isLocationServiceEnabled() async {
    return await Geolocator.isLocationServiceEnabled();
  }
} 