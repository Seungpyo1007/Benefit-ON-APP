import 'package:flutter/material.dart';
import 'dart:ui';
import '../models/store.dart';
import '../utils/category_utils.dart';
import '../utils/app_utils.dart';

class StoreCardWidget extends StatelessWidget {
  final Store store;
  final VoidCallback onSelectStore;
  final VoidCallback onToggleFavorite;
  final bool isFavorite;
  final bool showDistance;

  const StoreCardWidget({
    super.key,
    required this.store,
    required this.onSelectStore,
    required this.onToggleFavorite,
    required this.isFavorite,
    this.showDistance = false,
  });

  @override
  Widget build(BuildContext context) {
    final categoryInfo = CategoryUtils.getCategoryInfo(store.category);
    
    return InkWell(
      onTap: onSelectStore,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 300, minHeight: 320, maxHeight: 400),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Colors.white.withOpacity(0.18),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 30,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 이미지 섹션
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                  child: Container(
                    width: double.infinity,
                    height: 140,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade800,
                    ),
                    child: store.imageUrl != null
                        ? Image.asset(
                            store.imageUrl!,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                color: Colors.grey.shade700,
                                child: Icon(
                                  Icons.store,
                                  size: 48,
                                  color: Colors.grey.shade400,
                                ),
                              );
                            },
                          )
                        : Container(
                            color: Colors.grey.shade700,
                            child: Icon(
                              Icons.store,
                              size: 48,
                              color: Colors.grey.shade400,
                            ),
                          ),
                  ),
                ),
                // 찜 버튼
                Positioned(
                  top: 12,
                  right: 12,
                  child: GestureDetector(
                    onTap: onToggleFavorite,
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: isFavorite 
                            ? Colors.red.withOpacity(0.8) 
                            : Colors.black.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: Icon(
                        Icons.favorite,
                        color: isFavorite ? Colors.white : Colors.white.withOpacity(0.7),
                        size: 16,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            // 내용 섹션
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: SingleChildScrollView(
                  physics: const NeverScrollableScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // 카테고리 태그
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              categoryInfo.icon,
                              style: const TextStyle(fontSize: 10),
                            ),
                            const SizedBox(width: 3),
                            Flexible(
                              child: Text(
                                store.category.displayName,
                                style: const TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 6),
                      // 가게명
                      Text(
                        store.name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 3),
                      // 평점
                      if (store.rating != null) ...[
                        Row(
                          children: [
                            ...AppUtils.ratingToStars(store.rating!).map((isFilled) => 
                              Icon(
                                isFilled ? Icons.star : Icons.star_border,
                                color: Colors.amber,
                                size: 14,
                              ),
                            ),
                            const SizedBox(width: 3),
                            Text(
                              '(${store.rating!.toStringAsFixed(1)})',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.white.withOpacity(0.8),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 3),
                      ],
                      // 주소
                      Row(
                        children: [
                          Icon(
                            Icons.location_on,
                            size: 12,
                            color: Colors.white.withOpacity(0.5),
                          ),
                          const SizedBox(width: 3),
                          Expanded(
                            child: Text(
                              store.address,
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.white.withOpacity(0.7),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      // 거리 정보
                      if (showDistance && store.distance != null) ...[
                        const SizedBox(height: 3),
                        Row(
                          children: [
                            Icon(
                              Icons.directions_walk,
                              size: 12,
                              color: Colors.blue.shade300,
                            ),
                            const SizedBox(width: 3),
                            Text(
                              '${store.distance!.toStringAsFixed(1)}km',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.blue.shade300,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ],
                      const SizedBox(height: 8),
                      // 할인 정보
                      if (store.discounts.isNotEmpty) ...[
                        Container(
                          padding: const EdgeInsets.all(8),
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
                                store.discounts.first.description,
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.blue,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              if (store.discounts.first.conditions.isNotEmpty) ...[
                                const SizedBox(height: 2),
                                Text(
                                  store.discounts.first.conditions,
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: Colors.white.withOpacity(0.6),
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ],
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