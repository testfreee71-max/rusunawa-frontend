class UserProfile {
  const UserProfile({
    required this.nim,
    required this.name,
    required this.email,
    required this.phone,
    required this.studyProgram,
    required this.birthDate,
    required this.gender,
    required this.address,
  });

  final String nim;
  final String name;
  final String email;
  final String phone;
  final String studyProgram;
  final DateTime? birthDate;
  final String gender;
  final String address;

  String get initial {
    final trimmed = name.trim();
    return trimmed.isEmpty ? 'M' : trimmed.substring(0, 1).toUpperCase();
  }

  String get firstName {
    final trimmed = name.trim();
    if (trimmed.isEmpty) {
      return 'Mahasiswa';
    }
    return trimmed.split(RegExp(r'\s+')).first;
  }

  UserProfile copyWith({
    String? nim,
    String? name,
    String? email,
    String? phone,
    String? studyProgram,
    DateTime? birthDate,
    String? gender,
    String? address,
  }) {
    return UserProfile(
      nim: nim ?? this.nim,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      studyProgram: studyProgram ?? this.studyProgram,
      birthDate: birthDate ?? this.birthDate,
      gender: gender ?? this.gender,
      address: address ?? this.address,
    );
  }
}