# QuickSlot (Frontend)

A modern, high-performance slot booking mobile application built using Flutter. It connects to the QuickSlot Node.js/Express backend to manage real-time court and venue reservations.

The codebase implements a clean architectural pattern with GetX for state management, offering instant offline-first rendering, background synchronization, and efficient widget-level rebuilds.

## 🛠 Tech Stack

- **Framework:** Flutter (Dart)
- **State Management:** GetX
- **Networking:** Dio (packaged with custom exception mapping and error handling)
- **Local Persistence:** SharedPreferences
- **Layout & Sizing:** Flutter ScreenUtil (responsive, pixel-perfect proportions)

---

## ⚡ Key Features

- **Venue Catalog & Scheduler:** Browse courts and turfs. View a 7-day horizontal date slider to quickly check day-by-day court slot schedules.
- **Real-Time Polling & Widget-Level Updates:** The app polls the backend every 5 seconds for slot status updates. To avoid layout flickering and heavy widget tree rebuilds, a custom diffing mechanism compares the slot data and updates only the reactive `Rx` slot instances whose status changed. Only the affected slot widget repaints.
- **Past Slot Handling:** Auto-detects slots whose start times have passed. They are disabled, styled as "Passed", and automatically excluded from the "Available" slots count in the header.
- **Offline-First Rendering:** The "My Bookings" list loads instantly from local storage cache. A background update then fetches the latest state from the API. A thin progress bar at the top indicates active background syncs without blocking the user.
- **Cancellation Policy:** A strict 6-hour cancellation window is enforced on the frontend. Bookings starting within 6 hours have their cancel action disabled with clear policy details shown on an info dialog.
- **Robust Error & Concurrency Handling:** Maps network connection/timeout errors to user-friendly messages rather than raw API trace errors. Handles DB-level concurrency conflicts (e.g. if two users try booking the same slot simultaneously) by prompting the user and auto-refreshing the slot grid.

---

## 📁 Project Architecture

The client code follows a Clean Architecture approach:

- **Domain Layer (`lib/domain`)**: Contains immutable core models (`SlotModel`, `VenueModel`, etc.) and abstract repository interfaces. Contains zero dependencies on Flutter or GetX.
- **Data Layer (`lib/data`)**: Houses concrete repository implementations, API services, local Storage cache drivers, and the custom Dio client wrapper.
- **Presentation Layer (`lib/presentation`)**: Contains views (`GetView`), bindings (`Bindings` to manage dependency injection), and controllers (`GetxController` representing the UI state machine).
- **Shared Layer (`lib/shared`)**: General-purpose widgets (loaders, buttons, confirm modals).

---

## 🚀 Getting Started

1. **Prerequisites**: Ensure Flutter is installed and configured.
   ```bash
   flutter doctor
   ```
2. **Install dependencies**:
   ```bash
   flutter pub get
   ```
3. **Configure API Endpoint**:
   The base URL defaults to the production endpoint in `lib/core/constants/api_endpoints.dart`. If running the backend locally:
   - Change the `baseUrl` in that file to point to your local machine (e.g. `http://localhost:5001/api/v1` or your local IP if running on a physical device).
4. **Run the App**:
   ```bash
   flutter run
   ```

---

## 🔧 Release & Build Optimizations

For production releases, the app size has been optimized via the following configs:
- **R8 Minification (`android/app/build.gradle.kts`)**: Enabled `isMinifyEnabled` and `isShrinkResources` to tree-shake unused Java/Kotlin code and prune unused assets.
- **Split ABI Builds**:
  Instead of building a fat binary, generate optimized APKs per architecture to reduce download size:
  ```bash
  flutter build apk --split-per-abi
  ```
  For Google Play, generate an Android App Bundle (AAB):
  ```bash
  flutter build appbundle --release
  ```

---

## 🔮 What I'd Do with More Time

1. **WebSockets Integration:** Instead of using 5-second HTTP polling, integrate WebSockets (using `socket.io-client` or similar) to broadcast instant status flips globally. This would eliminate network polling overhead and ensure true real-time synchronization.
2. **Backend-Side Slot Validation:** Currently, the backend query returns all slots for a 24-hour window, forcing the frontend to filter out and mark past slots. Moving this logic to the backend would reduce payload size and clean up client-side checks.
3. **Comprehensive Integration Testing:** Write automated integration tests mocking multiple clients booking the same slot simultaneously to verify conflict resolution and rollback flows.
