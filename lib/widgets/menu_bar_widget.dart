import 'package:flutter/material.dart';
import 'dart:ui';

class MenuBarWidget extends StatefulWidget {
  final String activeView;
  final Function(String) onNavigate;
  final int favoriteCount;

  const MenuBarWidget({
    super.key,
    required this.activeView,
    required this.onNavigate,
    required this.favoriteCount,
  });

  @override
  State<MenuBarWidget> createState() => _MenuBarWidgetState();
}

class _MenuBarWidgetState extends State<MenuBarWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _indicatorAnimation;
  
  final List<GlobalKey> _tabKeys = [];
  final List<Map<String, dynamic>> _menuItems = [
    {'id': 'explore', 'label': '둘러보기', 'icon': Icons.explore},
    {'id': 'ai', 'label': 'AI 추천', 'icon': Icons.auto_awesome},
    {'id': 'receiptAi', 'label': '영수증 AI', 'icon': Icons.receipt},
    {'id': 'favorites', 'label': '찜 목록', 'icon': Icons.favorite},
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _indicatorAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    
    for (int i = 0; i < _menuItems.length; i++) {
      _tabKeys.add(GlobalKey());
    }
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _updateIndicator();
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _updateIndicator() {
    final activeIndex = _menuItems.indexWhere((item) => item['id'] == widget.activeView);
    if (activeIndex != -1 && _tabKeys[activeIndex].currentContext != null) {
      final RenderBox renderBox = _tabKeys[activeIndex].currentContext!.findRenderObject() as RenderBox;
      final position = renderBox.localToGlobal(Offset.zero);
      final size = renderBox.size;
      
      setState(() {
        _animationController.forward();
      });
    }
  }

  @override
  void didUpdateWidget(MenuBarWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.activeView != widget.activeView) {
      _updateIndicator();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      child: Center(
        child: Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(28),
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
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: _menuItems.asMap().entries.map((entry) {
              final index = entry.key;
              final item = entry.value;
              final isActive = widget.activeView == item['id'];
              
              return GestureDetector(
                key: _tabKeys[index],
                onTap: () => widget.onNavigate(item['id']),
                child: Container(
                  width: 80,
                  height: 48,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(24),
                    color: isActive 
                        ? Colors.white.withOpacity(0.25) 
                        : Colors.transparent,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Stack(
                        children: [
                          Icon(
                            item['icon'],
                            color: isActive 
                                ? Colors.blue.shade400 
                                : Colors.white.withOpacity(0.7),
                            size: 18,
                          ),
                          if (item['id'] == 'favorites' && widget.favoriteCount > 0)
                            Positioned(
                              top: -2,
                              right: -2,
                              child: Container(
                                width: 8,
                                height: 8,
                                decoration: BoxDecoration(
                                  color: Colors.blue.shade400,
                                  borderRadius: BorderRadius.circular(4),
                                  border: Border.all(
                                    color: Colors.black,
                                    width: 1,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        item['label'],
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: isActive 
                              ? Colors.blue.shade400 
                              : Colors.white.withOpacity(0.7),
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
} 