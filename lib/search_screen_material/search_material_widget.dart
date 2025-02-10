import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:online_dukans_user/core/config/common_widgets/custom_snackbar.dart';
import 'package:online_dukans_user/core/config/services/unit_service.dart';
import 'package:online_dukans_user/core/config/utils/constants.dart';
import 'package:online_dukans_user/provider/cart_provider.dart';

class SearchMaterialWidget extends ConsumerStatefulWidget {
  final Map<String, dynamic> product;
  final UnitService unitService;

  const SearchMaterialWidget({
    super.key,
    required this.product,
    required this.unitService,
  });

  @override
  ConsumerState<SearchMaterialWidget> createState() =>
      _SearchMaterialWidgetState();
}

class _SearchMaterialWidgetState extends ConsumerState<SearchMaterialWidget> {
  late Map<String, dynamic> selectedUnit;
  Map<String, String> unitNames = {};

  bool _isAddingCart = false;

  @override
  void initState() {
    super.initState();

    final productUnits = widget.product['productUnits'] as List<dynamic>? ?? [];
    selectedUnit = productUnits.isNotEmpty ? productUnits.first : {};

    _fetchAllUnitNames(productUnits);

    Future.microtask(() {
      ref.read(cartProvider.notifier).fetchCartDetails();
    });
  }

  Future<void> _fetchAllUnitNames(List<dynamic> units) async {
    for (var unit in units) {
      final unitId = unit['unitId'];
      if (unitId == null) continue;

      try {
        final unitDetails = await widget.unitService.fetchUnitDetails(
          "${Constants.apiUrl}/manageProducts/units/$unitId",
        );
        setState(() {
          unitNames[unitId] =
              "${unitDetails['unit_name']} (${unitDetails['unit_code']})";
        });
      } catch (e) {
        setState(() {
          unitNames[unitId] = "Unknown Unit";
        });
      }
    }
  }

  int _getCurrentQuantityFromCart(List<dynamic> carts) {
    for (final cart in carts) {
      final details = cart['details'] ?? [];
      for (final item in details) {
        final pu = item['productUnit'] ?? {};
        if (pu['id']?.toString() == selectedUnit['id']?.toString()) {
          return item['quantity'] ?? 0;
        }
      }
    }
    return 0;
  }

  String? _getCartDetailId(List<dynamic> carts) {
    for (final cart in carts) {
      final details = cart['details'] ?? [];
      for (final item in details) {
        final pu = item['productUnit'] ?? {};
        if (pu['id']?.toString() == selectedUnit['id']?.toString()) {
          return item['id'].toString(); 
        }
      }
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final carts = ref.watch(cartProvider) ?? [];
    final quantityInCart = _getCurrentQuantityFromCart(carts);
    final cartDetailId = _getCartDetailId(carts);

    final productUnits = widget.product['productUnits'] as List<dynamic>? ?? [];
    final String rawMax = selectedUnit['maxQuantity']?.toString() ?? "9999";
    final int maxQuantity = int.tryParse(rawMax) ?? 9999;

    double discountPercentage = 0;
    if (selectedUnit['mrp'] != null && selectedUnit['sale_price'] != null) {
      final double mrp = double.tryParse("${selectedUnit['mrp']}") ?? 0;
      final double salePrice = double.tryParse("${selectedUnit['sale_price']}") ?? 0;
      if (mrp > 0) {
        discountPercentage = ((mrp - salePrice) / mrp) * 100;
      }
    }

    final isUnitSelectionDisabled = productUnits.length <= 1;

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            if (widget.product['is_pluxee'] == 1)
              Align(
                alignment: Alignment.centerRight,
                child: Image.asset(
                  'assets/images/pluxee.png',
                  height: 20,
                  width: 130,
                ),
              ),
            Container(
              width: 75,
              height: 75,
              color: const Color.fromARGB(255, 238, 235, 235),
              child: selectedUnit['image'] != null
                  ? Image.network(
                      '${Constants.baseUrl}${selectedUnit['image']}',
                      fit: BoxFit.cover,
                    )
                  : const Icon(Icons.image_not_supported, size: 50),
            ),

            Align(
              alignment: Alignment.center,
              child: Text(
                widget.product['name'] ?? 'Unnamed Product',
                style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: Color.fromARGB(255, 118, 117, 117)),
              ),
            ),

            Align(
              alignment: Alignment.center,
              child: Text(
                widget.product['description'] ?? 'No description available',
                style: const TextStyle(
                    fontSize: 13, color: Color.fromARGB(255, 118, 117, 117)),
              ),
            ),

            // Unit Selection (dropdown if multiple units)
            if (!isUnitSelectionDisabled)
              SizedBox(
                width: 150,
                height: 30,
                child: GestureDetector(
                  onTap: () => _showUnitSelectionDialog(context, productUnits),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8.0,
                      vertical: 6.0,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            unitNames[selectedUnit['unitId']] ?? "Fetching...",
                            style: const TextStyle(
                                color: Colors.black, fontSize: 10),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                        ),
                        const Icon(Icons.arrow_drop_down, color: Colors.black),
                      ],
                    ),
                  ),
                ),
              )
            else
              // Directly show unit name if there's only one unit
              Text(
                unitNames[selectedUnit['unitId']] ?? "Fetching...",
                style: const TextStyle(color: Colors.black),
              ),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '₹${selectedUnit['sale_price'] ?? '0'}',
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  'MRP: ₹${selectedUnit['mrp'] ?? '0'}',
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.red,
                    decoration: TextDecoration.lineThrough,
                    decorationColor: Colors.red,
                  ),
                ),
              ],
            ),

            (quantityInCart <= 0)
                ? SizedBox(
                    width: 140,
                    height: 30,
                    child: ElevatedButton(
                      onPressed: _isAddingCart
                          ? null
                          : () async {
                              if (quantityInCart >= maxQuantity) {
                                CustomSnackbar.show(
                                  context,
                                  message:
                                      "Only maximum $maxQuantity quantity can be added for this product.",
                                  backgroundColor: Colors.red,
                                );
                                return;
                              }

                              setState(() => _isAddingCart = true);

                              try {
                                await ref.read(cartProvider.notifier).addToCart(
                                      productId: selectedUnit['productId'],
                                      productUnitId: selectedUnit['id'],
                                      quantity: 1,
                                    );
                                CustomSnackbar.show(
                                  context,
                                  message:
                                      "Added '${widget.product['name']}' to cart successfully!",
                                );
                              } catch (e) {
                                CustomSnackbar.show(
                                  context,
                                  message: "Error adding to cart: $e",
                                  backgroundColor: Colors.red,
                                );
                              } finally {
                                setState(() => _isAddingCart = false);
                              }
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                      ),
                      child: const Text(
                        'Add',
                        style: TextStyle(fontSize: 14),
                      ),
                    ),
                  )
                : Row(
                    children: [
                      Container(
                        height: 30,
                        width: 50,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.red),
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(8.0),
                            bottomLeft: Radius.circular(8.0),
                          ),
                        ),
                        child: Center(
                          child: GestureDetector(
                            onTap: () async {
                              final newQty = quantityInCart - 1;
                              if (newQty < 0) return;
                              if (cartDetailId == null) return;

                              await ref.read(cartProvider.notifier).patchQuantityOptimistic(
                                    cartId: _findCartIdOfLineItem(carts, cartDetailId),
                                    cartDetailId: cartDetailId,
                                    currentQty: quantityInCart,
                                    increment: false,
                                  );
                            },
                            child: const Icon(
                              Icons.remove,
                              color: Colors.red,
                              size: 24,
                            ),
                          ),
                        ),
                      ),
                      Container(
                        color: Colors.red,
                        height: 30,
                        width: 40,
                        child: Center(
                          child: Text(
                            '$quantityInCart',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                      Container(
                        height: 30,
                        width: 50,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.red),
                          borderRadius: const BorderRadius.only(
                            topRight: Radius.circular(8.0),
                            bottomRight: Radius.circular(8.0),
                          ),
                        ),
                        child: Center(
                          child: GestureDetector(
                            onTap: () async {
                              if (quantityInCart >= maxQuantity) {
                                CustomSnackbar.show(
                                  context,
                                  message:
                                      "Only maximum $maxQuantity quantity can be added for this product.",
                                  backgroundColor: Colors.red,
                                );
                                return;
                              }

                              if (cartDetailId == null) return;

                              await ref.read(cartProvider.notifier).patchQuantityOptimistic(
                                    cartId: _findCartIdOfLineItem(carts, cartDetailId),
                                    cartDetailId: cartDetailId,
                                    currentQty: quantityInCart,
                                    increment: true,
                                  );
                            },
                            child: const Icon(
                              Icons.add,
                              color: Colors.red,
                              size: 24,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
          ],
        ),
      ),
    );
  }

  String _findCartIdOfLineItem(List<dynamic> allCarts, String detailId) {
    for (final c in allCarts) {
      final details = c['details'] ?? [];
      for (final d in details) {
        if (d['id']?.toString() == detailId) {
          return c['id'].toString();
        }
      }
    }
    return "";
  }

  void _showUnitSelectionDialog(BuildContext context, List<dynamic> units) {
    showDialog(
      context: context,
      builder: (ctx) {
        return Dialog(
          backgroundColor: Colors.white, // Set dialog background color to white
          shape: RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(5.0), // Rounded corners for the dialog
          ),
          child: SingleChildScrollView(
            // Wrap content to avoid overflow
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: double.infinity,
                  color: const Color.fromARGB(255, 224, 223, 223),
                  child: Column(
                    children: [
                      const Text(
                        "Available Quantities for",
                        style: TextStyle(fontSize: 14, color: Colors.grey),
                      ),
                      const SizedBox(height: 8.0),
                      Text(
                        widget.product['name'] ?? '',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          overflow: TextOverflow.ellipsis,
                        ),
                        maxLines: 1,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16.0),

                // Table Headers for Unit Name, Unit MRP, and Unit Price
                Row(
                  children: [
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(2),
                        child: Container(
                          color: Colors.black,
                          child: const Center(
                            child: Text(
                              'Unit Name',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(2),
                        child: Container(
                          color: Colors.black,
                          child: const Center(
                            child: Text(
                              'Unit MRP',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(2),
                        child: Container(
                          color: Colors.black,
                          child: const Center(
                            child: Text(
                              'Unit Price',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                // Units List
                ...units.map((unit) {
                  final isSelected = unit['unitId'] == selectedUnit['unitId'];
                  return Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 8.0, horizontal: 16.0),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            // Unit Name (equal width)
                            Expanded(
                              child: InkWell(
                                onTap: () {
                                  setState(() {
                                    selectedUnit = unit;
                                  });
                                  Navigator.of(context).pop();
                                },
                                child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: const BorderRadius.only(
                                      topLeft: Radius.circular(
                                          5.0), // Top-left corner radius
                                      topRight: Radius.circular(
                                          0.0), // Top-right corner radius
                                      bottomLeft: Radius.circular(
                                          5.0), // Bottom-left corner radius
                                      bottomRight: Radius.circular(
                                          0.0), // Bottom-right corner radius
                                    ),
                                    color: isSelected
                                        ? Colors.grey
                                        : Colors
                                            .transparent, // Apply gray background to selected row
                                  ),
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 8.0),
                                  child: Center(
                                    child: Text(
                                      unitNames[unit['unitId']] ??
                                          "Fetching...",
                                      style: TextStyle(
                                        fontWeight: isSelected
                                            ? FontWeight.bold
                                            : FontWeight.normal,
                                        color: isSelected
                                            ? Colors.white
                                            : Colors.black,
                                        overflow: TextOverflow
                                            .ellipsis, // Ensure text doesn't overflow
                                      ),
                                      maxLines:
                                          1, // Text in Unit Name will be truncated with ellipsis
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            // Unit MRP (equal width) with line-through applied
                            Expanded(
                              child: InkWell(
                                onTap: () {
                                  setState(() {
                                    selectedUnit = unit;
                                  });
                                  Navigator.of(context).pop();
                                },
                                child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(
                                        0.0), // Apply circular border
                                    color: isSelected
                                        ? Colors.grey
                                        : Colors
                                            .transparent, // Apply gray background to selected row
                                  ),
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 8.0),
                                  child: Center(
                                    child: Text(
                                      '₹${unit['mrp'] ?? '0'}',
                                      style: TextStyle(
                                        fontWeight: isSelected
                                            ? FontWeight.bold
                                            : FontWeight.normal,
                                        color: isSelected
                                            ? Colors.white
                                            : Colors.black,
                                        decoration: TextDecoration
                                            .lineThrough, // Always apply line-through
                                        decorationColor: isSelected
                                            ? Colors.white
                                            : Colors
                                                .black, // Line-through color depends on selection
                                      ),
                                      overflow: TextOverflow
                                          .ellipsis, // Ensure text doesn't overflow
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            // Unit Sale Price (equal width)
                            Expanded(
                              child: InkWell(
                                onTap: () {
                                  setState(() {
                                    selectedUnit = unit;
                                  });
                                  Navigator.of(context).pop();
                                },
                                child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: const BorderRadius.only(
                                      topLeft: Radius.circular(
                                          0.0), // Top-left corner radius
                                      topRight: Radius.circular(
                                          5.0), // Top-right corner radius
                                      bottomLeft: Radius.circular(
                                          0.0), // Bottom-left corner radius
                                      bottomRight: Radius.circular(
                                          5.0), // Bottom-right corner radius
                                    ),
                                    color: isSelected
                                        ? Colors.grey
                                        : Colors
                                            .transparent, // Apply gray background to selected row
                                  ),
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 8.0),
                                  child: Center(
                                    child: Text(
                                      '₹${unit['sale_price'] ?? '0'}',
                                      style: TextStyle(
                                        fontWeight: isSelected
                                            ? FontWeight.bold
                                            : FontWeight.normal,
                                        color: isSelected
                                            ? Colors.white
                                            : Colors.black,
                                      ),
                                      overflow: TextOverflow
                                          .ellipsis, // Ensure text doesn't overflow
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        // Green divider after each row
                        Container(
                          height: 1,
                          color: Colors.green, // Green divider after each row
                        ),
                      ],
                    ),
                  );
                }),

                const SizedBox(height: 16.0),
                Container(
                  height: 40,
                  width: double.infinity,
                  color: Colors.orange,
                  child: const Center(
                    child: Text(
                      "Select one of the units available",
                      style: TextStyle(color: Colors.white, fontSize: 14),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
