import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:online_dukans_user/core/config/services/product_services.dart';
import 'package:online_dukans_user/core/config/services/secure_storage_service.dart';
import 'package:online_dukans_user/core/config/services/unit_service.dart';
import 'package:online_dukans_user/features/product_listing/presentation/viewmodels/product_view_model.dart';
// import 'package:onlinedukans_user/core/config/services/product_services.dart';
// import 'package:onlinedukans_user/core/config/services/unit_service.dart';
// import 'package:onlinedukans_user/core/config/services/secure_storage_service.dart';
// import 'package:onlinedukans_user/features/product_listing/presentation/viewmodels/product_view_model.dart';

final productViewModelProvider =
    ChangeNotifierProvider<ProductViewModel>((ref) {
  return ProductViewModel(
    productsService: ProductsService(
      secureStorageService: SecureStorageService(),
    ),
    unitService: UnitService(
      secureStorageService: SecureStorageService(),
    ),
  );
});
