import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:online_dukans_user/core/config/services/secure_storage_service.dart';
import 'package:online_dukans_user/core/config/utils/constants.dart';
import 'package:online_dukans_user/core/config/utils/token_manager.dart';
// import 'package:onlinedukans_user/core/config/services/secure_storage_service.dart';
// import 'package:onlinedukans_user/core/config/utils/constants.dart';
// import 'package:onlinedukans_user/core/config/utils/token_manager.dart';

class SummaryScreen extends StatefulWidget {
  final double? deliveryCharge; // Made optional
  final String? bearerToken;

  const SummaryScreen({super.key, this.deliveryCharge, this.bearerToken});

  @override
  State<SummaryScreen> createState() => _SummaryScreenState();
}

Future<List<Order>> getOrderDetail() async {
  final TokenManager tokenManager =
      TokenManager(SecureStorageService()); // For fetching token
  final token = await tokenManager.getToken();
  try {
    final response = await http.get(
      Uri.parse('${Constants.baseUrl}/api/orders/user/all'),
      headers: {
        'Authorization': 'Bearer $token', // Add the Bearer token here
      },
    );

    var data = jsonDecode(response.body);
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
      return [orders.first]; // Return most recent order
    } else {
      throw Exception('No orders found');
    }
  } catch (e) {
    print('Error occurred: $e');
    return [];
  }
}

// Function to fetch the address (either from default address or most recent order)
Future<Map<String, dynamic>> getAddressData(String userId) async {
  final TokenManager tokenManager = TokenManager(SecureStorageService());
  final token = await tokenManager.getToken();
  try {
    final response = await http.get(
      Uri.parse(
          '${Constants.baseUrl}/api/address/user-addresses?userId=$userId'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      var data = jsonDecode(response.body);
      if (data.isNotEmpty) {
        return data[0]; // Return the first address (default or most recent)
      } else {
        throw Exception('No address found');
      }
    } else {
      throw Exception('Failed to load address data');
    }
  } catch (e) {
    print('Error occurred: $e');
    return {}; // Return empty map in case of error
  }
}

// Function to fetch slot data based on the slot `id`
Future<Map<String, dynamic>> getSlotData(String slotId) async {
  final TokenManager tokenManager =
      TokenManager(SecureStorageService()); // For fetching token
  final token = await tokenManager.getToken();
  try {
    // Fetch slot data from API using the slot `id`
    final response = await http.get(
      Uri.parse('${Constants.baseUrl}/api/slots/$slotId'),
      headers: {
        'Authorization': 'Bearer $token', // Add the Bearer token here
      },
    );

    if (response.statusCode == 200) {
      // Decode the slot data from the API response
      return jsonDecode(response.body) as Map<String, dynamic>;
    } else {
      throw Exception('Failed to load slot data');
    }
  } catch (e) {
    print('Error occurred while fetching slot data: $e');
    return {}; // Return empty map in case of error
  }
}

class _SummaryScreenState extends State<SummaryScreen> {
  late List<Order> _orderDetails = [];
  late Map<String, dynamic> _addressDetails = {};
  late Map<String, dynamic> _slotDetails = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    try {
      _orderDetails = await getOrderDetail();
      if (_orderDetails.isNotEmpty) {
        final order = _orderDetails[0];
        _slotDetails = await getSlotData(order.deliverySlotId);
        _addressDetails = await getAddressData(order.buyerEmail);
      }
    } catch (e) {
      print('Error fetching data: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Re-Order and Pay Now Buttons
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Container(
                    height: 30,
                    width: 100,
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(20),
                        topRight: Radius.circular(10),
                        bottomLeft: Radius.circular(50),
                        bottomRight: Radius.circular(10),
                      ),
                    ),
                    child: const Center(
                      child: Text(
                        'RE-ORDER',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Container(
                    height: 30,
                    width: 150,
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.all(Radius.circular(6)),
                    ),
                    child: const Center(
                      child: Text('PAY NOW',
                          style: TextStyle(color: Colors.white)),
                    ),
                  ),
                ],
              ),
            ),

            // Delivery Slot section
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Align(
                  alignment: Alignment.topLeft, child: Text('DELIVERY SLOT')),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: _orderDetails.isNotEmpty
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Order ID: ${_orderDetails[0].id}',
                            style: TextStyle(fontWeight: FontWeight.bold)),
                        SizedBox(height: 8),
                        Text(
                            'Total Amount: ₹${_orderDetails[0].totalAmount.toStringAsFixed(2)}'),
                        Text('Buyer Phone: ${_orderDetails[0].buyerPhone}'),
                        Text(
                            'Sub Total: ₹${_orderDetails[0].subTotal.toStringAsFixed(2)}'),
                        Text('Status: ${_orderDetails[0].status}'),
                        Text(
                            'Wallet Amount: ₹${_orderDetails[0].walletAmount.toStringAsFixed(2)}'),
                        SizedBox(height: 8),
                        // Slot Information
                        Text(
                            'Slot Description: ${_slotDetails['description']}'),
                        Text(
                            'Slots: ${_slotDetails['slots']}'), // Display slot time
                        // Display dynamic order status message
                        Text(
                          _orderDetails[0].deliveryStatus == 'incompleted'
                              ? 'Order: Not Placed'
                              : 'Order: Placed',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, color: Colors.red),
                        ),
                      ],
                    )
                  : const Center(child: Text('No order data available')),
            ),

            // Address slot
            const Padding(
              padding: EdgeInsets.all(8.0),
              child:
                  Align(alignment: Alignment.topLeft, child: Text('ADDRESS')),
            ),
            _orderDetails.isNotEmpty
                ? Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(5),
                      ),
                      padding: const EdgeInsets.all(5),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                              'Name: ${_addressDetails['first_name']} ${_addressDetails['last_name']}'),
                          Text(
                              'Address: ${_addressDetails['house_number']} ${_addressDetails['address']}'),
                          Text('Landmark: ${_addressDetails['landmark']}'),
                          Text('Street: ${_addressDetails['street']}'),
                          Text(
                              'Address Type: ${_addressDetails['address_type']}'),
                          Text(
                              'Default Address: ${_addressDetails['default_address'] == 1 ? 'Yes' : 'No'}'),
                        ],
                      ),
                    ),
                  )
                : const Center(child: Text('No address data available')),

            // Payment details section
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Align(
                  alignment: Alignment.topLeft, child: Text('PAYMENT DETAILS')),
            ),
            Container(
              height: 200,
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(5),
              ),
              padding: const EdgeInsets.all(5),
              child: Column(
                children: [
                  Text(
                    'Delivery Charge: ₹${widget.deliveryCharge?.toStringAsFixed(2) ?? '0.00'}',
                    style: const TextStyle(fontSize: 16),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class Order {
  final String id;
  final String buyerEmail;
  final String buyerPhone;
  final double subTotal;
  final double shippingTotal;
  final double totalAmount;
  final String status;
  final String deliveryDate;
  final String orderDate;
  final double walletAmount; // Added walletAmount field
  final List<OrderDetail> orderDetails;
  final String deliverySlotId;
  final String deliveryStatus;

  Order({
    required this.id,
    required this.buyerEmail,
    required this.buyerPhone,
    required this.subTotal,
    required this.shippingTotal,
    required this.totalAmount,
    required this.status,
    required this.deliveryDate,
    required this.orderDate,
    required this.walletAmount,
    required this.orderDetails,
    required this.deliverySlotId,
    required this.deliveryStatus,
  });

  factory Order.fromJson(
      Map<String, dynamic> json, List<OrderDetail> detailsList) {
    return Order(
      id: json['id'] ?? '',
      buyerEmail: json['buyerEmail'] ?? '',
      buyerPhone: json['buyerPhone'] ?? '',
      subTotal: (json['sub_total'] ?? 0).toDouble(),
      shippingTotal: (json['shipping_total'] ?? 0).toDouble(),
      totalAmount: (json['total_amount'] ?? 0).toDouble(),
      status: json['status'] ?? '',
      deliveryDate: json['delivery_date'] ?? '',
      orderDate: json['order_date'] ?? '',
      walletAmount: (json['wallet_amount'] ?? 0).toDouble(),
      orderDetails: detailsList,
      deliverySlotId: json['deliverySlotId'] ?? '',
      deliveryStatus: json['delivery_status'] ?? '',
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
      isDelivered: json['is_delivered'] == 1, // Convert to boolean
    );
  }
}
