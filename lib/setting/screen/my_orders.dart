import 'dart:convert'; // For JSON decoding
import 'package:flutter/material.dart';
//import 'package:http/http.dart' as http; // HTTP package
import 'package:go_router/go_router.dart';
import 'package:online_dukans_user/core/config/common_widgets/custom_app_bar.dart';
import 'package:online_dukans_user/core/config/services/secure_storage_service.dart';
import 'package:online_dukans_user/core/config/utils/constants.dart';
import 'package:online_dukans_user/core/config/utils/token_manager.dart';
import 'package:online_dukans_user/features/product_listing/presentation/pages/payment_page2.dart';
import 'package:online_dukans_user/features/user_profile/model/address_model.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart'; // For date formatting


class Order {
  final String id;
  final String orderDate;
  final double totalAmount;
  final String deliveryStatus;
  final String status;
  final String paymentIntendId;
  final List<OrderDetail> orderDetails;

  Order({
    required this.id,
    required this.orderDate,
    required this.totalAmount,
    required this.deliveryStatus,
    required this.status,
    required this.paymentIntendId,
    required this.orderDetails,
  });

  factory Order.fromJson(
      Map<String, dynamic> json, List<OrderDetail> detailsList) {
    return Order(
      id: json['id'] ?? '',
      orderDate: json['order_date'] ?? '',
      totalAmount: (json['total_amount'] ?? 0).toDouble(),
      deliveryStatus: json['delivery_status'] ?? '',
      status: json['status'] ?? '',
      paymentIntendId: json['paymentIntendId'] ?? '',
      orderDetails: detailsList,
    );
  }
}

class OrderDetail {
  final String id;
  final String productId;
  final String unitId;
  final String image;
  final double mrp;
  final double salePrice;
  final int quantity;
  final int deliveredQuantity;
  final bool isDelivered;

  OrderDetail({
    required this.id,
    required this.productId,
    required this.unitId,
    required this.image,
    required this.mrp,
    required this.salePrice,
    required this.quantity,
    required this.deliveredQuantity,
    required this.isDelivered,
  });

  factory OrderDetail.fromJson(Map<String, dynamic> json) {
    return OrderDetail(
      id: json['id'] ?? '',
      productId: json['productId'] ?? '',
      unitId: json['unitId'] ?? '',
      image: json['image'] ?? '',
      mrp: (json['mrp'] ?? 0).toDouble(),
      salePrice: (json['sale_price'] ?? 0).toDouble(),
      quantity: json['quantity'] ?? 0,
      deliveredQuantity: json['delivered_quantity'] ?? 0,
      isDelivered: json['is_delivered'] == 1,
    );
  }
}

class OrderItem {
  final Order order;
  final List<OrderDetail> orderDetails;

  OrderItem({required this.order, required this.orderDetails});

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    final order = Order.fromJson(
      json['order'] as Map<String, dynamic>,
      (json['orderDetails'] as List<dynamic>)
          .map((e) => OrderDetail.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
    return OrderItem(order: order, orderDetails: order.orderDetails);
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

class MyOrder extends StatefulWidget {
  const MyOrder({super.key});

  @override
  State<MyOrder> createState() => _MyOrderState();
}

class _MyOrderState extends State<MyOrder> {
  late Future<Order> _recentOrder;

  @override
  void initState() {
    super.initState();
    _recentOrder = fetchOrders();
  }

  Future<Order> fetchOrders() async {
    final TokenManager tokenManager = TokenManager(SecureStorageService());
    final token = await tokenManager.getToken();
    print("Bearer Token: $token");

    try {
      final response = await http.get(
        Uri.parse('${Constants.baseUrl}/api/orders/user/all'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      var data = jsonDecode(response.body);
      print("API Response: $data");

      if (response.statusCode == 200 && data.containsKey('orders')) {
        List<Order> orders = [];
        for (var order in data['orders']) {
          List<OrderDetail> orderDetails = [];
          for (var detail in order['orderDetails']) {
            OrderDetail details = OrderDetail.fromJson(detail);
            orderDetails.add(details);
          }
          Order newOrder = Order.fromJson(order['order'], orderDetails);
          orders.add(newOrder);
        }

        orders.sort((a, b) => b.orderDate.compareTo(a.orderDate));

        return orders.isNotEmpty
            ? orders[0]
            : throw Exception('No orders found');
      } else {
        throw Exception('No orders found');
      }
    } catch (e) {
      print('Error occurred: $e');
      throw Exception('Failed to load orders');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomAppBar(title: 'My Orders', centerTitle: true),
      body: FutureBuilder<Order>(
        future: _recentOrder,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (snapshot.hasData) {
            final order = snapshot.data!;
            final formattedDate = DateFormat('EEEE, d MMM yyyy')
                .format(DateTime.parse(order.orderDate));
            final totalItems = order.orderDetails.length;

            return SingleChildScrollView(
              child: SizedBox(
                width: double.infinity,
                child: Column(
                  children: [
                    Container(
                      color: Colors.white,
                      width: double.infinity,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    formattedDate,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 5),
                                  Text(
                                    order.id,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.normal,
                                      color: Colors.black,
                                    ),
                                  ),
                                  const SizedBox(height: 5),
                                  Text(
                                    '₹${order.totalAmount.toStringAsFixed(2)}',
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 5),
                                  Text(
                                    'Total items: $totalItems',
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                            Column(
                              children: [
                                InkWell(
                                  onTap: () {
                                    context.push('/order_details',
                                        extra: order.id);
                                  },
                                  child: Container(
                                    height: 40,
                                    width: 100,
                                    decoration: const BoxDecoration(
                                      color: Colors.green,
                                      borderRadius: BorderRadius.only(
                                        topLeft: Radius.circular(10),
                                        topRight: Radius.circular(10),
                                        bottomLeft: Radius.circular(30),
                                        bottomRight: Radius.circular(10),
                                      ),
                                    ),
                                    child: const Center(
                                      child: Text(
                                        'View Details',
                                        style: TextStyle(color: Colors.white),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 10),
                                if (order.status == 'Cash on Delivery')
                                  InkWell(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => PaymentPage(
                                            cartId:
                                                "dummyCartId", // Replace accordingly
                                            totalAmount: order.totalAmount,
                                            deliveryCharge:
                                                0.0, // Replace accordingly
                                            selectedSlotId:
                                                "", // Replace accordingly
                                            address: AddressModel(
                                                id: "dummyId"), // Minimal AddressModel
                                            products: [], // Replace with actual products list
                                            deliveryDate: DateTime
                                                .now(), // Replace accordingly
                                            // Hide COD option
                                          ),
                                        ),
                                      );
                                    },
                                    child: Container(
                                      height: 40,
                                      width: 100,
                                      decoration: const BoxDecoration(
                                        color: Colors.red,
                                        borderRadius: BorderRadius.only(
                                          topLeft: Radius.circular(10),
                                          topRight: Radius.circular(10),
                                          bottomLeft: Radius.circular(10),
                                          bottomRight: Radius.circular(10),
                                        ),
                                      ),
                                      child: const Center(
                                        child: Text(
                                          'Pay Now',
                                          style: TextStyle(color: Colors.white),
                                        ),
                                      ),
                                    ),
                                  ),
                                
                                
                                Padding(
                                  padding: const EdgeInsets.only(
                                      right: 25.0, top: 8),
                                  child: Text(
                                    order.deliveryStatus == 'incompleted'
                                        ? 'Order placed'
                                        : 'Order completed',
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    const Divider(
                      color: Colors.green,
                      thickness: 2,
                    ),
                  ],
                ),
              ),
            );
          } else {
            return const Center(child: Text('No data available'));
          }
        },
      ),
    );
  }
}
