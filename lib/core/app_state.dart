import 'package:flutter/foundation.dart';

import '../data/initial_data.dart';
import '../services/api_service.dart';
import '../services/token_storage.dart';
import '../repositories/auth_repository.dart';
import '../repositories/room_repository.dart';
import '../repositories/booking_repository.dart';
import '../viewmodels/booking_view_model.dart';
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
      if (profile != null) { user = profile; isLoggedIn = true; await Future.wait([refreshRooms(), refreshBookings()]); }
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
  late final bookingViewModel = BookingViewModel(BookingRepository(api));
  List<Booking> get bookings => bookingViewModel.bookings;
  Future<void> refreshBookings() async {
    final pending = bookingViewModel.load();
    notifyListeners();
    await pending;
    notifyListeners();
  }
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
      await Future.wait([refreshRooms(), refreshBookings()]);
      return true;
    } finally { authBusy = false; notifyListeners(); }
  }

  Future<bool> login(
      String identifier,
      String password, {
        bool rememberMe = true,
      }) =>
      _authenticate(
            () => auth.repository.login(
          identifier.trim(),
          password,
          rememberMe: rememberMe,
        ),
      );

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
    bookingViewModel.reset();
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

  Future<Booking> submitBooking({
    required Room room,
    required DateTime startDate,
    required DateTime endDate,
    required String purpose,
    required String note,
  }) async {
    String date(DateTime d) => '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
    final booking = await bookingViewModel.create({
      'room_id': room.id, 'start_date': date(startDate), 'end_date': date(endDate),
      'purpose': purpose, 'note': note,
    });
    notifyListeners();
    return booking;
  }

  Future<void> cancelBooking(String id) async {
    await bookingViewModel.cancel(id);
    notifyListeners();
  }
}
