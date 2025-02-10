class OrderDetail {
  String id;
  String orderId;
  String productId;
  String unitId;
  String image;
  double mrp;
  double salePrice;
  int quantity;
  int deliveredQuantity;
  int isDelivered;
  String lastUpdatedDate;
  String lastUpdatedById;

  OrderDetail({
    required this.id,
    required this.orderId,
    required this.productId,
    required this.unitId,
    required this.image,
    required this.mrp,
    required this.salePrice,
    required this.quantity,
    required this.deliveredQuantity,
    required this.isDelivered,
    required this.lastUpdatedDate,
    required this.lastUpdatedById,
  });

  // Factory method to create an instance from a JSON map
  factory OrderDetail.fromJson(Map<String, dynamic> json) {
    return OrderDetail(
      id: json['id'],
      orderId: json['orderId'],
      productId: json['productId'],
      unitId: json['unitId'],
      image: json['image'],
      mrp: json['mrp'].toDouble(),
      salePrice: json['sale_price'].toDouble(),
      quantity: json['quantity'],
      deliveredQuantity: json['delivered_quantity'],
      isDelivered: json['is_delivered'],
      lastUpdatedDate: json['last_updated_date'],
      lastUpdatedById: json['lastUpdatedById'],
    );
  }

  // Method to convert to JSON map
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'orderId': orderId,
      'productId': productId,
      'unitId': unitId,
      'image': image,
      'mrp': mrp,
      'sale_price': salePrice,
      'quantity': quantity,
      'delivered_quantity': deliveredQuantity,
      'is_delivered': isDelivered,
      'last_updated_date': lastUpdatedDate,
      'lastUpdatedById': lastUpdatedById,
    };
  }
}

class Order {
  String id;
  String buyerEmail;
  String buyerPhone;
  double subTotal;
  double shippingTotal;
  double yourSaving;
  double couponAmount;
  String deliveryDate;
  String status;
  String deliveryStatus;
  String paymentIntendId;
  String orderDate;
  String lastUpdatedDate;
  String userId;
  String shippingAddressId;
  String deliverySlotId;
  String lastUpdatedById;
  double walletAmount;
  double amountPaid;
  double amountRefund;
  double totalAmount;
  List<OrderDetail> orderDetails;

  Order({
    required this.id,
    required this.buyerEmail,
    required this.buyerPhone,
    required this.subTotal,
    required this.shippingTotal,
    required this.yourSaving,
    required this.couponAmount,
    required this.deliveryDate,
    required this.status,
    required this.deliveryStatus,
    required this.paymentIntendId,
    required this.orderDate,
    required this.lastUpdatedDate,
    required this.userId,
    required this.shippingAddressId,
    required this.deliverySlotId,
    required this.lastUpdatedById,
    required this.walletAmount,
    required this.amountPaid,
    required this.amountRefund,
    required this.totalAmount,
    required this.orderDetails,
  });

  // Factory method to create an instance from a JSON map
  factory Order.fromJson(Map<String, dynamic> json) {
    var list = json['orderDetails'] as List;
    List<OrderDetail> orderDetailsList = list.map((i) => OrderDetail.fromJson(i)).toList();

    return Order(
      id: json['id'],
      buyerEmail: json['buyerEmail'],
      buyerPhone: json['buyerPhone'],
      subTotal: json['sub_total'].toDouble(),
      shippingTotal: json['shipping_total'].toDouble(),
      yourSaving: json['your_saving'].toDouble(),
      couponAmount: json['coupon_amount'].toDouble(),
      deliveryDate: json['delivery_date'],
      status: json['status'],
      deliveryStatus: json['delivery_status'],
      paymentIntendId: json['paymentIntendId'],
      orderDate: json['order_date'],
      lastUpdatedDate: json['last_updated_date'],
      userId: json['userId'],
      shippingAddressId: json['shippingAddressId'],
      deliverySlotId: json['deliverySlotId'],
      lastUpdatedById: json['lastUpdatedById'],
      walletAmount: json['wallet_amount'].toDouble(),
      amountPaid: json['amount_paid'].toDouble(),
      amountRefund: json['amount_refund'].toDouble(),
      totalAmount: json['total_amount'].toDouble(),
      orderDetails: orderDetailsList,
    );
  }

  // Method to convert to JSON map
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'buyerEmail': buyerEmail,
      'buyerPhone': buyerPhone,
      'sub_total': subTotal,
      'shipping_total': shippingTotal,
      'your_saving': yourSaving,
      'coupon_amount': couponAmount,
      'delivery_date': deliveryDate,
      'status': status,
      'delivery_status': deliveryStatus,
      'paymentIntendId': paymentIntendId,
      'order_date': orderDate,
      'last_updated_date': lastUpdatedDate,
      'userId': userId,
      'shippingAddressId': shippingAddressId,
      'deliverySlotId': deliverySlotId,
      'lastUpdatedById': lastUpdatedById,
      'wallet_amount': walletAmount,
      'amount_paid': amountPaid,
      'amount_refund': amountRefund,
      'total_amount': totalAmount,
      'orderDetails': orderDetails.map((i) => i.toJson()).toList(),
    };
  }
}

class OrdersData {
  List<Order> orders;

  OrdersData({required this.orders});

  // Factory method to create an instance from a JSON map
  factory OrdersData.fromJson(Map<String, dynamic> json) {
    var list = json['orders'] as List;
    List<Order> ordersList = list.map((i) => Order.fromJson(i)).toList();

    return OrdersData(orders: ordersList);
  }

  // Method to convert to JSON map
  Map<String, dynamic> toJson() {
    return {
      'orders': orders.map((i) => i.toJson()).toList(),
    };
  }
}
