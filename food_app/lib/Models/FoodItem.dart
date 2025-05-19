// import 'package:flutter/widgets.dart';
import 'package:food_app/Models/FoodNotification.dart';



class FoodItem {
  final String name;
  final DateTime expiryDate;
  late final List<FoodNotification> notifications = _getNotifications(expiryDate);
  
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
    
    int dayDiff = expiryDate.difference(todayOnlyDay).inDays;

    if(dayDiff == 0) {
      return [_getSingleNotificaction(expiryDate, dayDiff)];
    }
    
    List<FoodNotification> notificationDates = [];

    int cappedDayDiff = dayDiff;
  
    if(dayDiff > 3) {
      cappedDayDiff = 3;
    }
    
    for(int i = cappedDayDiff; i >= 0; --i) {
      // print(i);
      notificationDates.add(_getSingleNotificaction(expiryDate, i));
    }

    print(notificationDates);

    return notificationDates;
  }

  FoodNotification _getSingleNotificaction(DateTime expiryDate, int dayDiff) {
    // dayDiff == 2 days until expiry -notify 1 day before
    // dayDiff == 1 days until expiry -notify 0 days before (on the day)
    // dayDiff == 0 it's expiry day; maybe notify in evening
    if(dayDiff < 0) {
      throw Exception("dayDiff under 0");
    }

    FoodNotification? sameDayNotification;

    final todayOnlyDay = DateTime(
      DateTime.now().year,
      DateTime.now().month,
      DateTime.now().day,
    );

    // if submitted on same day as expired, give notification 3 hours later,
    // else: give notification on expiryDate at 9 AM
    if(todayOnlyDay == expiryDate) {
      sameDayNotification = FoodNotification(
        // we can use DateTime.now() here because expiryDate is same day as DateTime.now()
        notificationDate: DateTime.now().add(Duration(hours: 3)), 
        daysUntilExpiry: dayDiff,
        foodName: name, 
      );
    } else {
      sameDayNotification = FoodNotification(
        notificationDate: expiryDate.add(Duration(hours: 9)), 
        daysUntilExpiry: dayDiff,
        foodName: name, 
      );
    }

    
    switch (dayDiff) {
      case 0:
        return sameDayNotification;
      case 1:
        return FoodNotification(
          notificationDate: expiryDate.subtract(Duration(days: dayDiff)).add(Duration(hours: 9)), 
          daysUntilExpiry: dayDiff,
          foodName: name,
        );
      case 2:
        return FoodNotification(
          notificationDate: expiryDate.subtract(Duration(days: dayDiff)).add(Duration(hours: 9)), 
          daysUntilExpiry: dayDiff,
          foodName: name,
        ); 
      case 3:
        return FoodNotification(
          notificationDate: expiryDate.subtract(Duration(days: dayDiff)).add(Duration(hours: 9)), 
          daysUntilExpiry: dayDiff,
          foodName: name,
        ); 
      default:
        return FoodNotification(
          notificationDate: expiryDate.subtract(Duration(days: 3)).add(Duration(hours: 9)), 
          daysUntilExpiry: dayDiff,
          foodName: name,
        ); 
    }
  }
}


