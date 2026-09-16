import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

class NavigationService {
  static Future<bool> navigateTo({
    required double latitude,
    required double longitude,
    String? label,
  }) async {
    final encodedLabel = Uri.encodeComponent(label ?? 'VOGX Destination');

    // Android Google Maps native navigation.
    // Android đã xác nhận google.navigation: được Google Maps xử lý.
    final googleNavigation = Uri.parse(
      'google.navigation:q=$latitude,$longitude',
    );

    try {
      final launched = await launchUrl(
        googleNavigation,
        mode: LaunchMode.externalApplication,
      );

      if (launched) {
        return true;
      }
    } on PlatformException {
      // Continue to HTTPS fallback.
    } catch (_) {
      // Continue to HTTPS fallback.
    }

    // Google Maps universal URL fallback.
    final googleMaps = Uri.parse(
      'https://www.google.com/maps/dir/?api=1'
      '&destination=$latitude,$longitude'
      '&destination_place_id=$encodedLabel',
    );

    try {
      final launched = await launchUrl(
        googleMaps,
        mode: LaunchMode.externalApplication,
      );

      if (launched) {
        return true;
      }
    } on PlatformException {
      // Continue to geo fallback.
    } catch (_) {
      // Continue to geo fallback.
    }

    // Generic Android geo fallback.
    final fallback = Uri.parse(
      'geo:$latitude,$longitude?q=$latitude,$longitude($encodedLabel)',
    );

    try {
      return await launchUrl(
        fallback,
        mode: LaunchMode.externalApplication,
      );
    } on PlatformException {
      return false;
    } catch (_) {
      return false;
    }
  }
}
