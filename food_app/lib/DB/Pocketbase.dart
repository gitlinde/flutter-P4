import 'package:pocketbase/pocketbase.dart';
import 'package:food_app/Models/FoodItem.dart';
import 'package:food_app/Models/FoodNotification.dart';
import 'package:food_app/globals.dart';

// RUN POCKETBASE: pocketbase.exe serve --http="0.0.0.0:8090"
PocketBase pocketBase = PocketBase('http://87.104.249.148:8090'); // on local network
// PocketBase pocketBase = PocketBase('http://localhost:8090'); // localhost

/// Adds a foodItem to allFoodItems list and pushes it to the db.
Future<void> addFoodItem(FoodItem foodItem) async {
  foodItem.notificationIds.addAll(await scheduleNotificationsAndRetrieveIds(foodItem));
  String foodItemId = await pushFoodItemToDb(foodItem);
  foodItem.id = foodItemId;
  allFoodItems.add(foodItem);
}

Future<List<FoodItem>> fetchAllFoodItems() async {
  List<FoodItem> foodItems = [];
  final records = await pocketBase.collection('food').getFullList();

  for(int i = 0; i < records.length; ++i) {
    String foodName = records[i].get('name');
    DateTime foodExpiryDate = DateTime.parse(records[i].get('expiry_date'));
    String foodId = records[i].get('id');

    FoodItem foodItem = FoodItem(name: foodName, expiryDate: foodExpiryDate, id: foodId);

    foodItems.add(foodItem);
  }

  return foodItems;
}

void deleteFoodItem(String? foodItemId) {
  // the ! is used here because we know every foodItem has an id. Probably better to have error handling
  pocketBase.collection('food').delete(foodItemId!);
}

/// Returns the PocketBase id of the newly created food item.
Future<String> pushFoodItemToDb(FoodItem foodItem) async {

  final foodItemPushedToDb = await pocketBase.collection('food').create(
    body: {
      'name': foodItem.name,
      'expiry_date': foodItem.expiryDate.toIso8601String(),
    }
  );

  Map<String, dynamic> notificationBody = {};

  for(int i = 0; i < foodItem.notificationIds.length; ++i) {
    print("notification:${foodItem.notificationIds[i]}");
    notificationBody['notificationId$i'] = foodItem.notificationIds[i];
  }

  pocketBase.collection('food').update(foodItemPushedToDb.id, body: notificationBody);
  return foodItemPushedToDb.id;
}