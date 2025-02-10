import 'dart:convert';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:online_dukans_user/core/config/common_widgets/confirmation_dialogue_box.dart';
import 'package:online_dukans_user/core/config/services/secure_storage_service.dart';
import 'package:online_dukans_user/core/config/utils/constants.dart';
import 'package:online_dukans_user/core/config/utils/token_manager.dart';
import 'package:online_dukans_user/features/dashboard/presentation/viewmodels/user_profile_notifier.dart';
import 'package:online_dukans_user/features/dashboard/presentation/widgets/home_screen_various_order_widget.dart';
import 'package:online_dukans_user/features/dashboard/presentation/widgets/user_profile_widget.dart';
import 'package:online_dukans_user/provider/auth_providers.dart';

class Category {
  final String id;
  final String name;
  final String color;
  final String image;
  final String percentOff;
  final String isActive;

  Category({
    required this.id,
    required this.name,
    required this.color,
    required this.image,
    required this.percentOff,
    required this.isActive,
  });

  factory Category.fromMap(Map<String, dynamic> map) {
    return Category(
      id: map['id'],
      name: map['name'],
      color: map['color'],
      image: map['image'],
      percentOff: map['percentOff'],
      isActive: map['is_active'],
    );
  }
}

class CategoryGridWidget extends ConsumerStatefulWidget {
  const CategoryGridWidget({super.key});

  @override
  ConsumerState<CategoryGridWidget> createState() => _CategoryGridWidgetState();
}

class _CategoryGridWidgetState extends ConsumerState<CategoryGridWidget> {
  List<Category>? _categories;
  bool _loading = false;
  String? _error;
  List<dynamic> carouselImages = [];
  bool isLoadingCarousel = true;
  final int _selectedIndex = 0;
  bool _isMyAccountExpanded = false;

  final SecureStorageService secureStorageService = SecureStorageService();
  late final TokenManager tokenManager;

  String? _userId;

  int _visibleItemsCount = 9; // Control how many items are visible at a time
  int _currentCarouselIndex = 0; // Track current index for the carousel

  @override
  void initState() {
    super.initState();
    tokenManager = TokenManager(secureStorageService);

    _fetchCategories();
    fetchCarouselImages();

    final authState = ref.read(authViewModelProvider);
    final user = authState.user;
    if (user != null) {
      _userId = user.id;
      Future.microtask(() {
        ref.read(userProfileNotifierProvider.notifier).loadUserProfile(user.id);
      });
    }
  }

  Future<void> fetchCarouselImages() async {
    setState(() {
      isLoadingCarousel = true;
    });
    try {
      final headers = await _getHeaders();
      final response = await http.get(Uri.parse(Constants.carouselEndpoint),
          headers: headers);

      if (response.statusCode == 200) {
        setState(() {
          carouselImages = (jsonDecode(response.body)['carouselImages']
                  as List<dynamic>)
              .map((item) => item as Map<String, dynamic>)
              .toList()
            ..sort((a, b) => (a['order'] as int).compareTo(b['order'] as int));
        });
      } else {
        debugPrint('Failed to load carousel images: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint("Error fetching carousel images: $e");
    } finally {
      setState(() {
        isLoadingCarousel = false;
      });
    }
  }

  Future<void> _logout(BuildContext context) async {
    final authVM = ref.read(authViewModelProvider.notifier);
    await authVM.logout();
    if (context.mounted) {
      context.go('/login');
    }
  }

  Future<Map<String, String>> _getHeaders() async {
    final token = await tokenManager.getToken();
    if (token == null) {
      throw Exception('No token found');
    }
    return {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    };
  }

  Future<void> _fetchCategories() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final token = await tokenManager.getToken();
      if (token == null) {
        _error = 'No token found. Please log in again.';
      } else {
        final response = await http.get(
          Uri.parse('${Constants.manageProductApi}/categories'),
          headers: {
            'Authorization': 'Bearer $token',
          },
        );

        if (response.statusCode == 200) {
          final List<dynamic> data = json.decode(response.body);
          _categories = data
              .map((e) => Category.fromMap(e))
              .where((category) =>
                  category.isActive == '1') // Filter inactive categories
              .toList();
        } else {
          _error = 'Failed to load categories: ${response.statusCode}';
        }
      }
    } catch (e) {
      _error = 'Error fetching categories: $e';
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    }
  }

  void _loadMoreCategories() {
    setState(() {
      _visibleItemsCount += 9; // Load 9 more items at a time
    });
  }

  Widget _buildCarousel() {
    if (isLoadingCarousel) {
      return const Center(child: CircularProgressIndicator());
    }
    if (carouselImages.isEmpty) {
      return const Center(child: Text("No carousel images found."));
    }
    return Column(
      children: [
        CarouselSlider(
          options: CarouselOptions(
            height: 200.0,
            autoPlay: true,
            enlargeCenterPage: true,
            viewportFraction: 1.0, // Ensure it takes full width
            aspectRatio: 16 / 9,
            initialPage: 0,
            enableInfiniteScroll: true,
            autoPlayInterval: const Duration(seconds: 3),
            autoPlayAnimationDuration: const Duration(milliseconds: 800),
            onPageChanged: (index, reason) {
              setState(() {
                _currentCarouselIndex = index;
              });
            },
          ),
          items: carouselImages.map((image) {
            return Builder(
              builder: (BuildContext context) {
                return Image.network(
                  "${Constants.baseUrl}${image['path']}",
                  fit: BoxFit.cover,
                  width: MediaQuery.of(context)
                      .size
                      .width, // Make image fill width
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: Colors.grey[300],
                      child: const Icon(
                        Icons.broken_image,
                        size: 40,
                        color: Colors.grey,
                      ),
                    );
                  },
                );
              },
            );
          }).toList(),
        ),
        SizedBox(
          height: 10,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              carouselImages.length,
              (index) => Container(
                margin: const EdgeInsets.symmetric(horizontal: 4.0),
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _currentCarouselIndex == index
                      ? Colors.orange
                      : Colors.grey, // Orange for active dot
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final userProfileState = ref.watch(userProfileNotifierProvider);
    final profile = userProfileState.profile;

    return Scaffold(
      drawer: Drawer(
        backgroundColor: Colors.white,
        child: Column(
          children: [
            Column(
              children: [
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
                      Navigator.of(context).pop();
                    },
                  ),
                ),
                ExpansionTile(
                  leading: const Icon(Icons.person),
                  title: const Text("My Account"),
                  trailing: Icon(
                    _isMyAccountExpanded ? Icons.remove : Icons.add,
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
    // Navigate to "My Orders" screen
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => UserProfileWidget(userId: _userId!), // Pass the userId
      ),
    );
  },
),

                    ),
                  ],
                ),
              ],
            ),
            Expanded(child: Container()),
            Padding(
              padding: const EdgeInsets.only(bottom: 0.0),
              child: Container(
                color: Colors.red,
                child: ListTile(
                  leading: const Icon(Icons.logout, color: Colors.white),
                  title: const Text("Logout",
                      style: TextStyle(color: Colors.white)),
                  onTap: () async {
                    Navigator.of(context).pop();
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
      appBar: AppBar(
        backgroundColor: Colors.red,
        title: const Text('Home', style: TextStyle(color: Colors.white)),
        centerTitle: true,
        iconTheme:
            const IconThemeData(color: Colors.white), // Set icon color to white
        actions: [],
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
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
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
            if (!isLoadingCarousel && carouselImages.isNotEmpty)
              _buildCarousel(),
            HomeScreenVariousOrderWidget(
              imagePath: 'assets/images/main-banner3.jpg',
              orderText: 'From previous order',
              onTap: () {
                context.push('/previous_order');
              },
            ),
            Padding(
              padding: const EdgeInsets.only(left: 8.0, right: 8.0),
              child: Container(
                height: 60,
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: Color.fromARGB(255, 205, 203, 203),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(5),
                    topRight: Radius.circular(5),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Shop By Category',
                        style: TextStyle(
                          color: Color.fromARGB(255, 103, 102, 102),
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                      ),
                      SizedBox(
                        height: 50,
                        width: 50,
                        child: Image.asset('assets/images/ads-tagline.jpg'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            _loading
                ? const Center(child: CircularProgressIndicator())
                : _error != null
                    ? Center(child: Text(_error!))
                    : _categories == null || _categories!.isEmpty
                        ? const Center(child: Text("No categories available."))
                        : Padding(
                            padding:
                                const EdgeInsets.only(left: 8.0, right: 8.0),
                            child: GridView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount:
                                  _visibleItemsCount > _categories!.length
                                      ? _categories!.length
                                      : _visibleItemsCount,
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 3,
                                crossAxisSpacing: 0,
                                mainAxisSpacing: 0,
                                childAspectRatio: 0.9,
                              ),
                              itemBuilder: (context, index) {
                                final category = _categories![index];
                                late Color cardColor;
                                try {
                                  cardColor =
                                      Color(int.parse('0xFF${category.color}'));
                                } catch (e) {
                                  cardColor = Colors.grey;
                                }
                                final imageUrl =
                                    '${Constants.baseUrl}${category.image}';
                                return GestureDetector(
                                  onTap: () {
                                    context.push(
                                        '/products_with_units_by_category/${category.id}/${category.name}');
                                  },
                                  child: Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(0),
                                      border: Border.all(color: Colors.grey),
                                    ),
                                    clipBehavior: Clip.antiAlias,
                                    child: Stack(
                                      children: [
                                        Positioned.fill(
                                          child: Container(
                                            padding: const EdgeInsets.all(8),
                                            child: Image.network(
                                              imageUrl,
                                              fit: BoxFit.contain,
                                              errorBuilder:
                                                  (context, error, stackTrace) {
                                                return Container(
                                                  color: Colors.grey[300],
                                                  child: const Icon(
                                                    Icons.broken_image,
                                                    size: 40,
                                                    color: Colors.grey,
                                                  ),
                                                );
                                              },
                                            ),
                                          ),
                                        ),
                                        Positioned(
                                            top: 6,
                                            left: 6,
                                            child: Container(
                                              width: 40,
                                              decoration: BoxDecoration(
                                                color: Colors.red,
                                                borderRadius:
                                                    BorderRadius.circular(5),
                                              ),
                                              child: Column(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Text(
                                                    'Up to',
                                                    style: Theme.of(context)
                                                        .textTheme
                                                        .bodySmall
                                                        ?.copyWith(
                                                          color:
                                                              Theme.of(context)
                                                                  .colorScheme
                                                                  .onPrimary,
                                                          fontSize: 7,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                        ),
                                                  ),
                                                  Text(
                                                    '${category.percentOff}%',
                                                    style: Theme.of(context)
                                                        .textTheme
                                                        .bodySmall
                                                        ?.copyWith(
                                                          color:
                                                              Theme.of(context)
                                                                  .colorScheme
                                                                  .onPrimary,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          fontSize: 16,
                                                        ),
                                                  ),
                                                  Text(
                                                    'Off',
                                                    style: Theme.of(context)
                                                        .textTheme
                                                        .bodySmall
                                                        ?.copyWith(
                                                          color:
                                                              Theme.of(context)
                                                                  .colorScheme
                                                                  .onPrimary,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          fontSize: 7,
                                                        ),
                                                  ),
                                                ],
                                              ),
                                            )),
                                        Positioned(
                                          bottom: 0,
                                          left: 0,
                                          right: 0,
                                          child: Text(
                                            category.name,
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodyMedium
                                                ?.copyWith(
                                                  color: Colors.black,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                            textAlign: TextAlign.center,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
            if (_categories != null && _visibleItemsCount < _categories!.length)
              Padding(
                padding: const EdgeInsets.only(left: 8.0, right: 8.0),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _loadMoreCategories,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 205, 203, 203),
                      foregroundColor: Colors.green,
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(5),
                          bottomRight: Radius.circular(5),
                        ),
                      ),
                    ),
                    child: const Text("Load More"),
                  ),
                ),
              ),
            SizedBox(height: 8),
            HomeScreenVariousOrderWidget(
              imagePath: 'assets/images/main-banner2.jpg',
              orderText: 'Seasonal Fruits & Veggies',
              onTap: () {
                context.push('/is_seasonal');
              },
            ),
            SizedBox(height: 8),
            if (!isLoadingCarousel && carouselImages.isNotEmpty)
              _buildCarousel(),
            HomeScreenVariousOrderWidget(
              imagePath: 'assets/images/main-banner1.jpg',
              orderText: 'New Launches',
              onTap: () {
                context.push('/new_launch');
              },
            ),
            HomeScreenVariousOrderWidget(
              imagePath: 'assets/images/main-banner7.jpg',
              orderText: 'Recommendations for you',
              onTap: () {
                context.push('/is_recommendad');
              },
            ),
          ],
        ),
      ),
    );
  }
}
