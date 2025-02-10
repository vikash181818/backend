import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:online_dukans_user/core/config/common_widgets/custom_app_bar.dart';
import 'package:online_dukans_user/core/config/services/secure_storage_service.dart';
import 'package:online_dukans_user/core/config/utils/constants.dart';
import 'package:online_dukans_user/core/config/utils/token_manager.dart';
// import 'package:onlinedukans_user/core/config/common_widgets/custom_app_bar.dart';
// import 'package:onlinedukans_user/core/config/services/secure_storage_service.dart';
// import 'package:onlinedukans_user/core/config/utils/constants.dart';
// import 'package:onlinedukans_user/core/config/utils/token_manager.dart';

// ================== Model Classes ==================

class Order {
  final String id;
  final String buyerEmail;
  final String buyerPhone;
  final double subTotal;
  final double shippingTotal;
  final double yourSaving;
  final double couponAmount;
  final String deliveryDate;
  final String status;
  final String deliveryStatus;
  final String paymentIntendId;
  final String orderDate;
  final String lastUpdatedDate;
  final String userId;
  final String shippingAddressId;
  final String deliverySlotId;
  final String lastUpdatedById;
  final double walletAmount;
  final double amountPaid;
  final double amountRefund;
  final double totalAmount;

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
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['id'] as String,
      buyerEmail: json['buyerEmail'] as String,
      buyerPhone: json['buyerPhone'] as String,
      subTotal: (json['sub_total'] as num).toDouble(),
      shippingTotal: (json['shipping_total'] as num).toDouble(),
      yourSaving: (json['your_saving'] as num).toDouble(),
      couponAmount: (json['coupon_amount'] as num).toDouble(),
      deliveryDate: json['delivery_date'] as String,
      status: json['status'] as String,
      deliveryStatus: json['delivery_status'] as String,
      paymentIntendId: json['paymentIntendId'] as String,
      orderDate: json['order_date'] as String,
      lastUpdatedDate: json['last_updated_date'] as String,
      userId: json['userId'] as String,
      shippingAddressId: json['shippingAddressId'] as String,
      deliverySlotId: json['deliverySlotId'] as String,
      lastUpdatedById: json['lastUpdatedById'] as String,
      walletAmount: (json['wallet_amount'] as num).toDouble(),
      amountPaid: (json['amount_paid'] as num).toDouble(),
      amountRefund: (json['amount_refund'] as num).toDouble(),
      totalAmount: (json['total_amount'] as num).toDouble(),
    );
  }
}

class OrderDetail {
  final String id;
  final String orderId;
  final String productId;
  final String unitId;
  final String image;
  final double mrp;
  final double salePrice;
  final double quantity;
  final double deliveredQuantity;
  final int isDelivered;
  final String lastUpdatedDate;
  final String lastUpdatedById;

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

  factory OrderDetail.fromJson(Map<String, dynamic> json) {
    return OrderDetail(
      id: json['id'] as String,
      orderId: json['orderId'] as String,
      productId: json['productId'] as String,
      unitId: json['unitId'] as String,
      image: json['image'] as String,
      mrp: (json['mrp'] as num).toDouble(),
      salePrice: (json['sale_price'] as num).toDouble(),
      quantity: (json['quantity'] as num).toDouble(),
      deliveredQuantity: (json['delivered_quantity'] as num).toDouble(),
      isDelivered: json['is_delivered'] as int,
      lastUpdatedDate: json['last_updated_date'] as String,
      lastUpdatedById: json['lastUpdatedById'] as String,
    );
  }
}

class OrderItem {
  final Order order;
  final List<OrderDetail> orderDetails;

  OrderItem({required this.order, required this.orderDetails});

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    final order = Order.fromJson(json['order'] as Map<String, dynamic>);
    final details = (json['orderDetails'] as List<dynamic>)
        .map((e) => OrderDetail.fromJson(e as Map<String, dynamic>))
        .toList();
    return OrderItem(order: order, orderDetails: details);
  }
}

class OrdersResponse {
  final List<OrderItem> orders;

  OrdersResponse({required this.orders});

  factory OrdersResponse.fromJson(Map<String, dynamic> json) {
    final ordersJson = json['orders'] as List<dynamic>;
    final ordersList = ordersJson
        .map((e) => OrderItem.fromJson(e as Map<String, dynamic>))
        .toList();
    return OrdersResponse(orders: ordersList);
  }
}

// ================== Widget ==================

class MyPayments extends StatefulWidget {
  const MyPayments({super.key});

  @override
  State<MyPayments> createState() => _MyPaymentsState();
}

class _MyPaymentsState extends State<MyPayments> {
  // Function to fetch payment data from the API and parse using models
  Future<Order> fetchPaymentData() async {
    // Retrieve token using TokenManager and SecureStorageService
    final tokenManager = TokenManager(SecureStorageService());
    final token = await tokenManager.getToken();

    final url = Uri.parse('${Constants.baseUrl}/api/orders/user/all');
    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $token', // Use the Bearer token here
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final ordersResponse = OrdersResponse.fromJson(data);
      if (ordersResponse.orders.isNotEmpty) {
        // Sort orders by orderDate in descending order (most recent first)
        ordersResponse.orders
            .sort((a, b) => b.order.orderDate.compareTo(a.order.orderDate));

        // Return the most recent order
        return ordersResponse.orders.first.order;
      } else {
        throw Exception('No orders found.');
      }
    } else {
      throw Exception('Failed to load payment data');
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Order>(
      future: fetchPaymentData(),
      builder: (context, snapshot) {
        // Display a loading indicator while waiting for data
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        // Display error message if fetching fails
        else if (snapshot.hasError) {
          return Scaffold(
            appBar: const CustomAppBar(
              title: 'My Payments',
              centerTitle: true,
            ),
            body: Center(child: Text('Error: ${snapshot.error}')),
          );
        }
        // Handle case when no data is available
        else if (!snapshot.hasData) {
          return Scaffold(
            appBar: const CustomAppBar(
              title: 'My Payments',
              centerTitle: true,
            ),
            body: const Center(child: Text('No data available.')),
          );
        }

        // Extract values from the fetched data
        final orderData = snapshot.data!;
        final double amountPaid = orderData.amountPaid;
        final double totalAmount = orderData.totalAmount;

        return Container(
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/images/bgimg6.jpg'),
              fit: BoxFit.cover,
              alignment: Alignment.centerLeft,
            ),
          ),
          child: Scaffold(
            backgroundColor: Colors.transparent,
            appBar: const CustomAppBar(
              title: 'My Payments',
              centerTitle: true,
            ),
            body: Padding(
              padding: const EdgeInsets.only(left: 8.0, right: 8.0, top: 8.0),
              child: SizedBox(
                height:
                    MediaQuery.of(context).size.height, // Full screen height
                child: Column(
                  children: [
                    // 30% green section
                    Expanded(
                      flex: 3, // 30% of the screen height
                      child: Container(
                        width: double.infinity,
                        color: Colors.green,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            const Text(
                              'Online Payment',
                              style: TextStyle(color: Colors.white),
                            ),
                            const SizedBox(height: 15),
                            Text(
                              '₹ $amountPaid',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 15,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    // 70% grey section
                    Expanded(
                      flex: 7, // 70% of the screen height
                      child: Container(
                        width: double.infinity,
                        color: const Color.fromARGB(255, 227, 227, 227),
                        child: Align(
                          alignment: Alignment.topLeft,
                          child: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Text(
                              'Total Online Payment ₹ $amountPaid',
                              style: const TextStyle(
                                color: Colors.black,
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
