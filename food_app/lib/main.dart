import 'package:flutter/material.dart';
import 'package:mysql1/mysql1.dart';
import 'dart:math';
// import ''


// TODO - the more up the TODO, the more urgent

// make db connection
// change index in FoodItem to a db id
// note; the current delete bug gets fixed with db connection
// add button to delete
// add edit food button


// be able to add to the list of foods
// // how to pick date for it?

// view the foods
// add expired foods

// maybe just look at MoSCoW and add from there.

void main() => runApp(
  MaterialApp(
    home: FreshFood(),
    debugShowCheckedModeBanner: false,
    theme: ThemeData(
      colorScheme: ColorScheme.fromSeed(
      seedColor: Color.fromARGB(255, 60, 255, 0),brightness: Brightness.dark),
    ),
  ),
);





Future<String> getFirstRow(/*ConnectionSettings settings*/) async {

  var settings = ConnectionSettings(
    host: 'localhost', 
    port: 3306,
    user: 'root',
    password: 'KENDATABASE123',
    db: 'food_db'
  );
  var connection = await MySqlConnection.connect(settings);
  var results = await connection.query('select name from food');
  await connection.close();
  print (results.first.toString());
  return results.first.toString();
}

// var conn = await MySqlConnection.connect(settings);


List<FoodItem> allFoodItems = []; 

List<FoodItem> freshFoodItems = []; 

List<FoodItem> expiredFoodItems = []; 


int selectedDestinationIndex = 0;

// Descending
List<FoodItem> sortByExpiryDate() {
  List<FoodItem> sorted = allFoodItems;

  sorted.sort((a,b) => a.daysUntilExpiry.compareTo(b.daysUntilExpiry));

  return sorted;
}



class FreshFood extends StatefulWidget {
  const FreshFood({super.key});

  @override
  State<FreshFood> createState() => _FreshFoodState();
}

class _FreshFoodState extends State<FreshFood> {

  void addCustomFoodItem(List<FoodItem> foodItems) {
    setState(() =>
      foodItems.add(getRandomFoodItem())
    );
  }
  // List<FoodItem> foodItems = [];

  void addFoodItems() {
    for(int i = 0; i < 1; ++i) {
      allFoodItems.add(getRandomFoodItem());
      expiredFoodItems.add(getRandomFoodItem());
    }
  }

  @override
  void initState() {
    super.initState();
    if(allFoodItems.isEmpty) {
      addFoodItems();
    }
  }


  // DateTime addOrSubtractDay(int days, bool subtract, DateTime date) {
  //   if(subtract) {
  //     date.add
  //   } else {

  //   }
  // }


  // List<Widget> getFoodList() {
  //   List<Widget> foodItems = [];
  //   for(int i = 0; i < allFoodItems.length; ++i) {
  //     foodItems.add(
  //       FoodItemContainer(
  //         foodItem: allFoodItems[i],
  //         height: 50,
  //         // color: const Color.fromARGB(255, 17, 212, 212),
  //         decoration: BoxDecoration(
  //           border: Border.all(
  //             color: Colors.white
  //           ),
  //         ),
  //         child: Row(
  //           children: [
  //             ElevatedButton(onPressed: () => print('xd'), child: Icon(Icons.info)),
  //             Text(allFoodItems[i].getDisplayString()),
  //           ],
  //         ),
  //       )
  //     );

  //     foodItems.add(FoodItemContainer(hq))
  //   }
  //   return foodItems;
  // }


  

  void testMethod() {
    return;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        // backgroundColor: Color.fromARGB(255, 133, 134, 167),
        title: Center(
            child: Row(
              children: [
                Text('Fresh foods'), 
                ElevatedButton(onPressed: () => print('YEES'), child: Text('Sort by expiry date')
                )
              ]
            )
          ),
      ),
      body: ListView(
        children: [
          for(int i = 0; i < allFoodItems.length; ++i)
            FoodItemWidget(foodItem: allFoodItems[i], onDelete: () => setState(() {}),),
          ElevatedButton(
            onPressed:() {
              addCustomFoodItem(allFoodItems);
              // getFirstRow();
            },
            // onPressed: () => print('press'),
            child: Icon(Icons.add_rounded)
          ),
          ElevatedButton(
            onPressed:() {
              setState(() {
                allFoodItems = sortByExpiryDate(); //no reason for this to be in here tbh :p
              });
            },
            // onPressed: () => print('press'),
            child: Icon(Icons.accessibility)
          ),
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
    return Container(
      height: 50,
      // color: const Color.fromARGB(255, 17, 212, 212),
      decoration: BoxDecoration(
        border: Border.all(
          color: Colors.white
        ),
      ),
      child: Row(
        children: [
          ElevatedButton(
            onPressed: () => {
              allFoodItems.removeAt(widget.foodItem.index),
              widget.onDelete(),
              // setState(() {
                
              // }),
              // print(allFoodItems[foodItem.index].name + foodItem.name)
            },
            child: Icon(Icons.info)
          ),
          Text(widget.foodItem.getDisplayString()),
        ],
      ),
    );
  }
}

// class FoodItemContainer extends Container {
//   FoodItemContainer({required this.foodItem,super.key});
  
//   final FoodItem foodItem;
  
//   FoodItem get getFoodItem {
//     return foodItem;
//   }
// }

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
          print(value);
      },
    );
  }
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
    'Sausage', 'Bacon', 'Mushroom', 'Onion', 'Peach', 'Eren', 'Elias'
  ];
  
  return FoodItem(name: foodNames[Random().nextInt(30)], expiryDate: expiryDate, index: allFoodItems.length);
}


class FoodItem {
  final String name;
  final DateTime expiryDate;
  final int index;

  final DateTime todayOnlyDay = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);

  int get daysUntilExpiry => expiryDate.difference(todayOnlyDay).inDays; // +1 coz otherwise tomorrow is in 0 days //may be wrong lol 
  FoodItem({required this.name, required this.expiryDate, required this.index});


  String getDisplayString() {

    String dateString = expiryDate.toString().split(' ')[0];
    List<String> dateStrings = dateString.split('-');

    String dayString = dateStrings[2];
    String monthString = dateStrings[1];
    String yearString = dateStrings[0];
    

    return name + " - " + dayString + "/" + monthString + "/" + yearString + " - Expires in " + daysUntilExpiry.toString() + " days";

    // return name + " - " + expiryDate.toString().split(' ')[0] + " - Expires in " + daysUntilExpiry.toString() + " days;
  }
}




class FormWidget extends StatefulWidget {
  const FormWidget({super.key});

  @override
  State<FormWidget> createState() => _FormWidgetState();
}

class _FormWidgetState extends State<FormWidget> {

  String foodName = '';
  DateTime foodDate = DateTime.now();

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
                    
                        foodDate = date;
                        print(foodDate);
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
                onPressed: () => {
                  print(foodName.length),
                  if(foodName.isNotEmpty) {
                    allFoodItems.add(FoodItem(name: foodName, expiryDate: foodDate, index: allFoodItems.length)),
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