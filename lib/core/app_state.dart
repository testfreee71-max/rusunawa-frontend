import 'package:flutter/foundation.dart';

import '../data/initial_data.dart';
import '../models/app_notification.dart';
import '../models/booking.dart';
import '../models/room.dart';
import '../models/user_profile.dart';

class AppState extends ChangeNotifier {
  AppState._()
      : user = createInitialUser(),
        rooms = createInitialRooms(),
        notifications = createInitialNotifications();

  static final AppState instance = AppState._();

  // =========================
  // AUTH STATE
  // =========================
  bool isLoggedIn = false;

  // =========================
  // APP DATA
  // =========================
  UserProfile user;
  List<Room> rooms;
  List<Booking> bookings = <Booking>[];
  List<AppNotification> notifications;

  // =========================
  // UI STATE
  // =========================
  int tabIndex = 0;
  String roomQuery = '';

  // =========================
  // GETTERS
  // =========================
  int get unreadCount {
    return notifications.where((item) => !item.isRead).length;
  }

  int get roomsAvailableCount {
    return rooms.where((room) => room.available).length;
  }

  int get roomsOccupiedCount {
    return rooms.where((room) => !room.available).length;
  }

  int get bookingsInProgressCount {
    return bookings
        .where(
          (booking) =>
      booking.status == BookingStatus.waiting ||
          booking.status == BookingStatus.processing,
    )
        .length;
  }

  List<Booking> get activeBookings {
    return bookings
        .where(
          (booking) =>
      booking.status == BookingStatus.waiting ||
          booking.status == BookingStatus.processing ||
          booking.status == BookingStatus.approved,
    )
        .toList();
  }

  List<Booking> get historyBookings {
    return bookings
        .where(
          (booking) =>
      booking.status == BookingStatus.completed ||
          booking.status == BookingStatus.rejected ||
          booking.status == BookingStatus.cancelled,
    )
        .toList();
  }

  // =========================
  // AUTH METHODS
  // =========================

  /// Login menggunakan NIM atau email.
  /// Validasi utama tetap dilakukan di LoginScreen.
  bool login(String identifier, String password) {
    final trimmedIdentifier = identifier.trim();

    if (trimmedIdentifier.isEmpty || password.length < 6) {
      return false;
    }

    // Jika user masih menggunakan data awal/default,
    // simpan identifier yang digunakan untuk login.
    if (user.name == 'Mahasiswa' &&
        user.nim.isEmpty &&
        user.email.isEmpty) {
      final isNumber = RegExp(r'^\d+$').hasMatch(trimmedIdentifier);

      user = user.copyWith(
        nim: isNumber ? trimmedIdentifier : '',
        email: trimmedIdentifier.contains('@') ? trimmedIdentifier : '',
      );
    }

    isLoggedIn = true;
    notifyListeners();

    return true;
  }

  /// Registrasi user baru dan langsung masuk ke aplikasi.
  void register(
      String nim,
      String name,
      String email,
      String studyProgram,
      String password,
      ) {
    user = UserProfile(
      nim: nim.trim(),
      name: name.trim(),
      email: email.trim(),
      phone: '',
      studyProgram: studyProgram,
      birthDate: null,
      gender: '',
      address: '',
    );

    isLoggedIn = true;
    notifyListeners();
  }

  /// Logout dan reset state aplikasi.
  void logout() {
    isLoggedIn = false;

    // Reset UI state.
    tabIndex = 0;
    roomQuery = '';

    // Reset data ke data awal.
    user = createInitialUser();
    rooms = createInitialRooms();
    bookings = <Booking>[];
    notifications = createInitialNotifications();

    notifyListeners();
  }

  // =========================
  // USER METHODS
  // =========================

  void updateUser(UserProfile updatedUser) {
    user = updatedUser;
    notifyListeners();
  }

  // =========================
  // NAVIGATION & SEARCH
  // =========================

  void setTab(int index, {String? query}) {
    tabIndex = index;

    if (query != null) {
      roomQuery = query;
    }

    notifyListeners();
  }

  // =========================
  // ROOM METHODS
  // =========================

  void toggleFavorite(String roomId) {
    rooms = rooms
        .map(
          (room) => room.id == roomId
          ? room.copyWith(isFavorite: !room.isFavorite)
          : room,
    )
        .toList();

    notifyListeners();
  }

  // =========================
  // NOTIFICATION METHODS
  // =========================

  void markNotificationRead(String id) {
    notifications = notifications
        .map(
          (item) => item.id == id
          ? item.copyWith(isRead: true)
          : item,
    )
        .toList();

    notifyListeners();
  }

  void markAllNotificationsRead() {
    notifications = notifications
        .map(
          (item) => item.copyWith(isRead: true),
    )
        .toList();

    notifyListeners();
  }

  // =========================
  // BOOKING METHODS
  // =========================

  Booking submitBooking({
    required Room room,
    required DateTime startDate,
    required DateTime endDate,
    required String purpose,
    required String note,
  }) {
    final booking = Booking(
      id: 'SRN-${(bookings.length + 1).toString().padLeft(3, '0')}',
      room: room,
      status: BookingStatus.waiting,
      submittedAt: DateTime.now(),
      startDate: startDate,
      endDate: endDate,
      purpose: purpose,
      note: note,
    );

    bookings = <Booking>[
      booking,
      ...bookings,
    ];

    // Untuk sementara, kamar dianggap tidak tersedia
    // setelah booking dikirim.
    rooms = rooms
        .map(
          (item) => item.id == room.id
          ? item.copyWith(available: false)
          : item,
    )
        .toList();

    notifyListeners();

    return booking;
  }

  void cancelBooking(String id) {
    final bookingIndex = bookings.indexWhere(
          (item) => item.id == id,
    );

    // Hanya booking dengan status waiting yang dapat dibatalkan.
    if (bookingIndex == -1 ||
        bookings[bookingIndex].status != BookingStatus.waiting) {
      return;
    }

    final cancelledBooking = bookings[bookingIndex].copyWith(
      status: BookingStatus.cancelled,
    );

    bookings = bookings
        .map(
          (item) => item.id == id ? cancelledBooking : item,
    )
        .toList();

    // Kamar tersedia kembali setelah booking dibatalkan.
    rooms = rooms
        .map(
          (room) => room.id == cancelledBooking.room.id
          ? room.copyWith(available: true)
          : room,
    )
        .toList();

    notifyListeners();
  }
}