import 'room.dart';

enum BookingStatus {
  waiting,
  processing,
  approved,
  completed,
  rejected,
  cancelled,
}

extension BookingStatusExtension on BookingStatus {
  String get label {
    switch (this) {
      case BookingStatus.waiting:
        return 'Menunggu Persetujuan';
      case BookingStatus.processing:
        return 'Sedang Diproses';
      case BookingStatus.approved:
        return 'Disetujui';
      case BookingStatus.completed:
        return 'Selesai';
      case BookingStatus.rejected:
        return 'Ditolak';
      case BookingStatus.cancelled:
        return 'Dibatalkan';
    }
  }
}

class Booking {
  const Booking({
    required this.id,
    required this.room,
    required this.status,
    required this.submittedAt,
    required this.startDate,
    required this.endDate,
    required this.purpose,
    required this.note,
  });

  final String id;
  final Room room;
  final BookingStatus status;
  final DateTime submittedAt;
  final DateTime startDate;
  final DateTime endDate;
  final String purpose;
  final String note;

  int get durationMonths {
    final months =
        (endDate.year - startDate.year) * 12 + endDate.month - startDate.month;
    return months <= 0 ? 1 : months;
  }

  Booking copyWith({
    String? id,
    Room? room,
    BookingStatus? status,
    DateTime? submittedAt,
    DateTime? startDate,
    DateTime? endDate,
    String? purpose,
    String? note,
  }) {
    return Booking(
      id: id ?? this.id,
      room: room ?? this.room,
      status: status ?? this.status,
      submittedAt: submittedAt ?? this.submittedAt,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      purpose: purpose ?? this.purpose,
      note: note ?? this.note,
    );
  }
}