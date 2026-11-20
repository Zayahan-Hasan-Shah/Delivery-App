import 'package:flutter/foundation.dart';
import 'package:material_ui/material_ui.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:delivery_app/core/theme/app_colors.dart';
import 'package:delivery_app/core/utils/app_logger.dart';

class ExternalLauncher {
  /// Opens the native phone dialer with [phoneNumber].
  static Future<bool> openPhoneDialer(
    BuildContext context,
    String phoneNumber,
  ) async {
    final cleaned = phoneNumber.replaceAll(RegExp(r'[^0-9+]'), '');
    if (cleaned.isEmpty) {
      _showFeedback(context, 'No valid phone number available.');
      return false;
    }

    final uri = Uri(scheme: 'tel', path: cleaned);
    try {
      final launched = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );
      if (!launched && context.mounted) {
        _showFeedback(
          context,
          'Could not open Phone dialer for $cleaned on this device.',
        );
      }
      return launched;
    } catch (e, st) {
      AppLogger.error(
        'Failed to open phone dialer for $cleaned',
        error: e,
        stackTrace: st,
        tag: 'ExternalLauncher',
      );
      if (context.mounted) {
        _showFeedback(
          context,
          'Unable to open Phone dialer ($cleaned).',
        );
      }
      return false;
    }
  }

  /// Opens turn-by-turn navigation / directions to ([latitude], [longitude])
  /// using native Google Maps / Apple Maps / geo intent with web fallback.
  static Future<bool> openMapsNavigation(
    BuildContext context, {
    required double latitude,
    required double longitude,
    String? label,
  }) async {
    final encodedLabel = Uri.encodeComponent(label ?? 'Destination');
    final candidates = <Uri>[
      if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) ...[
        Uri.parse('google.navigation:q=$latitude,$longitude&mode=d'),
        Uri.parse('geo:$latitude,$longitude?q=$latitude,$longitude($encodedLabel)'),
      ],
      if (!kIsWeb && defaultTargetPlatform == TargetPlatform.iOS)
        Uri.parse('https://maps.apple.com/?daddr=$latitude,$longitude&dirflg=d'),
      Uri.parse(
        'https://www.google.com/maps/dir/?api=1&destination=$latitude,$longitude&travelmode=driving',
      ),
      Uri.parse(
        'https://www.openstreetmap.org/directions?to=$latitude,$longitude',
      ),
    ];

    for (final uri in candidates) {
      try {
        final launched = await launchUrl(
          uri,
          mode: LaunchMode.externalApplication,
        );
        if (launched) return true;
      } catch (e) {
        AppLogger.warning(
          'Navigation URI fallback failed ($uri): $e',
          tag: 'ExternalLauncher',
        );
      }
    }

    if (context.mounted) {
      _showFeedback(
        context,
        'No Maps app or browser available to open directions.',
      );
    }
    return false;
  }

  static void _showFeedback(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.warning,
      ),
    );
  }
}
