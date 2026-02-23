import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

import 'services/api_service.dart';

void main() {
  runApp(const MaterialApp(home: MapScreen()));
}

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  List<dynamic> restaurants = [];
  LatLng? driverLocation;
  late IO.Socket socket;

  final LatLng myLocation = LatLng(9.0100, 38.7636);

  @override
  void initState() {
    super.initState();
    fetchRestaurants();
    connectSocket();
  }

  void fetchRestaurants() async {
    final data = await ApiService.getNearbyRestaurants(
      myLocation.latitude,
      myLocation.longitude,
    );

    if (!mounted) return;
    setState(() {
      restaurants = data;
    });
  }

  void connectSocket() {
    socket = IO.io('http://localhost:3000', <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': false,
    });

    socket.connect();

    socket.onConnect((_) {
      print('Connected to Socket Server');
    });

    socket.on('trackDriver', (data) {
      final lat = (data['lat'] as num?)?.toDouble();
      final lng = (data['long'] as num?)?.toDouble();
      if (lat == null || lng == null || !mounted) return;

      print('Driver moved: $lat, $lng');
      setState(() {
        driverLocation = LatLng(lat, lng);
      });
    });
  }

  @override
  void dispose() {
    socket.dispose();
    super.dispose();
  }

  // Function to show the "Menu"
  void _showRestaurantMenu(dynamic restaurant) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          height: 250,
          width: double.infinity,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                restaurant['name'], 
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)
              ),
              const SizedBox(height: 10),
              Text("Distance: ${restaurant['distance'].toStringAsFixed(0)}m away"),
              const Divider(),
              const Text("🍔 Burger Combo - \$25.50", style: TextStyle(fontSize: 18)),
              const Spacer(),
              
              // THE ORDER BUTTON
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                  ),
                  onPressed: () => _placeOrder(restaurant['id']),
                  child: const Text("ORDER NOW (\$25.50)", style: TextStyle(fontSize: 18)),
                ),
              )
            ],
          ),
        );
      },
    );
  }

  // Logic to call API
  void _placeOrder(int restaurantId) async {
    // Close the sheet first
    Navigator.pop(context);

    // Show loading snackbar
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Finding a driver... 🚕"), duration: Duration(seconds: 1)),
    );

    // Call Backend
    final result = await ApiService.createOrder(restaurantId, 25.50);

    if (result['success']) {
      final data = result['data'];
      // Show Success Dialog
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text("Order Confirmed! ✅"),
          content: Text("Order #${data['orderId']}\n\nDriver ${data['driver']} has been assigned!"),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("OK"))
          ],
        ),
      );
    } else {
      // Show Error (e.g., "No drivers available")
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text("Order Failed ❌"),
          content: Text(result['message']),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Close"))
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Addis Food Delivery')),
      body: FlutterMap(
        options: MapOptions(
          initialCenter: myLocation,
          initialZoom: 13.0,
        ),
        children: [
          TileLayer(
            urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
            subdomains: const ['a', 'b', 'c'],
          ),
          MarkerLayer(
            markers: [
              Marker(
                point: myLocation,
                child: const Icon(
                  Icons.person_pin_circle,
                  color: Colors.blue,
                  size: 40,
                ),
              ),
              ...restaurants.map((r) {
                return Marker(
                  point: LatLng(
                    (r['latitude'] as num).toDouble(),
                    (r['longitude'] as num).toDouble(),
                  ),
                  width: 40,
                  height: 40,
                  child: GestureDetector(
                    onTap: () => _showRestaurantMenu(r),
                    child: const Icon(
                      Icons.restaurant,
                      color: Colors.orange,
                      size: 30,
                    ),
                  ),
                );
              }).toList(),
              if (driverLocation != null)
                Marker(
                  point: driverLocation!,
                  child: const Icon(
                    Icons.directions_car,
                    color: Colors.red,
                    size: 40,
                  ),
                ),
            ],
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: fetchRestaurants,
        child: const Icon(Icons.refresh),
      ),
    );
  }
}
