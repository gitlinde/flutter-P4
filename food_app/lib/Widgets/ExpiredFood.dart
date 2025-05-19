import 'package:flutter/material.dart';
import 'BottomNavigationBarWidget.dart';
import 'package:food_app/globals.dart';

class ExpiredFood extends StatefulWidget {
  const ExpiredFood({super.key});

  @override
  State<ExpiredFood> createState() => _ExpiredFoodState();
}

class _ExpiredFoodState extends State<ExpiredFood> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(child: Text('Expired foods')),
        automaticallyImplyLeading: false
      ),
      bottomNavigationBar: BottomNavigationBarWidget(),
      body: ListView(
        children: [
          for(int i = 0; i < expiredFoodItems.length; ++i)
            Container(
              height: 50,
              // color: const Color.fromARGB(255, 17, 212, 212),
              decoration: BoxDecoration(
                border: Border.all(
                  color: Colors.white
                ),
              ),
              child: Row(
                children: [
                  ElevatedButton(onPressed: () => print('xd'), child: Icon(Icons.info)),
                  Text(expiredFoodItems[i].getDisplayString()),
                ],
              ),
            ),
        ],
      ),
    );
  }
}