import 'package:equatable/equatable.dart';

class AppNotification extends Equatable {
  final String id;
  final String type;
  final String title;
  final String body;
  final Map<String, dynamic> data;
  final DateTime? readAt;
  final DateTime createdAt;
  final String timeAgo;

  const AppNotification({
    required this.id,
    required this.type,
    required this.title,
    required this.body,
    required this.data,
    this.readAt,
    required this.createdAt,
    required this.timeAgo,
  });

  bool get isUnread => readAt == null;

  AppNotification markAsRead() {
    return AppNotification(
      id: id,
      type: type,
      title: title,
      body: body,
      data: data,
      readAt: DateTime.now(),
      createdAt: createdAt,
      timeAgo: timeAgo,
    );
  }

  @override
  List<Object?> get props =>
      [id, type, title, body, data, readAt, createdAt, timeAgo];
}
