import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:online_dukans_user/core/config/utils/constants.dart';
import 'package:online_dukans_user/features/product_listing/presentation/widgets/product_with_units_card.dart';
import 'package:online_dukans_user/provider/product_view_model_provider.dart';
// import 'package:onlinedukans_user/core/config/utils/constants.dart';
// import 'package:onlinedukans_user/features/product_listing/presentation/widgets/product_with_units_card.dart';
// import 'package:onlinedukans_user/providers/product_view_model_provider.dart';

class SearchProductsWidget extends ConsumerStatefulWidget {
  const SearchProductsWidget({super.key});

  @override
  _SearchProductsWidgetState createState() => _SearchProductsWidgetState();
}

class _SearchProductsWidgetState extends ConsumerState<SearchProductsWidget> {
  @override
  void initState() {
    super.initState();
    // Using post-frame callback to trigger after widget build and layout phase
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(productViewModelProvider.notifier).fetchProductsWithUnits(
            Constants.isNewLaunch,
          );
    });
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = ref.watch(productViewModelProvider);
    return Column(
      children: [
        viewModel.isLoading
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
                        scrollDirection: Axis.horizontal,
                        itemCount: viewModel.products.length,
                        itemBuilder: (context, index) {
                          final product = viewModel.products[index];
                          return ProductWithUnitsCard(
                            product: product,
                            unitService: viewModel.unitService,
                          );
                        },
                      ),
        Text('jsdwqhdiuhwdiuhhhhhhhhhhhhhhhhhhhhhhhhhhh')
      ],
    );
  }
}
