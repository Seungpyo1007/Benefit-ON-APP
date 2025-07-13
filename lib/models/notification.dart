enum NotificationType {
  success,
  error,
  info,
  warning,
}

class NotificationMessage {
  final String id;
  final String message;
  final NotificationType type;
  final DateTime timestamp;

  NotificationMessage({
    required this.id,
    required this.message,
    required this.type,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  factory NotificationMessage.fromJson(Map<String, dynamic> json) {
    return NotificationMessage(
      id: json['id'] as String,
      message: json['message'] as String,
      type: NotificationType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => NotificationType.info,
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'message': message,
      'type': type.name,
    };
  }
} 