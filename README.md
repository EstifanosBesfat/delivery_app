# 📱 Real-Time Delivery App (Flutter Frontend)

The mobile client for the **Geospatial Delivery System**. Built with **Flutter**, this app visualizes real-time socket events, renders interactive maps using OpenStreetMap, and manages the ordering lifecycle via a custom Node.js backend.

🔗 **Backend Repository:** [https://github.com/EstifanosBesfat/delivery-api] (Node.js, PostGIS, Redis, Docker)

---

## 🛠️ Tech Stack

*   **Framework:** Flutter (Dart)
*   **Maps:** `flutter_map` (OpenStreetMap implementation) & `latlong2`
*   **Real-Time:** `socket_io_client` (WebSockets)
*   **Networking:** `http`
*   **Platform:** Android, iOS, Web

---

## ⚡ Key Features

### 1. 🗺️ Live Map Visualization
Instead of using paid map APIs, this app implements **OpenStreetMap (OSM)** via `flutter_map`.
*   Renders user location (Blue).
*   Renders restaurant locations fetched via **Geospatial Queries** (Orange).
*   Renders moving drivers in **Real-Time** (Red).

### 2. 📡 Real-Time Driver Tracking
The app connects to the backend via **WebSockets** (`socket.io`).
*   Listens for `trackDriver` events emitted by the Node.js server.
*   Updates the driver's marker position on the map instantly without page refreshes or polling.

### 3. 🍔 Transactional Ordering
*   **Dynamic Menus:** Clicking a map marker opens a bottom sheet with restaurant details.
*   **Atomic Orders:** When "Order Now" is clicked, the app sends a request to the backend.
*   **Error Handling:** Displays specific feedback if the backend rejects the order (e.g., "No drivers available" due to race conditions).

---

## 🔌 Backend Integration

This app is not a mock. It requires the custom **Delivery API** to function. It communicates with the backend in two ways:

1.  **REST API (HTTP):**
    *   `GET /api/restaurants`: Sends the user's GPS coordinates to the backend. The backend uses **PostGIS** to calculate distances and returns nearby venues.
    *   `POST /api/orders`: Initiates a database transaction to lock a driver and create an order record.

2.  **WebSockets (Socket.io):**
    *   Maintains a persistent connection to receive live location updates from the driver simulator.

### ⚙️ Networking Configuration
The app is configured to handle different environments (Emulator vs Web vs Physical Device):

```dart
// lib/services/api_service.dart

// Logic to determine the correct Backend IP
static String get baseUrl {
  if (kIsWeb) {
    return 'http://localhost:3000/api'; // For Web Browser
  } else if (Platform.isAndroid) {
    return 'http://10.0.2.2:3000/api';  // Android Emulator Magic IP
  } else {
    return 'http://YOUR_LOCAL_IP:3000/api'; // For Physical Devices
  }
}
