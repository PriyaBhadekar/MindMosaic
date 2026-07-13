class AiChatResponse {
  final String response;
  final String intent;
  final String emotion;
  final String action;
  final bool caregiverAlert;

  AiChatResponse({
    required this.response,
    required this.intent,
    required this.emotion,
    required this.action,
    required this.caregiverAlert,
  });

  factory AiChatResponse.fromJson(
      Map<String, dynamic> json,
      ) {
    return AiChatResponse(
      response: json['response'] ?? '',
      intent: json['intent'] ?? 'GENERAL',
      emotion: json['emotion'] ?? 'NEUTRAL',
      action: json['action'] ?? 'NONE',
      caregiverAlert: json['caregiverAlert'] ?? false,
    );
  }
}