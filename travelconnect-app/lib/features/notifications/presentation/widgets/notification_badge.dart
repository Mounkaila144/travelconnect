import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_colors.dart';
import '../bloc/notifications_center_bloc.dart';
import '../bloc/notifications_center_state.dart';

class NotificationBadge extends StatelessWidget {
  final Widget child;

  const NotificationBadge({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<NotificationsCenterBloc, NotificationsCenterState>(
      builder: (context, state) {
        final unreadCount = state is NotificationsCenterLoaded
            ? state.unreadCount
            : 0;

        if (unreadCount == 0) {
          return child;
        }

        return Badge(
          label: Text(
            unreadCount > 99 ? '99+' : '$unreadCount',
            style: const TextStyle(fontSize: 10),
          ),
          backgroundColor: AppColors.error,
          child: child,
        );
      },
    );
  }
}
