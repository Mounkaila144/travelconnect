import 'package:equatable/equatable.dart';

abstract class NotificationEvent extends Equatable {
  const NotificationEvent();

  @override
  List<Object?> get props => [];
}

class PermissionRequested extends NotificationEvent {
  const PermissionRequested();
}

class TokenReceived extends NotificationEvent {
  final String token;

  const TokenReceived(this.token);

  @override
  List<Object?> get props => [token];
}

class NotificationReceived extends NotificationEvent {
  final String? title;
  final String? body;
  final Map<String, dynamic> data;

  const NotificationReceived({
    this.title,
    this.body,
    this.data = const {},
  });

  @override
  List<Object?> get props => [title, body, data];
}
