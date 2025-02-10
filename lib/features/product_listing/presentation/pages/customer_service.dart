import 'package:flutter/material.dart';

class CustomerServices extends StatelessWidget {
  const CustomerServices({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green,
      //appBar: CustomAppBar(title: 'Customer Services'),
      body: Padding(
        padding: const EdgeInsets.only(left: 8.0, right: 8.0, top: 8.0),
        child: SizedBox(
          height: MediaQuery.of(context).size.height, // Full screen height
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.call,
                    color: Colors.white,
                    size: 15,
                  ),
                  const SizedBox(
                    width: 5.0,
                  ),
                  SizedBox(
                      height: 15,
                      width: 15,
                      child: Image.asset('images/social.png')),
                  const SizedBox(
                    width: 5.0,
                  ),
                  const Text(
                    'Customer Care: +91 818 8888 123',
                    style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w500,
                        color: Colors.white),
                  )
                ],
              ),
              const Text(
                'Email Us : onlinedukans@outlook.com',
                style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w500,
                    color: Colors.white),
              )
            ],
          ),
        ),
      ),
    );
  }
}
