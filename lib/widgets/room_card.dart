import 'package:flutter/material.dart';

import '../core/app_colors.dart';
import '../core/app_state.dart';
import '../core/app_text_styles.dart';
import '../models/room.dart';

enum RoomCardType {
  vertical,
  horizontal,
}

class RoomCard extends StatelessWidget {
  const RoomCard({
    super.key,
    required this.room,
    this.type = RoomCardType.vertical,
    this.onTap,
  });

  final Room room;
  final RoomCardType type;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return type == RoomCardType.horizontal
        ? _HorizontalRoomCard(
      room: room,
      onTap: onTap,
    )
        : _VerticalRoomCard(
      room: room,
      onTap: onTap,
    );
  }
}

class _VerticalRoomCard extends StatelessWidget {
  const _VerticalRoomCard({
    required this.room,
    this.onTap,
  });

  final Room room;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 156,
      height: 182,
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: onTap,
          child: Ink(
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(14),
              boxShadow: <BoxShadow>[
                BoxShadow(
                  color: AppColors.textDark.withValues(alpha: 0.08),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(14),
                  ),
                  child: SizedBox(
                    height: 84,
                    width: double.infinity,
                    child: Stack(
                      children: <Widget>[
                        Positioned.fill(
                          child: _RoomImage(
                            imageUrl: room.images.first,
                          ),
                        ),
                        Positioned(
                          top: 6,
                          right: 6,
                          child: _FavoriteButton(
                            room: room,
                            size: 26,
                            iconSize: 15,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(10, 7, 8, 7),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          room.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.cardTitle,
                        ),
                        const SizedBox(height: 3),
                        _RoomInfoRow(room: room),
                        const SizedBox(height: 3),
                        const _PriceText(),
                        const Spacer(),
                        Row(
                          children: <Widget>[
                            _AvailabilityBadge(available: room.available),
                            const Spacer(),
                            const Icon(
                              Icons.chevron_right_rounded,
                              size: 20,
                              color: AppColors.primary,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _HorizontalRoomCard extends StatelessWidget {
  const _HorizontalRoomCard({
    required this.room,
    this.onTap,
  });

  final Room room;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 108,
      width: double.infinity,
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: onTap,
          child: Ink(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(14),
              boxShadow: <BoxShadow>[
                BoxShadow(
                  color: AppColors.textDark.withValues(alpha: 0.06),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: <Widget>[
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: SizedBox(
                    width: 96,
                    height: 88,
                    child: _RoomImage(
                      imageUrl: room.images.first,
                    ),
                  ),
                ),
                const SizedBox(width: 11),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Row(
                        children: <Widget>[
                          Expanded(
                            child: Text(
                              room.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppTextStyles.cardTitle,
                            ),
                          ),
                          _FavoriteButton(
                            room: room,
                            size: 24,
                            iconSize: 16,
                            showBackground: false,
                          ),
                        ],
                      ),
                      const SizedBox(height: 3),
                      _RoomInfoRow(room: room),
                      const SizedBox(height: 4),
                      const _PriceText(),
                      const Spacer(),
                      Row(
                        children: <Widget>[
                          _AvailabilityBadge(available: room.available),
                          const Spacer(),
                          const Icon(
                            Icons.chevron_right_rounded,
                            size: 21,
                            color: AppColors.primary,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PriceText extends StatelessWidget {
  const _PriceText();

  @override
  Widget build(BuildContext context) {
    return Text.rich(
      TextSpan(
        children: <InlineSpan>[
          TextSpan(text: 'Gratis', style: AppTextStyles.bodySmallBold),
          TextSpan(
            text: ' (Subsidi Kampus)',
            style: AppTextStyles.bodySmall,
          ),
        ],
      ),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }
}

class _RoomImage extends StatelessWidget {
  const _RoomImage({required this.imageUrl});

  final String imageUrl;

  @override
  Widget build(BuildContext context) {
    return Image.network(
      imageUrl,
      fit: BoxFit.cover,
      loadingBuilder: (context, child, progress) {
        if (progress == null) {
          return child;
        }

        return Container(
          color: AppColors.placeholder,
          alignment: Alignment.center,
          child: const SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: AppColors.primary,
            ),
          ),
        );
      },
      errorBuilder: (_, _, _) {
        return Container(
          color: AppColors.placeholder,
          alignment: Alignment.center,
          child: const Icon(
            Icons.image_not_supported_outlined,
            color: AppColors.inactive,
          ),
        );
      },
    );
  }
}

class _FavoriteButton extends StatelessWidget {
  const _FavoriteButton({
    required this.room,
    required this.size,
    required this.iconSize,
    this.showBackground = true,
  });

  final Room room;
  final double size;
  final double iconSize;
  final bool showBackground;

  @override
  Widget build(BuildContext context) {
    final state = AppState.instance;

    return ListenableBuilder(
      listenable: state,
      builder: (context, _) {
        final isFavorite = state.rooms.any(
              (item) => item.id == room.id && item.isFavorite,
        );

        final icon = Icon(
          isFavorite
              ? Icons.favorite_rounded
              : Icons.favorite_border_rounded,
          size: iconSize,
          color: isFavorite
              ? AppColors.favorite
              : AppColors.favoriteOff,
        );

        return Material(
          color: showBackground
              ? AppColors.surface
              : Colors.transparent,
          shape: const CircleBorder(),
          child: InkWell(
            customBorder: const CircleBorder(),
            onTap: state.favoriteBusy ||
                state.roomsLoading ||
                !state.isLoggedIn
                ? null
                : () async {
              final success =
              await state.toggleFavorite(room.id);

              if (!context.mounted) return;

              if (!success) {
                ScaffoldMessenger.of(context)
                    .showSnackBar(
                  SnackBar(
                    content: Text(
                      state.favoriteError ??
                          'Gagal mengubah favorit.',
                    ),
                  ),
                );
              }
            },
            child: SizedBox(
              width: size,
              height: size,
              child: Center(child: icon),
            ),
          ),
        );
      },
    );
  }
}

class _RoomInfoRow extends StatelessWidget {
  const _RoomInfoRow({required this.room});

  final Room room;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        const Icon(
          Icons.person_outline_rounded,
          size: 12,
          color: AppColors.textMuted,
        ),
        const SizedBox(width: 2),
        Text('${room.capacity} orang', style: AppTextStyles.bodySmall),
        const SizedBox(width: 5),
        const Icon(
          Icons.ac_unit_rounded,
          size: 10,
          color: AppColors.textMuted,
        ),
        const SizedBox(width: 2),
        Text('AC', style: AppTextStyles.bodySmall),
        const SizedBox(width: 5),
        const Icon(
          Icons.wifi_rounded,
          size: 11,
          color: AppColors.textMuted,
        ),
        const SizedBox(width: 2),
        Text('WiFi', style: AppTextStyles.bodySmall),
      ],
    );
  }
}

class _AvailabilityBadge extends StatelessWidget {
  const _AvailabilityBadge({required this.available});

  final bool available;

  @override
  Widget build(BuildContext context) {
    final background = available ? AppColors.successBg : AppColors.dangerBg;
    final foreground = available ? AppColors.success : AppColors.danger;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(
            available
                ? Icons.check_circle_rounded
                : Icons.cancel_rounded,
            size: 10,
            color: foreground,
          ),
          const SizedBox(width: 3),
          Text(
            available ? 'Tersedia' : 'Habis',
            style: AppTextStyles.badge.copyWith(color: foreground),
          ),
        ],
      ),
    );
  }
}