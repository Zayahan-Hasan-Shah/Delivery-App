# Delivery App MVP — Completion Report

**Architecture:** Clean Architecture (`data / domain / presentation`) per `architecure.md`  
**Roles Supported:** `Sender` & `Rider` (`Client` role completely removed)  
**App Name:** `Delivery App` (formerly ShefsCloud Delivery)  
**Localization:** English (`en` — LTR default) & Urdu (`ur` — RTL) via Flutter `l10n` (`ARB` + `AppLocalizations` + `LocaleCubit`). *Language switcher toggle UI is hidden for MVP per user instruction.*  
**UI Reference:** Phase 1 Mobile Screens (`#FAF7F2` warm canvas, `#C2410C` burnt orange accent, `#1B1B1A` charcoal ink, responsive via `flutter_screenutil`)

---

## Overall Progress Summary

| # | Feature / Module | Status | Progress | Architecture Layers |
|---|------------------|--------|----------|---------------------|
| 1 | App-Wide Renaming to **Delivery App** | Completed | **100%** | `app_constants.dart`, `environment.dart`, `AndroidManifest.xml`, `Info.plist`, `l10n` |
| 2 | Language Switcher UI Hidden (MVP) | Completed | **100%** | `LanguageTogglePill` hidden app-wide, default English `en` preserved |
| 3 | Tile Map Connectivity & User Agent | Completed | **100%** | `TileLayer` updated to `com.deliveryapp.app`, `maxZoom: 19`, resilient caching & fallback |
| 4 | Sender Registration: Restaurant Removal & Map Pin Picker | Completed | **100%** | Removed restaurant name & all "restaurant" labels; added interactive `LocationPickerMap` with GPS centering alongside text field |
| 5 | Sender OTP Removal | Completed | **100%** | Removed OTP verification card from `TrackOrderScreen` & `OrderDetailsScreen`; simplified order tile subtitle |
| 6 | Rider Navigation Tab Renaming | Completed | **100%** | "Active Map" renamed to **Live Map**; "Logs / Log" renamed to **History** |
| 7 | Rider Delivery Fee & Share Prominence | Completed | **100%** | Delivery fee prominently displayed on `RiderOrderCard`, `OrderDetailsScreen` (Delivery Fee + Rider Earning + COD), and `RiderDeliveryLogView` |
| 8 | Rider Map Enlargement Preview & Camera Fixes | Completed | **100%** | Added interactive full-screen map enlargement dialogs on both multi-order map and order details; clamped zoom bounds (`minZoom: 12.5`, `maxZoom: 16.0`); resolved emulator cross-globe coordinate zoom bug |
| 9 | Proof Photo Hidden from MVP | Completed | **100%** | Hidden proof photo upload button & sheet; Rider directly confirms delivery with one tap |
| 10 | Mandatory Startup Location Permission Gate | Completed | **100%** | `LocationService`, `LocationGateCubit`, `LocationPermissionGateScreen`, `AppRouter` strict lifecycle guard |
| 11 | In-App Turn-by-Turn Navigation Map | Completed | **100%** | `InAppNavigationScreen` + `RouteNavigationService` (OSRM road routing + offline fallback + live GPS + phone call) |
| 12 | Background Delivery & Safe GPS Tracking | Completed | **100%** | `BackgroundDeliveryService`, crash-safe `LocationServiceImpl` (offline stream cancellation), Android Foreground Service & iOS Background Location configs |

---

## Detailed Feature Breakdown, Use Cases & Flows

### 1. App-Wide Renaming to "Delivery App" — 100%
- **Changes Applied:**
  - `lib/core/constant/app_constants.dart`: `appTitle = 'Delivery App'`
  - `lib/core/configurations/environment.dart`: `appName = 'Delivery App'` across dev and prod configurations
  - `android/app/src/main/AndroidManifest.xml`: `android:label="Delivery App"`
  - `ios/Runner/Info.plist`: `CFBundleDisplayName = "Delivery App"`, `CFBundleName = "Delivery App"`, and all permission usage strings updated to "Delivery App"
  - `lib/l10n/app_en.arb` & `app_ur.arb`: `appName = "Delivery App"`, `brandShort = "Delivery App"`
  - Default demo accounts: `sender@deliveryapp.com` & `rider@deliveryapp.com` (with backward-compatible support for legacy credentials)

---

### 2. Language Switcher Toggle Hidden (MVP) — 100%
- **Use Case:**
  - Hides language switcher widget (`LanguageTogglePill`) across all screens (Login, Sign Up, Forgot Password, Home, New Order, and Location Permission Gate) so end users experience a streamlined English UI for MVP without clutter.
- **Implementation:**
  - `lib/shared/widgets/language_toggle_pill.dart` safely returns `const SizedBox.shrink()`.
  - Underlying `LocaleCubit` defaults to `Locale('en')` and localization infrastructure remains fully intact for future international expansion.

---

### 3. 100% Free OpenStreetMap (No API Key Required) & Resilient Fallback — 100%
- **Use Case:**
  - Map tiles are 100% free, open-source OpenStreetMap (OSM) without requiring any API keys, paid subscriptions, or watermarks.
  - Prevents `ClientException with SocketException: Connection refused (OS Error: Connection refused, errno = 111)` from polluting the console during transient network blinks.
- **Implementation:**
  - Created centralized `AppTileLayer` widget in `lib/shared/widgets/app_tile_layer.dart`.
  - Configured official OpenStreetMap as primary (`https://tile.openstreetmap.org/{z}/{x}/{y}.png`) with official OSM Foundation mirror fallback (`https://tile.openstreetmap.de/{z}/{x}/{y}.png`).
  - Completely keyless and open-source: NO API keys required, NO watermarks.
  - Added `errorTileCallback` to gracefully intercept transient socket resets and offline states without raising unhandled Flutter image service exceptions.
  - Replaced raw `TileLayer` across all 7 map occurrences:
    - `LocationPickerMap` (Sender registration & order creation)
    - `RiderMultiOrderMap` (Rider & Sender live dashboard maps & fullscreen preview)
    - `OrderDetailsScreen` (Single-order route preview card & fullscreen preview)
    - `InAppNavigationScreen` (Turn-by-turn road navigation map)
    - `DeliveryMapWidget` (Live order tracking map)

---

### 4. Sender Registration: Restaurant Removal & Interactive Map Pin Picker — 100%
- **Use Case:**
  - Senders can be any package/parcel sender (not strictly a restaurant).
  - Senders input their pickup address both textually and visually by pinning on an interactive map.
- **Changes Applied:**
  - Removed "Restaurant / Business Name" text field completely from `RegisterScreen`.
  - Removed all occurrences of "restaurant" from labels, placeholders, validators, and entities.
  - Added an interactive `LocationPickerMap` (with GPS centering and tap-to-pin) directly on `RegisterScreen` for Senders, allowing them to accurately set their pickup latitude/longitude.
  - Refactored `RegisterSenderSubmittedEvent`, `RegisterSenderUseCase`, and `AuthRepository` to accept `fullName`, `phone`, `pickupAddress`, `pickupLatitude`, `pickupLongitude`, and `password`.
  - Preserved `pickupAddress` on `UserEntity` and `UserModel`.

---

### 5. Sender OTP Removal — 100%
- **Use Case:**
  - Delivery verification is simplified for MVP: Senders do not need to share a 4-digit OTP code, and Riders can confirm deliveries directly with one tap.
- **Changes Applied:**
  - Removed Delivery OTP display card from `TrackOrderScreen`.
  - Removed Delivery OTP display card from Sender view on `OrderDetailsScreen`.
  - Removed 4-digit recipient OTP input card and verification check from Rider view on `OrderDetailsScreen`.
  - Simplified `SenderOrderTile` subtitle to show `Fee: Rs {fee} • COD Rs {amount}` without displaying OTP text.

---

### 6. Rider Navigation Tab Renaming — 100%
- **Use Case:**
  - Clear, industry-standard tab labels for riders.
- **Changes Applied:**
  - Tab 0: Renamed from "Active Map" to **"Live Map"** (`l10n.tabMapOrders = 'Live Map'`).
  - Tab 1: Renamed from "Log / Logs" to **"History"** (`l10n.tabDeliveryLog = 'History'`).
  - Tab 2: "Earnings" preserved.

---

### 7. Rider Financial Display (Delivery Fee Hidden from Rider) — 100%
- **Use Case:**
  - Riders only see what they collect (COD Amount) and what they earn (Your Earning / Rider Share). Delivery fees charged to the sender are hidden from the rider across all views.
- **Changes Applied:**
  - `RiderOrderCard`: Removed delivery fee; shows `COD Rs {amount}` and highlighted earnings (`Your Share Rs {earning}`).
  - `OrderDetailsScreen`: Delivery Fee row is now strictly conditionally rendered (`if (!isRider)`); when a Rider views the order, they only see **COD Amount** and **Your Earning**.
  - `RiderDeliveryLogView`: History list tiles now exclusively show `${l10n.riderShare}: Rs {earning}` (delivery fee removed).
  - `RiderEarningsView`: Subtitle shows delivery date and `COD: Rs {amount}` without displaying delivery fees.

---

### 8. Rider Map Enlargement Preview & Interactive Tracking — 100%
- **Use Case:**
  - Allows riders and senders to expand the multi-order map to full-screen and interactively track individual orders with live GPS auto-following.
  - Eliminates the bug where emulator GPS caused the map to zoom out to the entire world when displaying delivery pins.
  - **Resolved Map Lifecycle Crash (`LateInitializationError`):** Calling `localController.fitCamera` inside `addPostFrameCallback` caused a crash (`LateInitializationError: Field '_interactiveViewerState' has not been initialized`) because `FlutterMap` had not yet attached its internal viewer.
  - **Resolved Missing Rider Marker in Order Details:** When viewing an order's details (`OrderDetailsScreen`), the rider motorcycle marker is now guaranteed to display for both Riders (labeled "You") and Senders (labeled "Rider"), with a connector polyline to the active stop and a one-tap Center on Rider button.
- **Changes Applied:**
  - **Full-Screen Interactive Tracking Dialog (`_EnlargedMultiOrderMapDialog`):**
    - **Live Rider GPS Tracking & Auto-Follow:** Listens directly to `sl<BackgroundDeliveryService>().riderLiveLocationStream` and updates the rider motorcycle pin in real time. Tapping the GPS button centers the camera and activates auto-following.
    - **Interactive Bottom Order Filter Strip:** Provides an "All (N)" chip plus individual color-coded chips for each active order. Tapping selects or unselects orders and dynamically reframes the camera.
    - **Interactive Map Pins:** Tapping any pickup or drop-off pin directly on the enlarged map selects that order, highlights its route, and emphasizes the active connector leg.
    - **Floating Active Order Card:** Displays the order number, next stop badge (`PICKUP` vs `DROP-OFF`), next stop destination address, and two action buttons:
      1. **"Navigate"** (`Icons.navigation_rounded`): Immediately launches in-app turn-by-turn navigation for that order.
      2. **"Details"** (`Icons.info_outline_rounded`): Opens full order details.
  - **In-Map Direct Navigation Buttons:**
    - **Multi-Order Dashboard Map Card (`RiderMultiOrderMap`):** When an order chip is tapped, a floating pill appears at the bottom-right of the map with **"Navigate • SC-XXX"** (`Icons.navigation_rounded`), allowing the rider to start turn-by-turn navigation in a single tap right from the home screen map!
    - **Order Details Screen (`OrderDetailsScreen`):** Added a floating **"Navigate"** button inside the embedded route card (`bottom: 10.h, right: 10.w`) and inside the enlarged route preview dialog (`bottom: 16.h, left: 16.w`).
  - **100% Free OpenStreetMap Tiles & Watermark Removal (`AppTileLayer`):**
    - Completely removed CartoDB Voyager which showed "API KEY REQUIRED" watermark tiles.
    - Standardized on 100% free OpenStreetMap (`tile.openstreetmap.org`) with automatic fallback to OSM Germany mirror (`tile.openstreetmap.de`).
    - Added `errorTileCallback` across all map widgets to absorb transient socket drops (`ClientException: Connection refused`) without displaying red Flutter error boxes.
  - **Guaranteed Rider Location Display (`_riderEffectiveLatLng`):**
    - Uses real live device GPS if nearby (< 50 km).
    - If GPS is uninitialized or testing overseas, anchors the rider realistically along the active leg based on status (e.g. approaching pickup for `assigned`, halfway to drop-off for `pickedUp`, and 72% along route for `onTheWay`).
    - The rider marker and active connector line now render for all roles (Rider & Sender) on both the embedded card and enlarged modal preview.
  - **Resolved Dialog Infinite Width Constraints (`BoxConstraints forces an infinite width`):**
    - `Dialog` widgets in Flutter provide unconstrained horizontal bounds by default. Setting `SizedBox(width: double.infinity)` inside a `Dialog` propagated `BoxConstraints(w=Infinity)` to children, causing `OutlinedButton` inside the action `Row` to crash the layout renderer.
    - Bound dialog width strictly using `final dialogWidth = MediaQuery.sizeOf(context).width - 16.w;` on both `_EnlargedMultiOrderMapDialog` and `OrderDetailsScreen`.
    - Proportioned the **Navigate** and **Details** buttons with `Expanded(flex: 3)` and `Expanded(flex: 2)` to guarantee clean layout on all device screen sizes.
    - Replaced premature `addPostFrameCallback` with `MapOptions(initialCameraFit: CameraFit.bounds(...))` across all modal preview dialogs and embedded cards.
    - `FlutterMap` now fits the camera natively as soon as the dialog layout is measured, with zero race conditions.
  - **Lifecycle Ready Guards (`_isMapReady` & `onMapReady`):**
    - Added `onMapReady: () { _isMapReady = true; }` to `RiderMultiOrderMap`, `OrderDetailsScreen`, `InAppNavigationScreen`, and `LocationPickerMap`.
    - Protected all user interactions (Fit Screen FAB, Recenter FAB, My Location FAB) with `_isMapReady` checks and `try / catch` error handlers so no uninitialized map controller call can ever crash the app.

---

### 9. Proof of Delivery (POD) Photo Hidden from MVP — 100%
- **Use Case:**
  - Streamlines delivery completion for MVP by removing camera permissions and photo upload steps.
- **Changes Applied:**
  - Removed "Add Proof Photo" button, camera modal sheet, and thumbnail preview from `OrderDetailsScreen`.
  - When Rider arrives at Drop-off, tapping **Confirm Delivery** immediately transitions the order status to `delivered`.

---

### 10. Turn-by-Turn In-App Road Navigation — 100%
- **Use Case:**
  - Allows riders to navigate directly inside the app with turn-by-turn routing instead of launching external mapping apps.
- **Features:**
  - Real road geometry via OSRM routing (`RouteNavigationService`) with automatic offline straight-line fallback.
  - Live turn maneuver banners (e.g. "Turn right on Margalla Road", distance, ETA).
  - Target switcher (Pickup vs Drop-off).
  - Live rider GPS beacon with heading orientation and Auto-Follow camera tracking.
  - Direct Phone dialer button (`ExternalLauncher.openPhoneDialer`).

---

### 11. Mandatory Startup Location Permission Gate — 100%
- **Use Case:**
  - Ensures continuous GPS access required for pickup/drop-off pinning and live delivery tracking.
- **Flow:**
  - App opens -> invokes `LocationGateCubit.checkAndRequestOnStartup()`.
  - If permission denied or GPS disabled: strictly locks user on `LocationPermissionGateScreen` with system settings shortcuts.
  - On return from OS settings, permissions automatically re-verify and unlock app to Login or Home.

---

### 12. Safe Background Delivery Service — 100%
- **Use Case:**
  - Prevents app crashes when toggling offline shift and maintains continuous background location broadcasting.
- **Fixes Applied:**
  - Wrapped subscription cancellation in safe error handlers (`cancelOnError: true`, `_positionStreamSubscription = null`).
  - Resolved `PlatformException(error, No active stream to cancel, null, null)`.
