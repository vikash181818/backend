import 'package:flutter/material.dart';
import 'package:online_dukans_user/core/config/utils/constants.dart';
// import 'package:onlinedukans_user/core/config/utils/constants.dart';

class BasketDetailsScreen extends StatelessWidget {
  final List<dynamic> cartDetails;

  const BasketDetailsScreen({super.key, required this.cartDetails});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Cart Details"),
      ),
      body: ListView.builder(
        itemCount: cartDetails.length,
        itemBuilder: (context, index) {
          final item = cartDetails[index];
          return Card(
            margin: const EdgeInsets.all(8.0),
            child: ListTile(
              leading: item['image'] != null
                  ? Image.network(
                      "${Constants.baseUrl}${item['image']}",
                      width: 50,
                      height: 50,
                    )
                  : const Icon(Icons.image_not_supported),
              title: Text(item['productId']),
              subtitle: Text("Quantity: ${item['quantity']}"),
              trailing: Text("Price: ₹${item['price']}"),
            ),
          );
        },
      ),
    );
  }
}
