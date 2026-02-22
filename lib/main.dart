import 'package:flutter/material.dart';
import 'services/api_service.dart';

void main() {
  runApp(const MaterialApp(home: HomeScreen()));
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<dynamic> restaurants = [];
  String status = "Press button to fetch";

  // Simulate Meskel Square Coordinates
  final double myLat = 9.0100;
  final double myLong = 38.7636;

  void fetchFood() async {
    setState(() => status = "Loading...");
    
    // Call our Node.js Backend
    final data = await ApiService.getNearbyRestaurants(myLat, myLong);
    
    setState(() {
      restaurants = data;
      status = "Found ${data.length} restaurants";
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Delivery App 🍕")),
      body: Column(
        children: [
          const SizedBox(height: 20),
          Text(status, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: fetchFood, 
            child: const Text("Find Food Near Me")
          ),
          const SizedBox(height: 20),
          
          // List of Restaurants
          Expanded(
            child: ListView.builder(
              itemCount: restaurants.length,
              itemBuilder: (context, index) {
                final r = restaurants[index];
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  child: ListTile(
                    leading: const Icon(Icons.restaurant, color: Colors.orange),
                    title: Text(r['name']),
                    subtitle: Text("${r['distance'].toStringAsFixed(0)} meters away"),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}