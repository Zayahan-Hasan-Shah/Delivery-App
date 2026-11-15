import 'dart:async';
import 'package:geolocator/geolocator.dart';
import 'package:delivery_app/core/constant/app_constants.dart';
import 'package:delivery_app/core/utils/app_logger.dart';

class UserLocation {
  final double latitude;
  final double longitude;
  final double? heading;
  final double? speed;
  final DateTime timestamp;

  UserLocation({
    required this.latitude,
    required this.longitude,
    this.heading,
    this.speed,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  Map<String, dynamic> toJson() => {
        'latitude': latitude,
        'longitude': longitude,
        'heading': heading,
        'speed': speed,
        'timestamp': timestamp.toIso8601String(),
      };
}

abstract class LocationService {
  Future<bool> checkPermission();
  Future<bool> requestPermission();
  Future<bool> isGpsEnabled();
  Future<UserLocation?> getCurrentLocation();
  Stream<UserLocation> get locationStream;
  Future<void> startTracking({int distanceFilterMeters, int intervalSeconds});
  Future<void> stopTracking();
  bool get isTracking;
}

class LocationServiceImpl implements LocationService {
  final _locationController = StreamController<UserLocation>.broadcast();
  StreamSubscription<Position>? _positionStreamSubscription;
  Timer? _simulatedTimer;
  bool _isTracking = false;

  @override
  Stream<UserLocation> get locationStream => _locationController.stream;

  @override
  bool get isTracking => _isTracking;

  @override
  Future<bool> isGpsEnabled() async {
    try {
      return await Geolocator.isLocationServiceEnabled();
    } catch (e) {
      AppLogger.warning('Error checking GPS availability: $e', tag: 'LocationService');
      return false;
    }
  }

  @override
  Future<bool> checkPermission() async {
    try {
      final permission = await Geolocator.checkPermission();
      return permission == LocationPermission.always || permission == LocationPermission.whileInUse;
    } catch (e) {
      AppLogger.warning('Error checking location permission: $e', tag: 'LocationService');
      return false;
    }
  }

  @override
  Future<bool> requestPermission() async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        AppLogger.info('Requesting device location permission...', tag: 'LocationService');
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.deniedForever) {
        AppLogger.warning('Location permissions are permanently denied by user.', tag: 'LocationService');
        return false;
      }

      final granted = permission == LocationPermission.always || permission == LocationPermission.whileInUse;
      AppLogger.info('Location permission result: $granted ($permission)', tag: 'LocationService');
      return granted;
    } catch (e, st) {
      AppLogger.error('Failed to request location permission', error: e, stackTrace: st, tag: 'LocationService');
      return false;
    }
  }

  @override
  Future<UserLocation?> getCurrentLocation() async {
    try {
      final hasPermission = await requestPermission();
      if (!hasPermission) {
        AppLogger.warning('Cannot get current location: permission not granted', tag: 'LocationService');
        return null;
      }

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 8),
        ),
      );

      AppLogger.info(
        'Fetched current location: (${position.latitude}, ${position.longitude})',
        tag: 'LocationService',
      );

      return UserLocation(
        latitude: position.latitude,
        longitude: position.longitude,
        heading: position.heading,
        speed: position.speed,
        timestamp: position.timestamp,
      );
    } catch (e, st) {
      AppLogger.error(
        'Unable to fetch real-time device location (GPS/Timeout), using fallback default coordinates',
        error: e,
        stackTrace: st,
        tag: 'LocationService',
      );
      // Return safe fallback center coordinates if device GPS fails/times out
      return UserLocation(
        latitude: AppConstants.defaultLatitude,
        longitude: AppConstants.defaultLongitude,
        timestamp: DateTime.now(),
      );
    }
  }

  @override
  Future<void> startTracking({
    int distanceFilterMeters = AppConstants.locationDistanceFilterMeters,
    int intervalSeconds = AppConstants.locationUpdateIntervalSeconds,
  }) async {
    if (_isTracking) return;
    _isTracking = true;

    final hasPermission = await requestPermission();
    if (hasPermission) {
      try {
        const locationSettings = LocationSettings(
          accuracy: LocationAccuracy.high,
          distanceFilter: AppConstants.locationDistanceFilterMeters,
        );

        _positionStreamSubscription = Geolocator.getPositionStream(locationSettings: locationSettings).listen(
          (position) {
            _locationController.add(
              UserLocation(
                latitude: position.latitude,
                longitude: position.longitude,
                heading: position.heading,
                speed: position.speed,
                timestamp: position.timestamp,
              ),
            );
          },
          onError: (e) {
            AppLogger.warning('Position stream error: $e. Falling back to simulation.', tag: 'LocationService');
            _startFallbackTracking(intervalSeconds);
          },
        );
        return;
      } catch (e) {
        AppLogger.warning('Position stream initialization failed: $e', tag: 'LocationService');
      }
    }

    _startFallbackTracking(intervalSeconds);
  }

  void _startFallbackTracking(int intervalSeconds) {
    _simulatedTimer?.cancel();
    double currentLat = AppConstants.defaultLatitude;
    double currentLng = AppConstants.defaultLongitude;

    _simulatedTimer = Timer.periodic(Duration(seconds: intervalSeconds), (_) {
      currentLat += 0.0001;
      currentLng += 0.0001;
      _locationController.add(
        UserLocation(
          latitude: currentLat,
          longitude: currentLng,
          heading: 45.0,
          speed: 25.0,
          timestamp: DateTime.now(),
        ),
      );
    });
  }

  @override
  Future<void> stopTracking() async {
    await _positionStreamSubscription?.cancel();
    _positionStreamSubscription = null;
    _simulatedTimer?.cancel();
    _simulatedTimer = null;
    _isTracking = false;
    AppLogger.info('Location tracking stopped', tag: 'LocationService');
  }

  void dispose() {
    stopTracking();
    _locationController.close();
  }
}
