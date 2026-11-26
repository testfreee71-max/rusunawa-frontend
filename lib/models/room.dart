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