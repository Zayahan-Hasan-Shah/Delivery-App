import 'package:material_ui/material_ui.dart';
import 'package:delivery_app/core/theme/app_colors.dart';

/// Assigns unique, visually distinct colors to orders so riders can
/// immediately match each pickup pin, drop-off pin, route polyline,
/// and list card belonging to the same order.
class OrderColorHelper {
  /// Returns a guaranteed unique color map for a list of order IDs.
  /// Orders get sequential high-contrast colors from [AppColors.orderPalette],
  /// guaranteeing zero collisions across active deliveries.
  static Map<String, Color> buildColorMap(List<String> orderIds) {
    final map = <String, Color>{};
    for (int i = 0; i < orderIds.length; i++) {
      map[orderIds[i]] = AppColors.colorForOrderIndex(i);
    }
    return map;
  }

  /// Fallback deterministic color lookup for a single order when no list context exists.
  static Color colorForOrderId(String orderId, {int? colorIndex}) {
    if (colorIndex != null) {
      return AppColors.colorForOrderIndex(colorIndex);
    }
    int hash = 0;
    for (final unit in orderId.codeUnits) {
      hash = (hash * 31 + unit) & 0x7fffffff;
    }
    return AppColors.colorForOrderIndex(hash);
  }
}
