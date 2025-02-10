import 'package:go_router/go_router.dart';
import 'package:online_dukans_user/core/config/services/secure_storage_service.dart';
import 'package:online_dukans_user/core/config/services/unit_service.dart';
import 'package:online_dukans_user/features/auth/presentation/pages/auth_screen.dart';
import 'package:online_dukans_user/features/auth/presentation/pages/forgot_password.dart';
import 'package:online_dukans_user/features/auth/presentation/pages/reset_password_page.dart';
import 'package:online_dukans_user/features/auth/presentation/pages/verify_email_screen.dart';
import 'package:online_dukans_user/features/dashboard/presentation/pages/dashboard.dart';
import 'package:online_dukans_user/features/dashboard/presentation/pages/search_product_page.dart';
import 'package:online_dukans_user/features/dashboard/presentation/widgets/user_profile_widget.dart';
import 'package:online_dukans_user/features/home/screen/from_previous_order.dart';
import 'package:online_dukans_user/features/home/screen/is_recommended.dart';
import 'package:online_dukans_user/features/home/screen/is_seasonal.dart';
import 'package:online_dukans_user/features/home/screen/new_launch.dart';
import 'package:online_dukans_user/features/order_details/screen/order_detail_screen.dart';
import 'package:online_dukans_user/features/product_listing/presentation/pages/all_products_page.dart';
import 'package:online_dukans_user/features/product_listing/presentation/pages/basket_screen.dart';
import 'package:online_dukans_user/features/product_listing/presentation/pages/customer_service.dart';
import 'package:online_dukans_user/features/product_listing/presentation/pages/my_payments_screen.dart';
import 'package:online_dukans_user/features/product_listing/presentation/pages/product_by_category_page.dart';
import 'package:online_dukans_user/features/product_listing/presentation/pages/wallet_screen.dart';
import 'package:online_dukans_user/features/user_profile/presentation/pages/add_new_delivery_address_page.dart';
import 'package:online_dukans_user/features/user_profile/presentation/pages/delivery_address_page.dart';
import 'package:online_dukans_user/features/user_profile/presentation/pages/edit_new_delevery_address_page.dart';
import 'package:online_dukans_user/setting/screen/my_orders.dart';

GoRouter createRouter(String initialLocation) {
  String? userId;
  return GoRouter(
    initialLocation: initialLocation,
    routes: [
      // Login Route
      // GoRoute(
      //   path: '/login',
      //   builder: (context, state) => const LoginPage(),
      // ),

      // // Signup Route
      // GoRoute(
      //   path: '/signup',
      //   builder: (context, state) => const SignupPage(),
      // ),
      GoRoute(
        path: '/auth',
        builder: (context, state) => const AuthPage(),
      ),

      GoRoute(
        path: '/my_payments',
        builder: (context, state) => const MyPayments(),
      ),

      GoRoute(
        path: '/my_orders',
        builder: (context, state) => const MyOrder(),
      ),

      GoRoute(
        path: '/user_profile',
        builder: (context, state) => UserProfileWidget(userId: userId!),
      ),

      GoRoute(
        path: '/basket_screen',
        builder: (context, state) => BasketWidget(
          unitService:
              UnitService(secureStorageService: SecureStorageService()),
        ),
      ),

      GoRoute(
        path: '/verify-email',
        builder: (context, state) {
          final token = state.uri.queryParameters['token'] ?? '';
          return VerifyEmailPage(token: token);
        },
      ),

      GoRoute(
        path: '/forgot-password',
        builder: (context, state) => const ForgotPasswordPage(),
      ),

      GoRoute(
        path: '/reset-password',
        builder: (context, state) => const ResetPasswordScreen(),
      ),
      //     GoRoute(
      //   path: '/verify-email',
      //   builder: (context, state) {
      //     final token = state.queryParams['token'] ?? '';
      //     return VerificationPage(token: token);
      //   },
      // ),

      // Dashboard Route

      GoRoute(
        path: '/dashboard',
        builder: (context, state) => const DashboardPage(),
      ),

      // Products By Category Route
      GoRoute(
        path: '/products_with_units_by_category/:categoryId/:categoryName',
        builder: (context, state) {
          final categoryId = state.pathParameters['categoryId']!;
          final categoryName = state.pathParameters['categoryName']!;
          return ProductsByCategoryPage(
              categoryId: categoryId, categoryName: categoryName);
        },
      ),

      //seasonal fruits and veggies

      GoRoute(
        path: '/products_with_units_by_category/:categoryId/:categoryName',
        builder: (context, state) {
          final categoryId = state.pathParameters['categoryId']!;
          final categoryName = state.pathParameters['categoryName']!;
          return ProductsByCategoryPage(
              categoryId: categoryId, categoryName: categoryName);
        },
      ),

      // Products With Units Route
      GoRoute(
        path: '/products_with_units',
        builder: (context, state) => const ProductsWithUnitsPage(),
      ),
      GoRoute(
        path: '/search_products',
        builder: (context, state) => const SearchProductsScreen(),
      ),

      GoRoute(
        path: '/customer_service',
        builder: (context, state) => const CustomerServices(),
      ),
      GoRoute(
        path: '/delivery_addresses',
        builder: (context, state) => const DeliveryAddressesPage(),
      ),

      GoRoute(
        path: '/add_new_delivery_address',
        builder: (context, state) => const AddNewDeliveryAddressPage(),
      ),

      // Edit Delivery Address Route
      GoRoute(
        path: '/edit_delivery_address/:id',
        builder: (context, state) {
          final addressId = state.pathParameters['id']!;
          return EditDeliveryAddressPage(addressId: addressId);
        },
      ),

//Home screen

//is_seasonal

      GoRoute(
        path: '/previous_order',
        builder: (context, state) => const PreviousOrder(),
      ),

      GoRoute(
        path: '/is_seasonal',
        builder: (context, state) => const IsSeasonal(),
      ),

      GoRoute(
        path: '/new_launch',
        builder: (context, state) => const IsNewLaunch(),
      ),

      GoRoute(
        path: '/is_recommendad',
        builder: (context, state) => const IsRecommendad(),
      ),

      //order details

      GoRoute(
        path: '/order_details',
        builder: (context, state) => const OrderDetailScreen(),
      ),

      GoRoute(
        path: '/order_details',
        builder: (context, state) => const OrderDetailScreen(),
      ),

      GoRoute(
        path: '/my_orders',
        builder: (context, state) => const MyOrder(),
      ),

      GoRoute(
        path: '/my_wallet',
        builder: (context, state) => const MyWallet(),
      ),

      GoRoute(
        path: '/my_payments',
        builder: (context, state) => const MyPayments(),
      ),
    ],
  );
}
