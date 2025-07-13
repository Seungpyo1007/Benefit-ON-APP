import 'package:flutter/material.dart';
import '../models/notification.dart';

class NotificationToast extends StatelessWidget {
  final NotificationMessage? notification;
  final VoidCallback? onDismiss;

  const NotificationToast({
    Key? key,
    this.notification,
    this.onDismiss,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (notification == null) return const SizedBox.shrink();

    return Positioned(
      top: 100,
      left: 16,
      right: 16,
      child: Material(
        color: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: _getBackgroundColor(notification!.type),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Icon(
                _getIcon(notification!.type),
                color: Colors.white,
                size: 24,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  notification!.message,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              if (onDismiss != null)
                GestureDetector(
                  onTap: onDismiss,
                  child: const Icon(
                    Icons.close,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getBackgroundColor(NotificationType type) {
    switch (type) {
      case NotificationType.success:
        return Colors.green.withOpacity(0.9);
      case NotificationType.error:
        return Colors.red.withOpacity(0.9);
      case NotificationType.info:
        return Colors.blue.withOpacity(0.9);
      case NotificationType.warning:
        return Colors.orange.withOpacity(0.9);
    }
  }

  IconData _getIcon(NotificationType type) {
    switch (type) {
      case NotificationType.success:
        return Icons.check_circle;
      case NotificationType.error:
        return Icons.error;
      case NotificationType.info:
        return Icons.info;
      case NotificationType.warning:
        return Icons.warning;
    }
  }
} 