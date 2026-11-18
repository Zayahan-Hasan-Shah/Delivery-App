import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:delivery_app/core/constant/app_constants.dart';
import 'package:delivery_app/core/constant/event_names.dart';
import 'package:delivery_app/core/utils/app_logger.dart';
import 'package:delivery_app/shared/service/location_service.dart';
import 'package:delivery_app/shared/service/realtime_service.dart';

/// Coordinates foreground + background delivery operations for Riders:
/// - Keeps Android Foreground Service & iOS Background Location Updates alive
/// - Persists Rider online shift state across app restarts
/// - Broadcasts live rider coordinates to [RealtimeService] for all active orders
abstract class BackgroundDeliveryService {
  bool get isBackgroundShiftRunning;
  Stream<UserLocation> get riderLiveLocationStream;
  UserLocation? get currentRiderLocation;

  Future<bool> wasOnlineBeforeRestart();
  Future<void> startRiderBackgroundShift({List<String> activeOrderIds = const []});
  void updateTrackedOrderIds(List<String> orderIds);
  Future<void> stopRiderBackgroundShift();
}

class BackgroundDeliveryServiceImpl implements BackgroundDeliveryService {
  final LocationService locationService;
  final RealtimeService realtimeService;

  StreamSubscription<UserLocation>? _locationSub;
  List<String> _activeOrderIds = const [];
  bool _isRunning = false;

  BackgroundDeliveryServiceImpl({
    required this.locationService,
    required this.realtimeService,
  });

  @override
  bool get isBackgroundShiftRunning => _isRunning;

  @override
  Stream<UserLocation> get riderLiveLocationStream => locationService.locationStream;

  @override
  UserLocation? get currentRiderLocation => locationService.lastKnownLocation;

  @override
  Future<bool> wasOnlineBeforeRestart() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool(AppConstants.keyRiderOnlineShift) ?? false;
    } catch (_) {
      return false;
    }
  }

  @override
  Future<void> startRiderBackgroundShift({
    List<String> activeOrderIds = const [],
  }) async {
    _activeOrderIds = List<String>.from(activeOrderIds);
    if (_isRunning) return;

    _isRunning = true;
    await _persistShiftState(true);

    await locationService.startTracking(
      distanceFilterMeters: AppConstants.locationDistanceFilterMeters,
      intervalSeconds: AppConstants.locationUpdateIntervalSeconds,
      enableBackgroundService: true,
    );

    await _locationSub?.cancel();
    _locationSub = locationService.locationStream.listen(_broadcastLocationToOrders);

    // Fetch an immediate initial fix so map centers immediately
    final initial = await locationService.getCurrentLocation();
    if (initial != null) {
      _broadcastLocationToOrders(initial);
    }

    AppLogger.info(
      'Background delivery shift STARTED for ${_activeOrderIds.length} active orders',
      tag: 'BackgroundDeliveryService',
    );
  }

  @override
  void updateTrackedOrderIds(List<String> orderIds) {
    _activeOrderIds = List<String>.from(orderIds);
  }

  void _broadcastLocationToOrders(UserLocation loc) {
    for (final orderId in _activeOrderIds) {
      realtimeService.emit(
        RealtimeEvent(
          eventName: RealtimeEventNames.riderLocationUpdated,
          orderId: orderId,
          payload: loc.toJson(),
        ),
      );
    }
  }

  @override
  Future<void> stopRiderBackgroundShift() async {
    _isRunning = false;
    await _persistShiftState(false);
    await _locationSub?.cancel();
    _locationSub = null;
    await locationService.stopTracking();
    AppLogger.info(
      'Background delivery shift STOPPED',
      tag: 'BackgroundDeliveryService',
    );
  }

  Future<void> _persistShiftState(bool online) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(AppConstants.keyRiderOnlineShift, online);
    } catch (_) {
      // Safe fallback for unit test environments
    }
  }
}
