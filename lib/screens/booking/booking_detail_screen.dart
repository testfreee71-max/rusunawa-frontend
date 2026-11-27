import '../../viewmodels/auth_view_model.dart';
import 'package:flutter/material.dart';

import '../../core/app_colors.dart';
import '../../core/app_state.dart';
import '../../core/app_text_styles.dart';
import '../../models/booking.dart';

class BookingDetailScreen extends StatelessWidget {
  const BookingDetailScreen({
    super.key,
    required this.bookingId,
  });

  final String bookingId;

  String _formatDate(DateTime date) {
    const months = <String>[
      'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
      'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des',
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  Future<void> _cancelBooking(
      BuildContext context,
      Booking booking,
      ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Batalkan Pengajuan?'),
          content: const Text(
            'Pengajuan booking yang dibatalkan tidak dapat dikembalikan.',
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Tidak'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.danger,
              ),
              child: const Text('Ya, Batalkan'),
            ),
          ],
        );
      },
    );

    if (confirmed != true || !context.mounted) return;

    try {
      await AppState.instance.cancelBooking(booking.id);
    } catch (e) {
      if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(AuthViewModel.message(e))));
      return;
    }
    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Pengajuan booking berhasil dibatalkan.'),
      ),
    );

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: AppState.instance,
      builder: (context, _) {
        final bookings = AppState.instance.bookings;

        final matches = bookings.where(
              (item) => item.id == bookingId,
        );

        if (matches.isEmpty) {
          return const Scaffold(
            body: Center(
              child: Text('Booking tidak ditemukan'),
            ),
          );
        }

        final booking = matches.first;

        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            elevation: 0,
            backgroundColor: AppColors.background,
            surfaceTintColor: Colors.transparent,
            title: const Text('Detail Booking'),
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                _StatusCard(
                  booking: booking,
                  formatDate: _formatDate,
                ),
                const SizedBox(height: 16),
                _SectionCard(
                  title: 'Informasi Kamar',
                  icon: Icons.meeting_room_outlined,
                  child: Column(
                    children: <Widget>[
                      Row(
                        children: <Widget>[
                          ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: SizedBox(
                              width: 80,
                              height: 80,
                              child: booking.room.images.isNotEmpty
                                  ? Image.network(
                                booking.room.images.first,
                                fit: BoxFit.cover,
                                errorBuilder: (_, _, _) => Container(
                                  color: AppColors.placeholder,
                                ),
                              )
                                  : Container(
                                color: AppColors.placeholder,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Text(
                                  booking.room.name,
                                  style: AppTextStyles.cardTitle,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${booking.room.building} • Lantai ${booking.room.floor}',
                                  style: AppTextStyles.bodySmall,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${booking.room.capacity} Orang • ${booking.room.gender}',
                                  style: AppTextStyles.bodySmall,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                _SectionCard(
                  title: 'Periode Tinggal',
                  icon: Icons.calendar_month_outlined,
                  child: Column(
                    children: <Widget>[
                      _DetailRow(
                        label: 'Tanggal Masuk',
                        value: _formatDate(booking.startDate),
                      ),
                      _DetailRow(
                        label: 'Tanggal Keluar',
                        value: _formatDate(booking.endDate),
                      ),
                      _DetailRow(
                        label: 'Durasi',
                        value: '${booking.durationMonths} bulan',
                      ),
                      _DetailRow(
                        label: 'Keperluan',
                        value: booking.purpose,
                      ),
                      if (booking.note.trim().isNotEmpty)
                        _DetailRow(
                          label: 'Catatan',
                          value: booking.note,
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                _Timeline(status: booking.status),
                const SizedBox(height: 16),
                _SectionCard(
                  title: 'Informasi Pengajuan',
                  icon: Icons.receipt_long_outlined,
                  child: Column(
                    children: <Widget>[
                      _DetailRow(
                        label: 'ID Booking',
                        value: booking.id,
                      ),
                      _DetailRow(
                        label: 'Tanggal Pengajuan',
                        value: _formatDate(booking.submittedAt),
                      ),
                      _DetailRow(
                        label: 'Status',
                        value: booking.status.label,
                      ),
                    ],
                  ),
                ),
                if (booking.status == BookingStatus.waiting) ...<Widget>[
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: OutlinedButton(
                      onPressed: () => _cancelBooking(context, booking),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.danger,
                        side: const BorderSide(color: AppColors.danger),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('Batalkan Pengajuan'),
                    ),
                  ),
                ],
                const SizedBox(height: 24),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _StatusCard extends StatelessWidget {
  const _StatusCard({
    required this.booking,
    required this.formatDate,
  });

  final Booking booking;
  final String Function(DateTime) formatDate;

  Color get _color {
    switch (booking.status) {
      case BookingStatus.waiting:
      case BookingStatus.processing:
        return AppColors.primary;
      case BookingStatus.approved:
      case BookingStatus.completed:
        return AppColors.success;
      case BookingStatus.rejected:
        return AppColors.danger;
      case BookingStatus.cancelled:
        return AppColors.textMuted;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: <Widget>[
          Icon(
            booking.status == BookingStatus.cancelled
                ? Icons.cancel_outlined
                : Icons.assignment_turned_in_outlined,
            size: 38,
            color: _color,
          ),
          const SizedBox(height: 8),
          Text(
            booking.status.label,
            style: AppTextStyles.cardTitle.copyWith(color: _color),
          ),
          const SizedBox(height: 5),
          Text(
            'ID Booking: ${booking.id}',
            style: AppTextStyles.bodySmall,
          ),
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({
    required this.title,
    required this.icon,
    required this.child,
  });

  final String title;
  final IconData icon;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Icon(icon, color: AppColors.primary, size: 20),
              const SizedBox(width: 8),
              Text(title, style: AppTextStyles.cardTitle),
            ],
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Divider(color: AppColors.border),
          ),
          child,
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Expanded(
            child: Text(label, style: AppTextStyles.bodySmall),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: AppTextStyles.bodySmallBold,
            ),
          ),
        ],
      ),
    );
  }
}

class _Timeline extends StatelessWidget {
  const _Timeline({required this.status});

  final BookingStatus status;

  int get _currentStep {
    switch (status) {
      case BookingStatus.waiting:
        return 0;
      case BookingStatus.processing:
        return 1;
      case BookingStatus.approved:
      case BookingStatus.completed:
        return 2;
      case BookingStatus.rejected:
      case BookingStatus.cancelled:
        return 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    const labels = <String>[
      'Diajukan',
      'Diproses',
      'Disetujui',
    ];

    final current = _currentStep;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text('Status Pengajuan', style: AppTextStyles.cardTitle),
          const SizedBox(height: 20),
          ...List<Widget>.generate(labels.length, (index) {
            final active = index <= current;
            final isLast = index == labels.length - 1;

            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Column(
                  children: <Widget>[
                    Container(
                      width: 26,
                      height: 26,
                      decoration: BoxDecoration(
                        color: active
                            ? AppColors.primary
                            : AppColors.placeholder,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        active ? Icons.check : Icons.circle,
                        color: Colors.white,
                        size: active ? 15 : 7,
                      ),
                    ),
                    if (!isLast)
                      Container(
                        width: 2,
                        height: 34,
                        color: index < current
                            ? AppColors.primary
                            : AppColors.border,
                      ),
                  ],
                ),
                const SizedBox(width: 12),
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    labels[index],
                    style: AppTextStyles.bodySmallBold.copyWith(
                      color: active
                          ? AppColors.textTitle
                          : AppColors.textMuted,
                    ),
                  ),
                ),
              ],
            );
          }),
          if (status == BookingStatus.rejected ||
              status == BookingStatus.cancelled)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                status.label,
                style: AppTextStyles.bodySmallBold.copyWith(
                  color: status == BookingStatus.rejected
                      ? AppColors.danger
                      : AppColors.textMuted,
                ),
              ),
            ),
        ],
      ),
    );
  }
}