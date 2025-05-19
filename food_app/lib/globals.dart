
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:food_app/Models/FoodItem.dart';



final FlutterLocalNotificationsPlugin localNotifications = FlutterLocalNotificationsPlugin();

// future plan is to split list into two for expired foods
List<FoodItem> allFoodItems = []; 

// List<FoodItem> freshFoodItems = [];
List<FoodItem> expiredFoodItems = []; 

int selectedDestinationIndex = 0;

/// The margin on the home screen from the left and right 'walls' of the screen
double homeMargin = 20;


bool sortByDescending = true;
