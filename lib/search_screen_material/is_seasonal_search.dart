import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:online_dukans_user/core/config/common_widgets/custom_app_bar.dart';
import 'package:online_dukans_user/core/config/utils/constants.dart';
import 'package:online_dukans_user/provider/product_view_model_provider.dart';
import 'package:online_dukans_user/search_screen_material/search_material_widget.dart';
// import 'package:onlinedukans_user/core/config/common_widgets/custom_app_bar.dart';
// import 'package:onlinedukans_user/core/config/utils/constants.dart';

// import 'package:onlinedukans_user/features/product_listing/presentation/widgets/product_with_units_card.dart';
// import 'package:onlinedukans_user/providers/product_view_model_provider.dart';
// import 'package:onlinedukans_user/search_screen_material/search_material_widget.dart';

class IsSeasonalSearch extends ConsumerStatefulWidget {
  const IsSeasonalSearch({super.key});

  @override
  _IsSeasonalSearchState createState() => _IsSeasonalSearchState();
}

class _IsSeasonalSearchState extends ConsumerState<IsSeasonalSearch> {
  @override
  void initState() {
    super.initState();
    // Trigger fetch on initialization
    Future.microtask(() {
      ref.read(productViewModelProvider.notifier).fetchProductsWithUnits(
            Constants.isSeasonal,
          );
    });
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = ref.watch(productViewModelProvider);

    return Scaffold(
      appBar: CustomAppBar(
        title: "Seasonal Fruits & Veggies",
        centerTitle: true,
      ),
      body: viewModel.isLoading
          ? const Center(child: CircularProgressIndicator())
          : viewModel.errorMessage != null
              ? Center(
                  child: Text(
                    'Error: ${viewModel.errorMessage}',
                    style: const TextStyle(fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                )
              : viewModel.products.isEmpty
                  ? const Center(child: Text('No products found.'))
                  : ListView.builder(
                      itemCount: viewModel.products.length,
                      itemBuilder: (context, index) {
                        final product = viewModel.products[index];
                        return SearchMaterialWidget(
                          product: product,
                          unitService: viewModel.unitService,
                        );
                      },
                    ),
    );
  }
}
