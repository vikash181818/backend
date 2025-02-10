import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:online_dukans_user/core/config/common_widgets/custom_app_bar.dart';
import 'package:online_dukans_user/core/config/common_widgets/custom_snackbar.dart';
import 'package:online_dukans_user/core/config/services/unit_service.dart';
import 'package:online_dukans_user/core/config/utils/constants.dart';
import 'package:online_dukans_user/features/dashboard/presentation/widgets/category_grid_widget.dart';
import 'package:online_dukans_user/features/product_listing/presentation/pages/delivery_options_page.dart';
import 'package:online_dukans_user/provider/cart_provider.dart';
// import 'package:onlinedukans_user/core/config/common_widgets/custom_app_bar.dart';
// import 'package:onlinedukans_user/core/config/common_widgets/custom_snackbar.dart';
// import 'package:onlinedukans_user/core/config/services/unit_service.dart';
// import 'package:onlinedukans_user/core/config/utils/constants.dart';
// import 'package:onlinedukans_user/features/dashboard/presentation/widgets/category_grid_widget.dart';
// import 'package:onlinedukans_user/providers/cart_provider.dart';
// import 'package:onlinedukans_user/features/product_listing/presentation/pages/delivery_options_page.dart';

class BasketWidget extends ConsumerStatefulWidget {
  final UnitService unitService;

  const BasketWidget({
    super.key,
    required this.unitService,
  });

  @override
  ConsumerState<BasketWidget> createState() => _BasketWidgetState();
}

class _BasketWidgetState extends ConsumerState<BasketWidget> {
  final Map<String, Map<String, dynamic>> _unitNameCache = {};

  @override
  Widget build(BuildContext context) {
    final carts = ref.watch(cartProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      // Customized AppBar
      appBar: const CustomAppBar(
        centerTitle: true,
        title: 'Review Basket',
        titleTextStyle: TextStyle(
            fontSize: 17, fontWeight: FontWeight.normal, color: Colors.white),
      ),
      body: _buildBody(context, carts),
    );
  }

  Widget _buildBody(BuildContext context, List<dynamic>? carts) {
    // 1) If still loading (null), show spinner
    if (carts == null) {
      return const Center(child: CircularProgressIndicator());
    }

    // 2) If loaded but empty or no items
    if (carts.isEmpty || _countAllItems(carts) == 0) {
      return Stack(
        children: [
          // Background Image
          Image.asset(
            'assets/images/bgimg3.jpg',
            width: double.infinity,
            height: double.infinity,
            fit: BoxFit.cover,
          ),
          // Centered Button
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Icon(Icons.shopping_basket, color: Colors.red, size: 100),
                const SizedBox(height: 10),
                const Text('Your basket is empty.'),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: () {
                    // Navigate to CategoryGridWidget
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const CategoryGridWidget()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 40, vertical: 15),
                  ),
                  child: const Text(
                    'Start Shopping',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      );
    }

    // 3) We have some items
    final totalItemCount = _countAllItems(carts);
    final total = _calculateTotal(carts);
    final saved = _calculateSaved(carts);

    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            itemCount: carts.length,
            itemBuilder: (context, index) {
              final cart = carts[index];
              final details = cart['details'] ?? [];
              if (details.isEmpty) {
                return const SizedBox.shrink();
              }

              return Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 5.0,
                  horizontal: 10.0,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: List.generate(details.length, (i) {
                    final detail = details[i];
                    final productUnit = detail['productUnit'] ?? {};
                    final product = detail['product'] ?? {};

                    final dynamic rawQty = detail['quantity'] ?? 0;
                    final int quantity = (rawQty is num) ? rawQty.toInt() : 0;
                    final String cartDetailId = detail['id'].toString();

                    // If there's a maxQuantity, parse it
                    final dynamic rawMax = productUnit['maxQuantity'];
                    final int maxQuantity = (rawMax is num)
                        ? rawMax.toInt()
                        : int.tryParse(rawMax?.toString() ?? "9999") ?? 9999;

                    final double baseMRP = double.tryParse(
                            productUnit['mrp']?.toString() ?? '0') ??
                        0.0;
                    final double baseSalePrice = double.tryParse(
                            productUnit['sale_price']?.toString() ?? '0') ??
                        0.0;

                    final double displayMRP = baseMRP * quantity;
                    final double displaySalePrice = baseSalePrice * quantity;

                    // **Updated: Calculate savedAmount instead of savedPercentage**
                    final double savedAmount =
                        (baseMRP - baseSalePrice) * quantity;

                    final dynamic unitId = productUnit['unitId'];
                    if (unitId != null) {
                      // Fetch unit name if not loaded
                      _ensureUnitNameIsLoaded(unitId.toString());
                    }

                    // Grab updated unit_name/code if fetched
                    final unitData = _unitNameCache[unitId?.toString()];
                    final String unitName =
                        unitData != null && unitData['unit_name'] != null
                            ? unitData['unit_name']
                            : productUnit['unit_name'] ?? 'N/A';
                    final String unitCode =
                        unitData != null && unitData['unit_code'] != null
                            ? unitData['unit_code']
                            : productUnit['unit_code'] ?? 'N/A';

                    return Column(
                      children: [
                        Container(
                          margin: const EdgeInsets.symmetric(vertical: 5.0),
                          child: Stack(
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  if (productUnit['image'] != null)
                                    Image.network(
                                      '${Constants.baseUrl}${productUnit['image']}',
                                      width: 100,
                                      height: 100,
                                      fit: BoxFit.cover,
                                      errorBuilder:
                                          (context, error, stackTrace) {
                                        return Container(
                                          width: 70,
                                          height: 70,
                                          color: Colors.grey[300],
                                          child: const Icon(
                                            Icons.broken_image,
                                            size: 40,
                                            color: Colors.grey,
                                          ),
                                        );
                                      },
                                    )
                                  else
                                    Container(
                                      width: 70,
                                      height: 70,
                                      color: Colors.grey[300],
                                      child: const Icon(
                                        Icons.image_not_supported,
                                        size: 40,
                                      ),
                                    ),
                                  Expanded(
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 15.0),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            product['name'] ??
                                                'Unnamed Product',
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16,
                                            ),
                                          ),
                                          const SizedBox(height: 15),
                                          Text(
                                            "$unitName ($unitCode)",
                                            style: const TextStyle(
                                              fontSize: 12,
                                              color: Colors.black54,
                                            ),
                                          ),
                                          const SizedBox(height: 15),
                                          Text(
                                            "MRP: ₹${displayMRP.toStringAsFixed(2)}",
                                            style: const TextStyle(
                                              fontSize: 12,
                                              decoration:
                                                  TextDecoration.lineThrough,
                                              color: Colors.grey,
                                            ),
                                          ),
                                          const SizedBox(height: 15),
                                          Text(
                                            "₹${displaySalePrice.toStringAsFixed(2)}",
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 14,
                                              color: Colors.black,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  // Quantity Controls
                                  Padding(
                                    padding: const EdgeInsets.only(top: 110.0),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        // Remove Button Container
                                        Container(
                                          height: 40,
                                          width: 40,
                                          decoration: BoxDecoration(
                                            border:
                                                Border.all(color: Colors.red),
                                            borderRadius:
                                                BorderRadius.circular(5.0),
                                          ),
                                          child: Center(
                                            child: IconButton(
                                              icon: const Icon(
                                                Icons.remove,
                                                color: Colors.red,
                                                size: 20,
                                              ),
                                              onPressed: () {
                                                if (quantity > 1) {
                                                  ref
                                                      .read(
                                                          cartProvider.notifier)
                                                      .patchQuantityOptimistic(
                                                        cartId: cart['id']
                                                            .toString(),
                                                        cartDetailId:
                                                            cartDetailId,
                                                        currentQty: quantity,
                                                        increment: false,
                                                      );
                                                } else {
                                                  // Optionally handle removal if quantity reaches zero
                                                  ref
                                                      .read(
                                                          cartProvider.notifier)
                                                      .patchQuantityOptimistic(
                                                        cartId: cart['id']
                                                            .toString(),
                                                        cartDetailId:
                                                            cartDetailId,
                                                        currentQty: quantity,
                                                        increment: false,
                                                      );
                                                }
                                              },
                                            ),
                                          ),
                                        ),

                                        // Quantity Display
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 16.0),
                                          child: Text(
                                            '$quantity',
                                            style: const TextStyle(
                                              fontSize: 16,
                                              color: Colors.red,
                                            ),
                                          ),
                                        ),

                                        // Add Button Container
                                        Container(
                                          height: 40,
                                          width: 40,
                                          decoration: BoxDecoration(
                                            border:
                                                Border.all(color: Colors.red),
                                            borderRadius:
                                                BorderRadius.circular(5.0),
                                          ),
                                          child: Center(
                                            child: IconButton(
                                              icon: const Icon(
                                                Icons.add,
                                                color: Colors.red,
                                                size: 20,
                                              ),
                                              onPressed: () {
                                                if (quantity >= maxQuantity) {
                                                  CustomSnackbar.show(
                                                    context,
                                                    message:
                                                        "Only maximum $maxQuantity quantity can be added for this product.",
                                                    backgroundColor: Colors.red,
                                                  );
                                                  return;
                                                }
                                                ref
                                                    .read(cartProvider.notifier)
                                                    .patchQuantityOptimistic(
                                                      cartId:
                                                          cart['id'].toString(),
                                                      cartDetailId:
                                                          cartDetailId,
                                                      currentQty: quantity,
                                                      increment: true,
                                                    );
                                              },
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  )
                                ],
                              ),
                              // **Updated: Display savedAmount instead of savedPercentage**
                              if (savedAmount > 0)
                                Positioned(
                                  top: 0,
                                  left: 0,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10, vertical: 10),
                                    decoration: BoxDecoration(
                                      color: Colors.red,
                                      borderRadius: BorderRadius.circular(50),
                                    ),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        Text(
                                          '₹${savedAmount.toStringAsFixed(1)}',
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold,
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                        const SizedBox(height: 2),
                                        const Text(
                                          'Saved',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 10,
                                            fontWeight: FontWeight.normal,
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                        const Divider(color: Colors.green),
                      ],
                    );
                  }),
                ),
              );
            },
          ),
        ),
        // Summary row + "CHECKOUT" button
        Container(
          padding: const EdgeInsets.all(10.0),
          decoration: BoxDecoration(
            color: Colors.black,
            border: Border(top: BorderSide(color: Colors.grey.shade300)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Summaries
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Dynamic total
                  Text(
                    "₹${total.toStringAsFixed(2)}",
                    style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
                  ),
                  Text(
                    "Saved: ₹${saved.toStringAsFixed(2)}",
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.green,
                    ),
                  ),
                ],
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 10,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5),
                  ),
                ),
                onPressed: () {
                  final cartId = carts[0]['id'].toString();
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => DeliveryOptionsPage(
                        unitService: widget.unitService,
                        cartId: cartId,
                      ),
                    ),
                  );
                },
                child: const Text(
                  "CHECKOUT",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Helper to store fetched unit_name if needed
  Future<void> _ensureUnitNameIsLoaded(String unitId) async {
    if (_unitNameCache.containsKey(unitId)) return;
    try {
      final fetched = await widget.unitService.fetchUnitDetails(
        "${Constants.apiUrl}/manageProducts/units/$unitId",
      );
      setState(() {
        _unitNameCache[unitId] = fetched;
      });
    } catch (e) {
      setState(() {
        _unitNameCache[unitId] = {};
      });
    }
  }

  // Count all items
  int _countAllItems(List<dynamic> carts) {
    int totalItems = 0;
    for (final cart in carts) {
      final details = cart['details'] ?? [];
      for (final detail in details) {
        final dynamic rawQty = detail['quantity'] ?? 0;
        final int qty = (rawQty is num) ? rawQty.toInt() : 0;
        totalItems += qty;
      }
    }
    return totalItems;
  }

  // Calculate total based on salePrice * quantity
  double _calculateTotal(List<dynamic> carts) {
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

  // Calculate saved amount based on (mrp - salePrice) * quantity
  double _calculateSaved(List<dynamic> carts) {
    double saved = 0.0;
    for (final cart in carts) {
      final details = cart['details'] ?? [];
      for (final detail in details) {
        final productUnit = detail['productUnit'] ?? {};
        final double mrp =
            double.tryParse(productUnit['mrp']?.toString() ?? '0') ?? 0.0;
        final double salePrice =
            double.tryParse(productUnit['sale_price']?.toString() ?? '0') ??
                0.0;
        final dynamic rawQty = detail['quantity'] ?? 0;
        final int qty = (rawQty is num) ? rawQty.toInt() : 0;

        saved += (mrp - salePrice) * qty;
      }
    }
    return saved;
  }
}
