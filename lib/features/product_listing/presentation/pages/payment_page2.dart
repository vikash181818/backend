import 'dart:convert';
import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart'; // Import Riverpod
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:online_dukans_user/core/config/common_widgets/custom_app_bar.dart';
import 'package:online_dukans_user/core/config/services/secure_storage_service.dart';
import 'package:online_dukans_user/core/config/utils/constants.dart';
import 'package:online_dukans_user/core/config/utils/paytm.dart';
import 'package:online_dukans_user/core/config/utils/token_manager.dart';
import 'package:online_dukans_user/features/order_details/screen/order_detail_screen.dart';
import 'package:online_dukans_user/features/product_listing/model/payment_product_model.dart';
import 'package:online_dukans_user/features/product_listing/presentation/pages/proceed_payment.dart';
import 'dart:convert';
// import 'package:webview_flutter/webview_flutter.dart'; // Import WebView
import 'dart:io';

import 'package:online_dukans_user/features/user_profile/model/address_model.dart';
import 'package:online_dukans_user/provider/cart_provider.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_wkwebview/webview_flutter_wkwebview.dart';

class PaymentPage extends ConsumerStatefulWidget {
  final String cartId;
  final double totalAmount;
  final double deliveryCharge;
  final String selectedSlotId;
  final AddressModel address;
  final List<PaymentProductModel> products;
  final DateTime deliveryDate; // Selected delivery date

  const PaymentPage({
    super.key,
    required this.cartId,
    required this.totalAmount,
    required this.deliveryCharge,
    required this.selectedSlotId,
    required this.address,
    required this.products,
    required this.deliveryDate, // Make it required
  });

  @override
  ConsumerState<PaymentPage> createState() => _PaymentPageState();
}

enum PaymentMethod { paytm, pluxee, cod }

class _PaymentPageState extends ConsumerState<PaymentPage> {
  PaymentMethod? _selectedPaymentMethod;
  bool _isPlacingOrder = false;
  bool _isPaytmCheckout = false;
  String? _paytmTxnToken;
  String? _paytmOrderId;
  String? _paytmUrl;

  late final WebViewController _webViewController;

  final TokenManager _tokenManager =
      TokenManager(SecureStorageService()); // For fetching token

  bool _isPaymentCompleted = false; // Flag to track payment status

  @override
  void initState() {
    super.initState();

    // Initialize the WebViewController based on the platform
    late final PlatformWebViewControllerCreationParams params;
    if (WebViewPlatform.instance is WebKitWebViewPlatform) {
      params = WebKitWebViewControllerCreationParams(
        allowsInlineMediaPlayback: true,
      );
    } else {
      params = const PlatformWebViewControllerCreationParams();
    }

    _webViewController = WebViewController.fromPlatformCreationParams(params);

    // Configure the controller
    _webViewController
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0x00000000)) // Transparent background
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
            debugPrint('WebView is loading (progress : $progress%)');
          },
          onPageStarted: (String url) {
            debugPrint('Page started loading: $url');
          },
          onPageFinished: (String url) {
            debugPrint('Page finished loading: $url');
          },
          onWebResourceError: (WebResourceError error) {
            debugPrint('''Page resource error:
  code: ${error.errorCode}
  description: ${error.description}
  errorType: ${error.errorType}
  isForMainFrame: ${error.isForMainFrame}
            ''');

          },
          onNavigationRequest: (NavigationRequest request) {
            _onPaytmTransactionCompleted(request.url);
            return NavigationDecision.navigate;
          },
        ),
      )
      ..addJavaScriptChannel(
        'Toaster',
        onMessageReceived: (JavaScriptMessage message) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(message.message)),
          );
        },
      )
      ..loadRequest(Uri.parse('https://flutter.dev')); // Placeholder URL
  }

  // Function to place the order (only after payment completion)
  Future<void> _placeOrder() async {
    if (_selectedPaymentMethod == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select a payment method.")),
      );
      return;
    }

    if (_selectedPaymentMethod == PaymentMethod.pluxee || _selectedPaymentMethod == PaymentMethod.paytm) {
      // If Pluxee or Paytm is selected, ensure payment is completed before placing the order
      if (!_isPaymentCompleted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Please complete the payment first.")),
        );
        return;
      }
    }

    setState(() {
      _isPlacingOrder = true;
    });

    try {
      // Fetch the bearer token
      final token = await _tokenManager.getToken();
      if (token == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Authentication token not found.")),
        );
        setState(() {
          _isPlacingOrder = false;
        });
        return;
      }

      // Prepare the API endpoint
      final url = Uri.parse("${Constants.baseUrl}/api/orders/create");

      // Determine paymentIntendId
      String paymentIntendId = _selectedPaymentMethod == PaymentMethod.cod
          ? 'CASH'
          : await _generatePaymentIntendId(); // Implement this function as per your payment gateway

      // Prepare the payload
      final payload = {
        "cartId": widget.cartId,
        "deliveryDate": widget.deliveryDate.toIso8601String(),
        "selectedSlotId": widget.selectedSlotId,
        "paymentMethod": _selectedPaymentMethod == PaymentMethod.paytm
            ? "Paytm"
            : _selectedPaymentMethod == PaymentMethod.pluxee
                ? "Pluxee Food Cards"
                : "Cash on Delivery",
        "deliveryCharge": widget.deliveryCharge, // Include deliveryCharge
        "shippingAddressId": widget.address.id, // Include shippingAddressId
        "paymentIntendId": paymentIntendId, // Include paymentIntendId
        "status": "completed", // Set status to 'completed' when order is placed
      };

      print("payload>>>>>>>>>>>>>>>>>> ${jsonEncode(payload)}");

      // Make the POST request
      final response = await http.post(
        url,
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
        body: jsonEncode(payload),
      );

      // Handle the response
      if (response.statusCode == 201) {
        final responseData = jsonDecode(response.body);
        final orderId = responseData['orderId'];

        // Update the order status to "completed"
        if (_selectedPaymentMethod == PaymentMethod.paytm) {
          // Get txnToken from response
          _paytmTxnToken = responseData['txnToken'];
          _paytmOrderId = orderId;

          // Prepare Paytm Checkout URL
          _paytmUrl = _getPaytmCheckoutUrl(_paytmTxnToken!);

          setState(() {
            _isPaytmCheckout = true;
          });

          // Load the Paytm WebView
          _webViewController.loadRequest(Uri.parse(_paytmUrl!));
        } else {
          // Handle non-Paytm payments (COD or Pluxee)
          await showDialog(
            context: context,
            builder: (ctx) => AlertDialog(
              title: const Text("Order Placed Successfully"),
              content: Text("Your Order ID is $orderId"),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(ctx).pop();
                    // Navigate to OrderDetailScreen and remove previous routes
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const OrderDetailScreen(),
                      ),
                    );
                  },
                  child: const Text("OK"),
                ),
              ],
            ),
          );

          // Refresh the cart to reflect cleared cart_details
          await ref.read(cartProvider.notifier).fetchCartDetails();

          // Optionally, navigate to an order confirmation page or back to home
          Navigator.of(context).popUntil((route) => route.isFirst);
        }
      } else {
        final responseData = jsonDecode(response.body);
        final message = responseData['message'] ?? 'Failed to place order.';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message)),
        );
      }
    } catch (e) {
      print("Error placing order: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text("An error occurred while placing the order.")),
      );
    } finally {
      setState(() {
        _isPlacingOrder = false;
      });
    }
  }

  // Function to generate Paytm Checkout URL
  String _getPaytmCheckoutUrl(String txnToken) {
    final mid = PaytmConfig.PAYTM_MERCHANT_ID; // Replace with your MID
    final orderId = _paytmOrderId!;
    final callbackUrl =
        PaytmConfig.PAYTM_CALLBACK_URL; // Defined in paytm_config.dart

    // Construct the Paytm Checkout URL
    return 'https://securegw-stage.paytm.in/theia/paytmCallback?ORDER_ID=$orderId&TXN_TOKEN=$txnToken&callbackUrl=$callbackUrl';
  }

  // Placeholder for generating paymentIntendId
  Future<String> _generatePaymentIntendId() async {
    // For Paytm, the transaction is handled via txnToken, so this can be a placeholder or left empty
    return 'PAYTM_INTEND_ID_12345';
  }

  // Function to handle Paytm payment completion
  void _onPaytmTransactionCompleted(String url) async {
    if (url.startsWith(PaytmConfig.PAYTM_CALLBACK_URL)) {
      // Close the webview
      setState(() {
        _isPaytmCheckout = false;
        _isPaymentCompleted = true; // Set payment to completed after successful Paytm payment
      });

      // Parse the URL to get transaction details
      Uri uri = Uri.parse(url);
      final params = uri.queryParameters;

      // Check transaction status
      if (params['STATUS'] == 'TXN_SUCCESS') {
        // Payment successful
        await showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text("Payment Successful"),
            content: Text(
                "Your payment was successful. Order ID: ${params['ORDERID']}"),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: const Text("OK"),
              ),
            ],
          ),
        );

        // Refresh the cart to reflect cleared cart_details
        await ref.read(cartProvider.notifier).fetchCartDetails();

        // Navigate back to home or order confirmation
        Navigator.of(context).popUntil((route) => route.isFirst);
      } else {
        // Payment failed or cancelled
        await showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text("Payment Failed"),
            content:
                Text("Your payment failed or was cancelled. Please try again."),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: const Text("OK"),
              ),
            ],
          ),
        );
      }
    }
  }
  
  @override
  Widget build(BuildContext context) {
    final double totalAmountPayable =
        widget.totalAmount + widget.deliveryCharge;
    final double totalSavings = widget.products
        .fold<double>(0.0, (sum, item) => sum + item.savedAmount);

    return Scaffold(
      appBar: CustomAppBar(centerTitle: true, title: "Payment"),
      body: _isPaytmCheckout
          ? WebViewWidget(controller: _webViewController)
          : _isPlacingOrder
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 10),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(8), // Add padding inside the container
                          decoration: BoxDecoration(
                            color: Colors.white, // Optional: Set background color
                            border: Border.all(
                              color: Colors.black, // Set the border color to black
                              width: 1, // Set the border width
                            ),
                            borderRadius: BorderRadius.circular(
                                5), // Set the border radius to 5 for circular corners
                          ),
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text(
                                    'Basket Value',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.normal,
                                    ),
                                  ),
                                  Text(
                                    '₹${widget.totalAmount.toStringAsFixed(2)}',
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.normal,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(
                                height: 15,
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text(
                                    'Delivery Charge',
                                    style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.normal),
                                  ),
                                  Text(
                                    '₹${widget.deliveryCharge.toStringAsFixed(2)}',
                                    style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.normal),
                                  ),
                                ],
                              ),
                              const SizedBox(
                                height: 10,
                              ),
                              const Divider(
                                color: Colors.black,
                              ),
                              const SizedBox(
                                height: 10,
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text(
                                    "Total Amount Payable",
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    "₹${totalAmountPayable.toStringAsFixed(2)}",
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(
                                height: 15,
                              ),
                              Container(
                                height: 40,
                                width: double.infinity,
                                color: const Color.fromARGB(255, 188, 232, 190),
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Text(
                                        "Total Savings",
                                        style: TextStyle(
                                          fontSize: 16,
                                          color:
                                              Color.fromARGB(255, 74, 196, 78),
                                        ),
                                      ),
                                      Text(
                                        "₹${totalSavings.toStringAsFixed(2)}",
                                        style: const TextStyle(
                                          fontSize: 16,
                                          color:
                                              Color.fromARGB(255, 74, 196, 78),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              )
                            ],
                          ),
                        ),

                        const SizedBox(height: 10),
                        Text(
                          'Delivery Charge: ₹${widget.deliveryCharge.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontSize: 16,
                          ),
                        ),

                        const SizedBox(height: 20),

                        // Payment Options
                        Container(
                          width: double.infinity,
                          height: 50,
                          decoration: const BoxDecoration(
                            color: Color.fromARGB(255, 102, 216, 105),
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(5),
                              topRight: Radius.circular(5),
                              bottomLeft: Radius.circular(0),
                              bottomRight: Radius.circular(0),
                            ),
                          ),
                          child: const Align(
                            alignment: Alignment.centerLeft,
                            child: Padding(
                              padding: EdgeInsets.all(8.0),
                              child: Text(
                                "Payment Option",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.normal,
                                ),
                              ),
                            ),
                          ),
                        ),

                        Container(
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: Colors.green, // Green border color
                              width: 1.0, // Border width (you can adjust this)
                            ),
                            borderRadius: BorderRadius.circular(
                                5), // Optional: if you want rounded corners
                          ),
                          child: Column(
                            children: [
                              RadioListTile<PaymentMethod>(
                                title: const Text('Paytm'),
                                value: PaymentMethod.paytm,
                                groupValue: _selectedPaymentMethod,
                                onChanged: (PaymentMethod? value) {
                                  setState(() {
                                    _selectedPaymentMethod = value;
                                  });
                                },
                              ),
                              RadioListTile<PaymentMethod>(
                                title: const Text('Pluxee Food Cards'),
                                value: PaymentMethod.pluxee,
                                groupValue: _selectedPaymentMethod,
                                onChanged: (PaymentMethod? value) {
                                  setState(() {
                                    _selectedPaymentMethod = value;
                                  });

                                  // Navigate to the PaymentScreen when Pluxee is selected
                                  if (value == PaymentMethod.pluxee) {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => PaymentScreen(
                                          amount: totalAmountPayable.toInt(),
                                        ),
                                      ),
                                    ).then((paymentStatus) {
                                      if (paymentStatus == true) {
                                        setState(() {
                                          _isPaymentCompleted = true;
                                        });
                                      }
                                    });
                                  }
                                },
                              ),
                              // RadioListTile<PaymentMethod>(
                              //   title: const Text('Cash on Delivery'),
                              //   value: PaymentMethod.cod,
                              //   groupValue: _selectedPaymentMethod,
                              //   onChanged: (PaymentMethod? value) {
                              //     setState(() {
                              //       _selectedPaymentMethod = value;
                              //     });
                              //   },
                              // ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 20),

                        // Place Order Button
                        ElevatedButton(
                          onPressed:
                              _selectedPaymentMethod == null || _isPlacingOrder
                                  ? null
                                  : _placeOrder,
                          style: ElevatedButton.styleFrom(
                            minimumSize: const Size.fromHeight(
                                50), // Make button full width
                            backgroundColor:
                                Colors.red, // Button color changed to red
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                  8), // Less circular, you can adjust the value
                            ),
                          ),
                          child: _isPlacingOrder
                              ? const CircularProgressIndicator(
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white),
                                )
                              : const Text(
                                  "Place Order",
                                  style: TextStyle(
                                      fontSize: 18, color: Colors.white),
                                ),
                        )
                      ],
                    ),
                  ),
                ),
    );
  }
}

