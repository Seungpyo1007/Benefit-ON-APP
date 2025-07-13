import 'package:flutter/material.dart';
import 'dart:math';

class AnimatedBackground extends StatefulWidget {
  final Widget child;

  const AnimatedBackground({
    super.key,
    required this.child,
  });

  @override
  State<AnimatedBackground> createState() => _AnimatedBackgroundState();
}

class _AnimatedBackgroundState extends State<AnimatedBackground>
    with TickerProviderStateMixin {
  late AnimationController _gradientController;
  late AnimationController _shape1Controller;
  late AnimationController _shape2Controller;
  late Animation<double> _gradientAnimation;
  late Animation<double> _shape1Animation;
  late Animation<double> _shape2Animation;

  @override
  void initState() {
    super.initState();
    
    // 그라데이션 애니메이션
    _gradientController = AnimationController(
      duration: const Duration(seconds: 18),
      vsync: this,
    )..repeat();
    
    _gradientAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _gradientController,
      curve: Curves.easeInOut,
    ));

    // 셰이프1 애니메이션
    _shape1Controller = AnimationController(
      duration: const Duration(seconds: 15),
      vsync: this,
    )..repeat(reverse: true);
    
    _shape1Animation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _shape1Controller,
      curve: Curves.easeInOut,
    ));

    // 셰이프2 애니메이션 (지연 시작)
    _shape2Controller = AnimationController(
      duration: const Duration(seconds: 20),
      vsync: this,
    )..repeat(reverse: true);
    
    _shape2Animation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _shape2Controller,
      curve: Curves.easeInOut,
    ));

    // 셰이프2 지연 시작
    Future.delayed(const Duration(seconds: 5), () {
      if (mounted) {
        _shape2Controller.forward();
      }
    });
  }

  @override
  void dispose() {
    _gradientController.dispose();
    _shape1Controller.dispose();
    _shape2Controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // 애니메이션 그라데이션 배경
        AnimatedBuilder(
          animation: _gradientAnimation,
          builder: (context, child) {
            return Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: const [
                    Color(0xFFEE7752), // 오렌지
                    Color(0xFFE73C7E), // 핑크
                    Color(0xFF23A6D5), // 블루
                    Color(0xFF23D5AB), // 그린
                  ],
                  stops: [
                    _gradientAnimation.value * 0.25,
                    _gradientAnimation.value * 0.5,
                    _gradientAnimation.value * 0.75,
                    _gradientAnimation.value,
                  ],
                ),
              ),
            );
          },
        ),
        
        // 플로팅 셰이프들
        Positioned.fill(
          child: Stack(
            children: [
              // 셰이프1 (블루)
              AnimatedBuilder(
                animation: _shape1Animation,
                builder: (context, child) {
                  return Positioned(
                    top: -100 + (_shape1Animation.value * 50),
                    left: -50 + (_shape1Animation.value * 30),
                    child: Transform.rotate(
                      angle: _shape1Animation.value * 0.35,
                      child: Container(
                        width: 300,
                        height: 300,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: RadialGradient(
                            colors: [
                              const Color(0xFF23A6D5).withOpacity(0.4),
                              const Color(0xFF23A6D5).withOpacity(0.0),
                            ],
                            stops: const [0.0, 0.7],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
              
              // 셰이프2 (핑크)
              AnimatedBuilder(
                animation: _shape2Animation,
                builder: (context, child) {
                  return Positioned(
                    bottom: -150 + (_shape2Animation.value * 50),
                    right: -100 + (_shape2Animation.value * 30),
                    child: Transform.rotate(
                      angle: _shape2Animation.value * 0.35,
                      child: Container(
                        width: 350,
                        height: 350,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: RadialGradient(
                            colors: [
                              const Color(0xFFE73C7E).withOpacity(0.3),
                              const Color(0xFFE73C7E).withOpacity(0.0),
                            ],
                            stops: const [0.0, 0.7],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
        
        // 메인 콘텐츠
        widget.child,
      ],
    );
  }
} 