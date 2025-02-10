import 'package:flutter/material.dart';
import 'package:online_dukans_user/core/config/common_widgets/custom_app_bar.dart';
//import 'package:onlinedukans_user/core/config/common_widgets/custom_app_bar.dart';

class MyWallet extends StatelessWidget {
  const MyWallet({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/images/bgimg6.jpg'),
          fit: BoxFit.cover,
          alignment: Alignment.centerLeft,
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: CustomAppBar(title: 'My Wallet',centerTitle: true,),
        body: Padding(
          padding: const EdgeInsets.only(left: 8.0, right: 8.0, top: 8.0),
          child: SizedBox(
            height: MediaQuery.of(context).size.height, // Full screen height
            child: Column(
              children: [
                // 30% green section
                Expanded(
                  flex: 3, // 30% of the screen height
                  child: Container(
                    width: double.infinity,
                    color: Colors.green,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          'wallet cash',
                          style: TextStyle(color: Colors.white),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Text(
                          '₹ 0.00',
                          style: TextStyle(color: Colors.white, fontSize: 15),
                        ),
                      ],
                    ),
                  ),
                ),
                // 70% grey section
                Expanded(
                  flex: 7, // 70% of the screen height
                  child: Container(
                    color: Color.fromARGB(255, 243, 242, 242),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
