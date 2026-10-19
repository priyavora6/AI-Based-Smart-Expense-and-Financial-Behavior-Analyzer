# neospend

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
# NeoSpend

## ML backend configuration

The Flutter app does not start the Python ML backend for end users. For local development, run the backend on port 5000 and override the deployed
URL with the default Android emulator URL:

```powershell
flutter run --dart-define=ML_API_BASE_URL=http://10.0.2.2:5000
```

Release builds use the deployed ML backend by default:

```powershell
flutter build apk --release
```

Users only install and open the Flutter app. The deployed ML API runs on the
server continuously and handles categorisation, anomaly detection, forecasts,
budget recommendations, and AI insights. The app checks the service health
endpoint, runs categorisation and anomaly detection immediately when a
transaction is added, and refreshes insights after realtime Firestore
transaction updates.

The deployed service currently configured for release builds is:

```text
https://neospend-ai-ml.onrender.com
```

To use another deployment without changing source code, pass
`--dart-define=ML_API_BASE_URL=https://your-ml-api.example.com`.

## Admin data access

The admin dashboard at https://neospend-97721.web.app reads the same
Firestore collections as the app. The authorized admin Firebase Auth account
must use the verified email `neospend@dmin.com`. Firestore rules check this
email in the Firebase Auth token, not a client-side email or password check.
If you also use a custom `admin: true` claim in backend tooling, sign out and
sign back in after setting it so the client receives a refreshed ID token.

The Firestore rules allow an admin claimant to read users, transactions,
budgets, savings goals, recurring transactions, notifications, categories,
feedback, and prediction records. Prediction records are read-only from the
admin dashboard. Regular users remain restricted to their own records.
