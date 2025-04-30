import 'package:flutter/material.dart';
import 'dart:math';


// TODO
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
  )
);

List<FoodItem> allFoodItems = []; 


// List<FoodItem> freshFoodItems = []; 

List<FoodItem> expiredFoodItems = []; 

int selectedDestinationIndex = 0;





class FreshFood extends StatefulWidget {
  FreshFood({super.key});

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          // backgroundColor: Color.fromARGB(255, 133, 134, 167),
          title: Center(child: Text('Fresh foods')),
        ),
        body: ListView(
          children: [
            for(int i = 0; i < allFoodItems.length; ++i)
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
                    Text(allFoodItems[i].getDisplayString()),
                  ],
                ),
              ),
            ElevatedButton(
              onPressed:() {
                addCustomFoodItem(allFoodItems);
              },
              // onPressed: () => print('press'),
              child: Icon(Icons.add_rounded)
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
    'Sausage', 'Bacon', 'Mushroom', 'Onion', 'Peach'
  ];
  
  return FoodItem(name: foodNames[Random().nextInt(30)], expiryDate: expiryDate);
}


class FoodItem {
  final String name;
  final DateTime expiryDate;

  final DateTime todayOnlyDay = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);

  int get daysUntilExpiry => expiryDate.difference(todayOnlyDay).inDays; // +1 coz otherwise tomorrow is in 0 days //may be wrong lol 
  FoodItem({required this.name, required this.expiryDate});


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
                    allFoodItems.add(FoodItem(name: foodName, expiryDate: foodDate)),
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