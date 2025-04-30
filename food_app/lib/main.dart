import 'package:flutter/material.dart';
import 'package:food_app/noti.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized;

  Noti().initNotification;
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: ElevatedButton(
            onPressed: () {
              Noti().showNotification(
                title: 'titel',
                body: 'her står der tekst',
              );
            },
            child: const Text('plz'),
          ),
        ),
      ),
    );
  }
}
