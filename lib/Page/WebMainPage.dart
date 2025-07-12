import 'dart:math'; // sin 함수 사용을 위해 import
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'GeminiLiveService.dart';
import 'dart:async';

class WebMainPage extends StatefulWidget {
  const WebMainPage({super.key});

  @override
  State<WebMainPage> createState() => _WebMainPageState();
}

class _WebMainPageState extends State<WebMainPage>
    with SingleTickerProviderStateMixin {
  late final WebViewController _controller;
  late final GeminiLiveService _geminiLiveService;

  bool _isListening = false;

  late final AnimationController _animationController;

  @override
  void initState() {
    super.initState();

    _geminiLiveService = GeminiLiveService();
    _geminiLiveService.connect();

    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0x00000000))
      ..loadRequest(Uri.parse('https://benefit-on-v2.vercel.app/'));

    // 애니메이션 컨트롤러 설정 (5초 동안 1회전, 계속 반복)
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    )..repeat(); // initState에서 바로 반복 시작
  }

  @override
  void dispose() {
    _animationController.dispose();
    _geminiLiveService.dispose();
    super.dispose();
  }

  void _startListening() {
    if (_isListening) return;
    setState(() {
      _isListening = true;
    });
    _geminiLiveService.startRecording();
  }

  void _stopListening() {
    if (!_isListening) return;
    setState(() {
      _isListening = false;
    });
    _geminiLiveService.stopRecording();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            // 1. 웹뷰
            WebViewWidget(controller: _controller),

            // 2. ✨ 새로운 Glow Effect 애니메이션
            if (_isListening)
              IgnorePointer(
                child: CustomPaint(
                  // 화면 전체에 그림을 그리기 위한 설정
                  size: Size.infinite,
                  // 애니메이션 컨트롤러를 화가에게 전달
                  painter: GlowPainter(animation: _animationController),
                ),
              ),

            // 3. '종료' 버튼 (화면 전체 탭)
            if (_isListening)
              GestureDetector(
                onTap: _stopListening,
                child: Container(color: Colors.transparent),
              ),

            // 4. '시작' 버튼 (왼쪽 상단 롱프레스)
            if (!_isListening)
              Positioned(
                top: 20.0,
                left: 20.0,
                child: GestureDetector(
                  onLongPress: _startListening,
                  child: Container(
                    width: 60,
                    height: 60,
                    color: Colors.transparent,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// ✨ 화면에 글로우 효과를 그리는 역할을 하는 CustomPainter
class GlowPainter extends CustomPainter {
  final Animation<double> animation;

  GlowPainter({required this.animation}) : super(repaint: animation);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.blue.withOpacity(0.7)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.0
    // ✨ 이 부분이 '글로우' 효과의 핵심 (블러 처리)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6.0);

    final path = Path();
    const double waveHeight = 15.0; // 물결의 높이
    const double waveFrequency = 2.0; // 물결의 빈도

    // 애니메이션 값 (0.0 ~ 1.0)을 사용하여 시간이 지남에 따라 위상이 변하게 함
    final double phase = animation.value * 2 * pi;

    // 화면의 네 변을 따라 물결 모양의 경로를 그림
    // Top
    for (double x = 0; x <= size.width; x++) {
      final y = sin(x / size.width * 2 * pi * waveFrequency + phase) * waveHeight;
      path.lineTo(x, y + waveHeight);
    }
    // Right
    for (double y = 0; y <= size.height; y++) {
      final x = sin(y / size.height * 2 * pi * waveFrequency + phase) * waveHeight;
      path.lineTo(size.width - waveHeight + x, y);
    }
    // Bottom
    for (double x = size.width; x >= 0; x--) {
      final y = sin(x / size.width * 2 * pi * waveFrequency + phase) * waveHeight;
      path.lineTo(x, size.height - waveHeight + y);
    }
    // Left
    for (double y = size.height; y >= 0; y--) {
      final x = sin(y / size.height * 2 * pi * waveFrequency + phase) * waveHeight;
      path.lineTo(waveHeight + x, y);
    }

    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    // 항상 다시 그릴 필요는 없으며, animation 객체가 변경될 때만 다시 그림
    return true;
  }
}