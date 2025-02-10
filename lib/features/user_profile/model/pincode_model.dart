// pincode_model.dart
class PincodeModel {
  final String? id;              // Firestore doc ID (or null if not yet created)
  final int pincode;
  final String postOffice;       // post_office
  final int isActive;
  final String createdDate;
  final String lastUpdatedDate;
  final String cityId;
  final int createdById;
  final int lastUpdatedById;

  PincodeModel({
    this.id,
    required this.pincode,
    required this.postOffice,
    required this.isActive,
    required this.createdDate,
    required this.lastUpdatedDate,
    required this.cityId,
    required this.createdById,
    required this.lastUpdatedById,
  });

  // Helper method to parse integers safely
  static int _parseInt(dynamic value) {
    if (value is int) {
      return value;
    } else if (value is String) {
      return int.tryParse(value) ?? 0; // Default to 0 if parsing fails
    } else {
      return 0; // Default to 0 for any other type
    }
  }

  // From JSON (e.g., from API)
  factory PincodeModel.fromJson(Map<String, dynamic> json) {
    print('PincodeModel.fromJson: $json'); // Debug statement

    return PincodeModel(
      id: json['id'] != null ? json['id'].toString() : "null",
      pincode: _parseInt(json['pincode']),
      postOffice: json['post_office'] as String,
      isActive: _parseInt(json['is_active']),
      createdDate: json['created_date'] as String,
      lastUpdatedDate: json['last_updated_date'] as String,
      cityId: json['cityId'] != null ? json['cityId'].toString() : '',
      createdById: _parseInt(json['createdById']),
      lastUpdatedById: _parseInt(json['lastUpdatedById']),
    );
  }

  // To JSON (e.g., for POST/PUT)
  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'pincode': pincode,
      'post_office': postOffice,
      'is_active': isActive,
      'created_date': createdDate,
      'last_updated_date': lastUpdatedDate,
      'cityId': cityId,
      'createdById': createdById,
      'lastUpdatedById': lastUpdatedById,
    };
  }
}
