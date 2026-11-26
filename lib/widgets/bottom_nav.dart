import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../core/app_colors.dart';
import '../core/app_state.dart';
import '../core/app_text_styles.dart';

/// Navbar rata di dasar layar. Tab aktif ditandai garis biru tipis
/// di tepi atas, ikon terisi, dan label biru tebal.
/// Ikon digambar sendiri (tanpa package) supaya bentuknya rapi dan konsisten.
class BottomNav extends StatelessWidget {
  const BottomNav({super.key});

  static const _items = <_NavItem>[
    _NavItem('Beranda', NavIconType.home),
    _NavItem('Cari Kamar', NavIconType.search),
    _NavItem('Booking Saya', NavIconType.calendar),
    _NavItem('Profil', NavIconType.user),
  ];

  // Tinggi isi bar (di luar area gesture sistem).
  static const double _contentHeight = 62;

  @override
  Widget build(BuildContext context) {
    final state = AppState.instance;
    // Area gesture/navigasi sistem di bawah layar. Bar putih ikut menutupinya.
    final bottomInset = MediaQuery.of(context).padding.bottom;

    // const BottomNav tidak ikut dibangun ulang oleh induknya,
    // jadi ia harus mendengarkan AppState sendiri.
    return ListenableBuilder(
      listenable: state,
      builder: (context, _) => _buildBar(state, bottomInset),
    );
  }

  Widget _buildBar(AppState state, double bottomInset) {
    return Container(
      padding: EdgeInsets.only(bottom: bottomInset),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border(
          top: BorderSide(
            color: AppColors.border.withValues(alpha: 0.8),
          ),
        ),
      ),
      child: SizedBox(
        height: _contentHeight,
        child: Row(
          children: List<Widget>.generate(_items.length, (index) {
            return Expanded(
              child: _NavButton(
                item: _items[index],
                active: state.tabIndex == index,
                onTap: () {
                  if (state.tabIndex != index) {
                    HapticFeedback.selectionClick();
                    state.setTab(index);
                  }
                },
              ),
            );
          }),
        ),
      ),
    );
  }
}

class _NavButton extends StatelessWidget {
  const _NavButton({
    required this.item,
    required this.active,
    required this.onTap,
  });

  final _NavItem item;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: active,
      label: item.label,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Stack(
          alignment: Alignment.center,
          children: <Widget>[
            // Garis penanda di tepi atas tab aktif.
            Align(
              alignment: Alignment.topCenter,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 220),
                curve: Curves.easeOutCubic,
                width: active ? 34 : 0,
                height: 3,
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.vertical(
                    bottom: Radius.circular(4),
                  ),
                ),
              ),
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                AnimatedScale(
                  duration: const Duration(milliseconds: 220),
                  curve: Curves.easeOutBack,
                  scale: active ? 1.08 : 1.0,
                  child: NavIcon(
                    type: item.icon,
                    active: active,
                    size: 26,
                    color: active ? AppColors.primary : AppColors.inactive,
                    cutColor: AppColors.surface,
                  ),
                ),
                const SizedBox(height: 3),
                AnimatedDefaultTextStyle(
                  duration: const Duration(milliseconds: 220),
                  style: AppTextStyles.navLabel(active: active),
                  child: Text(
                    item.label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
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

class _NavItem {
  const _NavItem(this.label, this.icon);

  final String label;
  final NavIconType icon;
}

// ===================== IKON KUSTOM =====================

enum NavIconType { home, search, calendar, user }

/// Ikon navbar: garis tipis bersudut bulat saat biasa, terisi saat aktif.
class NavIcon extends StatelessWidget {
  const NavIcon({
    super.key,
    required this.type,
    required this.active,
    required this.color,
    required this.cutColor,
    this.size = 26,
  });

  final NavIconType type;
  final bool active;
  final Color color;

  /// Warna latar di belakang ikon (untuk celah pada ikon yang terisi).
  final Color cutColor;
  final double size;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size.square(size),
      painter: _NavIconPainter(
        type: type,
        active: active,
        color: color,
        cutColor: cutColor,
      ),
    );
  }
}

class _NavIconPainter extends CustomPainter {
  const _NavIconPainter({
    required this.type,
    required this.active,
    required this.color,
    required this.cutColor,
  });

  final NavIconType type;
  final bool active;
  final Color color;
  final Color cutColor;

  @override
  void paint(Canvas canvas, Size size) {
    // Semua gambar dibuat pada kanvas 24x24 lalu diskalakan.
    canvas.scale(size.width / 24, size.height / 24);

    switch (type) {
      case NavIconType.home:
        _home(canvas);
      case NavIconType.search:
        _search(canvas);
      case NavIconType.calendar:
        _calendar(canvas);
      case NavIconType.user:
        _user(canvas);
    }
  }

  Paint get _stroke => Paint()
    ..color = color
    ..style = PaintingStyle.stroke
    ..strokeWidth = 1.8
    ..strokeCap = StrokeCap.round
    ..strokeJoin = StrokeJoin.round;

  Paint get _fill => Paint()
    ..color = color
    ..style = PaintingStyle.fill;

  // Garis tepi tipis pada bentuk terisi supaya sudutnya membulat.
  Paint get _fillEdge => Paint()
    ..color = color
    ..style = PaintingStyle.stroke
    ..strokeWidth = 1.2
    ..strokeJoin = StrokeJoin.round;

  void _home(Canvas canvas) {
    final path = Path()
      ..moveTo(4, 10.5)
      ..lineTo(12, 4)
      ..lineTo(20, 10.5)
      ..lineTo(20, 19)
      ..arcToPoint(const Offset(18.5, 20.5), radius: const Radius.circular(1.5))
      ..lineTo(15, 20.5)
      ..lineTo(15, 15)
      ..lineTo(9, 15)
      ..lineTo(9, 20.5)
      ..lineTo(5.5, 20.5)
      ..arcToPoint(const Offset(4, 19), radius: const Radius.circular(1.5))
      ..close();

    if (active) {
      canvas.drawPath(path, _fill);
      canvas.drawPath(path, _fillEdge);
    } else {
      canvas.drawPath(path, _stroke);
    }
  }

  void _search(Canvas canvas) {
    const center = Offset(11, 11);

    if (active) {
      canvas.drawCircle(
        center,
        6.5,
        Paint()..color = color.withValues(alpha: 0.22),
      );
    }

    final stroke = _stroke..strokeWidth = active ? 2.4 : 1.8;
    canvas.drawCircle(center, 6.5, stroke);
    canvas.drawLine(
      const Offset(16, 16),
      const Offset(20.5, 20.5),
      stroke..strokeWidth = active ? 2.6 : 1.8,
    );
  }

  void _calendar(Canvas canvas) {
    final body = RRect.fromRectAndRadius(
      const Rect.fromLTWH(4, 5.5, 16, 14.5),
      const Radius.circular(3.2),
    );

    if (active) {
      canvas.drawRRect(body, _fill);
      canvas.drawRRect(body, _fillEdge);
      // garis header dan titik memakai warna latar (tampak "berlubang")
      canvas.drawLine(
        const Offset(4, 10),
        const Offset(20, 10),
        Paint()
          ..color = cutColor
          ..strokeWidth = 1.8
          ..strokeCap = StrokeCap.round,
      );
      final dot = Paint()..color = cutColor;
      for (final dx in <double>[9, 12, 15]) {
        canvas.drawCircle(Offset(dx, 14.5), 1.1, dot);
      }
    } else {
      canvas.drawRRect(body, _stroke);
      canvas.drawLine(const Offset(4, 10), const Offset(20, 10), _stroke);
      final dot = _fill;
      for (final dx in <double>[9, 12, 15]) {
        canvas.drawCircle(Offset(dx, 14.5), 1, dot);
      }
    }

    // dua penjepit kalender di atas
    final tick = _stroke;
    canvas.drawLine(const Offset(8.5, 3.5), const Offset(8.5, 7), tick);
    canvas.drawLine(const Offset(15.5, 3.5), const Offset(15.5, 7), tick);
  }

  void _user(Canvas canvas) {
    const head = Offset(12, 8.5);

    if (active) {
      canvas.drawCircle(head, 3.8, _fill);
      canvas.drawCircle(head, 3.8, _fillEdge);

      final body = Path()
        ..moveTo(4.3, 20.2)
        ..cubicTo(4.8, 16.4, 7.8, 14, 12, 14)
        ..cubicTo(16.2, 14, 19.2, 16.4, 19.7, 20.2)
        ..cubicTo(19.8, 20.8, 19.3, 21.3, 18.7, 21.3)
        ..lineTo(5.3, 21.3)
        ..cubicTo(4.7, 21.3, 4.2, 20.8, 4.3, 20.2)
        ..close();
      canvas.drawPath(body, _fill);
      canvas.drawPath(body, _fillEdge);
    } else {
      canvas.drawCircle(head, 3.8, _stroke);

      final body = Path()
        ..moveTo(4.5, 20)
        ..cubicTo(5.1, 16.2, 8.2, 14, 12, 14)
        ..cubicTo(15.8, 14, 18.9, 16.2, 19.5, 20);
      canvas.drawPath(body, _stroke);
    }
  }

  @override
  bool shouldRepaint(covariant _NavIconPainter oldDelegate) {
    return oldDelegate.type != type ||
        oldDelegate.active != active ||
        oldDelegate.color != color ||
        oldDelegate.cutColor != cutColor;
  }
}