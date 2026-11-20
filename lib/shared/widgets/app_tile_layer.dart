import 'package:material_ui/material_ui.dart';
import 'package:flutter_map/flutter_map.dart';

/// Centralized, 100% free tile layer for all FlutterMap instances in the app.
///
/// Uses official OpenStreetMap (OSM) standard tiles with OSM Germany fallback.
/// Completely open-source and free: NO API KEY REQUIRED, NO WATERMARKS.
/// Features a resilient [errorTileCallback] to gracefully absorb transient
/// network/emulator socket blinks without polluting console or crashing.
class AppTileLayer extends StatelessWidget {
  final double maxZoom;

  const AppTileLayer({
    super.key,
    this.maxZoom = 19.0,
  });

  @override
  Widget build(BuildContext context) {
    return TileLayer(
      urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
      fallbackUrl: 'https://tile.openstreetmap.de/{z}/{x}/{y}.png',
      userAgentPackageName: 'com.deliveryapp.app',
      maxZoom: maxZoom,
      errorTileCallback: (tile, error, stackTrace) {
        // Gracefully handles transient network or offline tile issues
        debugPrint(
          '[AppTileLayer] Transient tile network notice at ${tile.coordinates}: $error',
        );
      },
    );
  }
}
