// lib/features/product_listing/data/models/slot_model.dart

class SlotModel {
  final String id;
  final String slots;
  final String description;
  final int isActive;
  final int isSameDay;
  final DateTime createdDate;
  final DateTime lastUpdatedDate;
  final int maxOrderAllowed;

  SlotModel({
    required this.id,
    required this.slots,
    required this.description,
    required this.isActive,
    required this.isSameDay,
    required this.createdDate,
    required this.lastUpdatedDate,
    required this.maxOrderAllowed,
  });

  factory SlotModel.fromJson(Map<String, dynamic> json) {
    return SlotModel(
      id: json['id'] as String,
      slots: json['slots'] as String,
      description: json['description'] as String,
      isActive: json['is_active'] as int,
      isSameDay: json['is_sameDay'] as int,
      createdDate: DateTime.parse(json['created_date'] as String),
      lastUpdatedDate: DateTime.parse(json['last_updated_date'] as String),
      maxOrderAllowed: json['maxOrderAllowed'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'slots': slots,
      'description': description,
      'is_active': isActive,
      'is_sameDay': isSameDay,
      'created_date': createdDate.toIso8601String(),
      'last_updated_date': lastUpdatedDate.toIso8601String(),
      'maxOrderAllowed': maxOrderAllowed,
    };
  }
}
