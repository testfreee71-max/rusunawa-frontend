class Room {
  const Room({
    required this.id,
    required this.name,
    required this.building,
    required this.floor,
    required this.images,
    required this.gender,
    required this.capacity,
    required this.size,
    required this.availableFrom,
    required this.description,
    required this.facilities,
    required this.available,
    required this.isFavorite,
  });

  factory Room.fromJson(Map<String, dynamic> json) {
    List<String> strings(Object? value) => value is List ? value.map((e) => e.toString()).toList() : <String>[];
    final images = strings(json['images']);
    return Room(
      id: json['id'].toString(), name: json['name']?.toString() ?? '',
      building: json['building']?.toString() ?? '', floor: (json['floor'] as num?)?.toInt() ?? 0,
      images: images.isEmpty ? <String>[''] : images, gender: json['gender']?.toString() ?? '',
      capacity: (json['capacity'] as num?)?.toInt() ?? 0, size: json['size']?.toString() ?? '',
      availableFrom: json['available_from']?.toString() ?? '', description: json['description']?.toString() ?? '',
      facilities: strings(json['facilities']), available: json['available'] == true || json['available'] == 1,
      isFavorite: json['is_favorite'] == true || json['is_favorite'] == 1,
    );
  }

  final String id;
  final String name;
  final String building;
  final int floor;
  final List<String> images;
  final String gender;
  final int capacity;
  final String size;
  final String availableFrom;
  final String description;
  final List<String> facilities;
  final bool available;
  final bool isFavorite;

  Room copyWith({
    String? id,
    String? name,
    String? building,
    int? floor,
    List<String>? images,
    String? gender,
    int? capacity,
    String? size,
    String? availableFrom,
    String? description,
    List<String>? facilities,
    bool? available,
    bool? isFavorite,
  }) {
    return Room(
      id: id ?? this.id,
      name: name ?? this.name,
      building: building ?? this.building,
      floor: floor ?? this.floor,
      images: images ?? this.images,
      gender: gender ?? this.gender,
      capacity: capacity ?? this.capacity,
      size: size ?? this.size,
      availableFrom: availableFrom ?? this.availableFrom,
      description: description ?? this.description,
      facilities: facilities ?? this.facilities,
      available: available ?? this.available,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }
}