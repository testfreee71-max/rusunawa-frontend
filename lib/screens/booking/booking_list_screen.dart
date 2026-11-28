import 'package:flutter/material.dart';

import '../../core/app_colors.dart';
import '../../core/app_state.dart';
import '../../core/app_text_styles.dart';
import '../../models/booking.dart';
import '../../widgets/header_scaffold.dart';
import 'booking_detail_screen.dart';

class BookingListScreen extends StatefulWidget {
  const BookingListScreen({super.key});

  @override
  State<BookingListScreen> createState() => _BookingListScreenState();
}

class _BookingListScreenState extends State<BookingListScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) AppState.instance.refreshBookings();
    });
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: AppState.instance,
      builder: (context, _) {
        final active = AppState.instance.activeBookings;
        final history = AppState.instance.historyBookings;

        return HeaderScaffold(
          title: 'Booking Saya',
          onBack: () => AppState.instance.setTab(0),
          child: ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
            child: Column(
              children: <Widget>[
                Container(
                  color: AppColors.surface,
                  child: TabBar(
                    controller: _tabController,
                    labelColor: AppColors.primary,
                    unselectedLabelColor: AppColors.textMuted,
                    labelStyle: AppTextStyles.label,
                    unselectedLabelStyle: AppTextStyles.label,
                    indicatorColor: AppColors.primary,
                    indicatorWeight: 3,
                    dividerColor: AppColors.border,
                    tabs: const <Widget>[
                      Tab(text: 'Aktif'),
                      Tab(text: 'Riwayat'),
                    ],
                  ),
                ),
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: <Widget>[
                      _BookingContent(bookings: active, isHistory: false),
                      _BookingContent(bookings: history, isHistory: true),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _BookingContent extends StatelessWidget {
  const _BookingContent({required this.bookings, required this.isHistory});

  final List<Booking> bookings;
  final bool isHistory;

  @override
  Widget build(BuildContext context) {
    final state = AppState.instance;
    final vm = state.bookingViewModel;
    if (vm.loading) return const Center(child: CircularProgressIndicator());
    if (vm.error != null)
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(vm.error!),
            TextButton(
              onPressed: state.refreshBookings,
              child: const Text('Coba Lagi'),
            ),
          ],
        ),
      );
    if (bookings.isEmpty) {
      return RefreshIndicator(
        onRefresh: state.refreshBookings,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: [_EmptyBooking(isHistory: isHistory)],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: state.refreshBookings,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        children: <Widget>[
          Text(
            isHistory ? 'Riwayat Booking' : 'Booking Aktif',
            style: AppTextStyles.sectionTitle,
          ),
          const SizedBox(height: 12),
          for (final booking in bookings) ...<Widget>[
            _BookingCard(booking: booking, isHistory: isHistory),
            const SizedBox(height: 14),
          ],
        ],
      ),
    );
  }
}

class _EmptyBooking extends StatelessWidget {
  const _EmptyBooking({required this.isHistory});

  final bool isHistory;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(
              isHistory ? Icons.history_rounded : Icons.calendar_month_outlined,
              size: 64,
              color: AppColors.placeholder,
            ),
            const SizedBox(height: 16),
            Text('Belum ada booking', style: AppTextStyles.cardTitle),
            const SizedBox(height: 6),
            Text(
              isHistory
                  ? 'Riwayat booking Anda akan muncul di sini.'
                  : 'Yuk cari kamar yang nyaman untuk Anda.',
              textAlign: TextAlign.center,
              style: AppTextStyles.body,
            ),
            if (!isHistory) ...<Widget>[
              const SizedBox(height: 18),
              ElevatedButton(
                onPressed: () => AppState.instance.setTab(1),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.accent,
                  elevation: 0,
                ),
                child: const Text('Cari Kamar'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _BookingCard extends StatelessWidget {
  const _BookingCard({required this.booking, required this.isHistory});

  final Booking booking;
  final bool isHistory;

  String _formatDate(DateTime date) {
    const months = <String>[
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'Mei',
      'Jun',
      'Jul',
      'Agu',
      'Sep',
      'Okt',
      'Nov',
      'Des',
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  Future<void> _openDetail(BuildContext context) async {
    await AppState.instance.refreshBookings();
    if (!context.mounted) return;
    Navigator.push(
      context,
      MaterialPageRoute<void>(
        builder: (_) => BookingDetailScreen(bookingId: booking.id),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          children: <Widget>[
            Row(
              children: <Widget>[
                _StatusBadge(status: booking.status),
                const Spacer(),
                Text(
                  _formatDate(booking.submittedAt),
                  style: AppTextStyles.bodySmall,
                ),
              ],
            ),
            const SizedBox(height: 14),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: SizedBox(
                    width: 78,
                    height: 78,
                    child: booking.room.images.isNotEmpty
                        ? Image.network(
                            booking.room.images.first,
                            fit: BoxFit.cover,
                            errorBuilder: (_, _, _) => Container(
                              color: AppColors.placeholder,
                              child: const Icon(Icons.image_outlined),
                            ),
                          )
                        : Container(
                            color: AppColors.placeholder,
                            child: const Icon(Icons.image_outlined),
                          ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(booking.room.name, style: AppTextStyles.cardTitle),
                      const SizedBox(height: 3),
                      Text(
                        '${booking.room.building} • Lantai ${booking.room.floor}',
                        style: AppTextStyles.bodySmall,
                      ),
                      const SizedBox(height: 7),
                      Text(
                        '${booking.room.capacity} Orang • ${booking.room.gender}',
                        style: AppTextStyles.bodySmall,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            const Divider(color: AppColors.border),
            const SizedBox(height: 8),
            _InfoRow(
              label: 'Periode',
              value:
                  '${_formatDate(booking.startDate)} - ${_formatDate(booking.endDate)}',
            ),
            const SizedBox(height: 7),
            _InfoRow(label: 'Keperluan', value: booking.purpose),
            if (!isHistory) ...<Widget>[
              const SizedBox(height: 18),
              _BookingProgress(status: booking.status),
            ],
            const SizedBox(height: 14),
            const Divider(color: AppColors.border),
            const SizedBox(height: 8),
            Row(
              children: <Widget>[
                Text('ID: ${booking.id}', style: AppTextStyles.bodySmallBold),
                const Spacer(),
                TextButton(
                  onPressed: () => _openDetail(context),
                  child: Text(
                    'Lihat Detail →',
                    style: AppTextStyles.bodySmallBold.copyWith(
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Expanded(flex: 2, child: Text(label, style: AppTextStyles.bodySmall)),
        Expanded(
          flex: 3,
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: AppTextStyles.bodySmallBold,
          ),
        ),
      ],
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.status});

  final BookingStatus status;

  Color get _background {
    switch (status) {
      case BookingStatus.waiting:
      case BookingStatus.processing:
        return AppColors.infoBg;
      case BookingStatus.approved:
      case BookingStatus.completed:
        return AppColors.successBg;
      case BookingStatus.rejected:
        return AppColors.dangerBg;
      case BookingStatus.cancelled:
        return AppColors.placeholder;
    }
  }

  Color get _foreground {
    switch (status) {
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
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: _background,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status.label,
        style: AppTextStyles.badge.copyWith(color: _foreground),
      ),
    );
  }
}

class _BookingProgress extends StatelessWidget {
  const _BookingProgress({required this.status});

  final BookingStatus status;

  int get _progress {
    switch (status) {
      case BookingStatus.waiting:
        return 0;
      case BookingStatus.processing:
        return 1;
      case BookingStatus.approved:
      case BookingStatus.completed:
        return 2;
      default:
        return 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    const labels = <String>['Diajukan', 'Diproses', 'Disetujui'];

    final progress = _progress;

    return Row(
      children: List<Widget>.generate(3, (index) {
        final done = index <= progress;

        return Expanded(
          child: Row(
            children: <Widget>[
              Column(
                children: <Widget>[
                  Container(
                    width: 22,
                    height: 22,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: done ? AppColors.primary : AppColors.placeholder,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      done ? Icons.check : Icons.circle,
                      size: done ? 13 : 6,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    labels[index],
                    style: AppTextStyles.bodySmall.copyWith(fontSize: 9),
                  ),
                ],
              ),
              if (index < 2)
                Expanded(
                  child: Container(
                    height: 2,
                    margin: const EdgeInsets.only(bottom: 19),
                    color: index < progress
                        ? AppColors.primary
                        : AppColors.border,
                  ),
                ),
            ],
          ),
        );
      }),
    );
  }
}
