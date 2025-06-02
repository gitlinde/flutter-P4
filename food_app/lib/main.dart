import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'globals.dart';
import 'Widgets/FreshFood.dart';
import 'DB/Pocketbase.dart' as db;

// from flutter local notification docs https://pub.dev/packages/flutter_local_notifications
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

// TODO - the more up the TODO, the more urgent
// Have sort the list by default
// Make the form / user input more user friendly
// Add edit / info button
// When updating allFoodItems list, put expired items into the expiredFoodItems list

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  //tz for timezones, initialize it
  tz.initializeTimeZones();
  tz.setLocalLocation(tz.getLocation('Europe/Copenhagen')); //hardcoded
  
  if(await Permission.notification.isDenied) {
    await Permission.notification.request();
  }

  await localNotifications.initialize(InitializationSettings(android: AndroidInitializationSettings('notif_icon')));

  allFoodItems.addAll(await db.fetchAllFoodItems());
  
  runApp(
    MaterialApp(
      home: FreshFood(),
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
        seedColor: Color.fromARGB(255, 60, 255, 0),brightness: Brightness.dark),
      ),
    ),
  );
}