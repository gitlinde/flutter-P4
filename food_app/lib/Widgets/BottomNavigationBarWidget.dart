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
          selectedDestinationIndex = value;
          switch(value) {
            // from https://docs.flutter.dev/ui/navigation
            // This works but we never pop from navigator, so we need to fix it up later
            case 0: Navigator.push(context, MaterialPageRoute(builder: (context) => FreshFood()));
            case 1: Navigator.push(context, MaterialPageRoute(builder: (context) => ExpiredFood()));
          }
      },
    );
  }
}