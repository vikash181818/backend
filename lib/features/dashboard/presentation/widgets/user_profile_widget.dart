import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:online_dukans_user/core/config/common_widgets/confirmation_dialogue_box.dart';
import 'package:online_dukans_user/features/dashboard/presentation/viewmodels/user_profile_notifier.dart';
import 'package:online_dukans_user/provider/auth_providers.dart';


class UserProfileWidget extends ConsumerStatefulWidget {
  final String userId;
  const UserProfileWidget({super.key, required this.userId});

  @override
  ConsumerState<UserProfileWidget> createState() => _UserProfileWidgetState();
}

class _UserProfileWidgetState extends ConsumerState<UserProfileWidget> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref
          .read(userProfileNotifierProvider.notifier)
          .loadUserProfile(widget.userId);
    });
  }

  Future<void> _handleLogout(BuildContext context) async {
    final result = await ConfirmationDialog.show(
      context,
      title: 'Confirm Logout',
      message: 'Are you sure you want to logout?',
      confirmText: 'Logout',
      cancelText: 'Cancel',
    );

    if (result == true) {
      await ref.read(authViewModelProvider.notifier).logout();
      if (context.mounted) {
        context.go('/login');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final userProfileState = ref.watch(userProfileNotifierProvider);

    if (userProfileState.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (userProfileState.error != null) {
      return Center(child: Text('Error: ${userProfileState.error}'));
    }

    final profile = userProfileState.profile;
    if (profile == null) {
      return const Center(child: Text("No profile data found"));
    }

    return Scaffold(
      backgroundColor: Colors.white.withOpacity(0.9),
      appBar: AppBar(
        backgroundColor: Colors.red,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            // ✅ Navigate to the previous screen using GoRouter
            context.pop();
          },
        ),
        title: const Text(
          'My Account',
          style: TextStyle(
            color: Colors.white,
            fontSize: 17,
            fontWeight: FontWeight.normal,
          ),
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/images/bgimg6.jpg',
              fit: BoxFit.cover,
            ),
          ),
          Container(
            color: Colors.white.withOpacity(0.8),
          ),
          ListView(
            children: [
              Container(
                color: Colors.red.withOpacity(0.8),
                padding:
                    const EdgeInsets.symmetric(vertical: 15, horizontal: 16),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 40,
                      backgroundColor: Colors.white,
                      child: Text(
                        profile.firstName.substring(0, 1).toUpperCase(),
                        style: const TextStyle(fontSize: 25, color: Colors.red),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${profile.firstName} ${profile.lastName}',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.normal,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            profile.email,
                            style: const TextStyle(
                                fontSize: 14, color: Colors.white),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${profile.phone}',
                            style: const TextStyle(
                                fontSize: 14, color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              ListTile(
                leading: const Icon(Icons.shopping_bag, color: Colors.green),
                title: const Text("My Orders"),
                onTap: () {
                  context.push('/my_orders');
                },
              ),
              Divider(color: Colors.green, height: 1),
              ListTile(
                leading: const Icon(Icons.account_balance_wallet,
                    color: Colors.green),
                title: const Text("My Wallet"),
                onTap: () {
                  context.push('/my_wallet');
                },
              ),
              Divider(color: Colors.green, height: 1),
              ListTile(
                leading: const Icon(Icons.payment, color: Colors.green),
                title: const Text("My Payments"),
                onTap: () {
                  context.push('/my_payments');
                },
              ),
              Divider(color: Colors.green, height: 1),
              ListTile(
                leading: const Icon(Icons.headset_mic, color: Colors.green),
                title: const Text("Customer Service"),
                onTap: () {
                  context.push("/customer_service");
                },
              ),
              Divider(color: Colors.green, height: 1),
              ListTile(
                leading: const Icon(Icons.location_on, color: Colors.green),
                title: const Text("My Delivery Address"),
                onTap: () {
                  context.push("/delivery_addresses");
                },
              ),
              Divider(color: Colors.green, height: 1),
              ListTile(
                leading: const Icon(Icons.logout, color: Colors.green),
                title: const Text("Logout"),
                onTap: () {
                  _handleLogout(context);
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}
