import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:delivery_app/core/constant/app_constants.dart';
import 'package:delivery_app/core/utils/app_logger.dart';

enum LocationAccessStatus {
  granted,
  denied,
  deniedForever,
  gpsDisabled,
}

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
  Future<LocationAccessStatus> checkLocationAccessStatus();
  Future<LocationAccessStatus> requestMandatoryLocationAccess();
  Future<bool> checkPermission();
  Future<bool> requestPermission();
  Future<bool> isGpsEnabled();
  Future<bool> openAppSettings();
  Future<bool> openLocationSettings();
  Future<UserLocation?> getCurrentLocation();
  Stream<UserLocation> get locationStream;
  Future<void> startTracking({
    int distanceFilterMeters = AppConstants.locationDistanceFilterMeters,
    int intervalSeconds = AppConstants.locationUpdateIntervalSeconds,
    bool enableBackgroundService = true,
  });
  Future<void> stopTracking();
  bool get isTracking;
  UserLocation? get lastKnownLocation;
}

class LocationServiceImpl implements LocationService {
  final _locationController = StreamController<UserLocation>.broadcast();
  StreamSubscription<Position>? _positionStreamSubscription;
  Timer? _simulatedTimer;
  bool _isTracking = false;
  UserLocation? _lastKnownLocation;

  @override
  Stream<UserLocation> get locationStream => _locationController.stream;

  @override
  bool get isTracking => _isTracking;

  @override
  UserLocation? get lastKnownLocation => _lastKnownLocation;

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
  Future<LocationAccessStatus> checkLocationAccessStatus() async {
    try {
      final gpsEnabled = await Geolocator.isLocationServiceEnabled();
      if (!gpsEnabled) {
        return LocationAccessStatus.gpsDisabled;
      }

      final permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.always ||
          permission == LocationPermission.whileInUse) {
        return LocationAccessStatus.granted;
      }
      if (permission == LocationPermission.deniedForever) {
        return LocationAccessStatus.deniedForever;
      }
      return LocationAccessStatus.denied;
    } catch (e) {
      AppLogger.warning('Error checking location access status: $e', tag: 'LocationService');
      return LocationAccessStatus.denied;
    }
  }

  @override
  Future<LocationAccessStatus> requestMandatoryLocationAccess() async {
    try {
      final gpsEnabled = await Geolocator.isLocationServiceEnabled();
      if (!gpsEnabled) {
        return LocationAccessStatus.gpsDisabled;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        AppLogger.info('Requesting mandatory location permission...', tag: 'LocationService');
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.deniedForever) {
        return LocationAccessStatus.deniedForever;
      }

      if (permission == LocationPermission.always ||
          permission == LocationPermission.whileInUse) {
        return LocationAccessStatus.granted;
      }

      return LocationAccessStatus.denied;
    } catch (e, st) {
      AppLogger.error(
        'Error requesting mandatory location permission',
        error: e,
        stackTrace: st,
        tag: 'LocationService',
      );
      return LocationAccessStatus.denied;
    }
  }

  @override
  Future<bool> checkPermission() async {
    final status = await checkLocationAccessStatus();
    return status == LocationAccessStatus.granted;
  }

  @override
  Future<bool> requestPermission() async {
    final status = await requestMandatoryLocationAccess();
    return status == LocationAccessStatus.granted;
  }

  @override
  Future<bool> openAppSettings() async {
    try {
      return await Geolocator.openAppSettings();
    } catch (e) {
      AppLogger.warning('Failed to open app settings: $e', tag: 'LocationService');
      return false;
    }
  }

  @override
  Future<bool> openLocationSettings() async {
    try {
      return await Geolocator.openLocationSettings();
    } catch (e) {
      AppLogger.warning('Failed to open location settings: $e', tag: 'LocationService');
      return false;
    }
  }

  @override
  Future<UserLocation?> getCurrentLocation() async {
    try {
      final access = await requestMandatoryLocationAccess();
      if (access != LocationAccessStatus.granted) {
        AppLogger.warning('Cannot get current location: $access', tag: 'LocationService');
        return null;
      }

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 8),
        ),
      );

      final loc = UserLocation(
        latitude: position.latitude,
        longitude: position.longitude,
        heading: position.heading,
        speed: position.speed,
        timestamp: position.timestamp,
      );
      _lastKnownLocation = loc;
      _locationController.add(loc);
      return loc;
    } catch (e, st) {
      AppLogger.error(
        'Unable to fetch GPS position, using safe fallback coordinates',
        error: e,
        stackTrace: st,
        tag: 'LocationService',
      );
      final fallback = UserLocation(
        latitude: AppConstants.defaultLatitude,
        longitude: AppConstants.defaultLongitude,
      );
      _lastKnownLocation = fallback;
      return fallback;
    }
  }

  LocationSettings _buildLocationSettings({
    required int distanceFilterMeters,
    required int intervalSeconds,
    required bool enableBackgroundService,
  }) {
    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
      return AndroidSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: distanceFilterMeters,
        intervalDuration: Duration(seconds: intervalSeconds),
        foregroundNotificationConfig: enableBackgroundService
            ? const ForegroundNotificationConfig(
                notificationTitle: 'ShefsCloud Delivery Active',
                notificationText:
                    'Live location tracking is running in the background for your deliveries.',
                enableWakeLock: true,
                setOngoing: true,
              )
            : null,
      );
    }

    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.iOS) {
      return AppleSettings(
        accuracy: LocationAccuracy.high,
        activityType: ActivityType.automotiveNavigation,
        distanceFilter: distanceFilterMeters,
        pauseLocationUpdatesAutomatically: false,
        showBackgroundLocationIndicator: enableBackgroundService,
        allowBackgroundLocationUpdates: enableBackgroundService,
      );
    }

    return LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: distanceFilterMeters,
    );
  }

  @override
  Future<void> startTracking({
    int distanceFilterMeters = AppConstants.locationDistanceFilterMeters,
    int intervalSeconds = AppConstants.locationUpdateIntervalSeconds,
    bool enableBackgroundService = true,
  }) async {
    if (_isTracking) return;

    final hasPerm = await requestPermission();
    if (!hasPerm) {
      AppLogger.warning('Cannot start tracking: permission denied', tag: 'LocationService');
      return;
    }

    _isTracking = true;
    AppLogger.info(
      'Started GPS tracking (background=$enableBackgroundService, filter=${distanceFilterMeters}m)',
      tag: 'LocationService',
    );

    try {
      final settings = _buildLocationSettings(
        distanceFilterMeters: distanceFilterMeters,
        intervalSeconds: intervalSeconds,
        enableBackgroundService: enableBackgroundService,
      );

      _positionStreamSubscription = Geolocator.getPositionStream(
        locationSettings: settings,
      ).listen(
        (Position pos) {
          final loc = UserLocation(
            latitude: pos.latitude,
            longitude: pos.longitude,
            heading: pos.heading,
            speed: pos.speed,
            timestamp: pos.timestamp,
          );
          _lastKnownLocation = loc;
          _locationController.add(loc);
        },
        onError: (Object err) {
          AppLogger.warning(
            'GPS position stream error, switching to fallback stream: $err',
            tag: 'LocationService',
          );
          _positionStreamSubscription = null;
          _startFallbackStream(intervalSeconds);
        },
        onDone: () {
          _positionStreamSubscription = null;
        },
        cancelOnError: true,
      );
    } catch (e) {
      AppLogger.warning(
        'Platform position stream unavailable, starting fallback simulation: $e',
        tag: 'LocationService',
      );
      _positionStreamSubscription = null;
      _startFallbackStream(intervalSeconds);
    }
  }

  void _startFallbackStream(int intervalSeconds) {
    _simulatedTimer?.cancel();
    double lat = _lastKnownLocation?.latitude ?? AppConstants.defaultLatitude;
    double lng = _lastKnownLocation?.longitude ?? AppConstants.defaultLongitude;
    _simulatedTimer = Timer.periodic(Duration(seconds: intervalSeconds), (_) {
      lat += 0.00018;
      lng += 0.00012;
      final loc = UserLocation(
        latitude: lat,
        longitude: lng,
        heading: 45.0,
        speed: 28.0,
      );
      _lastKnownLocation = loc;
      _locationController.add(loc);
    });
  }

  @override
  Future<void> stopTracking() async {
    final sub = _positionStreamSubscription;
    _positionStreamSubscription = null;
    if (sub != null) {
      try {
        await sub.cancel();
      } catch (e) {
        AppLogger.warning(
          'Ignoring benign GPS stream cancel error: $e',
          tag: 'LocationService',
        );
      }
    }
    _simulatedTimer?.cancel();
    _simulatedTimer = null;
    _isTracking = false;
    AppLogger.info('Stopped GPS tracking', tag: 'LocationService');
  }

  void dispose() {
    final sub = _positionStreamSubscription;
    _positionStreamSubscription = null;
    if (sub != null) {
      sub.cancel().catchError((_) {});
    }
    _simulatedTimer?.cancel();
    _locationController.close();
  }
}
