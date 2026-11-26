import 'package:flutter/foundation.dart';

import '../data/initial_data.dart';
import '../services/api_service.dart';
import '../services/token_storage.dart';
import '../repositories/auth_repository.dart';
import '../repositories/room_repository.dart';
import '../viewmodels/room_view_model.dart';
import '../viewmodels/auth_view_model.dart';
import '../models/app_notification.dart';
import '../models/booking.dart';
import '../models/room.dart';
import '../models/user_profile.dart';

class AppState extends ChangeNotifier {
  AppState._()
      : user = createInitialUser(),
        notifications = createInitialNotifications();

  static final AppState instance = AppState._();

  // =========================
  // AUTH STATE
  // =========================
  bool isLoggedIn = false;
  bool authBusy = false;
  bool restoring = true;
  final api = ApiService(TokenStorage());
  late final auth = AuthViewModel(AuthRepository(api));
  String? get authError => auth.error;

  Future<void> restoreSession() async {
    try {
      final profile = await auth.restore();
      if (profile != null) { user = profile; isLoggedIn = true; await refreshRooms(); }
    } finally { restoring = false; notifyListeners(); }
  }


  // =========================
  // APP DATA
  // =========================
  UserProfile user;
  late final roomViewModel = RoomViewModel(RoomRepository(api));
  List<Room> get rooms => roomViewModel.rooms;
  set rooms(List<Room> value) => roomViewModel.rooms = value;
  bool get roomsLoading => roomViewModel.loading;
  String? get roomsError => roomViewModel.error;
  Future<void> refreshRooms() async {
    final pending = roomViewModel.load();
    notifyListeners();
    await pending;
    notifyListeners();
  }
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

  Future<bool> _authenticate(Future<Map<String, dynamic>> Function() action) async {
    if (authBusy) return false;
    authBusy = true;
    notifyListeners();
    try {
      final profile = await auth.authenticate(action);
      if (profile == null) return false;
      user = profile;
      isLoggedIn = true;
      await refreshRooms();
      return true;
    } finally { authBusy = false; notifyListeners(); }
  }

  Future<bool> login(String identifier, String password) =>
      _authenticate(() => auth.repository.login(identifier.trim(), password));

  Future<bool> register(String nim, String name, String email, String studyProgram, String password) =>
      _authenticate(() => auth.repository.register({
        'nim': nim, 'name': name, 'email': email, 'study_program': studyProgram,
        'password': password, 'password_confirmation': password,
      }));

  Future<void> logout() async {
    try { await auth.repository.logout(); }
    catch (_) { /* local token is cleared by repository finally */ }
    isLoggedIn = false;
    tabIndex = 0;
    roomQuery = '';
    user = createInitialUser();
    roomViewModel.reset();
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