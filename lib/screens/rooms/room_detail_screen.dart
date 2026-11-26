import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

import '../../core/app_colors.dart';
import '../../core/app_state.dart';
import '../../core/app_text_styles.dart';
import '../../models/room.dart';
import '../booking/booking_form_screen.dart';

class RoomDetailScreen extends StatefulWidget {
  const RoomDetailScreen({
    super.key,
    required this.roomId,
  });

  final String roomId;

  @override
  State<RoomDetailScreen> createState() => _RoomDetailScreenState();
}

class _RoomDetailScreenState extends State<RoomDetailScreen> {
  late final PageController _pageController;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _openBookingForm(String roomId) {
    Navigator.push(
      context,
      MaterialPageRoute<void>(
        builder: (_) => BookingFormScreen(roomId: roomId),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: AppState.instance,
      builder: (context, _) {
        final room = AppState.instance.rooms.firstWhere(
              (item) => item.id == widget.roomId,
        );

        if (_currentPage >= room.images.length) {
          _currentPage = 0;
        }

        return Scaffold(
          backgroundColor: AppColors.background,
          body: SafeArea(
            top: false,
            child: Column(
              children: <Widget>[
                Expanded(
                  child: ScrollConfiguration(
                    behavior: ScrollConfiguration.of(context).copyWith(
                      overscroll: false,
                      physics: const ClampingScrollPhysics(),
                    ),
                    child: SingleChildScrollView(
                      child: Column(
                        children: <Widget>[
                          _ImageGallery(
                            room: room,
                            controller: _pageController,
                            currentPage: _currentPage,
                            onPageChanged: (index) {
                              setState(() {
                                _currentPage = index;
                              });
                            },
                          ),
                          Transform.translate(
                            offset: const Offset(0, -16),
                            child: _RoomInformation(room: room),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                _BottomBookingBar(
                  available: room.available,
                  onPressed: () => _openBookingForm(room.id),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// Membuka menu bagikan bawaan HP (WhatsApp, Telegram, dll).
Future<void> _shareRoom(Room room) {
  final status = room.available ? 'Tersedia' : 'Habis';
  final text = '${room.name} (${room.gender})\n'
      '${room.building} - Lantai ${room.floor}\n'
      'Kapasitas ${room.capacity} orang | Ukuran ${room.size}\n'
      'Status: $status\n'
      'Biaya: Gratis (Subsidi Kampus)\n\n'
      'Cek kamar ini di aplikasi SiRUNA.';

  return SharePlus.instance.share(
    ShareParams(text: text, subject: room.name),
  );
}

// Jarak titik indikator & penghitung "1/3" dari bawah foto.
// Makin besar, makin naik (sheet putih menimpa ±16px bagian bawah foto).
const double _indicatorBottom = 40;

class _ImageGallery extends StatelessWidget {
  const _ImageGallery({
    required this.room,
    required this.controller,
    required this.currentPage,
    required this.onPageChanged,
  });

  final Room room;
  final PageController controller;
  final int currentPage;
  final ValueChanged<int> onPageChanged;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 290,
      child: Stack(
        children: <Widget>[
          PageView.builder(
            controller: controller,
            itemCount: room.images.length,
            onPageChanged: onPageChanged,
            itemBuilder: (context, index) {
              return Image.network(
                room.images[index],
                fit: BoxFit.cover,
                width: double.infinity,
                errorBuilder: (_, _, _) {
                  return Container(color: AppColors.placeholder);
                },
              );
            },
          ),
          Positioned(
            top: MediaQuery.of(context).padding.top + 12,
            left: 16,
            right: 16,
            child: Row(
              children: <Widget>[
                _CircleAction(
                  icon: Icons.arrow_back_ios_new_rounded,
                  onTap: () => Navigator.pop(context),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Detail Kamar',
                    style: AppTextStyles.headerTitle.copyWith(fontSize: 14),
                  ),
                ),
                _CircleAction(
                  icon: room.isFavorite
                      ? Icons.favorite_rounded
                      : Icons.favorite_border_rounded,
                  iconColor: room.isFavorite
                      ? AppColors.favorite
                      : AppColors.primary,
                  onTap: () => AppState.instance.toggleFavorite(room.id),
                ),
                const SizedBox(width: 8),
                _CircleAction(
                  icon: Icons.share_outlined,
                  onTap: () => _shareRoom(room),
                ),
              ],
            ),
          ),
          Positioned(
            right: 16,
            bottom: _indicatorBottom,
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 8,
                vertical: 4,
              ),
              decoration: BoxDecoration(
                color: AppColors.textDark.withValues(alpha: 0.7),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '${currentPage + 1}/${room.images.length}',
                style: AppTextStyles.badge.copyWith(color: Colors.white),
              ),
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: _indicatorBottom,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List<Widget>.generate(room.images.length, (index) {
                final active = index == currentPage;

                return AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: active ? 16 : 6,
                  height: 6,
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  decoration: BoxDecoration(
                    color: active
                        ? AppColors.surface
                        : AppColors.surface.withValues(alpha: 0.55),
                    borderRadius: BorderRadius.circular(10),
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}

class _CircleAction extends StatelessWidget {
  const _CircleAction({
    required this.icon,
    required this.onTap,
    this.iconColor = AppColors.primary,
  });

  final IconData icon;
  final VoidCallback onTap;
  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: SizedBox(
          width: 34,
          height: 34,
          child: Icon(
            icon,
            size: 18,
            color: iconColor,
          ),
        ),
      ),
    );
  }
}

class _RoomInformation extends StatelessWidget {
  const _RoomInformation({required this.room});

  final Room room;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 20),
      decoration: const BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              _InfoChip(
                label: room.gender,
                background: AppColors.infoBg,
                foreground: AppColors.primary,
              ),
              const SizedBox(width: 7),
              _InfoChip(
                label: room.available
                    ? 'Tersedia · Sisa 1 kamar'
                    : 'Habis',
                background: room.available
                    ? AppColors.successBg
                    : AppColors.dangerBg,
                foreground: room.available
                    ? AppColors.success
                    : AppColors.danger,
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(room.name, style: AppTextStyles.sectionTitle),
          const SizedBox(height: 2),
          Text(
            '${room.building} - Lantai ${room.floor}',
            style: AppTextStyles.body,
          ),
          const SizedBox(height: 2),
          Text(
            'Gratis (Subsidi Kampus)',
            style: AppTextStyles.cardHeading.copyWith(fontSize: 12),
          ),
          const SizedBox(height: 12),
          _DetailStats(room: room),
          const SizedBox(height: 13),
          Text('Deskripsi Kamar', style: AppTextStyles.cardTitle),
          const SizedBox(height: 5),
          Text(room.description, style: AppTextStyles.body),
          const SizedBox(height: 14),
          Text('Fasilitas', style: AppTextStyles.cardTitle),
          const SizedBox(height: 8),
          _FacilitiesGrid(facilities: room.facilities),
        ],
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({
    required this.label,
    required this.background,
    required this.foreground,
  });

  final String label;
  final Color background;
  final Color foreground;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: AppTextStyles.badge.copyWith(color: foreground),
      ),
    );
  }
}

class _DetailStats extends StatelessWidget {
  const _DetailStats({required this.room});

  final Room room;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 60,
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: <Widget>[
          Expanded(
            child: _DetailStat(
              label: 'Ukuran',
              value: room.size,
            ),
          ),
          const VerticalDivider(
            width: 1,
            indent: 10,
            endIndent: 10,
            color: AppColors.border,
          ),
          Expanded(
            child: _DetailStat(
              label: 'Kapasitas',
              value: '${room.capacity} Orang',
            ),
          ),
          const VerticalDivider(
            width: 1,
            indent: 10,
            endIndent: 10,
            color: AppColors.border,
          ),
          Expanded(
            child: _DetailStat(
              label: 'Tersedia mulai',
              value: room.availableFrom,
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailStat extends StatelessWidget {
  const _DetailStat({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 5),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text(
            label,
            textAlign: TextAlign.center,
            style: AppTextStyles.bodySmall,
          ),
          const SizedBox(height: 3),
          Text(
            value,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.bodySmallBold.copyWith(
              color: AppColors.textTitle,
            ),
          ),
        ],
      ),
    );
  }
}

class _FacilitiesGrid extends StatelessWidget {
  const _FacilitiesGrid({required this.facilities});

  final List<String> facilities;

  IconData _iconFor(String facility) {
    switch (facility) {
      case 'Kasur':
        return Icons.bed_rounded;
      case 'Meja belajar':
        return Icons.table_restaurant_rounded;
      case 'Lemari':
        return Icons.door_sliding_rounded;
      case 'Stop kontak':
        return Icons.power_rounded;
      case 'AC':
        return Icons.ac_unit_rounded;
      case 'WiFi':
        return Icons.wifi_rounded;
      case 'WC dalam':
        return Icons.bathroom_rounded;
      case 'Air panas':
        return Icons.water_drop_outlined;
      default:
        return Icons.check_circle_outline_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      padding: EdgeInsets.zero, // buang padding bawaan GridView (penyebab gap)
      physics: const NeverScrollableScrollPhysics(),
      itemCount: facilities.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
        childAspectRatio: 1.05,
      ),
      itemBuilder: (context, index) {
        final facility = facilities[index];

        return Container(
          decoration: BoxDecoration(
            color: AppColors.infoBg,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Icon(
                _iconFor(facility),
                size: 18,
                color: AppColors.primary,
              ),
              const SizedBox(height: 4),
              Text(
                facility,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.bodySmallBold.copyWith(fontSize: 8),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _BottomBookingBar extends StatelessWidget {
  const _BottomBookingBar({
    required this.available,
    required this.onPressed,
  });

  final bool available;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
        decoration: BoxDecoration(
          color: AppColors.surface,
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: AppColors.textDark.withValues(alpha: 0.08),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: Row(
          children: <Widget>[
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text('Biaya', style: AppTextStyles.bodySmall),
                  Text('Gratis', style: AppTextStyles.priceBig),
                ],
              ),
            ),
            SizedBox(
              height: 46,
              width: 176,
              child: ElevatedButton(
                onPressed: available ? onPressed : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryDark,
                  disabledBackgroundColor: AppColors.placeholder,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  available ? 'Booking Sekarang' : 'Kamar Habis',
                  maxLines: 1,
                  softWrap: false,
                  style: AppTextStyles.button.copyWith(
                    fontSize: 12,
                    color: available ? Colors.white : AppColors.inactive,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}