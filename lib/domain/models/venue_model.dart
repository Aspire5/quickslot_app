class VenueModel {
  final String id;
  final String name;
  final String? location;

  const VenueModel({
    required this.id,
    required this.name,
    this.location,
  });

  factory VenueModel.fromJson(Map<String, dynamic> json) {
    return VenueModel(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      location: json['location'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'location': location,
    };
  }
}
