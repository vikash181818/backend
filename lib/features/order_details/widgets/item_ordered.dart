import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:online_dukans_user/core/config/services/secure_storage_service.dart';
import 'package:online_dukans_user/core/config/utils/constants.dart';
import 'package:online_dukans_user/core/config/utils/token_manager.dart';
// import 'package:onlinedukans_user/core/config/services/secure_storage_service.dart';
// import 'package:onlinedukans_user/core/config/utils/constants.dart';
// import 'package:onlinedukans_user/core/config/utils/token_manager.dart';

class ItemOrderScreen extends StatefulWidget {
  const ItemOrderScreen({super.key});

  @override
  _ItemOrderScreenState createState() => _ItemOrderScreenState();
}

class _ItemOrderScreenState extends State<ItemOrderScreen> {
  late Order latestOrder; // Store the latest order
  bool _isLoading = true; // Track loading state

  @override
  void initState() {
    super.initState();
    fetchLatestOrder(); // Fetch the latest order when the screen initializes
  }

  // Function to fetch the latest order
  Future<void> fetchLatestOrder() async {
    final TokenManager tokenManager = TokenManager(SecureStorageService());
    final token = await tokenManager.getToken();

    try {
      final response = await http.get(
        Uri.parse('${Constants.baseUrl}/api/orders/user/all'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body)['orders'];

        if (data.isNotEmpty) {
          // Extract orders and convert them to Order objects
          List<Order> orders = data.map((orderData) {
            var orderJson = orderData['order'];
            orderJson['orderDetails'] = orderData['orderDetails'];
            return Order.fromJson(orderJson);
          }).toList();

          // Sort orders by lastUpdatedDate in descending order
          orders.sort((a, b) => b.lastUpdatedDate.compareTo(a.lastUpdatedDate));

          // Set the latest order
          setState(() {
            latestOrder = orders.first;
            _isLoading = false;
          });
        } else {
          throw Exception('No orders found');
        }
      } else {
        throw Exception('Failed to load orders');
      }
    } catch (e) {
      print('Error occurred: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Fetch product name from the product API using productId
  Future<String> fetchProductName(String productId) async {
    final TokenManager tokenManager = TokenManager(SecureStorageService());
    final token =
        await tokenManager.getToken(); // Get the token for authorization

    try {
      final response = await http.get(
        Uri.parse(
            '${Constants.baseUrl}/api/manageProducts/products/$productId'),
        headers: {
          'Authorization': 'Bearer $token', // Add authorization header
        },
      );

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        return data['name'] ?? 'Unknown Product'; // Fetch the productName
      } else {
        throw Exception('Failed to load product details');
      }
    } catch (e) {
      print('Error fetching product details: $e');
      return 'Unknown Product'; // Return unknown product in case of error
    }
  }

  // Fetch unit name from the unit API using unitId
  Future<String> fetchUnitName(String unitId) async {
    final TokenManager tokenManager = TokenManager(SecureStorageService());
    final token =
        await tokenManager.getToken(); // Get the token for authorization

    try {
      final response = await http.get(
        Uri.parse('${Constants.baseUrl}/api/manageProducts/units/$unitId'),
        headers: {
          'Authorization': 'Bearer $token', // Add authorization header
        },
      );

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        return data['unit_name'] ?? 'Unknown Unit'; // Fetch the unit name
      } else {
        throw Exception('Failed to load unit details');
      }
    } catch (e) {
      print('Error fetching unit details: $e');
      return 'Unknown Unit'; // Return unknown unit in case of error
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator()) // Loading indicator
          : Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text('Payable Amount: ₹${latestOrder.totalAmount}',
                      style: const TextStyle(fontSize: 16)),
                  const SizedBox(height: 20),
                  // Display all order details dynamically
                  Expanded(
                    child: ListView.builder(
                      itemCount: latestOrder.orderDetails.length,
                      itemBuilder: (context, index) {
                        final detail = latestOrder.orderDetails[index];
                        final savedAmount = detail.mrp - detail.salePrice;

                        return FutureBuilder<String>(
                          future: fetchProductName(detail
                              .productId), // Fetch product name asynchronously
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const Center(
                                  child: CircularProgressIndicator());
                            }

                            if (snapshot.hasData) {
                              // Update the product name with the fetched value
                              detail.productName = snapshot.data!;

                              return FutureBuilder<String>(
                                future: fetchUnitName(detail
                                    .unitId), // Fetch unit name using unitId
                                builder: (context, unitSnapshot) {
                                  if (unitSnapshot.connectionState ==
                                      ConnectionState.waiting) {
                                    return const Center(
                                        child: CircularProgressIndicator());
                                  }

                                  // Update the unit name with the fetched value
                                  detail.unitName = unitSnapshot.data!;

                                  return Column(
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 8.0),
                                        child: Row(
                                          children: [
                                            Stack(
                                              children: [
                                                // Product image
                                                Image.network(
                                                  detail.image.isNotEmpty
                                                      ? '${Constants.baseUrl}${detail.image}'
                                                      : 'https://example.com/placeholder.jpg',
                                                  width: 100,
                                                  height: 100,
                                                  fit: BoxFit.cover,
                                                ),
                                                // Red container for savings
                                                Positioned(
                                                  top: 0,
                                                  left: 0,
                                                  child: Container(
                                                    padding: const EdgeInsets
                                                        .symmetric(
                                                        horizontal: 5,
                                                        vertical: 2),
                                                    decoration: BoxDecoration(
                                                      color: Colors.red,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              5),
                                                    ),
                                                    child: Column(
                                                      children: [
                                                        Text(
                                                          '₹${savedAmount.toStringAsFixed(2)}',
                                                          style:
                                                              const TextStyle(
                                                            color: Colors.white,
                                                            fontSize: 10,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                          ),
                                                        ),
                                                        const Text(
                                                          'Saved',
                                                          style: TextStyle(
                                                            color: Colors.white,
                                                            fontSize: 10,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(
                                                width:
                                                    8), // Space between image and text
                                            // Product details
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(detail.productName,
                                                      style: const TextStyle(
                                                          fontWeight:
                                                              FontWeight.bold)),
                                                  SizedBox(
                                                    height: 10,
                                                  ),
                                                  Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                    children: [
                                                      Text(
                                                          detail.unitName ?? 'Unknown Unit',
                                                          style:
                                                              const TextStyle(
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w400,
                                                                  color: Colors
                                                                      .grey)),
                                                      Text(
                                                        '₹${detail.salePrice} ',
                                                        style: const TextStyle(
                                                            fontSize: 14),
                                                      ),
                                                    ],
                                                  ),
                                                  SizedBox(
                                                    height: 10,
                                                  ),
                                                  Row(
                                                    children: [
                                                      Text(
                                                        '₹${detail.mrp}',
                                                        style: const TextStyle(
                                                          color: Colors
                                                              .red, // Set text color to red
                                                          decoration: TextDecoration
                                                              .lineThrough, // Add strikethrough
                                                          decorationColor: Colors
                                                              .red, // Set line-through color to red
                                                        ),
                                                      ),
                                                      const SizedBox(width: 10),
                                                      Text(
                                                        '${detail.quantity} × ₹${detail.salePrice} ',
                                                        style: const TextStyle(
                                                            fontSize: 14,
                                                            fontWeight:
                                                                FontWeight
                                                                    .bold),
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const Divider(
                                          color: Colors.green,
                                          thickness:
                                              1), // Ensure Divider is visible
                                    ],
                                  );
                                },
                              );
                            }

                            return const Text('Failed to load product name');
                          },
                        );
                      },
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
  final double totalAmount;
  final String lastUpdatedDate;
  final List<OrderDetail> orderDetails;

  Order({
    required this.id,
    required this.totalAmount,
    required this.lastUpdatedDate,
    required this.orderDetails,
  });

  // Convert JSON to Order object
  factory Order.fromJson(Map<String, dynamic> json) {
    var list = json['orderDetails'] as List;
    List<OrderDetail> detailsList =
        list.map((i) => OrderDetail.fromJson(i)).toList();

    return Order(
      id: json['id'] ?? '',
      totalAmount: (json['total_amount'] ?? 0).toDouble(),
      lastUpdatedDate: json['last_updated_date'] ?? '',
      orderDetails: detailsList,
    );
  }
}

class OrderDetail {
  final String id;
  final String productId;
  final String unitId; // For fetching unit name
  final String image;
  final double mrp; // Added MRP
  final double salePrice;
  final int quantity;
  String productName; // Store product name
  String unitName; // Store unit name (replaces unitId)

  OrderDetail({
    required this.id,
    required this.productId,
    required this.unitId,
    required this.image,
    required this.mrp,
    required this.salePrice,
    required this.quantity,
    required this.productName,
    required this.unitName,
  });

  // Convert JSON to OrderDetail object
  factory OrderDetail.fromJson(Map<String, dynamic> json) {
    return OrderDetail(
      id: json['id'] ?? '',
      productId: json['productId'] ?? '',
      unitId: json['unitId'] ?? '',
      image: json['image'] ?? '',
      mrp: (json['mrp'] ?? 0).toDouble(), // Fetching MRP from the API response
      salePrice: (json['sale_price'] ?? 0).toDouble(),
      quantity: json['quantity'] ?? 0,
      productName: json['productName'] ??
          'Unknown Product', // Default value for productName
      unitName: '', // Initialize with an empty string, will be updated later
    );
  }
}
