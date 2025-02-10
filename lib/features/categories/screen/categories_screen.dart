import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:online_dukans_user/features/categories/widgets/category_widget.dart';
// import 'package:onlinedukans_user/features/categories/widget/category_widget.dart';

class CategoriesScreen extends StatefulWidget {
  const CategoriesScreen({super.key});

  @override
  State<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.red,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () {
              Navigator.pop(context); // Navigate back to the previous screen
            },
          ),
          title: const Text(
            'Categories',
            style: TextStyle(
              color: Colors.white,
              fontSize: 17,
              fontWeight: FontWeight.normal,
            ),
          ),
          centerTitle: true, // Center the title
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 8.0, right: 8.0, top: 8.0),
              child: GestureDetector(
                onTap: () {
                  // Action for "Tap for All" if needed
                  context.push('/products_with_units');
                },
                child: Stack(
                  children: [
                    Container(
                      height: 110,
                      width: double.infinity,
                      decoration: const BoxDecoration(
                        color: Color.fromARGB(255, 205, 203, 203),
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(5), // Top-left corner radius
                          topRight:
                              Radius.circular(5), // Top-right corner radius
                        ),
                      ),
                      child: Center(
                        child: Text(
                          'Shop By Category',
                          style: TextStyle(
                            color: Color.fromARGB(255, 103, 102, 102),
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 5,
                      right: 2,
                      child: Container(
                        height: 35,
                        width: 120,
                        decoration: const BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.only(
                            topLeft:
                                Radius.circular(5), // Top-left corner radius
                            topRight:
                                Radius.circular(5), // Top-right corner radius
                            bottomLeft: Radius.circular(
                                20), // Bottom-left corner radius
                            bottomRight: Radius.circular(
                                5), // Bottom-right corner radius
                          ),
                        ),
                        child: const Center(
                          child: Text(
                            "TAP for All",
                            style: TextStyle(
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                    // Positioned(
                    //   top: 0,
                    //   left: 10,
                    //   child: TextButton(
                    //     onPressed: () {
                    //       // Action for "New Launch" if needed
                    //       context.push('/order_details');
                    //     },
                    //     child: const Text(
                    //       "New Launch",
                    //       style: TextStyle(
                    //         color: Colors.black,
                    //       ),
                    //     ),
                    //   ),
                    // ),
                  ],
                ),
              ),
            ),
            const Expanded(child: CategoryCustomWidget()),
          ],
        ));
  }
}
