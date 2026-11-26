import 'package:flutter/material.dart';

import '../core/app_colors.dart';
import '../core/app_text_styles.dart';
import '../models/booking.dart';

class StatusBadge extends StatelessWidget {
  const StatusBadge({
    super.key,
    required this.status,
  });

  final BookingStatus status;

  @override
  Widget build(BuildContext context) {
    final colors = _statusColors(status);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: colors.background,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        status.label,
        style: AppTextStyles.badge.copyWith(color: colors.foreground),
      ),
    );
  }
}

_StatusColors _statusColors(BookingStatus status) {
  switch (status) {
    case BookingStatus.waiting:
      return const _StatusColors(AppColors.warningBg, AppColors.warning);
    case BookingStatus.processing:
      return const _StatusColors(AppColors.infoBg, AppColors.info);
    case BookingStatus.approved:
    case BookingStatus.completed:
      return const _StatusColors(AppColors.successBg, AppColors.success);
    case BookingStatus.rejected:
    case BookingStatus.cancelled:
      return const _StatusColors(AppColors.dangerBg, AppColors.danger);
  }
}

class _StatusColors {
  const _StatusColors(this.background, this.foreground);

  final Color background;
  final Color foreground;
}