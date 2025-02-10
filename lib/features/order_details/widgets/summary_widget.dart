import 'dart:convert';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:online_dukans_user/core/config/services/secure_storage_service.dart';
import 'package:online_dukans_user/core/config/utils/constants.dart';
import 'package:online_dukans_user/core/config/utils/token_manager.dart';
// import 'package:intl/intl.dart';  // Import the intl package for date formatting
// import 'package:onlinedukans_user/core/config/services/secure_storage_service.dart';
// import 'package:onlinedukans_user/core/config/utils/constants.dart';
// import 'package:onlinedukans_user/core/config/utils/token_manager.dart';

class SummaryWidget extends StatefulWidget {
  final double? deliveryCharge; // Made optional
  final String? bearerToken;

  const SummaryWidget({super.key, this.deliveryCharge, this.bearerToken});

  @override
  State<SummaryWidget> createState() => _SummaryWidgetState();
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

// Function to fetch slot data based on the slot id
Future<Map<String, dynamic>> getSlotData(String slotId) async {
  final TokenManager tokenManager =
      TokenManager(SecureStorageService()); // For fetching token
  final token = await tokenManager.getToken();
  try {
    // Fetch slot data from API using the slot id
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

// Function to fetch pincode data based on pincodeId
Future<int?> getPincodeForAddress(String pincodeId) async {
  final TokenManager tokenManager =
      TokenManager(SecureStorageService()); // For fetching token
  final token = await tokenManager.getToken();
  try {
    final response = await http.get(
      Uri.parse('${Constants.baseUrl}/api/address/pincode/$pincodeId'),
      headers: {
        'Authorization': 'Bearer $token', // Add the Bearer token here
      },
    );

    if (response.statusCode == 200) {
      var data = jsonDecode(response.body);
      print('Pincode API Response: $data'); // Debug: print response data

      if (data.containsKey('pincode')) {
        return data['pincode']; // Return the pincode if found
      } else {
        print(
            'Pincode not found in the response'); // Debug: when pincode is not found
        return null;
      }
    } else {
      print(
          'Failed to load pincode, Status code: ${response.statusCode}'); // Debug: log failure status code
      throw Exception('Failed to load pincode');
    }
  } catch (e) {
    print('Error occurred while fetching pincode: $e');
    return null; // Return null in case of error
  }
}

// Function to fetch city data based on cityId
Future<String?> getCityNameForAddress(String cityId) async {
  final TokenManager tokenManager =
      TokenManager(SecureStorageService()); // For fetching token
  final token = await tokenManager.getToken();
  try {
    final response = await http.get(
      Uri.parse('${Constants.baseUrl}/api/address/city/$cityId'),
      headers: {
        'Authorization': 'Bearer $token', // Add the Bearer token here
      },
    );

    if (response.statusCode == 200) {
      var data = jsonDecode(response.body);
      print('City API Response: $data'); // Debug: print response data

      if (data.containsKey('city')) {
        return data['city']; // Return the city name if found
      } else {
        print(
            'City not found in the response'); // Debug: when city is not found
        return null;
      }
    } else {
      print(
          'Failed to load city, Status code: ${response.statusCode}'); // Debug: log failure status code
      throw Exception('Failed to load city');
    }
  } catch (e) {
    print('Error occurred while fetching city: $e');
    return null; // Return null in case of error
  }
}

// Function to fetch state data based on stateId
Future<String?> getStateNameForAddress(String stateId) async {
  final TokenManager tokenManager =
      TokenManager(SecureStorageService()); // For fetching token
  final token = await tokenManager.getToken();
  try {
    final response = await http.get(
      Uri.parse('${Constants.baseUrl}/api/address/state/$stateId'),
      headers: {
        'Authorization': 'Bearer $token', // Add the Bearer token here
      },
    );

    if (response.statusCode == 200) {
      var data = jsonDecode(response.body);
      print('State API Response: $data'); // Debug: print response data

      if (data.containsKey('state')) {
        return data['state']; // Return the state name if found
      } else {
        print(
            'State not found in the response'); // Debug: when state is not found
        return null;
      }
    } else {
      print(
          'Failed to load state, Status code: ${response.statusCode}'); // Debug: log failure status code
      throw Exception('Failed to load state');
    }
  } catch (e) {
    print('Error occurred while fetching state: $e');
    return null; // Return null in case of error
  }
}

class _SummaryWidgetState extends State<SummaryWidget> {
  late List<Order> _orderDetails = [];
  late Map<String, dynamic> _addressDetails = {};
  late Map<String, dynamic> _slotDetails = {};
  bool _isLoading = true;
  int? _pincode; // Store pincode here
  String? _city; // Store city name here
  String? _state; // Store state name here

  // Variables to store formatted date
  String? _currentDate;
  String? _tomorrowDate;

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

        // Fetch pincode, city, and state using their respective IDs (if available)
        if (_addressDetails.isNotEmpty) {
          String? pincodeId =
              _addressDetails['pincodeId']; // Fetch pincodeId from address
          String? cityId =
              _addressDetails['cityId']; // Fetch cityId from address
          String? stateId =
              _addressDetails['stateId']; // Fetch stateId from address

          if (pincodeId != null) {
            _pincode = await getPincodeForAddress(pincodeId);
          }

          if (cityId != null) {
            _city = await getCityNameForAddress(cityId);
          }

          if (stateId != null) {
            _state = await getStateNameForAddress(stateId);
          }
        }
      }

      // Get current date and tomorrow's date
      DateTime now = DateTime.now();
      DateTime tomorrow = now.add(Duration(days: 1));

      // Format the date
      _currentDate = DateFormat('EEEE, d MMMM yyyy').format(now);
      _tomorrowDate = DateFormat('EEEE, d MMMM yyyy').format(tomorrow);
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
    return SingleChildScrollView(
      child: Column(
        children: [
          if (_isLoading)
            Center(child: CircularProgressIndicator()) // Show loading indicator
          else ...[
            // Re-Order and Pay Now buttons
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  InkWell(
                    onTap: () {
                      // Handle the tap action here.
                      context.push('/previous_order');
                      // You can add navigation, API calls, or any other logic here.
                    },
                    child: Container(
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

            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Align(
                  alignment: Alignment.topLeft, child: Text('DELIVERY SLOT')),
            ),

            Container(
              color: Colors.white,
              width: double.infinity,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: _orderDetails.isNotEmpty
                        ? Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('$_currentDate'), // Display current date
                              SizedBox(
                                height: 5,
                              ),
                              Text('${_slotDetails['slots']}'),
                              // Display slot time
                              SizedBox(
                                height: 5,
                              ),
                              Text(
                                _orderDetails[0].deliveryStatus == 'incompleted'
                                    ? 'Order: Not Placed'
                                    : 'Order: Placed',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.red),
                              ),
                            ],
                          )
                        : const Center(child: Text('Data is fetching......')),
                  ),
                ],
              ),
            ),

            const Padding(
              padding: EdgeInsets.all(8.0),
              child:
                  Align(alignment: Alignment.topLeft, child: Text('ADDRESS')),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(5),
                ),
                width: double.infinity,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: _orderDetails.isNotEmpty
                          ? Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                    ' ${_addressDetails['house_number']} ${_addressDetails['address']}'),
                                SizedBox(height: 5),
                                Text('${_addressDetails['landmark']}'),
                                SizedBox(height: 5),
                                Text('${_addressDetails['street']}'),
                                SizedBox(height: 5),
                                Text('${_addressDetails['address_type']}'),
                                Row(
                                  children: [
                                    Text('${_city ?? "Loading..."},'),
                                    SizedBox(width: 2),
                                    Text(_state ?? "Loading..."),
                                    SizedBox(width: 2),
                                    Text('- ${_pincode ?? "Loading..."}'),
                                  ],
                                ),
                                SizedBox(height: 5),
                                Text(
                                    'Phone No: ${_orderDetails[0].buyerPhone}'),
                                SizedBox(height: 5),
                              ],
                            )
                          : const Center(child: Text('Data is fetching......')),
                    ),
                  ],
                ),
              ),
            ),

            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Align(
                  alignment: Alignment.topLeft, child: Text('PAYMENT DETAILS')),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(5),
                ),
                width: double.infinity,
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: _orderDetails.isNotEmpty
                          ? Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Order No: ${_orderDetails[0].id}',
                                    style: TextStyle(
                                        fontWeight: FontWeight.normal)),
                                SizedBox(height: 5),
                                Text('Invoice No: ${_orderDetails[0].id}',
                                    style: TextStyle(
                                        fontWeight: FontWeight.normal)),
                                SizedBox(height: 5),
                                Text(
                                    'Order Sub Total: ₹${_orderDetails[0].subTotal.toStringAsFixed(2)}'),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text('Total Amount:',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 15)),
                                    Text(
                                        '₹${_orderDetails[0].totalAmount.toStringAsFixed(2)}',
                                        style: TextStyle(
                                            color: Colors.red,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 15)),
                                  ],
                                ),
                                SizedBox(height: 8),
                              ],
                            )
                          : const Center(child: Text('Data is fetching......')),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
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
  final double walletAmount;
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
