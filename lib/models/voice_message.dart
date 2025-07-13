class VoiceMessage {
  final String id;
  final String message;
  final bool isUser;
  final DateTime timestamp;

  VoiceMessage({
    required this.id,
    required this.message,
    required this.isUser,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'message': message,
      'isUser': isUser,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  factory VoiceMessage.fromJson(Map<String, dynamic> json) {
    return VoiceMessage(
      id: json['id'],
      message: json['message'],
      isUser: json['isUser'],
      timestamp: DateTime.parse(json['timestamp']),
    );
  }
} 