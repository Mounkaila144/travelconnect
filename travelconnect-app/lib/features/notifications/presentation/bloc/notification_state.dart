import 'package:equatable/equatable.dart';

abstract class NotificationState extends Equatable {
  const NotificationState();

  @override
  List<Object?> get props => [];
}

class NotificationInitial extends NotificationState {
  const NotificationInitial();
}

class PermissionGranted extends NotificationState {
  const PermissionGranted();
}

class PermissionDenied extends NotificationState {
  const PermissionDenied();
}

class TokenRegistered extends NotificationState {
  final String token;

  const TokenRegistered(this.token);

  @override
  List<Object?> get props => [token];
}

class NotificationError extends NotificationState {
  final String message;

  const NotificationError(this.message);

  @override
  List<Object?> get props => [message];
}
