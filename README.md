# QuickSlot — Sports Slots Booking System

A production-grade slot booking mobile application for sports venues (turfs, badminton courts, etc.) integrated with a concurrency-safe Node.js Express server. Built using **GetX**, **Dio**, **ScreenUtil**, and **Prisma ORM**.

---

## 🚀 Setup & Execution Guide

### 1. Database & Backend Setup
1. Navigate to the server folder:
   ```bash
   cd quickslot_server
   ```
2. Install dependencies:
   ```bash
   npm install
   ```
3. Set up your `.env` variables (e.g. `DATABASE_URL` pointing to your PostgreSQL instance).
4. Run migrations and seed the database with mock courts/users:
   ```bash
   npx prisma migrate dev
   # The seed script will run automatically, creating 5 venues, 3 users, and 560 slots
   ```
5. Start the backend:
   ```bash
   npm run dev
   # Server listens on port 5001 by default
   ```

### 2. Flutter Mobile Setup
1. Ensure your Flutter environment is ready:
   ```bash
   flutter doctor
   ```
2. Navigate to the root directory of the Flutter app, get dependencies, and run:
   ```bash
   flutter pub get
   flutter run
   ```

---

## 🛠️ Tech Stack & Architecture Note

The mobile application follows **Clean Architecture** patterns:
- **Presentation**: View layout widgets (GetView) referencing reactive controllers and page bindings. Uses `flutter_screenutil` for responsive, pixel-perfect sizing.
- **Domain**: Pure business rules containing abstract interface repositories and strongly-typed models (`UserModel`, `VenueModel`, `SlotModel`, `BookingModel`).
- **Data**: Centralized networking services (`DioClient` and `ApiService`) and implementation repositories managing local persistent cache storing.
- **Shared**: Reusable loaders, confirmation dialogs, and styled action button components.

### Diagram Reference (Whiteboard Concept)
```
[ UI Screens: Login / Dashboard Grid / Venue Details ]
                       │ (reactive bindings)
            [ Controllers / Getx ]
                       │
       [ Domain Repository Interface ]
                       │ (data mapping)
         [ Data Repositories Impl ]
             /                   \
   [ Api Service / Dio ]   [ Local storage cache / SharedPreferences ]
             │
     [ Node.js server ]
```

---

## 📦 Release & Size Optimization

Optimizations are applied to minimize installation size and speed up compiling:

### 1. Android Configs (`android/app/build.gradle.kts`)
- Enabled **R8 Minification** (`isMinifyEnabled = true`): Shrinks code by removing unused classes and fields.
- Enabled **Resource Shrinking** (`isShrinkResources = true`): Removes unused resources from the final package bundle.

### 2. Compilation Commands
* **Android (Splitting APK per CPU architecture)**:
  Instead of compiling a heavy "fat" APK, compile individual optimized APKs using:
  ```bash
  flutter build apk --split-per-abi
  # Generates separate small APKs for armeabi-v7a, arm64-v8a, and x86_64
  ```
  Or compile a Google Play-compliant **Android App Bundle (AAB)**:
  ```bash
  flutter build appbundle --release
  ```
* **iOS**:
  Strip native debugging symbols and package into IPA:
  ```bash
  flutter build ipa --release
  ```

---

## ✂️ What was Cut & Why
1. **Lightweight Auth**: Handled authentication using simple username/password requests and simple token verification headers instead of complex OAuth flow to optimize development time.
2. **Real-time Polling**: Decided to skip active slot polling in this iteration to reduce network overhead and battery drain. The grid reloads directly whenever date selection changes, a booking confirmation completes, or a concurrency booking conflict is caught.
3. **Unit Tests**: Widget/unit testing was skipped for this phase to focus resources on a fully functioning local end-to-end user experience.

---

## 🔮 What We'd Do with One More Day
1. **Websockets Integration**: Push instant booking state updates to all active phone screens to prevent overlapping slot selections before a user hits confirm.
2. **Advanced Slot Filters**: Filter courts by slot times (Morning, Afternoon, Evening) and sport category (Tennis vs Soccer).
3. **Map Integrations**: Embed interactive Google Maps widgets on Venue cards for quick driving directions.

---

## 🤖 AI Usage Note
- **What AI was used for**: Generating the boilerplate clean architecture directories, setting up base Dio wrappers, and scaffolding initial controllers/views.
- **AI correction made**: Caught and resolved a few compiler warnings regarding non-nullable casts in parsing JSON lists from `shared_preferences`, and correctly ordered the `dart:io` and `get` imports at the top of the details controller rather than inline.
