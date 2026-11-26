import 'package:flutter/material.dart';

import '../../core/app_colors.dart';
import '../../core/app_state.dart';
import '../../core/app_text_styles.dart';
import '../../models/app_notification.dart';

void showNotificationSheet(BuildContext context) {
  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => const NotificationSheet(),
  );
}

class NotificationSheet extends StatelessWidget {
  const NotificationSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.sizeOf(context).height * 0.7;

    return ListenableBuilder(
      listenable: AppState.instance,
      builder: (context, _) {
        final notifications = AppState.instance.notifications;

        return Container(
          height: height,
          padding: const EdgeInsets.fromLTRB(16, 18, 16, 0),
          decoration: const BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: Column(
            children: <Widget>[
              Row(
                children: <Widget>[
                  Text('Notifikasi', style: AppTextStyles.sectionTitle),
                  const Spacer(),
                  TextButton(
                    onPressed: AppState.instance.markAllNotificationsRead,
                    child: Text(
                      'Tandai semua sudah dibaca',
                      style: AppTextStyles.bodySmallBold,
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(
                      Icons.close_rounded,
                      size: 20,
                      color: AppColors.primaryDark,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.only(bottom: 20),
                  itemCount: notifications.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final item = notifications[index];
                    return _NotificationCard(notification: item);
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _NotificationCard extends StatelessWidget {
  const _NotificationCard({required this.notification});

  final AppNotification notification;

  @override
  Widget build(BuildContext context) {
    final visual = _notificationVisual(notification.type);

    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () => AppState.instance.markNotificationRead(notification.id),
        child: Container(
          constraints: const BoxConstraints(minHeight: 76),
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: visual.background,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  visual.icon,
                  size: 17,
                  color: visual.foreground,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(top: 1),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(notification.title, style: AppTextStyles.cardTitle),
                      const SizedBox(height: 3),
                      Text(
                        notification.message,
                        style: AppTextStyles.bodySmall,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: <Widget>[
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Text(notification.time, style: AppTextStyles.bodySmall),
                      if (!notification.isRead) ...<Widget>[
                        const SizedBox(width: 5),
                        const _UnreadDot(),
                      ],
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _UnreadDot extends StatelessWidget {
  const _UnreadDot();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 6,
      height: 6,
      decoration: const BoxDecoration(
        color: AppColors.primary,
        shape: BoxShape.circle,
      ),
    );
  }
}

_NotificationVisual _notificationVisual(NotificationType type) {
  switch (type) {
    case NotificationType.approved:
      return const _NotificationVisual(
        Icons.check_rounded,
        AppColors.successBg,
        AppColors.success,
      );
    case NotificationType.document:
      return const _NotificationVisual(
        Icons.article_outlined,
        AppColors.infoBg,
        AppColors.info,
      );
    case NotificationType.processing:
      return const _NotificationVisual(
        Icons.access_time_rounded,
        AppColors.infoBg,
        AppColors.info,
      );
  }
}

class _NotificationVisual {
  const _NotificationVisual(
      this.icon,
      this.background,
      this.foreground,
      );

  final IconData icon;
  final Color background;
  final Color foreground;
}