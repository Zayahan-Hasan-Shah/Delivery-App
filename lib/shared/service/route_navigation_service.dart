import 'dart:math';
import 'package:dio/dio.dart';
import 'package:latlong2/latlong.dart';
import 'package:delivery_app/core/utils/app_logger.dart';

class NavigationStep {
  final String instruction;
  final String roadName;
  final String maneuverType;
  final String? modifier;
  final double distanceMeters;
  final LatLng location;

  const NavigationStep({
    required this.instruction,
    required this.roadName,
    required this.maneuverType,
    this.modifier,
    required this.distanceMeters,
    required this.location,
  });
}

class NavigationRouteResult {
  final List<LatLng> polylinePoints;
  final double distanceMeters;
  final double durationSeconds;
  final List<NavigationStep> steps;
  final bool isRoadSnapped;

  const NavigationRouteResult({
    required this.polylinePoints,
    required this.distanceMeters,
    required this.durationSeconds,
    required this.steps,
    required this.isRoadSnapped,
  });

  String get formattedDistance {
    if (distanceMeters < 1000) {
      return '${distanceMeters.round()} m';
    }
    return '${(distanceMeters / 1000).toStringAsFixed(1)} km';
  }

  String get formattedEta {
    final mins = (durationSeconds / 60).ceil().clamp(1, 999);
    return '$mins min';
  }
}

abstract class RouteNavigationService {
  Future<NavigationRouteResult> fetchRoute({
    required LatLng origin,
    required LatLng destination,
    String destinationName = 'Destination',
  });
}

class RouteNavigationServiceImpl implements RouteNavigationService {
  final Dio dio;

  RouteNavigationServiceImpl({required this.dio});

  @override
  Future<NavigationRouteResult> fetchRoute({
    required LatLng origin,
    required LatLng destination,
    String destinationName = 'Destination',
  }) async {
    try {
      final url =
          'https://router.project-osrm.org/route/v1/driving/'
          '${origin.longitude},${origin.latitude};'
          '${destination.longitude},${destination.latitude}'
          '?overview=full&geometries=geojson&steps=true';

      final response = await dio.get<Map<String, dynamic>>(
        url,
        options: Options(
          sendTimeout: const Duration(seconds: 6),
          receiveTimeout: const Duration(seconds: 8),
        ),
      );

      final data = response.data;
      final routes = data?['routes'] as List?;
      if (routes != null && routes.isNotEmpty) {
        final route = routes.first as Map<String, dynamic>;
        final geometry = route['geometry'] as Map<String, dynamic>?;
        final rawCoords = (geometry?['coordinates'] as List?) ?? const [];

        final points = rawCoords
            .whereType<List>()
            .where((c) => c.length >= 2)
            .map(
              (c) => LatLng(
                (c[1] as num).toDouble(),
                (c[0] as num).toDouble(),
              ),
            )
            .toList();

        final distance = (route['distance'] as num?)?.toDouble() ??
            _haversineMeters(origin, destination);
        final duration = (route['duration'] as num?)?.toDouble() ??
            (distance / 8.5);

        final parsedSteps = <NavigationStep>[];
        final legs = (route['legs'] as List?) ?? const [];
        for (final leg in legs) {
          final rawSteps =
              ((leg as Map<String, dynamic>)['steps'] as List?) ?? const [];
          for (final raw in rawSteps) {
            final stepMap = raw as Map<String, dynamic>;
            final maneuver =
                (stepMap['maneuver'] as Map<String, dynamic>?) ?? const {};
            final mType = maneuver['type']?.toString() ?? 'continue';
            final modifier = maneuver['modifier']?.toString();
            final locList = (maneuver['location'] as List?) ?? const [];
            final stepLatLng = locList.length >= 2
                ? LatLng(
                    (locList[1] as num).toDouble(),
                    (locList[0] as num).toDouble(),
                  )
                : destination;
            final road = (stepMap['name']?.toString() ?? '').trim();
            final stepDist = (stepMap['distance'] as num?)?.toDouble() ?? 0;

            parsedSteps.add(
              NavigationStep(
                instruction: _formatInstruction(
                  mType,
                  modifier,
                  road,
                  destinationName,
                ),
                roadName: road.isEmpty ? 'Local Road' : road,
                maneuverType: mType,
                modifier: modifier,
                distanceMeters: stepDist,
                location: stepLatLng,
              ),
            );
          }
        }

        if (points.length >= 2) {
          return NavigationRouteResult(
            polylinePoints: points,
            distanceMeters: distance,
            durationSeconds: duration,
            steps: parsedSteps.isNotEmpty
                ? parsedSteps
                : _fallbackSteps(origin, destination, destinationName, distance),
            isRoadSnapped: true,
          );
        }
      }
    } catch (e) {
      AppLogger.warning(
        'OSRM road routing unavailable, using direct in-app fallback route: $e',
        tag: 'RouteNavigationService',
      );
    }

    // Graceful offline / direct route fallback so in-app navigation ALWAYS works
    final directMeters = _haversineMeters(origin, destination);
    final approxSeconds = (directMeters / 7.5).clamp(60.0, 7200.0);
    return NavigationRouteResult(
      polylinePoints: [origin, destination],
      distanceMeters: directMeters,
      durationSeconds: approxSeconds,
      steps: _fallbackSteps(origin, destination, destinationName, directMeters),
      isRoadSnapped: false,
    );
  }

  List<NavigationStep> _fallbackSteps(
    LatLng origin,
    LatLng destination,
    String destinationName,
    double distanceMeters,
  ) {
    return [
      NavigationStep(
        instruction: 'Head toward $destinationName',
        roadName: 'Direct Route',
        maneuverType: 'depart',
        distanceMeters: distanceMeters,
        location: origin,
      ),
      NavigationStep(
        instruction: 'Arrive at $destinationName',
        roadName: destinationName,
        maneuverType: 'arrive',
        distanceMeters: 0,
        location: destination,
      ),
    ];
  }

  String _formatInstruction(
    String type,
    String? modifier,
    String road,
    String destinationName,
  ) {
    final onto = road.isNotEmpty ? ' onto $road' : '';
    final mod = (modifier ?? '').replaceAll('_', ' ').trim();

    switch (type) {
      case 'depart':
        return road.isNotEmpty
            ? 'Start on $road'
            : 'Head toward $destinationName';
      case 'arrive':
        return 'Arrive at $destinationName';
      case 'turn':
        return 'Turn ${mod.isEmpty ? 'ahead' : mod}$onto';
      case 'roundabout':
      case 'rotary':
        return 'Take roundabout$onto';
      case 'merge':
        return 'Merge ${mod.isEmpty ? '' : '$mod '}$onto'.trim();
      case 'fork':
        return 'Keep ${mod.isEmpty ? 'straight' : mod}$onto';
      case 'end of road':
        return 'At end of road, turn ${mod.isEmpty ? 'ahead' : mod}$onto';
      default:
        return road.isNotEmpty ? 'Continue on $road' : 'Continue straight';
    }
  }

  double _haversineMeters(LatLng a, LatLng b) {
    const r = 6371000.0;
    final dLat = (b.latitude - a.latitude) * (pi / 180.0);
    final dLng = (b.longitude - a.longitude) * (pi / 180.0);
    final s1 = sin(dLat / 2);
    final s2 = sin(dLng / 2);
    final h = s1 * s1 +
        cos(a.latitude * pi / 180.0) *
            cos(b.latitude * pi / 180.0) *
            s2 *
            s2;
    return 2 * r * atan2(sqrt(h), sqrt(1 - h));
  }
}
