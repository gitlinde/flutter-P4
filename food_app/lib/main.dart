import 'package:flutter/material.dart';
import 'package:food_app/noti.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  final noti = Noti(); 
  noti.initNotification();
  runApp(MainApp(noti: noti));
}

class MainApp extends StatelessWidget {
  final Noti noti;
  
  MainApp({super.key, required this.noti});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: ElevatedButton(
            onPressed: () {
              print('showing noti');
              noti.showNotification(
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
