import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  // ⚠️ CRITICAL: 
  // If using Android Emulator: use '10.0.2.2'
  // If using iOS Simulator: use 'localhost'
  // If using Real Phone: use your laptop's Wi-Fi IP (e.g., '192.168.1.5')
  static const String baseUrl = 'http://localhost:3000/api';

  // Fetch Restaurants (The function we tested with curl yesterday)
  static Future<List<dynamic>> getNearbyRestaurants(double lat, double long) async {
    final url = Uri.parse('$baseUrl/restaurants?lat=$lat&long=$long&radius=5000');
    
    try {
      print("📡 Calling API: $url");
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        print("✅ Data Received: ${json['count']} restaurants");
        return json['data'];
      } else {
        print("❌ Error: ${response.statusCode}");
        return [];
      }
    } catch (e) {
      print("❌ Connection Failed: $e");
      return [];
    }
  }
}