// lib/features/product_listing/data/models/delivery_charge_model.dart

class DeliveryChargeModel {
  final String id;
  final double deliveryCharge;
  final double minAmount;
  final double maxAmount;
  final int isActive;
  final DateTime createdDate;
  final DateTime lastUpdatedDate;

  DeliveryChargeModel({
    required this.id,
    required this.deliveryCharge,
    required this.minAmount,
    required this.maxAmount,
    required this.isActive,
    required this.createdDate,
    required this.lastUpdatedDate,
  });

  factory DeliveryChargeModel.fromJson(Map<String, dynamic> json) {
    return DeliveryChargeModel(
      id: json['id'] as String,
      deliveryCharge: (json['deliveryCharge'] as num).toDouble(),
      minAmount: (json['minAmount'] as num).toDouble(),
      maxAmount: (json['maxAmount'] as num).toDouble(),
      isActive: json['is_active'] as int,
      createdDate: DateTime.parse(json['created_date'] as String),
      lastUpdatedDate: DateTime.parse(json['last_updated_date'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'deliveryCharge': deliveryCharge,
      'minAmount': minAmount,
      'maxAmount': maxAmount,
      'is_active': isActive,
      'created_date': createdDate.toIso8601String(),
      'last_updated_date': lastUpdatedDate.toIso8601String(),
    };
  }
}
