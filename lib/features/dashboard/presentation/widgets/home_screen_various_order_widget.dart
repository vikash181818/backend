import 'package:flutter/material.dart';

class HomeScreenVariousOrderWidget extends StatefulWidget {
  final String imagePath;
  final String orderText;
  final VoidCallback onTap;

  // Constructor with required parameters
  const HomeScreenVariousOrderWidget({
    super.key,
    required this.imagePath,
    required this.orderText,
    required this.onTap,
  });

  @override
  State<HomeScreenVariousOrderWidget> createState() => _HomeScreenVariousOrderWidgetState();
}

class _HomeScreenVariousOrderWidgetState extends State<HomeScreenVariousOrderWidget> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 8.0, right: 8.0, bottom: 5),
      child: Stack(
        children: [
          GestureDetector(
            onTap: widget.onTap,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(5), // Circular by 5 pixels
              child: SizedBox(
                width: double.infinity,
                height: 100,
                child: Image.asset(
                  widget.imagePath,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          Positioned(
            left: 0,
            top: 0,
            child: Container(
  decoration: const BoxDecoration(
    color: Colors.black87,
    borderRadius: BorderRadius.only(
      topLeft: Radius.circular(5),    // Top-left corner radius
      topRight: Radius.circular(10),  // Top-right corner radius
      bottomLeft: Radius.circular(0), // Bottom-left corner radius
      bottomRight: Radius.circular(35), // Bottom-right corner radius
    ),
  ),
  child: Padding(
    padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
    child: Text(
      widget.orderText,
      style: const TextStyle(fontSize: 17, color: Colors.white),
    ),
  ),
),

          ),
          Positioned(
            right: 0,
            bottom: 0,
            child: GestureDetector(
              onTap: widget.onTap,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(7),
                    topRight: Radius.circular(3),
                    bottomLeft: Radius.circular(20),
                    bottomRight: Radius.circular(3),
                  ),
                ),
                child: const Padding(
                  padding: EdgeInsets.all(4.0),
                  child: Text(
                    'TAP In',
                    style: TextStyle(fontSize: 15, color: Colors.white),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
