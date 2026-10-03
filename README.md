# FEEL-IT Official

Flutter-first Himalayan motorcycle adventure app.

## Included in this starter

- Modular Flutter architecture.
- Riverpod app state.
- Dark/light theme toggle.
- Traveler/Captain mode switch.
- Universal motorcycle garage: no manufacturer/model whitelist.
- Open-Meteo weather.
- Weather-reactive Dowie/Snowie mascot state.
- Flutter Map + OpenStreetMap development map.
- Live GPS tracking.
- GPS checkpoint radius detection.
- Basic tour catalogue.
- Secure-storage service skeleton.
- Dio API client skeleton.
- Unit tests for universal motorcycles and checkpoint radius.

## Important security boundary

The app can detect that the phone is inside a checkpoint radius, but it must NOT be trusted to grant valuable rewards by itself.

For production rewards:
1. App sends signed/authenticated location evidence to backend.
2. Backend validates timestamp, route/session, checkpoint radius and anti-spoof rules.
3. Backend writes the reward unlock.
4. App refreshes the authoritative reward wallet.

Do not put reward-granting secrets in the Flutter client.

## Run

```bash
flutter pub get
flutter run -d chrome
```

For Android/iOS later:

```bash
flutter devices
flutter run -d <device-id>
```

Chrome is the lightest development preview route.

## Web GPS

The browser asks for location permission. Run the app from the Flutter development server (`flutter run -d chrome`) rather than opening generated HTML directly from disk.

## Assets

Add:

- assets/images/dowie.png
- assets/images/snowie.png
- assets/images/logo.png

The mascot screen has an icon fallback if mascot images are missing.
