// lib/features/product_listing/presentation/pages/delivery_options_page.dart

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:online_dukans_user/core/config/common_widgets/custom_app_bar.dart';
import 'package:online_dukans_user/core/config/services/secure_storage_service.dart';
import 'package:online_dukans_user/core/config/services/unit_service.dart';
import 'package:online_dukans_user/core/config/utils/constants.dart';
import 'package:online_dukans_user/core/config/utils/token_manager.dart';
import 'package:online_dukans_user/features/product_listing/model/delivery_charge_model.dart';
import 'package:online_dukans_user/features/product_listing/model/payment_product_model.dart';
import 'package:online_dukans_user/features/product_listing/model/slot_model.dart';
import 'package:online_dukans_user/features/product_listing/presentation/pages/payment_page.dart';
import 'package:online_dukans_user/features/product_listing/services/delivery_charge_service.dart';
import 'package:online_dukans_user/features/product_listing/services/slot_service.dart';
import 'package:online_dukans_user/features/user_profile/data/services/address_service.dart';
import 'package:online_dukans_user/features/user_profile/model/address_model.dart';
import 'package:online_dukans_user/features/user_profile/presentation/pages/delivery_address_page.dart';
import 'package:online_dukans_user/provider/cart_provider.dart';

class DateWiseSlot {
  final DateTime date;
  final SlotModel slot;

  DateWiseSlot({
    required this.date,
    required this.slot,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DateWiseSlot &&
          runtimeType == other.runtimeType &&
          date == other.date &&
          slot.id == other.slot.id;

  @override
  int get hashCode => date.hashCode ^ slot.id.hashCode;
}

class DeliveryOptionsPage extends ConsumerStatefulWidget {
  final UnitService unitService; // Inject UnitService
  final String cartId;
  const DeliveryOptionsPage({
    super.key,
    required this.cartId,
    required this.unitService, // Make it a required parameter
  });

  @override
  ConsumerState<DeliveryOptionsPage> createState() =>
      _DeliveryOptionsPageState();
}

class _DeliveryOptionsPageState extends ConsumerState<DeliveryOptionsPage> {
  late final TokenManager tokenManager;
  String? bearerToken;
  final Map<String, String> _unitNameCache = {}; // Cache for unit names
  final AddressService _addressService =
      AddressService(); // Initialize AddressService
  final SlotService _slotService = SlotService(); // Initialize SlotService
  final DeliveryChargeService _deliveryChargeService =
      DeliveryChargeService(); // Initialize DeliveryChargeService

  AddressModel? _defaultAddress; // To store the default address
  bool _isLoadingAddress = true; // Loading state for address
  String? _addressError; // Error message for address fetching

  List<SlotModel> _slots = []; // List to store fetched slots
  bool _isLoadingSlots = true; // Loading state for slots
  String? _slotsError; // Error message for slots fetching

  List<DeliveryChargeModel> _deliveryCharges =
      []; // List to store delivery charges
  bool _isLoadingDeliveryCharges = true; // Loading state for delivery charges
  String? _deliveryChargesError; // Error message for delivery charges fetching

  DeliveryChargeModel? _applicableDeliveryCharge; // Applicable delivery charge

  // New: List to store available slots with dates
  List<DateWiseSlot> _availableDateWiseSlots = [];

  DateWiseSlot? _selectedDateWiseSlot; // Selected slot with date

  @override
  void initState() {
    super.initState();
    tokenManager = TokenManager(SecureStorageService());
    _loadToken();
    _fetchSlots(); // Fetch slots on initialization
    _fetchDeliveryCharges(); // Fetch delivery charges on initialization
  }

  /// Loads the bearer token and fetches the default address
  Future<void> _loadToken() async {
    final tok = await tokenManager.getToken();
    setState(() {
      bearerToken = tok;
    });

    if (tok != null) {
      await _fetchDefaultAddress();
    } else {
      setState(() {
        _addressError = "No authentication token found.";
        _isLoadingAddress = false;
      });
    }
  }

  /// Fetches the default address based on the userId
  Future<void> _fetchDefaultAddress() async {
    try {
      final user = await tokenManager.getUser();

      print("userId>>>>>>>>>$user");

      if (user == null) {
        setState(() {
          _addressError = "User data not found.";
          _isLoadingAddress = false;
        });
        return;
      }

      final userId =
          user['id'] as String?; // Corrected to 'userId' instead of 'id'
      if (userId == null) {
        setState(() {
          _addressError = "User ID not found.";
          _isLoadingAddress = false;
        });
        return;
      }

      final addresses = await _addressService.getAddressesByUserId(userId);
      final defaultAddress = addresses.firstWhere(
        (addr) => addr.defaultAddress == 1,
      );

      setState(() {
        _defaultAddress = defaultAddress;
        _isLoadingAddress = false;
      });
    } catch (e) {
      setState(() {
        _addressError = "Failed to load address: $e";
        _isLoadingAddress = false;
      });
    }
  }

  /// Fetches delivery slots from the API
  Future<void> _fetchSlots() async {
    try {
      final fetchedSlots = await _slotService.fetchSlots();
      setState(() {
        _slots = fetchedSlots;
        _isLoadingSlots = false;
      });
      _generateAvailableDateWiseSlots(); // Generate available slots after fetching
    } catch (e) {
      setState(() {
        _slotsError = "Failed to load slots: $e";
        _isLoadingSlots = false;
      });
    }
  }

  /// Fetches delivery charges from the API
  Future<void> _fetchDeliveryCharges() async {
    try {
      final fetchedCharges =
          await _deliveryChargeService.fetchDeliveryCharges();
      setState(() {
        _deliveryCharges = fetchedCharges;
        _isLoadingDeliveryCharges = false;
        _determineDeliveryCharge();
      });
    } catch (e) {
      setState(() {
        _deliveryChargesError = "Failed to load delivery charges: $e";
        _isLoadingDeliveryCharges = false;
      });
    }
  }

  /// Determines the delivery charge based on the total amount
  void _determineDeliveryCharge() {
    final carts = ref.read(cartProvider);
    if (carts == null) {
      setState(() {
        _applicableDeliveryCharge = null;
      });
      return;
    }

    final totalAmount = _calculateTotal(carts);

    DeliveryChargeModel? applicableCharge;
    for (var charge in _deliveryCharges) {
      if (charge.isActive == 1 &&
          totalAmount >= charge.minAmount &&
          totalAmount <= charge.maxAmount) {
        applicableCharge = charge;
        break;
      }
    }

    setState(() {
      _applicableDeliveryCharge = applicableCharge;
    });
  }

  /// Function to remove item
  Future<void> _removeItem(String cartDetailId, double lineTotal) async {
    if (bearerToken == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("No auth token found.")),
      );
      return;
    }

    final url = Uri.parse("${Constants.baseUrl}/api/cart/detail/$cartDetailId");
    try {
      final response = await http.delete(
        url,
        headers: {
          "Authorization": "Bearer $bearerToken",
          "Content-Type": "application/json",
        },
        body: jsonEncode({
          "lineTotal": lineTotal.toStringAsFixed(2),
        }),
      );

      if (response.statusCode == 200) {
        // Successfully deleted on server
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Item removed from cart.")),
        );
        // Refresh cart details via Riverpod
        await ref.read(cartProvider.notifier).fetchCartDetails();
        // Recalculate delivery charge
        _determineDeliveryCharge();
        // Regenerate available slots in case delivery charges affect slots
        _generateAvailableDateWiseSlots();
      } else {
        final body = jsonDecode(response.body);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "Delete failed: ${body['message'] ?? response.statusCode}",
            ),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Delete exception: $e")),
      );
    }
  }

  /// Count total distinct items
  num _countDistinctItems(List<dynamic>? carts) {
    if (carts == null) return 0;
    num totalItems = 0;
    for (final cart in carts) {
      final details = cart['details'] ?? [];
      totalItems += details.length;
    }
    return totalItems;
  }

  /// Calculate total sale price
  double _calculateTotal(List<dynamic>? carts) {
    if (carts == null) return 0.0;
    double total = 0.0;
    for (final cart in carts) {
      final details = cart['details'] ?? [];
      for (final detail in details) {
        final productUnit = detail['productUnit'] ?? {};
        final double salePrice =
            double.tryParse(productUnit['sale_price']?.toString() ?? '0') ??
                0.0;
        final dynamic rawQty = detail['quantity'] ?? 0;
        final int qty = (rawQty is num) ? rawQty.toInt() : 0;
        total += salePrice * qty;
      }
    }
    return total;
  }

  /// Fetch unit name and cache it
  Future<String> _getUnitName(String unitId) async {
    print(">>>>>unitId>>>>>>>>$unitId");

    if (_unitNameCache.containsKey(unitId)) {
      return _unitNameCache[unitId]!;
    } else {
      try {
        final unitDetails = await widget.unitService.fetchUnitDetails(
            "${Constants.apiUrl}/manageProducts/units/$unitId");

        print("unitDetails============$unitDetails");

        final unitName = unitDetails['unit_name'] ?? 'N/A';
        _unitNameCache[unitId] = unitName;
        return unitName;
      } catch (e) {
        // Handle error or set default
        _unitNameCache[unitId] = 'N/A';
        return 'N/A';
      }
    }
  }

  /// Collect all product details to pass to PaymentPage
  List<PaymentProductModel> _collectProductDetails(List<dynamic> carts) {
    List<PaymentProductModel> products = [];

    for (final cart in carts) {
      final details = cart['details'] ?? [];
      for (final detail in details) {
        final productUnit = detail['productUnit'] ?? {};
        final product = detail['product'] ?? {};

        final String productId = product['id']?.toString() ?? 'N/A';
        final String unitId = productUnit['unitId']?.toString() ?? 'N/A';
        final String productName = product['name'] ?? 'Unnamed Product';
        final String imageUrl = productUnit['image'] != null
            ? '${Constants.baseUrl}${productUnit['image']}'
            : '';

        final double salePrice =
            double.tryParse(productUnit['sale_price']?.toString() ?? '0') ??
                0.0;
        final double mrp =
            double.tryParse(productUnit['mrp']?.toString() ?? '0') ?? 0.0;
        final dynamic rawQty = detail['quantity'] ?? 0;
        final int quantity = (rawQty is num) ? rawQty.toInt() : 0;

        final double savedAmount = (mrp - salePrice) * quantity;

        products.add(PaymentProductModel(
          productId: productId,
          unitId: unitId,
          imageUrl: imageUrl,
          productName: productName,
          quantity: quantity,
          salePrice: salePrice,
          mrp: mrp,
          savedAmount: savedAmount,
        ));
      }
    }

    return products;
  }

  /// Generate available slots for the next 5 days
  void _generateAvailableDateWiseSlots() {
    List<DateWiseSlot> availableSlots = [];
    final now = DateTime.now(); // Get today's date

    // Loop through the next 4 days (starting from today)
    for (int i = 0; i <= 4; i++) {
      final date = now.add(Duration(days: i));
      final dateOnly = DateTime(date.year, date.month, date.day);
      int slotsCount = 0;

      for (var slot in _slots) {
        if (slot.isActive != 1) continue; // Only active slots

        // Check if slot is allowed for same day
        if (i == 0 && slot.isSameDay != 1) {
          continue; // For today, slot must allow same day
        }

        // For today, check if current time is before slot end time
        if (i == 0) {
          final slotEndTime = _parseSlotEndTime(slot.slots);
          if (slotEndTime == null) continue;

          final slotEndDateTime = DateTime(
            date.year,
            date.month,
            date.day,
            slotEndTime.hour,
            slotEndTime.minute,
          );

          if (now.isAfter(slotEndDateTime)) {
            continue; // Slot already passed
          }
        }

        // Add to available slots if we haven't already added 2 slots for the day
        if (slotsCount < 2) {
          availableSlots.add(DateWiseSlot(
            date: dateOnly,
            slot: slot,
          ));
          slotsCount++;
        }
      }
    }

    // Optionally, sort the available slots by date and time
    availableSlots.sort((a, b) {
      int dateCompare = a.date.compareTo(b.date);
      if (dateCompare != 0) return dateCompare;
      return a.slot.slots.compareTo(b.slot.slots);
    });

    // Update selected slot if it's no longer available
    if (_selectedDateWiseSlot != null &&
        !_availableDateWiseSlots.contains(_selectedDateWiseSlot)) {
      _selectedDateWiseSlot = null;
    }

    // Optionally, set the first available slot as selected if none is selected
    if (_selectedDateWiseSlot == null && availableSlots.isNotEmpty) {
      _selectedDateWiseSlot = availableSlots.first;
    }

    setState(() {
      _availableDateWiseSlots = availableSlots;
    });
  }

  /// Parse the end time from slot string
  TimeOfDay? _parseSlotEndTime(String slotStr) {
    try {
      // slotStr format: "8:00 AM-10:00 AM"
      final parts = slotStr.split('-');
      if (parts.length != 2) return null;
      final endTimeStr = parts[1].trim(); // "10:00 AM"
      final time = _parseTimeOfDay(endTimeStr);
      return time;
    } catch (e) {
      return null;
    }
  }

  /// Parse time string to TimeOfDay
  TimeOfDay? _parseTimeOfDay(String timeStr) {
    try {
      final format = DateFormat.jm(); // "10:00 AM"
      final dateTime = format.parse(timeStr);
      return TimeOfDay(hour: dateTime.hour, minute: dateTime.minute);
    } catch (e) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final carts = ref.watch(cartProvider);
    final totalItems = _countDistinctItems(carts);
    final totalAmount = _calculateTotal(carts);

    // Recalculate delivery charge whenever totalAmount changes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_isLoadingDeliveryCharges) {
        _determineDeliveryCharge();
        _generateAvailableDateWiseSlots(); // Regenerate slots if needed
      }
    });

    return Scaffold(
      appBar: const CustomAppBar(
        centerTitle: true,
        title: 'Delivery Options',
        titleTextStyle: TextStyle(
            fontSize: 17, fontWeight: FontWeight.normal, color: Colors.white),
      ),
      body: SingleChildScrollView(
        // To prevent overflow on smaller screens
        child: Container(
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/images/bgimg3.jpg'),
              fit: BoxFit.cover,
            ),
          ),
          child: Column(
            children: [
              // Display Default Address Section
              _isLoadingAddress
                  ? const Center(child: CircularProgressIndicator())
                  : _addressError != null
                      ? Text(
                          _addressError!,
                          style: const TextStyle(color: Colors.red),
                        )
                      : _defaultAddress != null
                          ? Container(
                              width: double.infinity,
                              color: Color.fromARGB(255, 250, 245, 245),
                              child: ListTile(
                                  title: Text(
                                      "Deliver to: ${_defaultAddress!.addressType}"),
                                  subtitle: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                          "${_defaultAddress!.firstName} ${_defaultAddress!.lastName}"),
                                      Text(
                                          "Address: ${_defaultAddress!.houseNumber}, ${_defaultAddress!.address}, ${_defaultAddress!.street}"),
                                      Text(
                                          "Landmark: ${_defaultAddress!.landmark}"),
                                    ],
                                  ),
                                  trailing: Padding(
                                    padding:
                                        const EdgeInsets.only(bottom: 20.0),
                                    child: ElevatedButton(
                                      onPressed: () {
                                        // Navigate to DeliveryAddressesPage
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                const DeliveryAddressesPage(),
                                          ),
                                        ).then((_) {
                                          // Refresh default address after returning
                                          _fetchDefaultAddress();
                                        });
                                      },
                                      style: ElevatedButton.styleFrom(
                                        foregroundColor: Colors.black,
                                        backgroundColor: Colors
                                            .white, // Set the text color to black
                                        side: const BorderSide(
                                          color: Colors
                                              .grey, // Set the border color to grey
                                          width: 1, // Set the border width
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                              8), // Set the border radius to make it less circular
                                        ),
                                      ),
                                      child: const Text("Change"),
                                    ),
                                  )),
                            )
                          : const Text("No default address found."),

              // Display Slots Dropdown
              _isLoadingSlots
                  ? const CircularProgressIndicator()
                  : _slotsError != null
                      ? Text(
                          _slotsError!,
                          style: const TextStyle(color: Colors.red),
                        )
                      : _availableDateWiseSlots.isEmpty
                          ? const Text(
                              "No available delivery slots for the next 5 days.",
                              style: TextStyle(color: Colors.red),
                            )
                          : Container(
                              color: Color.fromARGB(255, 224, 223, 223),
                              child: Column(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        const Text('Default delivery option'),
                                        const Divider(
                                          color: Colors.white,
                                        ),
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text('$totalItems Shipment'),
                                            Text(
                                                "Delivery charges:₹${_applicableDeliveryCharge?.deliveryCharge.toStringAsFixed(2)}")
                                          ],
                                        )
                                      ],
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                            "Shipment $totalItems:Standard Delivery"),
                                        SizedBox(
                                          height: 30,
                                          width: 150,
                                          child: ElevatedButton(
                                            onPressed: totalItems > 0
                                                ? _showItemsDialog
                                                : null,
                                            style: ElevatedButton.styleFrom(
                                              foregroundColor: Colors.black,
                                              backgroundColor: Colors
                                                  .white, // Set the text color
                                              side: const BorderSide(
                                                color: Colors
                                                    .black, // Set the border color to black
                                                width:
                                                    0, // Set the border width
                                              ),
                                              shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(
                                                    5), // Less circular corners
                                              ),
                                            ),
                                            child:
                                                Text("View $totalItems Items"),
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                  SizedBox(
                                    height: 15,
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: SizedBox(
                                      width: double.infinity,
                                      height: 40,
                                      child: ElevatedButton(
                                        onPressed: () =>
                                            _showSlotSelectionDialog(), // Call show dialog on button press
                                        style: ElevatedButton.styleFrom(
                                          foregroundColor: Colors.black,
                                          backgroundColor: Colors.white,
                                          side: const BorderSide(
                                            color: Colors.black,
                                            width: 0,
                                          ),
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(5),
                                          ),
                                        ),
                                        child: Text(
                                          _selectedDateWiseSlot == null
                                              ? 'Select Delivery Slot'
                                              : '${DateFormat('dd MMM yyyy').format(_selectedDateWiseSlot!.date)} - ${_selectedDateWiseSlot!.slot.slots}',
                                          style: TextStyle(fontSize: 14),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),

              // Display Delivery Charges Information
              _isLoadingDeliveryCharges
                  ? const CircularProgressIndicator()
                  : _deliveryChargesError != null
                      ? Text(
                          _deliveryChargesError!,
                          style: const TextStyle(color: Colors.red),
                        )
                      : Container(
                          color: Color.fromARGB(255, 224, 223, 223),
                          child: ListTile(
                            title: const Text(
                              "Delivery Charge",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            subtitle: Text(
                              _applicableDeliveryCharge != null
                                  ? "₹${_applicableDeliveryCharge!.deliveryCharge.toStringAsFixed(2)} for orders between ₹${_applicableDeliveryCharge!.minAmount} - ₹${_applicableDeliveryCharge!.maxAmount}"
                                  : "Free",
                              style: TextStyle(
                                color: _applicableDeliveryCharge != null
                                    ? Colors.black
                                    : Colors.green,
                                fontSize: 16,
                              ),
                            ),
                            trailing: _applicableDeliveryCharge != null
                                ? const Icon(
                                    Icons.check_circle,
                                    color: Colors.green,
                                  )
                                : const Icon(
                                    Icons.check_circle_outline,
                                    color: Colors.green,
                                  ),
                          ),
                        ),

              Divider(
                color: Colors.white,
                height: 1,
              ),
              // Display Cart Items Button

              // Display Total Amount
              // Text(
              //   "Total Amount: ₹${totalAmount.toStringAsFixed(2)}",
              //   style: const TextStyle(
              //     fontSize: 16,
              //     fontWeight: FontWeight.bold,
              //   ),
              // ),

              // Proceed to Pay Button
              Container(
                color: Color.fromARGB(255, 224, 223, 223),
                padding: EdgeInsets.all(8),
                child: ElevatedButton(
                  onPressed: (totalAmount > 0 &&
                          _defaultAddress != null &&
                          _selectedDateWiseSlot != null)
                      ? () {
                          // Collect all product details
                          final productDetails = _collectProductDetails(carts!);
                          // Get selected delivery date
                          final selectedDate = _selectedDateWiseSlot!.date;
                          // Get selected slot
                          final selectedSlot = _selectedDateWiseSlot!.slot;
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => PaymentPage(
                                cartId: widget.cartId,
                                totalAmount: totalAmount,
                                deliveryCharge:
                                    _applicableDeliveryCharge?.deliveryCharge ??
                                        0.0,
                                selectedSlotId: selectedSlot.id,
                                address: _defaultAddress!,
                                products: productDetails,
                                deliveryDate: selectedDate,
                              ),
                            ),
                          );
                        }
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        Colors.red, // Set the background color to red
                    minimumSize:
                        const Size.fromHeight(50), // Make button full width
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(8), // Less circular corners
                    ),
                  ),
                  child: const Text(
                    "PROCEED TO PAY",
                    style: TextStyle(fontSize: 18, color: Colors.white),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

// Function to show the slot selection dialog
  void _showSlotSelectionDialog() {
    if (_availableDateWiseSlots.isEmpty) {
      // If there are no available slots, show an error message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text("No available delivery slots for the next 5 days.")),
      );
      return;
    }

    // Group the slots by the date
    Map<DateTime, List<SlotModel>> groupedSlots = {};
    for (var slot in _availableDateWiseSlots) {
      final dateOnly = DateTime(
          slot.date.year, slot.date.month, slot.date.day); // Remove time part
      if (groupedSlots.containsKey(dateOnly)) {
        groupedSlots[dateOnly]!.add(slot.slot);
      } else {
        groupedSlots[dateOnly] = [slot.slot];
      }
    }

    // Show dialog with available slots
    showDialog(
      context: context,
      builder: (ctx) {
        return Dialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(12), // Rounded corners for a cleaner look
          ),
          child: Container(
            color: Colors.white,
            width: MediaQuery.of(ctx).size.width *
                0.5, // Set dialog width to 90% of the screen
            child: SingleChildScrollView(
              // Make the dialog scrollable if necessary
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: double.infinity,
                    color: Colors.red, // Red background for the header
                    child: Center(
                      child: const Text(
                        "Select Delivery Slot",
                        style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.normal,
                            color: Colors.white),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16.0),
                  // List all available slots grouped by date
                  ...groupedSlots.entries.map((entry) {
                    final dateOnly = entry.key;
                    final timeSlots = entry.value;

                    final dateStr = DateFormat('dd MMM yyyy').format(dateOnly);
                    final dayOfWeek = DateFormat('EEEE').format(dateOnly);

                    return GestureDetector(
                      onTap: () {
                        // When the user taps on a slot, update the selected slot for the day
                        setState(() {
                          if (_selectedDateWiseSlot?.date == dateOnly) {
                            // If the user taps the same date, deselect it
                            _selectedDateWiseSlot = null;
                          } else {
                            _selectedDateWiseSlot = DateWiseSlot(
                              date: dateOnly,
                              slot: timeSlots
                                  .first, // Select the first available slot for simplicity
                            );
                          }
                        });
                        Navigator.of(ctx).pop(); // Close the dialog
                      },
                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.center, // Center the text
                        children: [
                          // Wrap the day and date in a grey container
                          Container(
                            width: double.infinity,
                            color: Colors
                                .grey[200], // Light grey background for the day
                            padding: const EdgeInsets.all(8.0),
                            child: Center(
                              // Center the day and date text
                              child: Text(
                                '$dayOfWeek, $dateStr',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          // List the time slots for this date
                          for (var slot in timeSlots)
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  _selectedDateWiseSlot = DateWiseSlot(
                                    date: dateOnly,
                                    slot: slot,
                                  );
                                });
                                Navigator.of(ctx).pop(); // Close the dialog
                              },
                              child: Container(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 8.0),
                                color:
                                    _selectedDateWiseSlot?.date == dateOnly &&
                                            _selectedDateWiseSlot?.slot == slot
                                        ? Colors.red.shade100
                                        : Colors.white,
                                child: Center(
                                  // Center the slot text
                                  child: Text(
                                    slot.slots,
                                    style: TextStyle(
                                      color: _selectedDateWiseSlot?.date ==
                                                  dateOnly &&
                                              _selectedDateWiseSlot?.slot ==
                                                  slot
                                          ? Colors
                                              .red // Change text color to red when selected
                                          : Colors.black, // Default color
                                    ),
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    );
                  }),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  /// Shows the Delivery Charges dialog
  void _showDeliveryChargesDialog() {
    if (_isLoadingDeliveryCharges) {
      return;
    }
    if (_deliveryChargesError != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_deliveryChargesError!)),
      );
      return;
    }

    // Sort delivery charges by minAmount
    List<DeliveryChargeModel> sortedCharges = List.from(_deliveryCharges);
    sortedCharges.sort((a, b) => a.minAmount.compareTo(b.minAmount));

    showDialog(
      context: context,
      builder: (ctx) {
        return Dialog(
          child: Container(
            padding: const EdgeInsets.all(16.0),
            width: MediaQuery.of(ctx).size.width * 0.8,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  "Delivery Charges",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16.0),
                SizedBox(
                  height: 200, // Adjust height as needed
                  child: ListView.builder(
                    itemCount: sortedCharges.length,
                    itemBuilder: (context, index) {
                      final charge = sortedCharges[index];
                      return ListTile(
                        title: Text(
                            "₹${charge.deliveryCharge} for orders between ₹${charge.minAmount} - ₹${charge.maxAmount}"),
                        trailing: charge.isActive == 1
                            ? const Icon(
                                Icons.check_circle,
                                color: Colors.green,
                              )
                            : const Icon(
                                Icons.cancel,
                                color: Colors.red,
                              ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 16.0),
                ElevatedButton(
                  onPressed: () => Navigator.of(ctx).pop(),
                  child: const Text("Close"),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// Get selected delivery charge model
  Future<DeliveryChargeModel?> _getSelectedDeliveryCharge() async {
    if (_applicableDeliveryCharge == null) return null;
    return _applicableDeliveryCharge;
  }

  /// Shows the items dialog
  void _showItemsDialog() {
    final carts = ref.read(cartProvider);
    if (carts == null || carts.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("No items to display.")),
      );
      return;
    }

    // Flatten all cart details into a single list
    List<Map<String, dynamic>> allItems = [];
    for (final cart in carts) {
      final details = cart['details'] ?? [];
      for (final detail in details) {
        allItems.add(detail as Map<String, dynamic>);
      }
    }

    final int distinctItemCount = allItems.length;
    final double totalSalesPrice = _calculateTotal(carts);

    showDialog(
      context: context,
      builder: (ctx) {
        return Dialog(
          child: Container(
            width: MediaQuery.of(ctx).size.width *
                0.9, // Ensure dialog takes up 90% of the screen width
            padding: const EdgeInsets.all(16.0),
            child: SingleChildScrollView(
              // Make the entire dialog scrollable
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    "Standard Delivery",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  const SizedBox(height: 8.0),
                  Text(
                    "$distinctItemCount items | Total: ₹${totalSalesPrice.toStringAsFixed(2)}",
                    style: const TextStyle(fontSize: 14),
                    overflow: TextOverflow.ellipsis, // Prevent overflow of text
                  ),
                  const Divider(),
                  allItems.isEmpty
                      ? const Center(
                          child: Text("No items in your cart."),
                        )
                      : ListView.builder(
                          shrinkWrap: true,
                          itemCount: allItems.length,
                          itemBuilder: (context, index) {
                            final item = allItems[index];
                            final productUnit = item['productUnit'] ?? {};
                            final product = item['product'] ?? {};

                            final dynamic rawQty = item['quantity'] ?? 0;
                            final int qty =
                                (rawQty is num) ? rawQty.toInt() : 0;
                            final String cartDetailId = item['id'].toString();

                            final double mrp = double.tryParse(
                                    productUnit['mrp']?.toString() ?? '0') ??
                                0.0;
                            final double salePrice = double.tryParse(
                                    productUnit['sale_price']?.toString() ??
                                        '0') ??
                                0.0;
                            final double savedPrice =
                                (mrp * qty) - (salePrice * qty);
                            final double lineTotal = salePrice * qty;

                            final String? imagePath = productUnit['image'];
                            final String unitId =
                                productUnit['unitId']?.toString() ?? '';
                            final String productName =
                                product['name'] ?? 'Unnamed Product';

                            return FutureBuilder<String>(
                              future: _getUnitName(unitId),
                              builder: (context, snapshot) {
                                String unitName = 'N/A';
                                if (snapshot.connectionState ==
                                    ConnectionState.done) {
                                  if (snapshot.hasData) {
                                    unitName = snapshot.data!;
                                  }
                                }

                                return Card(
                                  child: ListTile(
                                    leading: imagePath != null
                                        ? Image.network(
                                            '${Constants.baseUrl}$imagePath',
                                            width: 50,
                                            height: 50,
                                            fit: BoxFit.cover,
                                          )
                                        : const Icon(Icons.image_not_supported),
                                    title: Text(productName),
                                    subtitle: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text("$qty x $unitName"),
                                        Text(
                                          "₹${salePrice.toStringAsFixed(2)}",
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 14,
                                          ),
                                        ),
                                      ],
                                    ),
                                    trailing: IconButton(
                                      icon: const Icon(
                                        Icons.delete,
                                        color: Colors.red,
                                      ),
                                      onPressed: () async {
                                        final confirm = await showDialog<bool>(
                                          context: context,
                                          builder: (c) => AlertDialog(
                                            title: const Text("Remove Item?"),
                                            content: const Text(
                                              "Are you sure you want to remove this item?",
                                            ),
                                            actions: [
                                              TextButton(
                                                onPressed: () =>
                                                    Navigator.of(c).pop(false),
                                                child: const Text("Cancel"),
                                              ),
                                              TextButton(
                                                onPressed: () =>
                                                    Navigator.of(c).pop(true),
                                                child: const Text("Delete"),
                                              ),
                                            ],
                                          ),
                                        );
                                        if (confirm == true) {
                                          await _removeItem(
                                              cartDetailId, lineTotal);
                                        }
                                      },
                                    ),
                                  ),
                                );
                              },
                            );
                          },
                        ),
                ],
              ),
            ),
          ),
        );
      },
      // isScrollControlled: true, // Allow the dialog to adjust its height
    );
  }
}
