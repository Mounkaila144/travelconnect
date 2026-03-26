import '../../domain/entities/app_notification.dart';

class NotificationModel {
  final String id;
  final String type;
  final String title;
  final String body;
  final Map<String, dynamic> data;
  final DateTime? readAt;
  final DateTime createdAt;
  final String timeAgo;

  const NotificationModel({
    required this.id,
    required this.type,
    required this.title,
    required this.body,
    required this.data,
    this.readAt,
    required this.createdAt,
    required this.timeAgo,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'] as String,
      type: json['type'] as String,
      title: json['title'] as String,
      body: json['body'] as String,
      data: json['data'] as Map<String, dynamic>? ?? {},
      readAt: json['read_at'] != null
          ? DateTime.parse(json['read_at'] as String)
          : null,
      createdAt: DateTime.parse(json['created_at'] as String),
      timeAgo: json['time_ago'] as String? ?? '',
    );
  }

  AppNotification toEntity() {
    return AppNotification(
      id: id,
      type: type,
      title: title,
      body: body,
      data: data,
      readAt: readAt,
      createdAt: createdAt,
      timeAgo: timeAgo,
    );
  }
}
