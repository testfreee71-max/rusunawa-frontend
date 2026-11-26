import '../models/app_notification.dart';
import '../models/room.dart';
import '../models/user_profile.dart';

const _facilities = <String>[
  'Kasur',
  'Meja belajar',
  'Lemari',
  'Stop kontak',
  'AC',
  'WiFi',
  'WC dalam',
  'Air panas',
];

List<Room> createInitialRooms() {
  const urls = <String>[
    'https://images.unsplash.com/photo-1522708323590-d24dbb6b0267?w=800',
    'https://images.unsplash.com/photo-1505693416388-ac5ce068fe85?w=800',
    'https://images.unsplash.com/photo-1616486338812-3dadae4b4ace?w=800',
    'https://images.unsplash.com/photo-1540518614846-7eded433c457?w=800',
    'https://images.unsplash.com/photo-1590490360182-c33d57733427?w=800',
  ];

  return <Room>[
    Room(
      id: 'A101',
      name: 'Kamar Putra A101',
      building: 'Gedung A',
      floor: 1,
      images: <String>[urls[0], urls[1], urls[2]],
      gender: 'Putra',
      capacity: 2,
      size: '3 x 3 m',
      availableFrom: '1 Jan 2027',
      description: 'Kamar nyaman untuk mahasiswa dengan fasilitas lengkap.',
      facilities: _facilities,
      available: true,
      isFavorite: false,
    ),
    Room(
      id: 'A102',
      name: 'Kamar Putra A102',
      building: 'Gedung A',
      floor: 1,
      images: <String>[urls[1], urls[2], urls[3]],
      gender: 'Putra',
      capacity: 2,
      size: '3 x 4 m',
      availableFrom: '1 Jan 2027',
      description: 'Hunian kampus yang nyaman dan dekat dengan fasilitas.',
      facilities: _facilities,
      available: true,
      isFavorite: false,
    ),
    Room(
      id: 'B201',
      name: 'Kamar Putri B201',
      building: 'Gedung B',
      floor: 2,
      images: <String>[urls[2], urls[3], urls[4]],
      gender: 'Putri',
      capacity: 2,
      size: '3 x 3 m',
      availableFrom: '1 Feb 2027',
      description: 'Kamar bersih dan nyaman untuk menunjang aktivitas kuliah.',
      facilities: _facilities,
      available: true,
      isFavorite: false,
    ),
    Room(
      id: 'C103',
      name: 'Kamar Putri C103',
      building: 'Gedung C',
      floor: 1,
      images: <String>[urls[3], urls[4], urls[0]],
      gender: 'Putri',
      capacity: 1,
      size: '3 x 3 m',
      availableFrom: '1 Jan 2027',
      description: 'Kamar privat dengan suasana tenang dan fasilitas lengkap.',
      facilities: _facilities,
      available: true,
      isFavorite: false,
    ),
    Room(
      id: 'D14',
      name: 'Kamar Putra D14',
      building: 'Gedung D',
      floor: 1,
      images: <String>[urls[4], urls[0], urls[1]],
      gender: 'Putra',
      capacity: 1,
      size: '3 x 3 m',
      availableFrom: '1 Jan 2027',
      description: 'Kamar nyaman dengan akses mudah ke area kampus.',
      facilities: _facilities,
      available: false,
      isFavorite: false,
    ),
    Room(
      id: 'D202',
      name: 'Kamar Putri D202',
      building: 'Gedung D',
      floor: 2,
      images: <String>[urls[0], urls[2], urls[4]],
      gender: 'Putri',
      capacity: 2,
      size: '3 x 4 m',
      availableFrom: '1 Mar 2027',
      description: 'Hunian mahasiswa dengan lingkungan yang aman dan nyaman.',
      facilities: _facilities,
      available: false,
      isFavorite: false,
    ),
  ];
}

List<AppNotification> createInitialNotifications() {
  return const <AppNotification>[
    AppNotification(
      id: 'N001',
      title: 'Pengajuan Disetujui',
      message: 'Pengajuan kamar Anda telah disetujui.',
      type: NotificationType.approved,
      time: '2 jam lalu',
      isRead: false,
    ),
    AppNotification(
      id: 'N002',
      title: 'Dokumen Diterima',
      message: 'Berkas yang Anda unggah telah diterima.',
      type: NotificationType.document,
      time: '1 hari lalu',
      isRead: false,
    ),
    AppNotification(
      id: 'N003',
      title: 'Pengajuan Diproses',
      message: 'Pengajuan kamar Anda sedang diproses.',
      type: NotificationType.processing,
      time: '2 hari lalu',
      isRead: false,
    ),
    AppNotification(
      id: 'N004',
      title: 'Pengajuan Diproses',
      message: 'Pengajuan kamar Anda sedang diproses.',
      type: NotificationType.processing,
      time: '2 hari lalu',
      isRead: true,
    ),
    AppNotification(
      id: 'N005',
      title: 'Pengajuan Diproses',
      message: 'Pengajuan kamar Anda sedang diproses.',
      type: NotificationType.processing,
      time: '2 hari lalu',
      isRead: true,
    ),
  ];
}

UserProfile createInitialUser() {
  return const UserProfile(
    nim: '',
    name: 'Mahasiswa',
    email: '',
    phone: '',
    studyProgram: '',
    birthDate: null,
    gender: '',
    address: '',
  );
}