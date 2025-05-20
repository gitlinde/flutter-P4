import 'dart:math';
import 'package:food_app/Models/FoodItem.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:food_app/globals.dart';
import 'package:unixtime/unixtime.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';


/// FoodNotification class that contains info about a specific notifications date and message
class FoodNotification {
  final DateTime notificationDate;
  final int daysUntilExpiry;
  final String foodName;

  FoodNotification({required this.notificationDate, required this.daysUntilExpiry, required this.foodName});

  get titleMessage => "$foodName is about to expire!";
  String get subTitleMessage {
    if(daysUntilExpiry == 0) {
      return "Your ${foodName.toLowerCase()} expires today! ${generateNotifEmoji()}";
    } else {
      return "Your ${foodName.toLowerCase()} expires in ${daysUntilExpiry.toString()} days ${generateNotifEmoji()}";
    }
  }
}

String generateNotifEmoji() {
  List<String> emojis = [
    '😞', '😔', '😟', '😕', '🙁', '☹️', '😢', '😭', '😫', '😩',
    '🥺', '😓', '😥', '😰', '😿', '🙀', '💔', '🫤', '😣', '😖',
    '😬', '🥲', '😶‍🌫️', '😮‍💨', '😵', '😱', '💀', '😋', '🤓', '🤨'
  ];
  
  // works because value of nextInt is >= 0 and < emojis.length. 
  int randomIndex = Random().nextInt(emojis.length);

  return emojis[randomIndex];
}


void scheduleNotifications(/*DateTime time, */FoodItem foodItem) async {
  // an error happens if the user uses a date which is less than 3 days (at 9am) before it expires
  // can be fixed in FoodItem class and by checking input

  for(FoodNotification notification in foodItem.notifications) {
    // DateTime fewSecondsFromNow = DateTime.now().add(Duration(seconds: 5));

    // This one is for testing // DOESN'T WORK ANYMORE BECAUSE OF THE LOOP!
    // tz.TZDateTime timeToNotify = tz.TZDateTime.from(fewSecondsFromNow, tz.getLocation('Europe/Copenhagen'));

    // This is the working version
    tz.TZDateTime timeToNotify = tz.TZDateTime.from(notification.notificationDate, tz.getLocation('Europe/Copenhagen'));
    
    // getting bug must be a date in the future

    await localNotifications.zonedSchedule(
      DateTime.now().unixtime, //generate a unique id https://pub.dev/documentation/unixtime/latest/
      // using string interpolation coz the blue lines made me angry
      notification.titleMessage,
      notification.subTitleMessage,
      timeToNotify,
      NotificationDetails(android: AndroidNotificationDetails(
        'channel_id',
        'Basic Notifications',
        importance: Importance.defaultImportance,
        priority: Priority.defaultPriority,
      )),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle
    );
  }
}