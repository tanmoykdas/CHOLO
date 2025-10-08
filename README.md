# CHOLO – University Ride Sharing (Bangladesh)

CHOLO is a Flutter-based ride-sharing platform tailored for university students in Bangladesh. Students can offer or find daily rides (bike/car) along common campus commute routes after verifying their academic email addresses.

## Current Status
Scaffold implemented: authentication provider, ride & booking models, placeholder UI screens (landing, login, register, home, offer, search, profile), local notifications service, and initial unit/widget tests. Firebase initialization & data persistence are stubbed; you must add real Firebase configuration (see below).

## Core Features (Phase 1)
1. University Email Registration & Login (verification flow via Firebase Auth email verification) – logic scaffolded.
2. Offer Ride: form captures vehicle, route, seats, price, time (currently placeholder publish logic).
3. Search Ride: real-time query placeholder (route-based) using Firestore stream wiring in `RideService` (needs Firebase config).
4. Booking: transactional seat decrement logic implemented in `RideService.bookRide`.
5. Local Notifications: via `flutter_local_notifications` (will expand to FCM later).
6. User Profile: displays account info & logout.
7. Admin Panel: deferred (future phase).

## Planned Enhancements (Roadmap)
- Live map tracking & route suggestions (Google Maps / Mapbox)
- In-app driver–rider chat (Firestore real-time or dedicated WebSocket)
- Ratings & reviews; trust & safety module
- Multi-university domain whitelist management via remote config / Firestore collection
- Push notifications (FCM) replacing local-only notifications
- Ride cancellation flow & refund policy (business rules)
- Analytics & abuse reporting

## Tech Stack
- Flutter 3 (Dart SDK 3.x)
- State Management: Provider
- Backend (Phase 1): Firebase Auth + Cloud Firestore
- Notifications: flutter_local_notifications (later FCM)

## Project Structure (key folders)
```
lib/
	core/
		models/        # Data models (User, Ride, Booking)
		services/      # Firebase + notification abstractions
		providers/     # State management (Auth, Ride search)
	main.dart        # App entry & route table
test/              # Unit & widget tests
```

## Setup Instructions
1. Install Flutter & Dart (ensure `flutter doctor` passes).
2. Enable Firebase for the project:
	 - Create a Firebase project named e.g. `cholo`.
	 - Add Android app (use your package ID from `android/app/src/main/AndroidManifest.xml`). Download `google-services.json` into `android/app/`.
	 - Add iOS app; download `GoogleService-Info.plist` into `ios/Runner/`.
	 - (Optional) Add web, macOS, Windows if targeting those platforms.
3. Run `dart pub global activate flutterfire_cli` then:
	 ```bash
	 flutterfire configure
	 ```
	 This generates `firebase_options.dart`; import it in `main.dart` and replace the `Firebase.initializeApp()` TODO with:
	 ```dart
	 await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
	 ```
4. Install dependencies:
	 ```bash
	 flutter pub get
	 ```
5. Run the app:
	 ```bash
	 flutter run
	 ```

## Firestore Data Model (Suggested)
```
users/{uid}:
	name, email, universityEmail, emailVerified, isAdmin
rides/{rideId}:
	ownerId, vehicleType, route, availableSeats, pricePerSeat, rideTime (Timestamp), bookedSeats
bookings/{bookingId}:
	rideId, userId, seats, createdAt
```

Indexes you may need (composite) later for advanced queries (not yet required):
- rides: route + rideTime

## Security Rules (High-Level Draft)
You must enforce that users can only modify their own user doc & their own rides.
```
rules_version = '2';
service cloud.firestore {
	match /databases/{database}/documents {
		function isAuth() { return request.auth != null; }
		function isOwner(pathUserId) { return isAuth() && request.auth.uid == pathUserId; }

		match /users/{userId} {
			allow read: if isAuth();
			allow create: if isAuth() && request.auth.uid == userId;
			allow update, delete: if isOwner(userId);
		}

		match /rides/{rideId} {
			allow read: if true; // public listing
			allow create: if isAuth();
			allow update, delete: if isAuth() && resource.data.ownerId == request.auth.uid;
		}

		match /bookings/{bookingId} {
			allow read: if isAuth();
			allow create: if isAuth();
			allow delete: if isAuth() && resource.data.userId == request.auth.uid;
		}
	}
}
```
Adjust with stricter seat validation using Cloud Functions (future).

## Testing
Run all tests:
```
flutter test
```
Add more tests for:
- AuthService (mock FirebaseAuth & Firestore using mocktail)
- RideService transactional booking
- Widget golden tests for key screens

## Contribution Guidelines
Use feature branches, submit PR with:
- Description
- Screenshots (UI changes)
- Test coverage summary

## License
Private / Internal (add explicit license text when ready).

## Contact
Product Owner / Maintainer: (add name & email)

---
Feel free to open issues for roadmap items or clarifications.
