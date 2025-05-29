// import 'package:flutter/widgets.dart';
import 'package:food_app/Models/FoodNotification.dart';



class FoodItem {
  final String name;
  final DateTime expiryDate;
  late final List<FoodNotification> notifications = _getNotifications(expiryDate);
  
  final List<int> notificationIds = [];
  String? id;

  final DateTime todayOnlyDay = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);

  int get daysUntilExpiry => expiryDate.difference(todayOnlyDay).inDays; // +1 coz otherwise tomorrow is in 0 days //may be wrong lol 
  FoodItem({required this.name, required this.expiryDate, this.id});

  String getDisplayString() {

    String dateString = expiryDate.toString().split(' ')[0];
    List<String> dateStrings = dateString.split('-');

    String dayString = dateStrings[2];
    String monthString = dateStrings[1];
    String yearString = dateStrings[0];

    // string interpolation would be better
    return name + " - " + dayString + "/" + monthString + "/" + yearString + " - Expires in " + daysUntilExpiry.toString() + " days";
  }

  List<FoodNotification> _getNotifications(DateTime expiryDate) {
    print("_getFoodNotifications ran!");
    final DateTime todayOnlyDay = DateTime(
      DateTime.now().year,
      DateTime.now().month,
      DateTime.now().day,
    );
    
    expiryDate = DateTime(
      expiryDate.year,
      expiryDate.month,
      expiryDate.day,
    );
    
    final int dayDiff = expiryDate.difference(todayOnlyDay).inDays;
    final List<FoodNotification> notificationDates = [];
    final int maxDaysBeforeNotification = 3;
    int cappedDayDiff = dayDiff;

    if(dayDiff > maxDaysBeforeNotification) {
      cappedDayDiff = maxDaysBeforeNotification;
    }
    
    for(int i = cappedDayDiff; i >= 0; --i) {
      notificationDates.add(_getSingleFoodNotificaction(expiryDate, i));
    }

    print(notificationDates);

    return notificationDates;
  }

  FoodNotification _getSingleFoodNotificaction(DateTime expiryDate, int dayDiff) {
    if(dayDiff < 0 || dayDiff > 3) {
      throw Exception("dayDiff is invalid in _getSingleFoodNotificaction. dayDiff: " + dayDiff.toString());
    }
    
    return FoodNotification(
      notificationDate: _getValidNotificationDate(expiryDate, dayDiff), 
      daysUntilExpiry: dayDiff,
      foodName: name,
    );
  }

  DateTime _getValidNotificationDate(DateTime expiryDate, int dayDiff) {
    // one bad thing about this method is that
    // it sends a notification to you 2 days before expiry 
    // even if that's the same day you registered the food item

    DateTime notifactionDate = expiryDate.subtract(Duration(days: dayDiff));

    final todayOnlyDay = DateTime(
      DateTime.now().year,
      DateTime.now().month,
      DateTime.now().day,
    );

    // if the notification date is the same as today
    if(notifactionDate.difference(todayOnlyDay) == Duration(/*no args means no duration*/)) {
      return DateTime.now().add(Duration(hours: 3));
      // return DateTime.now().add(Duration(seconds: 10));
    }
    return expiryDate.subtract(Duration(days: dayDiff)).add(Duration(hours: 9));
  }
}