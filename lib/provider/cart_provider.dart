import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:online_dukans_user/core/config/services/secure_storage_service.dart';
import 'package:online_dukans_user/features/product_listing/services/cart_services.dart';
// import 'package:onlinedukans_user/core/config/services/secure_storage_service.dart';
// import 'package:onlinedukans_user/features/product_listing/services/cart_services.dart';

/// Cart Provider
final cartProvider = StateNotifierProvider<CartNotifier, List<dynamic>?>((ref) {
  return CartNotifier(
    cartService: CartService(SecureStorageService()),
  );
});

class CartNotifier extends StateNotifier<List<dynamic>?> {
  final CartService cartService;

  CartNotifier({required this.cartService}) : super(null) {
    // Immediately fetch on init
    fetchCartDetails();
  }

  /// Load user’s entire cart from server
  Future<void> fetchCartDetails() async {
    try {
      final result = await cartService.fetchUserCartDetailsWithAmount();
      state = result;
    } catch (e) {
      // On error, set to empty list
      state = [];
    }
  }

  /// Patch quantity (optimistic UI)
  Future<void> patchQuantityOptimistic({
    required String cartId,
    required String cartDetailId,
    required int currentQty,
    required bool increment,
  }) async {
    if (state == null) return; // Skip if not loaded
    final newQty = increment ? currentQty + 1 : currentQty - 1;

    final updated = [...state!];
    final cartIndex = updated.indexWhere((c) => c['id'].toString() == cartId);
    if (cartIndex != -1) {
      final cart = updated[cartIndex];
      final details = cart['details'] as List<dynamic>;

      final detailIndex = details.indexWhere((d) => d['id'] == cartDetailId);
      if (detailIndex != -1) {
        if (newQty <= 0) {
          details.removeAt(detailIndex);
        } else {
          final detail = details[detailIndex];
          detail['quantity'] = newQty;
          // Update lineItemTotal in memory
          final productUnit = detail['productUnit'] ?? {};
          final salePrice =
              double.tryParse("${productUnit['sale_price'] ?? '0'}") ?? 0.0;
          productUnit['lineItemTotal'] = newQty * salePrice;
        }
      }
    }
    state = updated;

    // Call backend
    try {
      await cartService.patchCartDetail(
        cartDetailId: cartDetailId,
        quantity: newQty,
      );
    } catch (err) {
      await fetchCartDetails();
      rethrow;
    }
  }

  /// Add item to cart
  Future<void> addToCart({
    required String productId,
    required String productUnitId,
    required int quantity,
  }) async {
    try {
      await cartService.addToCart(
        productId: productId,
        productUnitId: productUnitId,
        quantity: quantity,
      );
      await fetchCartDetails();
    } catch (e) {
      rethrow;
    }
  }
}

/// Computed Provider to get total number of distinct items in the cart
final cartItemCountProvider = Provider<num>((ref) {
  final cart = ref.watch(cartProvider);
  if (cart == null) return 0;
  num distinctCount = 0;
  for (var cartItem in cart) {
    if (cartItem['details'] is List) {
      distinctCount += cartItem['details'].length;
    }
  }
  return distinctCount;
});
