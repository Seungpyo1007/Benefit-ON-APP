import 'package:flutter/material.dart';
import 'dart:ui';
import '../constants/app_constants.dart';

class HeaderWidget extends StatelessWidget {
  final String? userName;
  final VoidCallback onLogout;
  final VoidCallback onShowFavorites;
  final VoidCallback onShowReceiptHistory;
  final int favoriteCount;
  final bool isScrolled;
  final VoidCallback onLogoClick;

  const HeaderWidget({
    super.key,
    this.userName,
    required this.onLogout,
    required this.onShowFavorites,
    required this.onShowReceiptHistory,
    required this.favoriteCount,
    required this.isScrolled,
    required this.onLogoClick,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withOpacity(0.18),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          // Logo
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: Colors.blue.shade400,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.local_offer,
                  color: Colors.white,
                  size: 18,
                ),
              ),
              const SizedBox(width: 8),
              const Text(
                'Benefit-ON',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          
          const Spacer(),
          
          // User Info
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (userName != null) ...[
                Text(
                  '안녕하세요, $userName님!',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(width: 8),
              ],
              GestureDetector(
                onTap: onLogout,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: Colors.red.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.logout,
                        color: Colors.red,
                        size: 14,
                      ),
                      SizedBox(width: 4),
                      Text(
                        '로그아웃',
                        style: TextStyle(
                          color: Colors.red,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
} 