import 'package:flutter/material.dart';

import '../../core/app_colors.dart';
import '../../core/app_state.dart';
import '../../core/app_text_styles.dart';
import '../../widgets/room_card.dart';
import '../rooms/room_detail_screen.dart';
import 'notification_sheet.dart';

const double _heroGap = 50; // search bar -> banner
const double _heroBottom = 50; // banner -> sheet putih
const double _sheetRadius = 24; // foto menjulur sedalam ini di bawah sheet
const bool _lockScroll = true;

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late final TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _submitSearch(String value) {
    AppState.instance.setTab(1, query: value.trim());
  }

  @override
  Widget build(BuildContext context) {
    final state = AppState.instance;
    final topPadding = MediaQuery.of(context).padding.top;

    return ListenableBuilder(
      listenable: state,
      builder: (context, _) {
        return Scaffold(
          backgroundColor: AppColors.background,
          // Tanpa efek stretch/bounce di ujung scroll (penyebab "goyang").
          body: ScrollConfiguration(
            behavior: ScrollConfiguration.of(context).copyWith(
              overscroll: false,
              physics: const ClampingScrollPhysics(),
            ),
            child: SingleChildScrollView(
              physics: _lockScroll ? const NeverScrollableScrollPhysics() : null,
              child: Column(
                children: <Widget>[
                  // Foto gedung ikut tinggi konten hero, jadi tidak ada gap biru.
                  Stack(
                    clipBehavior: Clip.none,
                    children: <Widget>[
                      const Positioned(
                        top: 0,
                        left: 0,
                        right: 0,
                        // Menjulur ke bawah sheet supaya sudut membulatnya
                        // menampilkan foto, bukan warna polos.
                        bottom: -_sheetRadius,
                        child: _HeroBackground(),
                      ),
                      _HeroContent(
                        topPadding: topPadding,
                        searchController: _searchController,
                        onSearch: _submitSearch,
                      ),
                    ],
                  ),
                  _HomeSheet(state: state),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _HeroBackground extends StatelessWidget {
  const _HeroBackground();

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: <Widget>[
        // Warna cadangan kalau foto lebih pendek dari areanya.
        const ColoredBox(color: AppColors.primary),
        Image.asset(
          'assets/images/gedung_home.png',
          // cover = foto selalu memenuhi area hero, tanpa gap.
          fit: BoxFit.cover,
          alignment: Alignment.bottomCenter,
        ),
        DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: <Color>[
                AppColors.primaryDark.withValues(alpha: 0.35),
                AppColors.primary.withValues(alpha: 0.02),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _HeroContent extends StatelessWidget {
  const _HeroContent({
    required this.topPadding,
    required this.searchController,
    required this.onSearch,
  });

  final double topPadding;
  final TextEditingController searchController;
  final ValueChanged<String> onSearch;

  @override
  Widget build(BuildContext context) {
    final state = AppState.instance;

    return Padding(
      padding: EdgeInsets.fromLTRB(16, topPadding + 14, 16, _heroBottom),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              _Avatar(initial: state.user.initial),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      'Halo, ${state.user.firstName}!',
                      style: AppTextStyles.headerTitle.copyWith(
                        fontSize: 15,
                        height: 1.3,
                      ),
                    ),
                    Text(
                      'Selamat Datang Di SiRUNA',
                      style: AppTextStyles.headerTitle.copyWith(
                        fontSize: 10,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
              Stack(
                clipBehavior: Clip.none,
                children: <Widget>[
                  IconButton(
                    onPressed: () => showNotificationSheet(context),
                    icon: const Icon(
                      Icons.notifications_none_rounded,
                      color: Colors.white,
                      size: 26,
                    ),
                  ),
                  if (state.unreadCount > 0)
                    Positioned(
                      top: 9,
                      right: 10,
                      child: Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: AppColors.accent,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 14),
          _SearchBar(
            controller: searchController,
            onSubmitted: onSearch,
          ),
          const SizedBox(height: _heroGap),
          const _CampusBanner(),
        ],
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  const _Avatar({required this.initial});

  final String initial;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: AppColors.surface,
        shape: BoxShape.circle,
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.15),
        ),
      ),
      alignment: Alignment.center,
      child: Text(
        initial,
        style: AppTextStyles.cardHeading.copyWith(fontSize: 16),
      ),
    );
  }
}

class _SearchBar extends StatelessWidget {
  const _SearchBar({
    required this.controller,
    required this.onSubmitted,
  });

  final TextEditingController controller;
  final ValueChanged<String> onSubmitted;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 46,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: AppColors.textDark.withValues(alpha: 0.12),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        onSubmitted: onSubmitted,
        textInputAction: TextInputAction.search,
        style: AppTextStyles.input,
        decoration: InputDecoration(
          border: InputBorder.none,
          prefixIcon: const Icon(
            Icons.search_rounded,
            size: 21,
            color: AppColors.primary,
          ),
          hintText: 'Cari kamar, lokasi, atau fasilitas....',
          hintStyle: AppTextStyles.hint,
          contentPadding: const EdgeInsets.symmetric(vertical: 13),
        ),
      ),
    );
  }
}

class _CampusBanner extends StatelessWidget {
  const _CampusBanner();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 135,
      alignment: Alignment.centerLeft,
      padding: const EdgeInsets.fromLTRB(18, 0, 16, 0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        gradient: LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: <Color>[
            AppColors.primaryDark.withValues(alpha: 0.92),
            AppColors.primary.withValues(alpha: 0.65),
            AppColors.primary.withValues(alpha: 0.0),
          ],
          stops: const <double>[0.0, 0.45, 0.8],
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            'Temukan Hunian\nNyaman di Kampus',
            style: AppTextStyles.headerTitle.copyWith(
              fontSize: 14,
              height: 1.25,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            'Aman, bersih dan strategis\nuntuk mendukung aktivitasmu.',
            style: AppTextStyles.bodySmall.copyWith(
              fontSize: 10,
              color: Colors.white,
              height: 1.3,
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 28,
            child: ElevatedButton(
              onPressed: () => AppState.instance.setTab(1),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.accent,
                foregroundColor: Colors.white,
                elevation: 2,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Text(
                    'Cari Kamar',
                    style: AppTextStyles.button.copyWith(fontSize: 11),
                  ),
                  const SizedBox(width: 6),
                  const Icon(Icons.arrow_forward_rounded, size: 14),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HomeSheet extends StatelessWidget {
  const _HomeSheet({required this.state});

  final AppState state;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(0, 20, 0, 18),
      decoration: const BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.vertical(top: Radius.circular(_sheetRadius)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text('Ringkasan Kamar', style: AppTextStyles.cardHeading),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: _StatCard(
                    icon: Icons.bed_rounded,
                    value: state.roomsAvailableCount,
                    label: 'Tersedia',
                    background: AppColors.successBg,
                    foreground: AppColors.success,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _StatCard(
                    icon: Icons.bed_rounded,
                    value: state.roomsOccupiedCount,
                    label: 'Terisi',
                    background: AppColors.dangerBg,
                    foreground: AppColors.danger,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _StatCard(
                    icon: Icons.timer_outlined,
                    value: state.bookingsInProgressCount,
                    label: 'Dalam Proses',
                    background: AppColors.infoBg,
                    foreground: AppColors.info,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          _AvailabilitySection(state: state),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.icon,
    required this.value,
    required this.label,
    required this.background,
    required this.foreground,
  });

  final IconData icon;
  final int value;
  final String label;
  final Color background;
  final Color foreground;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 72,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: <Widget>[
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              color: AppColors.surface.withValues(alpha: 0.5),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 16, color: foreground),
          ),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Text(
                  '$value',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.statNumber.copyWith(
                    fontSize: 17,
                    height: 1.1,
                    color: foreground,
                  ),
                ),
                Text(
                  label,
                  maxLines: 2,
                  textAlign: TextAlign.center,
                  style: AppTextStyles.statLabel.copyWith(
                    fontSize: 10,
                    color: foreground,
                    height: 1.1,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AvailabilitySection extends StatelessWidget {
  const _AvailabilitySection({required this.state});

  final AppState state;

  @override
  Widget build(BuildContext context) {
    final rooms = state.rooms;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: <Widget>[
              Text('Ketersediaan Kamar', style: AppTextStyles.cardHeading),
              const Spacer(),
              InkWell(
                onTap: () => state.setTab(1),
                borderRadius: BorderRadius.circular(8),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Text('Lihat Semua', style: AppTextStyles.linkText),
                      const SizedBox(width: 2),
                      const Icon(
                        Icons.chevron_right_rounded,
                        color: AppColors.primary,
                        size: 20,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 190,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 6),
            itemCount: rooms.length,
            separatorBuilder: (_, _) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              final room = rooms[index];

              return RoomCard(
                room: room,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute<void>(
                      builder: (_) => RoomDetailScreen(roomId: room.id),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}