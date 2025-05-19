import 'package:flutter/material.dart';
import 'package:food_app/DB/Pocketbase.dart' as db;
import 'package:food_app/Models/FoodItem.dart';
import 'package:food_app/Widgets/FreshFood.dart';



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
                    await db.addFoodItem(FoodItem(name: foodName, expiryDate: foodExpiryDate)),
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
