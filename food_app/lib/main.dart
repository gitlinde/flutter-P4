import 'package:flutter/material.dart';
import 'package:pocketbase/pocketbase.dart';
import 'dart:math';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:unixtime/unixtime.dart';

// from flutter local notification docs https://pub.dev/packages/flutter_local_notifications
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

void debugMethod() {
  print('DEBUGGING!!');
}

// TODO - the more up the TODO, the more urgent

// Add notification package
// Initialize notification package variables
// Make a notification occur at a specific time
  // import timezone, use zonedSchedule

// Each time a food item is added; schedule that item as a notification
// Each time a food item is deleted; clear all scheduled notifications

// Show asc/desc and have sort the list by default

// Make the form / user input more user friendly


// Add edit / info button
// Move the delete button to the right and change icon
// When updating allFoodItems list, put expired items into the expiredFoodItems list







final FlutterLocalNotificationsPlugin localNotifications = FlutterLocalNotificationsPlugin();



// split list into two later for expired foods
List<FoodItem> allFoodItems = []; 
// List<FoodItem> freshFoodItems = [];
List<FoodItem> expiredFoodItems = []; 

int selectedDestinationIndex = 0;

/// The margin on the home screen from the left and right 'walls' of the screen
double homeMargin = 20;

// RUN POCKETBASE: pocketbase.exe serve --http="0.0.0.0:8090"
PocketBase pocketBase = PocketBase('http://192.168.0.155:8090');
// PocketBase pocketBase = PocketBase('http://localhost:8090');

bool sortByDescending = true;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  //tz for timezones, initialize it
  tz.initializeTimeZones();
  tz.setLocalLocation(tz.getLocation('Europe/Copenhagen')); //hardcoded

  // openExactAlarmSettings();
  
  
  
  if(await Permission.notification.isDenied) {
    await Permission.notification.request();
  }





  await localNotifications.initialize(InitializationSettings(android: AndroidInitializationSettings('notif_icon')));

  allFoodItems.addAll(await fetchAllFoodItems());
  
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


void scheduleNotification(/*DateTime time, */FoodItem foodItem) async {
  // FoodItem has an expiry date, so maybe we only need the foodItem?

  // Subtracts 3 days from expiry date (which is at midnight), then adds 9 hours. Notificaiton at 9 AM.
  DateTime timeToNotify = foodItem.expiryDate.subtract(Duration(days: 3)).add(Duration(hours: 9));
  
  // Change notification to 5 seconds after adding to test
  // timeToNotify = DateTime.now().add(Duration(seconds: 5));
  
  final tzDateTime = tz.TZDateTime.from(timeToNotify, tz.getLocation('Europe/Copenhagen'));

  
  print("TIME OF NOTIFICATION: " + timeToNotify.toString());
  
  // an error happens if the user uses a date which is less than 3 days (at 9am) before it expires
  // can be fixed in FoodItem class and by checking input
  await localNotifications.zonedSchedule(
    DateTime.now().unixtime, //generate a unique id https://pub.dev/documentation/unixtime/latest/
    // using string interpolation coz the yellow line made me angry
    "${foodItem.name} is about to expire!",
    "Your ${foodItem.name.toLowerCase()} expires in ${foodItem.daysUntilExpiry.toString()} days ${generateNotifEmoji()}",
    tzDateTime.add(Duration(seconds: 5)),
    NotificationDetails(android: AndroidNotificationDetails(
      'channel_id',
      'Basic Notifications',
      importance: Importance.defaultImportance,
      priority: Priority.defaultPriority,
    )),
    androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle
  );
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
  // the ! is used since we know every foodItem has an id. Probably better to have error handling
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

  return foodItemPushedToDb.id;
}

/// Adds a foodItem to allFoodItems list and pushes it to the db.
Future<void> addFoodItem(FoodItem foodItem) async {
  scheduleNotification(foodItem);
  String foodItemId = await pushFoodItemToDb(foodItem);
  foodItem.id = foodItemId;
  allFoodItems.add(foodItem);
}

List<FoodItem> sortByExpiryDate(bool descending) {
  List<FoodItem> sorted = allFoodItems;

  if(descending) {
    sorted.sort((a,b) => a.daysUntilExpiry.compareTo(b.daysUntilExpiry));
    return sorted;
  }

  sorted.sort((a,b) => b.daysUntilExpiry.compareTo(a.daysUntilExpiry));
  return sorted;
}

class FreshFood extends StatefulWidget {
  const FreshFood({super.key});

  @override
  State<FreshFood> createState() => _FreshFoodState();
}

class _FreshFoodState extends State<FreshFood> {
  Future<void> addRandomFoodItem(List<FoodItem> foodItems) async {
    await addFoodItem(getRandomFoodItem());
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
          // if(false) ElevatedButton( 
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
  final VoidCallback onDelete;

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
                  onPressed: () => {
                    allFoodItems.removeWhere((foodInList) => foodInList.id == widget.foodItem.id),
                    deleteFoodItem(widget.foodItem.id), 
                    widget.onDelete(),
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

class BottomNavigationBarWidget extends StatelessWidget {
  const BottomNavigationBarWidget({super.key});

  @override
  Widget build(context) {

    // return BottomNavigationBar(items: [items])


    return NavigationBar(
      destinations: [
        NavigationDestination(
          icon: Icon(Icons.dining),
          label: 'Fresh foods',
        ),
        NavigationDestination(
          icon: Icon(Icons.apple), 
          label: 'Expired foods',
        ),
      ],
      selectedIndex: selectedDestinationIndex,
      onDestinationSelected: (value) {
          // Navigator.push(context,MaterialPageRoute(builder: (context) => ExpiredFoods()));
          selectedDestinationIndex = value;
          switch(value) {
            case 0: Navigator.push(context,MaterialPageRoute(builder: (context) => FreshFood()));
            case 1: Navigator.push(context,MaterialPageRoute(builder: (context) => ExpiredFoods()));
          }
      },
    );
  }
}

// I'm a bit annoyed that the DateTime.now() saves what time of day it is as well. But it doesn't matter.
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


class FoodItem {
  final String name;
  final DateTime expiryDate;
  // final int index;
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

    return name + " - " + dayString + "/" + monthString + "/" + yearString + " - Expires in " + daysUntilExpiry.toString() + " days";
  }
}


class FormWidget extends StatefulWidget {
  const FormWidget({super.key});

  @override
  State<FormWidget> createState() => _FormWidgetState();
}

class _FormWidgetState extends State<FormWidget> {

  String foodName = '';

  // terrible name for a variable
  DateTime foodExpiryDate = DateTime.now();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Color.fromARGB(255, 56, 163, 127),brightness: Brightness.dark),
      ),
      home: Scaffold(
        body: Form(
          child: Column(
            children: [
              SizedBox(height: 50),
              SizedBox(
                width: 373,
                child: TextFormField(
                  onChanged: (value) {
                    foodName = value;
                    print(foodName);
                  },
                  decoration: InputDecoration(
                    label: Text('Food name'),
                    // hintText: 'Food name',
                    // hintStyle: TextStyle(color: Color.fromARGB(160, 240, 227, 227))
                  ),
                ),
              ),
              SizedBox(height: 20),
               Row(
                 children: [
                    ElevatedButton(onPressed: () {
                      print('minus 1');
                    }, child: Icon(Icons.exposure_minus_1)),
                    SizedBox(
                    width: 100,
                    child: TextFormField(
                      onChanged: (value) {
                        if(value.isEmpty || value.length != 10) {
                          return;
                        }
                        List<String> inputs = value.split('/');
                    
                        String dd = inputs[0];
                        String mm = inputs[1];
                        String yyyy = inputs[2];
                    
                        DateTime date = DateTime(int.parse(yyyy), int.parse(mm), int.parse(dd));
                    
                        foodExpiryDate = date;
                        // print(foodExpiryDate);
                      },
                      decoration: InputDecoration(
                        // hintText: 'dd/mm/yyyy',
                        label: Text('dd/mm/yyyy'),
                        // hintStyle: TextStyle(color: Color.fromARGB(100, 0, 0, 0))
                      ),
                    ),
                  ),
                  ElevatedButton(onPressed: () {
                    print('plus 1');
                  }, child: Icon(Icons.exposure_plus_1)),
                 ]
               ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async => {
                  print(foodName.length),
                  if(foodName.isNotEmpty) {
                    print("CURRENT EXPIRY: " + foodExpiryDate.toString()),
                    await addFoodItem(FoodItem(name: foodName, expiryDate: foodExpiryDate)),
                  },
                  // runApp(FreshFood())
                  Navigator.push(context,MaterialPageRoute(builder: (context) => FreshFood()))
                },
                child: Text('Submit')
              )
            ],
          ),
        ),
      ),   
    );
  }
}



class ExpiredFoods extends StatefulWidget {
  const ExpiredFoods({super.key});

  @override
  State<ExpiredFoods> createState() => _ExpiredFoodsState();
}

class _ExpiredFoodsState extends State<ExpiredFoods> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(child: Text('Expired foods')),
        automaticallyImplyLeading: false
      ),
      bottomNavigationBar: BottomNavigationBarWidget(),
      body: ListView(
        children: [
          for(int i = 0; i < expiredFoodItems.length; ++i)
            Container(
              height: 50,
              // color: const Color.fromARGB(255, 17, 212, 212),
              decoration: BoxDecoration(
                border: Border.all(
                  color: Colors.white
                ),
              ),
              child: Row(
                children: [
                  ElevatedButton(onPressed: () => print('xd'), child: Icon(Icons.info)),
                  Text(expiredFoodItems[i].getDisplayString()),
                ],
              ),
            ),
        ],
      ),
    );
  }
}