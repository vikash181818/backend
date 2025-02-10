class CityModel {
  final String id;
  final String city;
  final int isActive;
  final String createdDate;
  final String lastUpdatedDate;
  final String stateId;
  final int createdById;
  final int lastUpdatedById;

  CityModel({
    required this.id,
    required this.city,
    required this.isActive,
    required this.createdDate,
    required this.lastUpdatedDate,
    required this.stateId,
    required this.createdById,
    required this.lastUpdatedById,
  });

  factory CityModel.fromJson(Map<String, dynamic> json) {
    return CityModel(
      id: json['id'] as String,
      city: json['city'] as String,
      isActive: json['is_active'] ?? 1, // Default to 1 if missing
      createdDate: json['created_date'] ?? '', // Default empty if missing
      lastUpdatedDate: json['last_updated_date'] ?? '', // Default empty if missing
      stateId: json['stateId'] as String,
      createdById: int.tryParse(json['createdById'].toString()) ?? 0, // Safely parse int
      lastUpdatedById: int.tryParse(json['lastUpdatedById'].toString()) ?? 0, // Safely parse int
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'city': city,
      'is_active': isActive,
      'created_date': createdDate,
      'last_updated_date': lastUpdatedDate,
      'stateId': stateId,
      'createdById': createdById,
      'lastUpdatedById': lastUpdatedById,
    };
  }
}



