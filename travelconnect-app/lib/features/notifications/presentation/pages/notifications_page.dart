import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:travelconnect_app/l10n/app_localizations.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_theme.dart';
import '../../domain/entities/app_notification.dart';
import '../bloc/notifications_center_bloc.dart';
import '../bloc/notifications_center_event.dart';
import '../bloc/notifications_center_state.dart';
import '../widgets/notification_item.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  @override
  void initState() {
    super.initState();
    context.read<NotificationsCenterBloc>().add(const LoadNotifications());
  }

  void _handleNotificationTap(AppNotification notification) {
    // Mark as read
    context.read<NotificationsCenterBloc>().add(MarkAsRead(notification));

    // Navigate to linked content
    final data = notification.data;
    switch (notification.type) {
      case 'new_answer':
      case 'nearby_question':
        final questionId = data['question_id'];
        if (questionId != null) {
          Navigator.pushNamed(context, '/question/$questionId');
        }
        break;
    }
  }

  /// Groups notifications by date
  Map<String, List<AppNotification>> _groupByDate(
      List<AppNotification> notifications) {
    final l10n = AppLocalizations.of(context)!;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));

    final groups = <String, List<AppNotification>>{};

    for (final n in notifications) {
      final date = DateTime(n.createdAt.year, n.createdAt.month, n.createdAt.day);
      String label;
      if (date == today || date.isAfter(today)) {
        label = l10n.notifications_today;
      } else if (date == yesterday || (date.isAfter(yesterday) && date.isBefore(today))) {
        label = l10n.notifications_yesterday;
      } else {
        label = l10n.notifications_older;
      }
      groups.putIfAbsent(label, () => []);
      groups[label]!.add(n);
    }

    return groups;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.notifications_title),
        centerTitle: true,
        actions: [
          BlocBuilder<NotificationsCenterBloc, NotificationsCenterState>(
            builder: (context, state) {
              if (state is NotificationsCenterLoaded &&
                  state.unreadCount > 0) {
                return TextButton(
                  onPressed: () {
                    context
                        .read<NotificationsCenterBloc>()
                        .add(const MarkAllAsRead());
                  },
                  child: Text(l10n.notifications_markAllRead),
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
      body: BlocBuilder<NotificationsCenterBloc, NotificationsCenterState>(
        builder: (context, state) {
          if (state is NotificationsCenterLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is NotificationsCenterError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppColors.error.withAlpha(25),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.error_outline,
                      size: 64,
                      color: AppColors.error,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Text(
                    state.message,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  ElevatedButton(
                    onPressed: () {
                      context
                          .read<NotificationsCenterBloc>()
                          .add(const LoadNotifications());
                    },
                    child: Text(l10n.common_retry),
                  ),
                ],
              ),
            );
          }

          if (state is NotificationsCenterLoaded) {
            if (state.notifications.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withAlpha(25),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.notifications_none,
                        size: 64,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    Text(
                      l10n.notifications_empty,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      l10n.notifications_emptyMessage,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppColors.textSecondary,
                          ),
                    ),
                  ],
                ),
              );
            }

            final grouped = _groupByDate(state.notifications);
            // Maintain order
            final orderedKeys = <String>[];
            if (grouped.containsKey(l10n.notifications_today)) {
              orderedKeys.add(l10n.notifications_today);
            }
            if (grouped.containsKey(l10n.notifications_yesterday)) {
              orderedKeys.add(l10n.notifications_yesterday);
            }
            if (grouped.containsKey(l10n.notifications_older)) {
              orderedKeys.add(l10n.notifications_older);
            }

            return RefreshIndicator(
              onRefresh: () async {
                context
                    .read<NotificationsCenterBloc>()
                    .add(const RefreshNotifications());
              },
              child: ListView.builder(
                itemCount: _countItems(grouped, orderedKeys),
                itemBuilder: (context, index) {
                  // Find which section + item this index maps to
                  int current = 0;
                  for (final key in orderedKeys) {
                    // Section header
                    if (current == index) {
                      return _SectionHeader(title: key);
                    }
                    current++;

                    final items = grouped[key]!;
                    for (int i = 0; i < items.length; i++) {
                      if (current == index) {
                        final notification = items[i];
                        return Dismissible(
                          key: Key(notification.id),
                          direction: DismissDirection.horizontal,
                          background: Container(
                            alignment: Alignment.centerLeft,
                            padding: const EdgeInsets.only(left: 20),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  AppColors.info,
                                  AppColors.info.withAlpha(200),
                                ],
                                begin: Alignment.centerLeft,
                                end: Alignment.centerRight,
                              ),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.mark_email_read,
                                    color: Colors.white),
                                const SizedBox(width: AppSpacing.sm),
                                Text(l10n.notifications_markRead,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600,
                                    )),
                              ],
                            ),
                          ),
                          secondaryBackground: Container(
                            alignment: Alignment.centerRight,
                            padding: const EdgeInsets.only(right: 20),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  AppColors.error.withAlpha(200),
                                  AppColors.error,
                                ],
                                begin: Alignment.centerLeft,
                                end: Alignment.centerRight,
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Text(l10n.notifications_delete,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600,
                                    )),
                                const SizedBox(width: AppSpacing.sm),
                                const Icon(Icons.delete, color: Colors.white),
                              ],
                            ),
                          ),
                          confirmDismiss: (direction) async {
                            if (direction == DismissDirection.startToEnd) {
                              // Mark as read
                              context
                                  .read<NotificationsCenterBloc>()
                                  .add(MarkAsRead(notification));
                              return false; // Don't dismiss, just mark as read
                            }
                            return true; // Allow dismiss for delete
                          },
                          onDismissed: (direction) {
                            // Delete notification (swipe left)
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(l10n.notifications_deleted),
                                duration: const Duration(seconds: 2),
                              ),
                            );
                          },
                          child: Container(
                            decoration: notification.isUnread
                                ? const BoxDecoration(
                                    border: Border(
                                      left: BorderSide(
                                        color: AppColors.primary,
                                        width: 3,
                                      ),
                                    ),
                                  )
                                : null,
                            child: Column(
                              children: [
                                NotificationItem(
                                  notification: notification,
                                  onTap: () =>
                                      _handleNotificationTap(notification),
                                ),
                                const Divider(height: 1),
                              ],
                            ),
                          ),
                        );
                      }
                      current++;
                    }
                  }
                  return const SizedBox.shrink();
                },
              ),
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  int _countItems(
      Map<String, List<AppNotification>> grouped, List<String> keys) {
    int count = 0;
    for (final key in keys) {
      count++; // section header
      count += grouped[key]!.length;
    }
    return count;
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;

  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.lg,
        AppSpacing.lg,
        AppSpacing.sm,
      ),
      color: AppColors.surfaceVariant,
      child: Text(
        title,
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
      ),
    );
  }
}
