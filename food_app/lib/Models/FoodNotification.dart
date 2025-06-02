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

Future<List<int>> scheduleNotificationsAndRetrieveIds(FoodItem foodItem) async {
  List<int> notificationIds = [];

  print("");
  for(FoodNotification notification in foodItem.notifications) {
    print(notification.titleMessage);
    print(notification.subTitleMessage);
    print(notification.notificationDate);

    print(" ");
  }

  for(int i = 0; i < foodItem.notifications.length; ++i) {
    final notification = foodItem.notifications[i];

    // if you add another item within 3 seconds this approach won't work
    // a hashing algorithm would be better, but doesn't matter for us right now.
    int notificationId = DateTime.now().unixtime + i;
    notificationIds.add(notificationId);

    tz.TZDateTime timeToNotify = tz.TZDateTime.from(notification.notificationDate, tz.getLocation('Europe/Copenhagen'));
    
    await localNotifications.zonedSchedule(
      notificationId, //generate a unique id https://pub.dev/documentation/unixtime/latest/
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
  return notificationIds;
}

void removeNotifications(List<int> notificationIds) {
  for(int notificationId in notificationIds) {
    localNotifications.cancel(notificationId);
  }
}

// REMOVE THIS METHOD
// Future<void> reloadNotifications() async {
//   localNotifications.cancelAll();
//   print("cancelled all notifications, schedueling new ones!");
//   for(FoodItem foodItem in allFoodItems) {
//     scheduleNotificationsAndRetrieveIds(foodItem);
//   }
// }