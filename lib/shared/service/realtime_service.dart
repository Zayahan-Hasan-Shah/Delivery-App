import 'dart:async';
import 'dart:math';
import 'package:delivery_app/core/constant/event_names.dart';
import 'package:delivery_app/core/utils/app_logger.dart';

enum RealtimeConnectionStatus { disconnected, connecting, connected, error }

class RealtimeEvent {
  final String eventName;
  final String orderId;
  final Map<String, dynamic> payload;
  final DateTime timestamp;

  RealtimeEvent({
    required this.eventName,
    required this.orderId,
    required this.payload,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  @override
  String toString() => 'RealtimeEvent($eventName, orderId: $orderId, payload: $payload)';
}

abstract class RealtimeService {
  Stream<RealtimeConnectionStatus> get connectionStatusStream;
  Stream<RealtimeEvent> get eventStream;
  RealtimeConnectionStatus get currentStatus;

  Future<void> connect();
  Future<void> disconnect();
  Future<void> reconnect();

  void subscribeToOrder(String orderId);
  void unsubscribeFromOrder(String orderId);

  Stream<RealtimeEvent> getOrderEvents(String orderId);
  Stream<Map<String, dynamic>> listenForStatusUpdates(String orderId);
  Stream<Map<String, dynamic>> listenForRiderAssignment(String orderId);
  Stream<Map<String, dynamic>> listenForRiderLocation(String orderId);

  void emit(RealtimeEvent event);
}

class MockRealtimeService implements RealtimeService {
  final _statusController = StreamController<RealtimeConnectionStatus>.broadcast();
  final _eventController = StreamController<RealtimeEvent>.broadcast();
  final Set<String> _subscribedOrders = {};
  Timer? _simulationTimer;
  RealtimeConnectionStatus _status = RealtimeConnectionStatus.disconnected;

  MockRealtimeService() {
    _status = RealtimeConnectionStatus.disconnected;
  }

  @override
  Stream<RealtimeConnectionStatus> get connectionStatusStream => _statusController.stream;

  @override
  Stream<RealtimeEvent> get eventStream => _eventController.stream;

  @override
  RealtimeConnectionStatus get currentStatus => _status;

  @override
  Future<void> connect() async {
    if (_status == RealtimeConnectionStatus.connected) return;
    _setStatus(RealtimeConnectionStatus.connecting);
    await Future.delayed(const Duration(milliseconds: 500));
    _setStatus(RealtimeConnectionStatus.connected);
    AppLogger.info('Realtime connected to mock transport', tag: 'RealtimeService');
  }

  @override
  Future<void> disconnect() async {
    _simulationTimer?.cancel();
    _setStatus(RealtimeConnectionStatus.disconnected);
    AppLogger.info('Realtime disconnected', tag: 'RealtimeService');
  }

  @override
  Future<void> reconnect() async {
    await disconnect();
    await connect();
  }

  @override
  void subscribeToOrder(String orderId) {
    _subscribedOrders.add(orderId);
    AppLogger.debug('Subscribed to order: $orderId', tag: 'RealtimeService');
    _startSimulatingOrderUpdatesIfNeeded(orderId);
  }

  @override
  void unsubscribeFromOrder(String orderId) {
    _subscribedOrders.remove(orderId);
    AppLogger.debug('Unsubscribed from order: $orderId', tag: 'RealtimeService');
  }

  @override
  Stream<RealtimeEvent> getOrderEvents(String orderId) {
    return _eventController.stream.where((event) => event.orderId == orderId);
  }

  @override
  Stream<Map<String, dynamic>> listenForStatusUpdates(String orderId) {
    return getOrderEvents(orderId)
        .where((e) => e.eventName == RealtimeEventNames.orderStatusUpdated)
        .map((e) => e.payload);
  }

  @override
  Stream<Map<String, dynamic>> listenForRiderAssignment(String orderId) {
    return getOrderEvents(orderId)
        .where((e) => e.eventName == RealtimeEventNames.riderAssigned)
        .map((e) => e.payload);
  }

  @override
  Stream<Map<String, dynamic>> listenForRiderLocation(String orderId) {
    return getOrderEvents(orderId)
        .where((e) => e.eventName == RealtimeEventNames.riderLocationUpdated)
        .map((e) => e.payload);
  }

  @override
  void emit(RealtimeEvent event) {
    AppLogger.debug('Emitted Realtime event: ${event.eventName} for order: ${event.orderId}', tag: 'RealtimeService');
    _eventController.add(event);
  }

  void _setStatus(RealtimeConnectionStatus status) {
    _status = status;
    _statusController.add(status);
  }

  void _startSimulatingOrderUpdatesIfNeeded(String orderId) {
    // Generates periodic updates (e.g. rider movement) if simulated
    if (_simulationTimer != null && _simulationTimer!.isActive) return;

    final random = Random();
    double currentLat = 33.6844;
    double currentLng = 73.0479;

    _simulationTimer = Timer.periodic(const Duration(seconds: 4), (timer) {
      if (_subscribedOrders.isEmpty) {
        timer.cancel();
        return;
      }

      for (final id in _subscribedOrders) {
        // Jiggle rider location smoothly
        currentLat += (random.nextDouble() - 0.48) * 0.0005;
        currentLng += (random.nextDouble() - 0.48) * 0.0005;

        emit(
          RealtimeEvent(
            eventName: RealtimeEventNames.riderLocationUpdated,
            orderId: id,
            payload: {
              'latitude': currentLat,
              'longitude': currentLng,
              'heading': (random.nextDouble() * 360).roundToDouble(),
              'speed': 25.0 + random.nextInt(15),
              'timestamp': DateTime.now().toIso8601String(),
            },
          ),
        );
      }
    });
  }

  void dispose() {
    _simulationTimer?.cancel();
    _statusController.close();
    _eventController.close();
  }
}
