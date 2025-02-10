import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
// import 'package:onlinedukans_user/core/config/services/secure_storage_service.dart';
// import 'package:onlinedukans_user/core/config/services/unit_service.dart';
// import 'package:onlinedukans_user/core/config/utils/constants.dart';
// import 'package:onlinedukans_user/core/config/utils/token_manager.dart';
import 'package:http/http.dart' as http;
import 'package:online_dukans_user/core/config/services/secure_storage_service.dart';
import 'package:online_dukans_user/core/config/services/unit_service.dart';
import 'package:online_dukans_user/core/config/utils/constants.dart';
import 'package:online_dukans_user/core/config/utils/token_manager.dart';
import 'package:online_dukans_user/features/product_listing/presentation/widgets/product_with_units_card.dart';
import 'package:online_dukans_user/search_screen_material/search_material_widget.dart';
// import 'package:onlinedukans_user/features/dashboard/presentation/widgets/home_screen_various_order_widget.dart';
// import 'package:onlinedukans_user/features/product_listing/presentation/widgets/product_with_units_card.dart';
// import 'package:onlinedukans_user/search_screen_material/search_material_widget.dart';

class SearchProductsScreen extends StatefulWidget {
  const SearchProductsScreen({super.key});

  @override
  State<SearchProductsScreen> createState() => _SearchProductsScreenState();
}

class _SearchProductsScreenState extends State<SearchProductsScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<dynamic> _searchResults = [];
  List<dynamic> _seasonalProducts = [];
  List<dynamic> _newLaunchProducts = [];
  List<dynamic> _recommendedProducts = [];
  bool _isLoadingSearch = false;
  bool _isLoadingSeasonal = false;
  bool _isLoadingNewLaunch = false;
  bool _isLoadingRecommended = false;
  final TokenManager _tokenManager = TokenManager(SecureStorageService());

  Timer? _debounce;

  @override
  @override
  void initState() {
    super.initState();
    _fetchSeasonalProducts(); // Fetch seasonal products on initialization
    _fetchNewLaunchProducts(); // Fetch new launch products on initialization
    _fetchRecommendedProducts(); // Fetch recommended products on initialization
    _fetchPreviousOrders(); // Fetch previous orders on initialization
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  // Debounce mechanism to prevent excessive API calls
  void _onSearchChanged() {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      final query = _searchController.text.trim();
      if (query.isEmpty) {
        setState(() {
          _searchResults = [];
        });
      } else {
        _searchProducts(query);
      }
    });
  }

  //previous order

  // Function to fetch previous orders
  Future<void> _fetchPreviousOrders() async {
    setState(() {
      _isLoadingRecommended = true;
    });

    try {
      final String? token = await _tokenManager.getToken();
      if (token == null) {
        throw Exception("Authorization token not found");
      }

      final response = await http.get(
        Uri.parse('${Constants.baseUrl}/api/manageProducts/previous_orders'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> previousOrders = json.decode(response.body);
        setState(() {
          _recommendedProducts =
              previousOrders; // Assuming you want to use this for previous orders
          _isLoadingRecommended = false;
        });
      } else {
        setState(() {
          _isLoadingRecommended = false;
        });
      }
    } catch (e) {
      setState(() {
        _isLoadingRecommended = false;
      });
    }
  }

  // Function to fetch seasonal products
  Future<void> _fetchSeasonalProducts() async {
    setState(() {
      _isLoadingSeasonal = true;
    });

    try {
      final String? token = await _tokenManager.getToken();
      if (token == null) {
        throw Exception("Authorization token not found");
      }

      final response = await http.get(
        Uri.parse(Constants.isSeasonal),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> seasonal = json.decode(response.body);
        final List<dynamic> filteredSeasonal =
            seasonal.where((product) => product['is_seasonal'] == 1).toList();
        setState(() {
          _seasonalProducts = filteredSeasonal;
          _isLoadingSeasonal = false;
        });
      } else {
        setState(() {
          _isLoadingSeasonal = false;
        });
      }
    } catch (e) {
      setState(() {
        _isLoadingSeasonal = false;
      });
    }
  }

  // Function to fetch new launch products
  Future<void> _fetchNewLaunchProducts() async {
    setState(() {
      _isLoadingNewLaunch = true;
    });

    try {
      final String? token = await _tokenManager.getToken();
      if (token == null) {
        throw Exception("Authorization token not found");
      }

      final response = await http.get(
        Uri.parse('${Constants.baseUrl}/api/manageProducts/is_new_launch'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> newLaunch = json.decode(response.body);
        final List<dynamic> filteredNewLaunch = newLaunch
            .where((product) => product['is_new_launch'] == 1)
            .toList();
        setState(() {
          _newLaunchProducts = filteredNewLaunch;
          _isLoadingNewLaunch = false;
        });
      } else {
        setState(() {
          _isLoadingNewLaunch = false;
        });
      }
    } catch (e) {
      setState(() {
        _isLoadingNewLaunch = false;
      });
    }
  }

  // Function to fetch recommended products
  Future<void> _fetchRecommendedProducts() async {
    setState(() {
      _isLoadingRecommended = true;
    });

    try {
      final String? token = await _tokenManager.getToken();
      if (token == null) {
        throw Exception("Authorization token not found");
      }

      final response = await http.get(
        Uri.parse('${Constants.baseUrl}/api/manageProducts/is_Recommendad'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> recommended = json.decode(response.body);
        final List<dynamic> filteredRecommended = recommended
            .where((product) => product['is_Recommendad'] == 1)
            .toList();
        setState(() {
          _recommendedProducts = filteredRecommended;
          _isLoadingRecommended = false;
        });
      } else {
        setState(() {
          _isLoadingRecommended = false;
        });
      }
    } catch (e) {
      setState(() {
        _isLoadingRecommended = false;
      });
    }
  }

  // Function to perform product search
  Future<void> _searchProducts(String query) async {
    setState(() {
      _isLoadingSearch = true;
    });

    try {
      final String? token = await _tokenManager.getToken();
      if (token == null) {
        throw Exception("Authorization token not found");
      }

      final String encodedQuery = Uri.encodeQueryComponent(query);

      final response = await http.get(
        Uri.parse(
            '${Constants.manageProductApi}/search_products_with_units?searchTerm=$encodedQuery'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> results = json.decode(response.body);
        setState(() {
          _searchResults = results;
          _isLoadingSearch = false;
        });
      } else {
        setState(() {
          _isLoadingSearch = false;
        });
      }
    } catch (e) {
      setState(() {
        _isLoadingSearch = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.red,
        title: const Text(
          'Search Products',
          style: TextStyle(
              color: Colors.white, fontSize: 17, fontWeight: FontWeight.normal),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(40),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: SizedBox(
              width: double.infinity,
              height: 50,
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                  hintText: 'Enter the keywords to filter products...',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_searchController.text.isEmpty) {
      // Display Seasonal Products, New Launch Products, and Recommended Products
      if (_isLoadingSeasonal || _isLoadingNewLaunch || _isLoadingRecommended) {
        return const Center(child: CircularProgressIndicator());
      } else if (_seasonalProducts.isEmpty &&
          _newLaunchProducts.isEmpty &&
          _recommendedProducts.isEmpty) {
        return Container(
          height: 500,
          width: double.infinity,
          color: Colors.green,
          child: const Center(
              child: Text(
                  'No seasonal, new launch, or recommended products available.')),
        );
      } else {
        return ListView(
          children: [
            if (_recommendedProducts.isNotEmpty) ...[
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: SizedBox(
                  height: 100,
                  width: double.infinity,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(5),
                    child: Image.asset(
                      'assets/images/main-banner7.jpg',
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  color: Color(0xFFF7F6F6),
                  height: 240,
                  child: Stack(
                    children: [
                      // The main ListView content for Previous Orders
                      ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: _recommendedProducts
                            .length, // Display previous orders here
                        itemBuilder: (context, index) {
                          return Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 8.0),
                            child: Row(
                              children: [
                                // The product widget for previous orders
                                SearchMaterialWidget(
                                  product: _recommendedProducts[index],
                                  unitService: UnitService(
                                      secureStorageService:
                                          SecureStorageService()),
                                ),
                                // Add a vertical divider after each product except the last one
                                if (index != _recommendedProducts.length - 1)
                                  const VerticalDivider(
                                    color: Colors.grey, // Divider color
                                    thickness: 1, // Divider thickness
                                    width:
                                        20, // Space between product and divider
                                  ),
                              ],
                            ),
                          );
                        },
                      ),
                      // The yellow container in the top-left corner
                      Positioned(
                        top: 0, // Adjust top position if needed
                        left: 0, // Adjust left position if needed
                        child: Container(
                          padding: EdgeInsets.all(10),
                          height: 50,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(0.0),
                              topRight: Radius.circular(0.0),
                              bottomLeft: Radius.circular(0.0),
                              bottomRight: Radius.circular(25.0),
                            ),
                            color: Color.fromRGBO(255, 255, 0,
                                0.5), // Transparent yellow with 50% opacity
                          ),
                          child: Center(
                            child: Text(
                              'Previous Orders',
                              style: TextStyle(color: Colors.red, fontSize: 20),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
            if (_seasonalProducts.isNotEmpty) ...[
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: SizedBox(
                  height: 100,
                  width: double.infinity,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(5),
                    child: Image.asset(
                      'assets/images/main-banner3.jpg',
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
              Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    height: 240,
                    color:
                        Color(0xFFF7F6F6), // Adjust the height based on content
                    child: Stack(
                      children: [
                        // The main ListView content
                        ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: _seasonalProducts.length,
                          itemBuilder: (context, index) {
                            return Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 8.0),
                              child: Row(
                                children: [
                                  // The product widget
                                  SearchMaterialWidget(
                                    product: _seasonalProducts[index],
                                    unitService: UnitService(
                                        secureStorageService:
                                            SecureStorageService()),
                                  ),
                                  // Add divider after each product except the last one
                                  if (index != _seasonalProducts.length - 1)
                                    const VerticalDivider(
                                      color: Colors.grey,
                                      thickness:
                                          1, // Adjust thickness of the divider
                                      width:
                                          20, // Adjust space between product and divider
                                    ),
                                ],
                              ),
                            );
                          },
                        ),
                        // The transparent container in the top-left corner with text
                        Positioned(
                          top: 0, // Adjust the top position as needed
                          left: 0, // Adjust the left position as needed
                          child: Container(
                            padding: EdgeInsets.all(10),
                            height: 50, // Adjust the height as needed
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(
                                    0.0), // Top-left corner radius
                                topRight: Radius.circular(
                                    0.0), // Top-right corner radius
                                bottomLeft: Radius.circular(
                                    0.0), // Bottom-left corner radius
                                bottomRight: Radius.circular(
                                    25.0), // Bottom-right corner radius
                              ),
                              color: Color.fromRGBO(255, 255, 0,
                                  0.5), // Yellow with 50% transparency
                            ),
                            child: Center(
                              child: Text(
                                'Seasonal Fruits & Veggies',
                                style:
                                    TextStyle(color: Colors.red, fontSize: 20),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  )),
            ],
            if (_newLaunchProducts.isNotEmpty) ...[
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: SizedBox(
                  height: 100,
                  width: double.infinity,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(5),
                    child: Image.asset(
                      'assets/images/main-banner2.jpg',
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
              Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    color: Color(0xFFF7F6F6),
                    height: 240,
                    child: Stack(
                      children: [
                        // The main ListView content
                        ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: _newLaunchProducts.length,
                          itemBuilder: (context, index) {
                            return Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 8.0),
                              child: Row(
                                children: [
                                  // The product widget
                                  SearchMaterialWidget(
                                    product: _newLaunchProducts[index],
                                    unitService: UnitService(
                                        secureStorageService:
                                            SecureStorageService()),
                                  ),
                                  // Add a vertical divider after each product except the last one
                                  if (index != _newLaunchProducts.length - 1)
                                    const VerticalDivider(
                                      color: Colors
                                          .grey, // Black color for divider
                                      thickness: 1, // Divider thickness
                                      width:
                                          20, // Space between the product and divider
                                    ),
                                ],
                              ),
                            );
                          },
                        ),
                        // The yellow container in the top-left corner
                        Positioned(
                          top: 0, // Adjust the top position as needed
                          left: 0, // Adjust the left position as needed
                          child: Container(
                            padding: const EdgeInsets.all(10),
                            height: 50, // Adjust the height as needed
                            decoration: const BoxDecoration(
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(
                                    0.0), // Top-left corner radius
                                topRight: Radius.circular(
                                    0.0), // Top-right corner radius
                                bottomLeft: Radius.circular(
                                    0.0), // Bottom-left corner radius
                                bottomRight: Radius.circular(
                                    25.0), // Bottom-right corner radius
                              ),
                              color: Color.fromRGBO(255, 255, 0,
                                  0.5), // Yellow with 50% transparency
                            ),
                            child: const Center(
                              child: Text(
                                'New Launches',
                                style:
                                    TextStyle(color: Colors.red, fontSize: 20),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  )),
            ],
            if (_recommendedProducts.isNotEmpty) ...[
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: SizedBox(
                  height: 100,
                  width: double.infinity,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(5),
                    child: Image.asset(
                      'assets/images/main-banner7.jpg',
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
              Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    color: const Color(0xFFF7F6F6),
                    height: 240,
                    child: Stack(
                      children: [
                        // The main ListView content
                        ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: _recommendedProducts.length,
                          itemBuilder: (context, index) {
                            return Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 8.0),
                              child: Row(
                                children: [
                                  // The product widget
                                  SearchMaterialWidget(
                                    product: _recommendedProducts[index],
                                    unitService: UnitService(
                                        secureStorageService:
                                            SecureStorageService()),
                                  ),
                                  // Add a vertical divider after each product except the last one
                                  if (index != _recommendedProducts.length - 1)
                                    const VerticalDivider(
                                      color: Colors
                                          .grey, // Black color for divider
                                      thickness: 1, // Divider thickness
                                      width:
                                          20, // Space between the product and divider
                                    ),
                                ],
                              ),
                            );
                          },
                        ),
                        // The transparent yellow container in the top-left corner with text
                        Positioned(
                          top: 0, // Adjust the top position as needed
                          left: 0, // Adjust the left position as needed
                          child: Container(
                            padding: EdgeInsets.all(10),
                            height: 50, // Adjust the height as needed
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(
                                    0.0), // Top-left corner radius
                                topRight: Radius.circular(
                                    0.0), // Top-right corner radius
                                bottomLeft: Radius.circular(
                                    0.0), // Bottom-left corner radius
                                bottomRight: Radius.circular(
                                    25.0), // Bottom-right corner radius
                              ),
                              color: Color.fromRGBO(255, 255, 0,
                                  0.5), // Transparent yellow with 50% opacity
                            ),
                            child: Center(
                              child: Text(
                                'Recommended Products',
                                style:
                                    TextStyle(color: Colors.red, fontSize: 20),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  )),
            ],
          ],
        );
      }
    } else {
      // Display Search Results
      if (_isLoadingSearch) {
        return const Center(child: CircularProgressIndicator());
      } else if (_searchResults.isEmpty) {
        return const Center(child: Text('No products found.'));
      } else {
        return ListView.builder(
          itemCount: _searchResults.length,
          itemBuilder: (context, index) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: ProductWithUnitsCard(
                product: _searchResults[index],
                unitService:
                    UnitService(secureStorageService: SecureStorageService()),
              ),
            );
          },
        );
      }
    }
  }
}
