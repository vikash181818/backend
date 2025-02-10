import 'package:flutter/material.dart';
import 'package:online_dukans_user/core/config/common_widgets/custom_app_bar.dart';
import 'package:online_dukans_user/features/order_details/widgets/item_ordered.dart';
import 'package:online_dukans_user/features/order_details/widgets/summary_widget.dart';
// import 'package:onlinedukans_user/core/config/common_widgets/custom_app_bar.dart';
// import 'package:onlinedukans_user/features/order_detail/widget/item_ordered.dart';
// import 'package:onlinedukans_user/features/order_detail/widget/summary.dart';
// import 'package:onlinedukans_user/features/order_detail/widget/summary_widget.dart';

class OrderDetailScreen extends StatefulWidget {
  const OrderDetailScreen({super.key});

  @override
  State<OrderDetailScreen> createState() => _OrderDetailScreenState();
}

class _OrderDetailScreenState extends State<OrderDetailScreen>
    with TickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 223, 222, 222),
      appBar: CustomAppBar(title: 'Order Details', centerTitle: true),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // TabBar wrapped in a red Container
            Container(
              color: Colors.red,
              child: TabBar(
                controller: _tabController,
                tabs: const <Widget>[
                  Tab(text: 'SUMMARY'),
                  Tab(text: 'ITEM ORDERED'),
                ],
                labelColor: Colors.white,
                unselectedLabelColor: Colors.white,
                indicatorColor: Colors.green,
              ),
            ),
            SizedBox(
              height: 765, // Adjust height to fit content
              child: TabBarView(
                controller: _tabController,
                children: <Widget>[
                  // Overview Tab Content
                  SummaryWidget(),
                  // Specifications Tab Content
                  ItemOrderScreen(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
