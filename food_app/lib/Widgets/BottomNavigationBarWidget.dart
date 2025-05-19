import 'package:flutter/material.dart';
import 'package:food_app/globals.dart';
import 'FreshFood.dart';
import 'ExpiredFood.dart';

class BottomNavigationBarWidget extends StatelessWidget {
  const BottomNavigationBarWidget({super.key});

  @override
  Widget build(context) {
    return NavigationBar(
      destinations: [
        NavigationDestination(
          icon: Icon(Icons.dining),
          label: 'Fresh foods',
        ),
        NavigationDestination(
          icon: Icon(Icons.apple), 
          label: 'Expired foods',
        ),
      ],
      selectedIndex: selectedDestinationIndex,
      onDestinationSelected: (value) {
          // Navigator.push(context,MaterialPageRoute(builder: (context) => ExpiredFoods()));
          selectedDestinationIndex = value;
          switch(value) {
            case 0: Navigator.push(context,MaterialPageRoute(builder: (context) => FreshFood()));
            case 1: Navigator.push(context,MaterialPageRoute(builder: (context) => ExpiredFood()));
          }
      },
    );
  }
}