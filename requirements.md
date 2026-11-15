You are a senior Flutter architect and production mobile application engineer.

I need you to help me design and implement a production-ready Flutter application for a delivery/logistics system.

The application will have three user roles:

1. Customer
2. Client
3. Rider

IMPORTANT:

- We are developing ONLY the Flutter mobile application.
- Backend development is NOT part of this task So we have to use dummy data for now.
- Assume REST APIs already exist or will be provided.
- The Flutter application must be architected so that API endpoints, authentication, real-time communication and Firebase configuration can easily be connected.
- Do not create a fake architecture that would need to be completely rewritten when real APIs are connected.
- Use repository/service abstractions and mock implementations only where necessary.
- The application must be production-oriented and scalable.
- Do not put business logic inside UI widgets.
- Do not hardcode business data in widgets.
- Do not create one completely separate application for each role. Use role-based navigation and shared components/features.
- The application must be prepared for future wallet functionality and integration with another application.

==================================================
TECHNOLOGY REQUIREMENTS
==================================================

Use:

- Flutter
- Dart
- Bloc for state management
- GoRouter for navigation
- REST API integration
- WebSocket or SignalR abstraction for real-time communication
- Firebase Cloud Messaging (FCM) for push notifications
- Google Maps / appropriate Flutter map SDK for maps or any other map package which is free and easy to use
- Location services for rider location tracking
- Dio for HTTP networking
- Secure token storage
- JSON serialization/model layer
- Clean Architecture / feature-first architecture

Use responsive UI.

Avoid putting API calls, WebSocket logic, Firebase logic, location logic or business logic directly inside widgets.

Use:

- Models
- DTOs where appropriate
- Repositories
- Services
- Providers
- Controllers/Notifiers
- Shared widgets
- Shared utilities

Use proper error handling, loading states, empty states and retry states.

==================================================
USER ROLES
==================================================

The application supports:

CUSTOMER

The customer can:

- Login
- Register
- View dashboard
- Create delivery orders
- Track their orders
- View order details
- View live rider location
- View order status
- Contact relevant parties
- View delivered orders

CLIENT

The client can:

- Login
- Register if allowed by backend
- View dashboard
- View relevant orders
- Track orders
- View live rider location
- View order status
- Contact relevant parties
- View order details

RIDER

The rider can:

- Login
- View dashboard
- View assigned orders
- View order details
- Track assigned orders
- See pickup and drop-off locations
- Share live location
- Receive FCM notifications
- Contact customer/client
- View earnings
- View total earned

IMPORTANT:

The rider CANNOT create orders.

The rider CANNOT manually accept orders at this stage.

The system will automatically assign an order to a rider based on proximity to the pickup location.

The backend is responsible for the actual assignment decision, but Flutter must be designed to receive and display the assignment in real time.

In the future, riders may be allowed to accept orders, so do not hardcode the current behavior in a way that prevents this future functionality.

==================================================
MAIN SCREENS
==================================================

Create the following main screens:

1. Splash Screen
2. Login Screen
3. Registration Screen
4. Home Screen
5. New Order Screen
6. Track Order Screen
7. Rider Orders Screen
8. Order Details Screen where appropriate

Navigation must be role-aware.

==================================================
1. SPLASH SCREEN
==================================================

The splash screen should:

- Display application branding
- Initialize required services
- Check authentication state
- Restore stored authentication token/session
- Determine current user role
- Navigate to the appropriate home screen
- Navigate to login if unauthenticated

Do not artificially delay the splash screen unless required for UX.

==================================================
2. LOGIN
==================================================

Login should contain:

- Phone/email field depending on backend contract
- Password field
- Login button
- Validation
- Loading state
- API error handling
- Invalid credentials handling
- Session/token storage

After successful login:

Customer → Customer Home

Client → Client Home

Rider → Rider Home

The role must come from authenticated user information/API response rather than being manually selected by the user.

==================================================
3. REGISTRATION
==================================================

Create registration architecture that can support backend-defined registration fields.

At minimum prepare support for:

- Name
- Phone
- Email if required
- Password
- Confirm password
- Relevant role information if backend requires it

Do not allow users to arbitrarily register as Rider unless the backend explicitly supports rider registration.

Add:

- Field validation
- Password validation
- Loading state
- API error handling
- Successful registration handling

==================================================
4. HOME SCREEN
==================================================

The Home Screen is role-dependent but should share reusable components.

CUSTOMER HOME

Display:

1. Summary cards

- On Road
- Waiting
- Delivered

2. Live map

Display relevant active order information.

The map should support:

- Pickup marker
- Drop-off marker
- Rider marker
- Route if backend/provider supports it
- Live rider position
- Multiple active orders where applicable

3. Summarized order list

Each order item should show useful information such as:

- Order number
- Current status
- Pickup location
- Drop-off location
- Estimated arrival time
- Rider information if assigned

CLIENT HOME

Display:

1. Summary cards

- On Road
- Waiting
- Delivered

2. Live map

3. Summarized order list

The list must only contain orders the authenticated client is authorized to view.

RIDER HOME

Display:

1. Summary cards

- On Road
- Waiting
- Delivered

2. Live map

3. Summarized assigned-order list

4. Total earned

The earnings component must be designed so that wallet/earnings functionality can be expanded in the future.

Do not implement a full wallet system yet.

==================================================
5. NEW ORDER SCREEN
==================================================

Only CUSTOMER can currently create an order.

RIDER cannot create orders.

The New Order screen should contain:

--------------------------------
PICKUP / DROP-OFF TABS
--------------------------------

Create two tabs:

- Pickup Pin Point
- Drop-off Pin Point

When Pickup tab is active:

- Display map
- Allow user to select pickup location
- Display draggable pickup marker

When Drop-off tab is active:

- Display map
- Allow user to select drop-off location
- Display draggable drop-off marker

The user must be able to change the location by dragging the marker.

The selected coordinates must be stored independently:

pickupLatitude
pickupLongitude

dropoffLatitude
dropoffLongitude

Do not overwrite one location with another.

--------------------------------
PICKUP DETAILS
--------------------------------

Fields:

- Name
- Phone number
- Address (optional)

Pickup information must be editable.

--------------------------------
DROP-OFF DETAILS
--------------------------------

Fields:

- Name
- Phone number
- Address (optional)

Drop-off information must be editable.

The drop-off information may sometimes be automatically populated by the backend or previous data.

Therefore:

- The UI must support prefilled drop-off data.
- The user must still be able to edit it when permitted.
- Do not assume drop-off data is always manually entered.

--------------------------------
ITEMS
--------------------------------

The customer can add multiple items.

Each item should contain:

- Item name
- Quantity

Example:

Item 1:
Name: Documents
Quantity: 2

Item 2:
Name: Shoes
Quantity: 1

Allow:

- Add item
- Edit item
- Remove item

Do not use hardcoded item lists.

--------------------------------
RIDER NOTE
--------------------------------

Provide an optional note/message for the rider.

Example:

"Please call before arriving."

--------------------------------
ORDER CREATION
--------------------------------

Provide a Place Order button.

Before submitting:

Validate:

- Pickup coordinates
- Drop-off coordinates
- Pickup name
- Pickup phone
- Drop-off name
- Drop-off phone
- At least one item
- Valid item quantities

The application should display a confirmation/loading state while creating the order.

Prevent duplicate submissions by disabling the button while the request is in progress.

After successful creation:

- Clear/refresh appropriate state
- Show order number
- Navigate to order tracking/details
- Subscribe to relevant real-time order events
- Display current order status

==================================================
6. TRACK ORDER SCREEN
==================================================

The Track Order screen is shared between:

- Customer
- Client
- Rider

but behavior and permissions are role-dependent.

--------------------------------
ORDER SELECTOR
--------------------------------

At the top, display order numbers horizontally.

Example:

[ORD-1005] [ORD-1004] [ORD-1003] [ORD-1002]

By default:

- Select the latest order.

When the user selects another order:

- Load its details
- Load its map state
- Subscribe/unsubscribe from relevant real-time events correctly

Avoid unnecessary API calls when the same order is already loaded.

--------------------------------
MAP
--------------------------------

Display:

- Pickup marker
- Drop-off marker
- Rider marker when rider is assigned
- Rider live location

The rider marker must update in real time.

Do not rebuild the entire screen unnecessarily every time a rider location update is received.

Use efficient state separation.

The map should support camera movement appropriately.

Handle:

- Location permission errors
- GPS unavailable
- Rider location unavailable
- Rider not yet assigned
- Network disconnection
- Reconnection

--------------------------------
ETA
--------------------------------

Display estimated arrival time.

Example:

"Arriving in 18 min"

The ETA must come from backend/API when available.

Do not calculate fake ETA values.

If the backend does not provide ETA, expose an abstraction so ETA calculation can be added later.

--------------------------------
ORDER STATUS TIMELINE
--------------------------------

Display current status and status history.

Initial statuses may include:

PLACED
ACCEPTED
PICKED_UP
DELIVERED

The architecture must also be able to support future statuses such as:

ASSIGNED
ON_THE_WAY
CANCELLED
REJECTED
FAILED

The UI should clearly show:

- Completed statuses
- Current status
- Upcoming statuses

If the backend sends status history, display the actual history instead of assuming every status occurred.

--------------------------------
CALL OPTIONS
--------------------------------

Display relevant contact options:

- Call Customer
- Call Rider
- Call Client

However, do not show a user a call option for themselves.

Therefore:

CUSTOMER:

Can call:
- Rider
- Client

Cannot call:
- Customer/self

RIDER:

Can call:
- Customer
- Client

Cannot call:
- Rider/self

CLIENT:

Can call:
- Customer
- Rider

Cannot call:
- Client/self

The call buttons should use the phone number supplied by the backend.

Do not hardcode phone numbers.

Use a reusable contact/call component.

--------------------------------
ORDER ITEMS
--------------------------------

Display all items belonging to the selected order:

- Item name
- Quantity

Also display rider note when available.

==================================================
7. RIDER ORDERS SCREEN
==================================================

This screen is primarily for the Rider.

Display assigned orders.

Orders must be filterable by status.

Example filters:

- All
- Waiting
- Assigned
- Picked Up
- On Road
- Delivered

The exact status list must be configurable.

Each order card should show:

- Order number
- Pickup
- Drop-off
- Current status
- ETA if available
- Assignment information
- Relevant timestamps

On tapping an order:

→ Open Order Details / Track Order screen.

The rider must NOT be allowed to create an order.

The rider must NOT be allowed to manually accept the order in the current version.

==================================================
8. AUTOMATIC RIDER ASSIGNMENT
==================================================

Important business rule:

When an order is created, the rider should be automatically assigned based on proximity to the pickup location.

The Flutter application does NOT need to calculate the final assignment unless the backend explicitly requires it.

Instead:

Backend determines:

- Which rider is closest
- Whether rider is available
- Which rider should receive the order

Flutter must:

- Receive assignment event
- Update order state
- Display assigned rider
- Display rider location
- Display rider on map
- Notify user appropriately

The architecture must be prepared for future rider manual acceptance.

==================================================
9. REAL-TIME COMMUNICATION
==================================================

Real-time order status and rider tracking are mandatory.

Create a dedicated real-time abstraction.

For example:

RealtimeService

or

RealtimeRepository

Do NOT directly place WebSocket/SignalR connection code inside widgets.

The abstraction should support:

- Connect
- Disconnect
- Reconnect
- Subscribe to order
- Unsubscribe from order
- Listen for order status updates
- Listen for rider assignment
- Listen for rider location updates
- Listen for order events
- Connection state
- Error state

The implementation should be replaceable between:

- WebSocket
- SignalR

without changing the presentation layer.

Example conceptual events:

ORDER_STATUS_UPDATED

RIDER_ASSIGNED

RIDER_LOCATION_UPDATED

ORDER_UPDATED

ORDER_CANCELLED

DELIVERY_COMPLETED

Do not assume these are the final backend event names.

Create an event mapping layer/configuration so the backend event names can easily be changed.

==================================================
10. RIDER LOCATION
==================================================

The rider's device must be capable of sending location updates to the backend when the rider is actively handling a delivery.

Create a dedicated location service.

Responsibilities:

- Request location permission
- Check GPS availability
- Start tracking
- Stop tracking
- Stream location
- Handle permission denial
- Handle background limitations appropriately
- Send location updates through the appropriate backend mechanism

Do not continuously send location updates when they are unnecessary.

The architecture should support configurable:

- Distance filter
- Update interval
- Accuracy

The exact values should be configurable rather than scattered as magic numbers.

==================================================
11. FIREBASE CLOUD MESSAGING
==================================================

Integrate FCM.

Prepare notification handling for:

- Order placed
- Order accepted
- Rider assigned
- Rider approaching
- Order picked up
- Order delivered
- Order cancelled
- Other backend-defined events

Support:

- Foreground notification
- Background notification
- Notification tap
- Cold-start notification navigation

If a notification references an order ID:

The application should be able to navigate directly to that order's tracking/details screen.

Do not hardcode notification navigation.

Create a notification routing abstraction.

==================================================
12. AUTHENTICATION
==================================================

Create proper authentication architecture.

Support:

- Login
- Logout
- Token persistence
- Token refresh if backend supports it
- Unauthorized API response handling
- Session restoration

If API returns HTTP 401:

- Clear invalid session where appropriate
- Redirect to login
- Avoid navigation loops

Use secure storage for tokens.

Do not store sensitive tokens in plain SharedPreferences.

==================================================
13. API ARCHITECTURE
==================================================

Use a clean API architecture.

Suggested structure:

ApiClient
AuthService
OrderService
UserService
RiderService
LocationService
NotificationService
RealtimeService

Repositories should sit between services/data sources and presentation logic.

Example:

UI
↓
Controller / Notifier
↓
Repository
↓
Service
↓
API

For real-time:

UI
↓
Controller / Notifier
↓
RealtimeRepository
↓
RealtimeService
↓
WebSocket / SignalR

==================================================
14. PROJECT STRUCTURE
==================================================

Use feature-first architecture.

Suggested structure:

lib/

  core/
    constants/
    errors/
    network/
    storage/
    routing/
    theme/
    utils/
    permissions/

  features/

    auth/
      data/
      domain/
      presentation/

    home/
      data/
      domain/
      presentation/

    orders/
      data/
      domain/
      presentation/

    tracking/
      data/
      domain/
      presentation/

    rider/
      data/
      domain/
      presentation/

    notifications/
      data/
      domain/
      presentation/

    location/
      data/
      domain/
      presentation/

  shared/
    widgets/
    models/
    extensions/

Keep responsibilities separated.

==================================================
15. STATE MANAGEMENT
==================================================

Use Riverpod.

Do not create one giant provider for the entire application.

Separate state by responsibility.

For example:

authProvider

currentUserProvider

ordersProvider

activeOrdersProvider

orderDetailsProvider

trackingProvider

riderLocationProvider

realtimeConnectionProvider

notificationProvider

Use appropriate Riverpod patterns such as:

Notifier
AsyncNotifier
FutureProvider
StreamProvider

where appropriate.

Avoid unnecessary state duplication.

==================================================
16. ERROR HANDLING
==================================================

Every API-driven screen must support:

Loading
Success
Empty
Error
Retry

Handle:

- Network failure
- Timeout
- Unauthorized
- Server errors
- Validation errors
- No internet
- WebSocket disconnect
- Firebase failure
- Location permission denial
- GPS unavailable

Do not expose raw technical exceptions directly to users.

Create user-friendly error messages while preserving useful logs for developers.

==================================================
17. LOGGING
==================================================

Use structured development logging.

Do not use print() throughout the application.

Logs should help diagnose:

- API requests
- API failures
- Authentication
- WebSocket connection
- WebSocket reconnection
- Order status updates
- Rider location updates
- FCM events

Never log:

- Passwords
- Authentication tokens
- Sensitive personal information

==================================================
18. FUTURE WALLET SUPPORT
==================================================

Wallet is NOT part of the current implementation.

However, the architecture must not prevent it.

Future wallet may include:

- Balance
- Transactions
- Earnings
- Withdrawals
- Payments
- Refunds

Do not build wallet screens now.

Only make sure financial/earnings models and architecture can be extended without major restructuring.

==================================================
19. FUTURE APP INTEGRATION
==================================================

This application will eventually integrate with another application.

Therefore:

- Keep API layer modular
- Keep authentication abstraction clean
- Keep deep linking in mind
- Keep order IDs stable
- Keep notification routing modular
- Avoid hardcoding assumptions about where orders originate
- Use backend IDs rather than relying on local indexes
- Keep models serializable

==================================================
20. MAP REQUIREMENTS
==================================================

Create reusable map components.

For example:

DeliveryMap

PickupMarker

DropoffMarker

RiderMarker

MapController/service where necessary

The map should not contain business logic.

The tracking feature should provide map state to the map widget.

Support:

- Pickup location
- Drop-off location
- Rider location
- Camera fitting
- Marker updates
- Permission handling
- Loading state

Avoid rebuilding the entire page for every location update.

==================================================
21. UI/UX REQUIREMENTS
==================================================

Create a modern professional logistics/delivery UI.

Do not make the application look like a generic tutorial project.

Use:

- Consistent spacing
- Typography hierarchy
- Reusable cards
- Reusable buttons
- Status chips
- Bottom sheets where useful
- Proper loading indicators
- Skeleton/loading states where appropriate
- Empty states
- Error states
- Responsive layouts

The dashboard should prioritize:

1. Current active deliveries
2. Important delivery status
3. Live tracking
4. Recent orders

Do not overcrowd the interface.

==================================================
22. SECURITY
==================================================

The Flutter app must:

- Store tokens securely
- Never hardcode production API secrets
- Never hardcode user credentials
- Avoid exposing sensitive information in logs
- Validate user input
- Handle unauthorized responses
- Respect backend permissions
- Never assume a user can access an order simply because they know its order ID

The backend remains the source of truth for authorization.

==================================================
23. PERFORMANCE
==================================================

Pay special attention to:

- Map performance
- Rider location updates
- WebSocket streams
- Large order lists
- Rebuilding widgets
- Image loading
- API calls

Use:

- Pagination where needed
- Lazy lists
- Selective Riverpod rebuilds
- Debouncing where appropriate
- Cached data where appropriate
- Efficient marker updates

Do not make an API request every time a widget rebuilds.

==================================================
24. OFFLINE / CONNECTION HANDLING
==================================================

The application should gracefully handle temporary connectivity loss.

For tracking:

If real-time connection drops:

- Show connection state appropriately
- Attempt reconnection
- Refresh order data when connection is restored

Do not falsely display old rider location as current without indicating that live updates are unavailable.

==================================================
25. BACKEND CONTRACT ASSUMPTIONS
==================================================

Because backend development is outside this Flutter task, create clear interfaces for the following conceptual APIs:

Authentication:

POST /auth/login
POST /auth/register
POST /auth/logout
POST /auth/refresh

Orders:

POST /orders
GET /orders
GET /orders/{id}
GET /orders/{id}/tracking
GET /orders/{id}/history

Rider:

GET /rider/orders
GET /rider/profile
GET /rider/earnings

Location:

POST /rider/location

Notifications:

POST /notifications/token

These are conceptual endpoints only.

Do not assume these exact URLs are final.

Put endpoint configuration in one centralized place.

==================================================
26. IMPORTANT DOMAIN MODELS
==================================================

Design proper models for at least:

User

Customer

Client

Rider

Order

OrderItem

PickupLocation

DropoffLocation

OrderStatus

OrderStatusHistory

RiderLocation

TrackingInformation

Notification

Earnings

Create enums or strongly typed representations where appropriate.

Do not represent everything as dynamic Map<String, dynamic> throughout the application.

==================================================
27. ORDER MODEL
==================================================

An order should conceptually support:

id
orderNumber
customer
client
rider
pickup
dropoff
items
riderNote
status
statusHistory
createdAt
updatedAt
eta
riderLocation
timestamps

Do not assume every field is always present.

Handle nullability properly.

==================================================
28. ORDER STATUS
==================================================

Create a centralized order status system.

Example:

placed
accepted
assigned
pickedUp
onTheWay
delivered
cancelled
rejected
failed

The current backend may only use:

placed
accepted
pickedUp
delivered

but the application must be extensible.

Create helpers for:

- Display label
- Status color/theme
- Timeline ordering
- Whether status is completed
- Whether status is active
- Whether status is terminal

Do not duplicate status logic across widgets.

==================================================
29. IMPLEMENTATION STRATEGY
==================================================

Do NOT immediately dump thousands of lines of code.

Work incrementally.

Phase 1:

- Project architecture
- Dependencies
- Theme
- Routing
- Authentication architecture
- Models
- Core networking

Phase 2:

- Home
- Orders
- New Order

Phase 3:

- Tracking
- Maps
- Rider location

Phase 4:

- WebSocket/SignalR
- FCM

Phase 5:

- Rider functionality
- Automatic assignment events

Phase 6:

- Error handling
- Performance
- Testing
- Production cleanup

==================================================
30. VERY IMPORTANT DEVELOPMENT RULE
==================================================

Before generating implementation code:

First provide:

1. Complete architecture
2. Folder structure
3. Required packages
4. Domain models
5. Navigation structure
6. State management strategy
7. API abstraction strategy
8. Real-time strategy
9. FCM strategy
10. Location tracking strategy
11. Order state machine
12. Role/permission matrix
13. Data flow diagrams in text
14. Implementation phases

Then implement the project phase by phase.

For each phase:

- Explain what is being implemented
- Show files to create
- Provide complete code
- Make code copy-paste ready
- Do not omit imports
- Do not use pseudo-code when real implementation is expected
- Do not use "...existing code..."
- Do not silently invent APIs
- Clearly mark assumptions
- Keep code consistent with previous phases

If backend contracts are unknown, create interfaces and mock implementations that can later be replaced by the real API.

==================================================
31. TESTING
==================================================

Create tests for important business logic.

At minimum consider tests for:

- Authentication state
- Role-based navigation
- Order status transitions
- Order validation
- Multiple order items
- Tracking state
- Rider assignment event
- Rider location update
- WebSocket reconnection
- Notification routing

Do not focus only on widget tests.

Business logic and state-management tests are important.

==================================================
32. FINAL QUALITY REQUIREMENT
==================================================

The final Flutter application should feel like a real production logistics application, not a demo.

Prioritize:

- Maintainability
- Scalability
- Clean architecture
- Real-time reliability
- Correct role-based behavior
- Performance
- Error handling
- Testability
- Future extensibility

Do not over-engineer unnecessarily, but do not take shortcuts that will make future backend integration, wallet integration, or multi-application integration difficult.



========================================================================================================================


New requirements:
Add authentication flow in it also:
1. registration
2. login
3. forgot password