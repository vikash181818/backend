import 'package:flutter/material.dart';
import 'package:online_dukans_user/core/config/services/product_services.dart';
import 'package:online_dukans_user/core/config/services/unit_service.dart';
// import 'package:onlinedukans_user/core/config/services/product_services.dart';
// import 'package:onlinedukans_user/core/config/services/unit_service.dart';

class ProductViewModel extends ChangeNotifier {
  final ProductsService productsService;
  final UnitService unitService;

  ProductViewModel({
    required this.productsService,
    required this.unitService,
  });

  bool _isLoading = false;
  String? _errorMessage;
  List<dynamic> _products = [];

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  List<dynamic> get products => _products;

  Future<void> fetchProductsWithUnits(String url) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _products = await productsService.fetchProductsWithUnits(url);
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
