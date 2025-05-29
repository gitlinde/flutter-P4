import 'package:flutter/material.dart';
import 'package:food_app/Models/FoodNotification.dart';
import 'package:food_app/globals.dart';
import '../Models/FoodItem.dart';
import 'dart:math';
import 'BottomNavigationBarWidget.dart';
import 'package:food_app/DB/Pocketbase.dart' as db;
import 'package:food_app/Widgets/FormWidget.dart';


List<FoodItem> sortByExpiryDate(bool descending) {
  List<FoodItem> sorted = allFoodItems;

  if(descending) {
    sorted.sort((a,b) => a.daysUntilExpiry.compareTo(b.daysUntilExpiry));
    return sorted;
  }

  sorted.sort((a,b) => b.daysUntilExpiry.compareTo(a.daysUntilExpiry));
  return sorted;
}

FoodItem getRandomFoodItem() {

  DateTime expiryDate = DateTime.now();

  final int randomInt = Random().nextInt(15);
  expiryDate = DateTime.now().add(Duration(days: randomInt));

  List<String> foodNames = [
    'Apple', 'Banana', 'Bread', 'Cheese', 'Carrot',
    'Tomato', 'Milk', 'Eggs', 'Yogurt', 'Chicken',
    'Rice', 'Pasta', 'Beans', 'Cereal', 'Fish',
    'Steak', 'Orange', 'Lettuce', 'Broccoli', 'Potato',
    'Pizza', 'Burger', 'Ice Cream', 'Cake', 'Soup',
    'Sausage', 'Bacon', 'Mushroom', 'Onion', 'Peach',
  ];
  
  return FoodItem(name: foodNames[Random().nextInt(30)], expiryDate: expiryDate);
}

class FreshFood extends StatefulWidget {
  const FreshFood({super.key});

  @override
  State<FreshFood> createState() => _FreshFoodState();
}

class _FreshFoodState extends State<FreshFood> {
  Future<void> addRandomFoodItem(List<FoodItem> foodItems) async {
    await db.addFoodItem(getRandomFoodItem());
    setState(() =>
      print('added random food item to db'),
    );
  }

  @override
  void initState() {
    super.initState();
    setState(() {}); // i think i need this
    // put expired food items in expired category
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        titleSpacing: homeMargin,
        automaticallyImplyLeading: false,
        // backgroundColor: Color.fromARGB(255, 133, 134, 167),
        title: Row( //could be wrapped in Center?
          children: [
            Text('Fresh foods'), 
            Spacer(),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  allFoodItems = sortByExpiryDate(sortByDescending); //no reason for this to be in setState, just needs to be onPressed
                });
                sortByDescending = !sortByDescending;
                // setState(()=>{}); can be empty like this
              },
              child: Text('Sort by expiry date')
            ),
            if(sortByDescending) Icon(Icons.arrow_downward) else Icon(Icons.arrow_upward) //USE ICON
            // if(sortByDescending) Text("⬇️") else Text("⬆️") //USE ICON
          ]
        ),
      ),
      body: ListView(
        children: [
          for(int i = 0; i < allFoodItems.length; ++i)
            FoodItemWidget(foodItem: allFoodItems[i], onDelete: () => setState(() {}),),
          // ElevatedButton( 
          //   onPressed:() {
          //     addRandomFoodItem(allFoodItems);
          //     // getFirstRow();
          //   },
          //   // onPressed: () => print('press'),
          //   child: Icon(Icons.add_rounded)
          // ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => {
          Navigator.push(context,MaterialPageRoute(builder: (context) => FormWidget()))
        }, 
        // backgroundColor: Color.fromARGB(255, 104, 71, 123),
        child: Icon(Icons.add),
      ),
      bottomNavigationBar: BottomNavigationBarWidget(),
    );
  }
}

class FoodItemWidget extends StatefulWidget {
  const FoodItemWidget({required this.foodItem, super.key, required this.onDelete});

  final FoodItem foodItem;

  // we have to do this because we want to set the state of a parent widget (FreshFoodState) 
  // this is so the list of food items gets updated in the ui
  final VoidCallback onDelete; // setState should be called onDelete

  @override
  State<FoodItemWidget> createState() => _FoodItemWidgetState();
}

class _FoodItemWidgetState extends State<FoodItemWidget> {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(width: homeMargin),
        Expanded(
          child: Container( 
            height: 50,
            // color: const Color.fromARGB(255, 17, 212, 212),
            decoration: BoxDecoration(
              border: Border.all(
                color: Colors.white
              ),
            ),
            child: Row(
              children: [
                SizedBox(width: 15),
                Text(widget.foodItem.getDisplayString()),
                Spacer(),
                ElevatedButton(
                  onPressed: () async => {
                    allFoodItems.removeWhere((foodInList) => foodInList.id == widget.foodItem.id),
                    db.deleteFoodItem(widget.foodItem.id), 
                    widget.onDelete(), // visually show the update before using an async method
                    removeNotifications(widget.foodItem.notificationIds)

                    // await reloadNotifications(), //delete all notifications and add them back
                    // print(allFoodItems[foodItem.index].name + foodItem.name)
                  },
                  child: Icon(Icons.delete)
                ),
                SizedBox(width: 10)
              ],
            ),
          ),
        ),
        SizedBox(width: homeMargin)
      ]
    );
  }
}