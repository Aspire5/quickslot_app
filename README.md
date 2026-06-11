# QuickSlot (Frontend)

A modern, high-performance slot booking mobile application built using Flutter. It connects to the QuickSlot Node.js/Express backend to manage real-time court and venue reservations.

The codebase implements a clean architectural pattern with GetX for state management, offering instant offline-first rendering, background synchronization, and efficient widget-level rebuilds.

---

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

## 📁 Project Architecture & Structure

The codebase is organized following **Clean Architecture** patterns to enforce strict separation of concerns, testability, and mockability:

```
lib/
├── core/
│   ├── constants/       # App themes, colors, and endpoints config
│   └── network/         # Custom Dio HTTP client with connectivity exception mapping
├── domain/
│   ├── models/          # Immutable domain models (UserModel, SlotModel, etc.)
│   └── repositories/    # Abstract repository interfaces (pure business logic contracts)
├── data/
│   ├── repositories/    # Concrete implementations of Domain Repository contracts
│   └── services/        # Low-level network API client and persistent local storage
├── presentation/
│   ├── bindings/        # GetX bindings to manage dependency injection lifecycle
│   ├── controllers/     # GetX controllers containing UI states, variables, and event logic
│   └── views/           # Stateless views mapping elements to screen (zero calculations or business logic)
└── shared/
    ├── dialogs/         # Styled custom dialogs and snackbar alerts
    ├── loaders/         # Custom loaders and progress indicator elements
    └── widgets/         # App-wide reusable components (custom buttons, layouts)
```

### 1. Domain Layer (`lib/domain`)
The core layer of the application. It contains pure Dart entities and abstract repository definitions. It is entirely free of any framework-specific dependencies (such as Flutter or GetX), meaning it can be easily unit-tested in isolation.
- **Models:** Blueprint objects modeling backend records. Handles JSON serialization/deserialization and provides basic computed getters (e.g. `isExpired` checking if slot start time is before current time).
- **Repositories:** Abstract interfaces establishing communication boundaries between presentation state machines and the data sources.

### 2. Data Layer (`lib/data`)
Implements the contracts defined in the Domain layer. It coordinates calls between remote web services and local caches.
- **Services:** Includes `ApiService` (handling raw Dio client queries) and `StorageService` (caching JSON lists in SharedPreferences).
- **Repositories Implementations:** Manages offline fallback fallback rules. For example, `BookingRepositoryImpl.getUserBookings` retrieves locally cached bookings instantly to render on view, then fires background re-syncs to populate the cache with updated network responses.

### 3. Presentation Layer (`lib/presentation`)
Contains MVC-like constructs built on top of GetX.
- **Bindings:** Lazily injects ApiServices, Repositories, and Controllers to the navigation routes when screen views are pushed.
- **Controllers:** Contains UI states (reactive `Rx` variables like lists, loading flags, error strings). Controls API integrations, timer loops (polling scheduler), user inputs, and navigation actions.
- **Views:** Renders layouts. Widgets are kept "pure" of inline calculation logic—for example, the grid layout fetches properties directly from getters in the controller instead of containing inline filters or local calendar mapping logic.

### 4. Core Layer (`lib/core`)
Houses app-wide constants (routes, theme colors) and standard infrastructure extensions like error mapping interceptors.

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

---

## 🤖 Use of AI

I used AI heavily to build this project. Specifically:
- **Antigravity** was used for code generation, file modifications, running tests, and debugging in the workspace. (and to also generate this readme file :p)
- **ChatGPT** was used to draft core logic details, resolve configuration problems, and generate development prompts.

Things AI got wrong that I caught and fixed :- 

On the frontend, I noticed a couple of inefficiencies in state management.

First, the state updates were not optimized — on every API call, all slot widgets were being rebuilt, even if only a few had changed.
I refactored this to update only the affected widgets, which improved performance and reduced unnecessary rebuilds.

Secondly, for the “My Bookings” screen, the API was being called every time the user navigated to it.
I optimized this by introducing a dirty flag mechanism — whenever a booking is successfully made, the screen is marked as dirty.
Then, when the user revisits the screen, a background refresh is triggered with a non-blocking loader, instead of always fetching data upfront.

This approach reduced redundant API calls while still keeping the UI up-to-date.

---

## 💻 Process of Building via AI (similar flow for both backend & frontend)

My build process involved the following structured steps:
1. **Requirements Gathering:** Documented and organized software requirements specifications on my notepad.
2. **Feature Selection:** Selected the precise set of features that I wanted to integrate.
3. **Architecture Planning:** Sketched out the database schema, normalized entities, and mapped their logical relations.
4. **AI Consultation:** Discussed and argued ideas with ChatGPT, asking it to look for architectural flaws, validate new ideas, and point out edge cases I might have missed.
5. **Schema Setup:** Once finalized, generated a multi-phase implementation plan to deploy the Prisma schema, set up relations, and accepted the correct code edits generated by Antigravity in real-time.
6. **API Flow Drafting & Prompting:** Discussed API endpoint structures and payloads with ChatGPT to save Antigravity context tokens. I then had ChatGPT generate structured prompts summarizing the designs, verified them, applied manual edits, and input them to Antigravity to perform code modifications.
7. **Backend as Reference:** Once the backend server was verified, used it as a strict reference contract to write the frontend, ensuring the API parsing structure matches exactly.
8. **Deployment:** Manually deployed the backend instance to Railway, configured env variables, and verified that everything connected successfully.
