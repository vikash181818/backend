import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:online_dukans_user/core/config/common_widgets/confirmation_dialogue_box.dart';
import 'package:online_dukans_user/core/config/utils/constants.dart';
import 'package:online_dukans_user/features/dashboard/presentation/viewmodels/user_profile_notifier.dart';
import 'package:online_dukans_user/features/product_listing/presentation/widgets/product_with_units_card.dart';
import 'package:online_dukans_user/provider/auth_providers.dart';
import 'package:online_dukans_user/provider/cart_provider.dart';
import 'package:online_dukans_user/provider/product_view_model_provider.dart';


class IsRecommendad extends ConsumerStatefulWidget {
  const IsRecommendad({super.key});

  @override
  _IsRecommendadState createState() => _IsRecommendadState();
}

class _IsRecommendadState extends ConsumerState<IsRecommendad> {
  bool _isMyAccountExpanded = false;
  @override
  void initState() {
    super.initState();
    // Trigger fetch on initialization
    Future.microtask(() {
      ref.read(productViewModelProvider.notifier).fetchProductsWithUnits(
            Constants.isRecomendad,
          );
    });
  }

  Future<void> _logout(BuildContext context) async {
    final authVM = ref.read(authViewModelProvider.notifier);
    await authVM.logout();
    if (context.mounted) {
      context.go('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = ref.watch(productViewModelProvider);
    final cartItemCount =
        ref.watch(cartItemCountProvider); // Watch computed cart item count
    final userProfileState = ref.watch(userProfileNotifierProvider);
    final profile = userProfileState.profile;
    int selectedIndex = 0;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.red,
        iconTheme: const IconThemeData(
          color: Colors.white, // Sets the drawer icon color to white
        ),
        title: Text("Recommendations for you"),
        centerTitle: true,
        titleTextStyle: const TextStyle(
          fontSize: 17,
          fontWeight: FontWeight.normal,
          color: Colors.white,
        ),
        actions: [
          // Basket Badge
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10.0),
            child: Stack(
              children: [
                IconButton(
                  icon: const Icon(Icons.shopping_cart, color: Colors.white),
                  onPressed: () {
                    // Navigate to the basket or cart page
                    // context.push('/basket');
                  },
                ),
                if (cartItemCount > 0)
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      padding: const EdgeInsets.all(4.0),
                      decoration: const BoxDecoration(
                        color: Colors.green,
                        shape: BoxShape.circle,
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 20,
                        minHeight: 20,
                      ),
                      child: Text(
                        '$cartItemCount',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(30.0),
          child: Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: GestureDetector(
              onTap: () {
                context.push('/search_products');
              },
              child: Container(
                height: 40,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8.0),
                  border: Border.all(color: Colors.grey),
                  color: Colors.white,
                ),
                child: const Row(
                  children: [
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8.0),
                      child: Icon(Icons.search, color: Colors.grey),
                    ),
                    Text(
                      'Search 1000+ products',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
      drawer: Drawer(
        backgroundColor: Colors.white,
        child: Column(
          children: [
            // Top section of the drawer
            Column(
              children: [
                // Custom header with user info in one row and blue background
                if (profile != null)
                  Container(
                    color: const Color.fromARGB(255, 3, 54, 95),
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(top: 25.0),
                          child: CircleAvatar(
                            backgroundColor: Colors.white,
                            child: Text(
                              profile.firstName.substring(0, 1).toUpperCase(),
                              style: const TextStyle(color: Colors.red),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(top: 25.0),
                              child: Text(
                                "Hello, ${profile.firstName}",
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.normal,
                                    fontSize: 19),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  )
                else
                  Container(
                    color: Colors.blue,
                    padding: const EdgeInsets.all(16),
                    child: const Row(
                      children: [
                        CircleAvatar(
                          child:
                              Text('?', style: TextStyle(color: Colors.white)),
                        ),
                        SizedBox(width: 16),
                        Text(
                          "Guest",
                          style: TextStyle(
                              color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                // Home wrapped in blue container
                Container(
                  color: const Color.fromARGB(255, 190, 215, 236),
                  child: ListTile(
                    leading: const Icon(
                      Icons.home,
                      color: Color.fromARGB(255, 3, 54, 95),
                    ),
                    title: const Text("Home",
                        style: TextStyle(
                          color: Color.fromARGB(255, 3, 54, 95),
                        )),
                    onTap: () {
                      Navigator.of(context).pop(); // Close drawer
                      setState(() {
                        selectedIndex = 0;
                      });
                    },
                  ),
                ),

                // "My Account" with expandable sections
                ExpansionTile(
                  leading: const Icon(Icons.person),
                  title: const Text("My Account"),
                  trailing: Icon(
                    _isMyAccountExpanded
                        ? Icons.remove
                        : Icons
                            .add, // Conditionally show "+" or "-" based on the expansion state
                  ),
                  onExpansionChanged: (bool expanded) {
                    setState(() {
                      _isMyAccountExpanded = expanded;
                    });
                  },
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 15.0),
                      child: ListTile(
                        title: const Text("My Orders"),
                        onTap: () {
                          // Navigate to "My Orders" screen
                          context.push(
                              '/my_orders'); // Make sure the route is correctly set in your router
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 15.0),
                      child: ListTile(
                        title: const Text("My Payments"),
                        onTap: () {
                          // Corrected navigation
                          context.push('/my_payments');
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 15.0),
                      child: ListTile(
                        title: const Text("My Profile"),
                        onTap: () {
                          // Navigate to "My Profile" screen
                          context.push(
                              '/user_profile'); // Make sure the route is correctly set in your router
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
            // Use Expanded to push Logout to the bottom
            Expanded(
              child: Container(),
            ),
            // Bottom section (Logout wrapped in red container, always at the bottom)
            Padding(
              padding: const EdgeInsets.only(bottom: 0.0),
              child: Container(
                color: Colors.red, // Red container for logout
                child: ListTile(
                  leading: const Icon(Icons.logout, color: Colors.white),
                  title: const Text("Logout",
                      style: TextStyle(color: Colors.white)),
                  onTap: () async {
                    Navigator.of(context).pop(); // Close drawer

                    final result = await ConfirmationDialog.show(
                      context,
                      title: 'Confirm Logout',
                      message: 'Are you sure you want to logout?',
                      confirmText: 'Logout',
                      cancelText: 'Cancel',
                    );

                    if (result == true) {
                      await _logout(context);
                    }
                  },
                ),
              ),
            ),
          ],
        ),
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
                        return ProductWithUnitsCard(
                          product: product,
                          unitService: viewModel.unitService,
                        );
                      },
                    ),
    );
  }
}
