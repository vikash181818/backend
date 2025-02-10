// lib/features/product_listing/model/payment_product_model.dart

class PaymentProductModel {
  final String productId;
  final String unitId;
  final String imageUrl;
  final String productName;
  final int quantity;
  final double salePrice;
  final double mrp;
  final double savedAmount;

  PaymentProductModel({
    required this.productId,
    required this.unitId,
    required this.imageUrl,
    required this.productName,
    required this.quantity,
    required this.salePrice,
    required this.mrp,
    required this.savedAmount,
  });
}
