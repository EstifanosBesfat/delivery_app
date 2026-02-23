# Delivery App (Flutter + Map + Realtime Driver Tracking)

This project is a Flutter delivery app prototype with:
- Restaurant markers on OpenStreetMap (`flutter_map`)
- Tap restaurant marker to open menu/order sheet
- Realtime driver location updates via `socket.io`
- Backend API integration for restaurants and order creation

## Tech Stack
- Flutter
- Dart SDK `^3.11.0`
- `flutter_map`
- `latlong2`
- `http`
- `socket_io_client`

## Prerequisites
- Flutter SDK installed and working (`flutter doctor`)
- Microsoft Edge (for web target)
- Backend server running on `http://localhost:3000`

## Install
```powershell
flutter pub get
```

## Run in Edge (Web)
```powershell
flutter config --enable-web
flutter devices
flutter run -d edge
```

## Backend Requirements
The app currently calls:
- REST base URL: `http://localhost:3000/api`
- Socket server: `http://localhost:3000`

Expected endpoints/events:
- `GET /api/restaurants?lat=<value>&long=<value>&radius=5000`
- `POST /api/orders` with JSON body:
  - `restaurantId` (int)
  - `total` (double)
- Socket event:
  - listen: `trackDriver`
  - payload should include `lat` and `long`

## Important Network Notes
`localhost` only works when backend is on the same machine as the app runtime.

If you run on:
- Android emulator: use `10.0.2.2` instead of `localhost`
- iOS simulator: `localhost` is usually fine
- Real device: use your computer LAN IP (for example `192.168.1.5`)

Update `baseUrl` in `lib/services/api_service.dart` and socket URL in `lib/main.dart` if needed.

## Project Structure
- `lib/main.dart`: map UI, marker rendering, socket listener, order flow
- `lib/services/api_service.dart`: REST calls for restaurants and orders
- `pubspec.yaml`: dependencies and SDK constraint

## Troubleshooting
- `pubspec.yaml has no lower-bound SDK constraint`:
  - Ensure `pubspec.yaml` contains:
    - `environment:`
    - `  sdk: ^3.11.0`
- `No supported devices found with name or id matching 'edge'`:
  - Install Edge, run `flutter config --enable-web`, then `flutter devices`
- Map loads but no restaurants:
  - Check backend is running on port `3000`
  - Verify `/api/restaurants` returns data
- Socket not updating driver:
  - Ensure server emits `trackDriver` with numeric `lat`/`long`

