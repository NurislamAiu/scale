# Yoda

A custom Flutter application for Yoda BLE smart scales. This project uses Clean Architecture to process broadcast-only Manufacturer Data from the scales without requiring a GATT connection.

## Features Completed
- [x] BLE scanning for Yoda1 devices.
- [x] Parsing of manufacturer data to reconstruct payload.
- [x] Extracted real-time weight value handling.
- [x] Clean Architecture setup (Domain, Data, Presentation layers).
- [x] Automatic permission handling for Android.
- [x] Simple, responsive UI displaying live weight.

## Getting Started

### Prerequisites
- Flutter 3.19+
- Dart 3.3+
- A connected Android device (tested on Android)

### Running the App
1. Install dependencies:
   ```bash
   flutter pub get
   ```

2. Run the application on your Android device:
   ```bash
   flutter run --platforms=android
   ```

### Expected Behavior
1. Upon opening the app, it will request Bluetooth and Location permissions (needed for BLE scanning).
2. The UI will show a loading spinner with the text "Step on the scale...".
3. When you step on the Yoda1 scale, the live weight will dynamically appear on the screen with huge text.
4. The weight will update in real-time as the scale broadcasts new packets.
