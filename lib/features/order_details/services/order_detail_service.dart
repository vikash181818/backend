import 'package:flutter/material.dart';
import 'package:online_dukans_user/core/config/common_widgets/custom_app_bar.dart';
// import 'package:onlinedukans_user/core/config/common_widgets/custom_app_bar.dart';

class OrderDetailServices extends StatefulWidget {
  const OrderDetailServices({super.key});

  @override
  State<OrderDetailServices> createState() => _OrderDetailServicesState();
}

class _OrderDetailServicesState extends State<OrderDetailServices> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: 'Order Details'),
      body: SingleChildScrollView(
        child: Column(children: []),
      ),
    );
  }
}
