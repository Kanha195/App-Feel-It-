# FEEL-IT Official

Flutter-first Himalayan motorcycle adventure app.

## Included

- Modular Flutter architecture with Riverpod state.
- Midnight Void theme, frosted glass surfaces, and dark/light toggle.
- Traveler/Captain mode switch with mode-specific navigation.
- Supabase email authentication using PKCE sessions.
- Universal motorcycle garage with free-form manufacturer, model, and displacement.
- Weather-reactive Dowie/Snowie home with five-minute Open-Meteo refresh and shared wardrobe.
- OpenStreetMap display, live GPS tracking, and checkpoint accuracy checks.
- GPS-gated teahouse food rewards with server verification.
- Camera/audio mechanic scanner with Supabase Edge Function integration.

## Run

```bash
flutter pub get
flutter run -d chrome \
  --dart-define=SUPABASE_URL=https://your-project.supabase.co \
  --dart-define=SUPABASE_ANON_KEY=your-public-anon-key
```

`SUPABASE_URL` and `SUPABASE_ANON_KEY` are compile-time values read by
`AppConfig`; no project credentials are checked into source control. The anon
key is a public client key, not a secret. Enable Row Level Security for all user
data. Without both values, the app opens in guest mode and Supabase-backed
actions remain unavailable.

Chrome is the lightest development preview route. For a connected browser GPS,
run the Flutter development server rather than opening generated HTML from disk.

## Backend Functions

Checkpoint foods stay blurred until a live GPS fix is within the configured
checkpoint radius, has accuracy of 30 meters or better, and the authenticated
`verify-checkpoint` Supabase Edge Function returns `{ "verified": true }`. The
function receives `checkpoint_id`, `latitude`, `longitude`, and
`accuracy_meters`. Validate the signed-in user, timestamp, route/session, radius,
and anti-spoof rules server-side before granting the reward. The phone alone
must never be treated as the reward authority.

The scanner invokes `mechanic-diagnosis` with `image_base64`,
`image_mime_type`, and `audio_rms`. The function should return a JSON `suggestion`
string. Keep any model-provider credentials inside the Edge Function, never in
the Flutter app.

## Mobile Builds

This checkout does not include generated `android/` or `ios/` host projects.
Generate the desired Flutter platform folders before device builds, then add
camera, microphone, and location permissions and usage descriptions to the
native manifests. The `camera`, `record`, and `geolocator` plugins are already
in `pubspec.yaml`.

## Assets

Optional mascot images can be added at `assets/images/dowie.png` and
`assets/images/snowie.png`. The home screen uses an animated fallback when they
are absent.
