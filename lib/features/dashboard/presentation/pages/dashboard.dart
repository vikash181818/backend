import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'package:carousel_slider/carousel_slider.dart';
import 'package:online_dukans_user/core/config/common_widgets/confirmation_dialogue_box.dart';
import 'package:online_dukans_user/core/config/services/secure_storage_service.dart';
import 'package:online_dukans_user/core/config/services/unit_service.dart';
import 'package:online_dukans_user/core/config/utils/constants.dart';
import 'package:online_dukans_user/core/config/utils/token_manager.dart';
import 'package:online_dukans_user/features/categories/screen/categories_screen.dart';
import 'package:online_dukans_user/features/dashboard/presentation/viewmodels/user_profile_notifier.dart';
import 'package:online_dukans_user/features/dashboard/presentation/widgets/category_grid_widget.dart';
import 'package:online_dukans_user/features/dashboard/presentation/widgets/user_profile_widget.dart';
import 'package:online_dukans_user/features/product_listing/presentation/pages/basket_screen.dart';
import 'package:online_dukans_user/provider/auth_providers.dart';
class DashboardPage extends ConsumerStatefulWidget {
  const DashboardPage({super.key});

  @override
  ConsumerState<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends ConsumerState<DashboardPage> {
  int _selectedIndex = 0;
  String? _userId;
  List<dynamic> carouselImages = [];
  bool isLoadingCarousel = true;
  final TokenManager _tokenManager = TokenManager(SecureStorageService());

  @override
  void initState() {
    super.initState();
    // Load carousel images
    fetchCarouselImages();

    // Check if user is authenticated from authViewModelProvider
    final authState = ref.read(authViewModelProvider);
    final user = authState.user;
    if (user != null) {
      _userId = user.id;
      // Load user profile from the server
      Future.microtask(() {
        ref.read(userProfileNotifierProvider.notifier).loadUserProfile(user.id);
      });
    }
    
  }

  Future<Map<String, String>> _getHeaders() async {
    final token = await _tokenManager.getToken();
    return {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    };
  }

  Future<void> fetchCarouselImages() async {
    setState(() {
      isLoadingCarousel = true;
    });
    try {
      final headers = await _getHeaders();
      final response = await http.get(Uri.parse(Constants.carouselEndpoint),
          headers: headers);

      debugPrint("Response carousel: ${response.body}");

      if (response.statusCode == 200) {
        setState(() {
          carouselImages = (jsonDecode(response.body)['carouselImages']
                  as List<dynamic>)
              .map((item) => item as Map<String, dynamic>)
              .toList()
            ..sort((a, b) => (a['order'] as int).compareTo(b['order'] as int));
        });
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

  Widget _buildCarousel() {
    if (isLoadingCarousel) {
      return const Center(child: CircularProgressIndicator());
    }
    if (carouselImages.isEmpty) {
      return const Center(child: Text("No carousel images found."));
    }
    return CarouselSlider(
      options: CarouselOptions(
        height: 200.0,
        autoPlay: true,
        enlargeCenterPage: true,
        viewportFraction: 0.9,
        aspectRatio: 16 / 9,
        initialPage: 0,
        enableInfiniteScroll: true,
        autoPlayInterval: const Duration(seconds: 3),
        autoPlayAnimationDuration: const Duration(milliseconds: 800),
      ),
      items: carouselImages.map((image) {
        return Builder(
          builder: (BuildContext context) {
            return Image.network(
              "${Constants.baseUrl}${image['path']}",
              fit: BoxFit.cover,
              width: MediaQuery.of(context).size.width,
            );
          },
        );
      }).toList(),
    );
  }

  Widget _buildBody(BuildContext context) {
    switch (_selectedIndex) {
      case 0:
        return const Column(
          children: [
            // if (!isLoadingCarousel && carouselImages.isNotEmpty)
            //   _buildCarousel(),
            Expanded(child: CategoryGridWidget()),
          ],
        );
      case 1:
        return const CategoriesScreen();

      case 2:
        return BasketWidget(
          unitService:
              UnitService(secureStorageService: SecureStorageService()),
        );
      case 3:
        if (_userId == null) {
          return const Center(child: Text("No user logged in"));
        }
        return UserProfileWidget(userId: _userId!);
      default:
        return const Center(child: Text("Unknown tab"));
    }
  }

  @override
  Widget build(BuildContext context) {
    final userProfileState = ref.watch(userProfileNotifierProvider);
    final profile = userProfileState.profile;

    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      drawer: Drawer(
        backgroundColor: Colors.white,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Top section of the drawer
            Column(
              children: [
                if (profile != null)
                  UserAccountsDrawerHeader(
                    accountName:
                        Text("${profile.firstName} ${profile.lastName}"),
                    accountEmail: Text(profile.email),
                    currentAccountPicture: CircleAvatar(
                      child:
                          Text(profile.firstName.substring(0, 1).toUpperCase()),
                    ),
                  )
                else
                  const UserAccountsDrawerHeader(
                    accountName: Text("Guest"),
                    accountEmail: Text(""),
                    currentAccountPicture: CircleAvatar(
                      child: Text('?'),
                    ),
                  ),
                ListTile(
                  leading: const Icon(Icons.home),
                  title: const Text("Home"),
                  onTap: () {
                    Navigator.of(context).pop(); // Close drawer
                    setState(() {
                      _selectedIndex = 0;
                    });
                  },
                ),
                const ListTile(
                  leading: Icon(Icons.man),
                )
              ],
            ),

            // Bottom section (Logout)
            Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: ListTile(
                leading: const Icon(Icons.logout, color: Colors.red),
                title: const Text("Logout"),
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
          ],
        ),
      ),
      body: _buildBody(context),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (newIndex) {
          setState(() {
            _selectedIndex = newIndex;
          });
        },
        backgroundColor: Colors.grey.shade600,
        selectedItemColor: Colors.red,
        unselectedItemColor: Colors.white,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.category_sharp),
            label: 'Category',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_basket),
            label: 'Basket',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
