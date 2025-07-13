enum Category {
  culture('문화'),
  study('스터디'),
  shopping('쇼핑'),
  food('음식'),
  free('무료'),
  movie('영화'),
  other('기타');

  const Category(this.displayName);
  final String displayName;
}

class DiscountInfo {
  final String id;
  final String description;
  final String conditions;

  DiscountInfo({
    required this.id,
    required this.description,
    required this.conditions,
  });

  factory DiscountInfo.fromJson(Map<String, dynamic> json) {
    return DiscountInfo(
      id: json['id'] as String,
      description: json['description'] as String,
      conditions: json['conditions'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'description': description,
      'conditions': conditions,
    };
  }
}

class Store {
  final String id;
  final String name;
  final String address;
  final Category category;
  final List<DiscountInfo> discounts;
  final double? rating;
  final String? imageUrl;
  final String? contact;
  final String? operatingHours;
  final double? distance;
  final double? latitude;
  final double? longitude;
  String? recommendationReason; // AI 추천 이유

  Store({
    required this.id,
    required this.name,
    required this.address,
    required this.category,
    required this.discounts,
    this.rating,
    this.imageUrl,
    this.contact,
    this.operatingHours,
    this.distance,
    this.latitude,
    this.longitude,
    this.recommendationReason,
  });

  factory Store.fromJson(Map<String, dynamic> json) {
    return Store(
      id: json['id'] as String,
      name: json['name'] as String,
      address: json['address'] as String,
      category: Category.values.firstWhere(
        (e) => e.displayName == json['category'],
        orElse: () => Category.other,
      ),
      discounts: (json['discounts'] as List<dynamic>)
          .map((e) => DiscountInfo.fromJson(e as Map<String, dynamic>))
          .toList(),
      rating: json['rating'] as double?,
      imageUrl: json['imageUrl'] as String?,
      contact: json['contact'] as String?,
      operatingHours: json['operatingHours'] as String?,
      distance: json['distance'] as double?,
      latitude: json['latitude'] as double?,
      longitude: json['longitude'] as double?,
      recommendationReason: json['recommendationReason'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'address': address,
      'category': category.displayName,
      'discounts': discounts.map((e) => e.toJson()).toList(),
      'rating': rating,
      'imageUrl': imageUrl,
      'contact': contact,
      'operatingHours': operatingHours,
      'distance': distance,
      'latitude': latitude,
      'longitude': longitude,
      'recommendationReason': recommendationReason,
    };
  }

  // copyWith 메서드 추가
  Store copyWith({
    String? id,
    String? name,
    String? address,
    Category? category,
    List<DiscountInfo>? discounts,
    double? rating,
    String? imageUrl,
    String? contact,
    String? operatingHours,
    double? distance,
    double? latitude,
    double? longitude,
    String? recommendationReason,
  }) {
    return Store(
      id: id ?? this.id,
      name: name ?? this.name,
      address: address ?? this.address,
      category: category ?? this.category,
      discounts: discounts ?? this.discounts,
      rating: rating ?? this.rating,
      imageUrl: imageUrl ?? this.imageUrl,
      contact: contact ?? this.contact,
      operatingHours: operatingHours ?? this.operatingHours,
      distance: distance ?? this.distance,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      recommendationReason: recommendationReason ?? this.recommendationReason,
    );
  }
} 