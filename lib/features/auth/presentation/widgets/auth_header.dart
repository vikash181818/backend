import 'package:flutter/material.dart';

class AuthHeader extends StatelessWidget {
  const AuthHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          color: Colors.white,
          height: 65,
          width: 65,
          child: FittedBox(
            fit: BoxFit.contain, // Image will fit within the box
            child: Image.asset(
              'assets/images/logo-original.png',
            ),
          ),
        ),
        SizedBox(height: 5),
        const Text.rich(
          TextSpan(
            children: [
              TextSpan(
                text: 'ONLINE ',
                style: TextStyle(
                  color: Colors.orange, // Set "ONLINE" to orange
                  fontWeight: FontWeight.normal,
                  fontSize: 10,
                ),
              ),
              TextSpan(
                text: 'DUKANS',
                style: TextStyle(
                  color: Colors.green, // Set "DUKANS" to green
                  fontWeight: FontWeight.normal,
                  fontSize: 10,
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 5),
        Text(
          'ONLINE DUKANS',
          style: TextStyle(
              color: Colors.red, fontSize: 18, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 5),
        Text(
          'We promise to amaze you always!',
          style: TextStyle(
              color: const Color.fromARGB(255, 60, 54, 244),
              fontSize: 15,
              fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}
