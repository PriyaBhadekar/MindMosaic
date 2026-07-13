class ScheduleModel {
  final int id;
  final String title;
  final String scheduledTime;
  final String? voiceDescription;
  final String repeatType;
  final String reminderType;
  final bool active;
  final String? createdAt;

  ScheduleModel({
    required this.id,
    required this.title,
    required this.scheduledTime,
    this.voiceDescription,
    required this.repeatType,
    required this.reminderType,
    required this.active,
    this.createdAt,
  });

  factory ScheduleModel.fromJson(Map<String, dynamic> json) => ScheduleModel(
    id: json['id'] ?? 0,
    title: json['title'] ?? '',
    scheduledTime: json['scheduledTime'] ?? '',
    voiceDescription: json['voiceDescription'],
    repeatType: json['repeatType'] ?? 'DAILY',
    reminderType: json['reminderType'] ?? 'VOICE',
    active: json['active'] ?? true,
    createdAt: json['createdAt'],
  );
}