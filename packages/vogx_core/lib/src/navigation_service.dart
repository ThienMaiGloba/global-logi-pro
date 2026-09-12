import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

class NavigationService {
  static Future<bool> navigateTo({
    required double latitude,
    required double longitude,
    String? label,
  }) async {
    final encodedLabel = Uri.encodeComponent(label ?? 'VOGX Destination');

    // Android Google Maps navigation intent.
    final googleNavigation = Uri.parse(
      'google.navigation:q=$latitude,$longitude',
    );

    try {
      if (await canLaunchUrl(googleNavigation)) {
        return await launchUrl(
          googleNavigation,
          mode: LaunchMode.externalApplication,
        );
      }
    } on PlatformException {
      // Continue to fallbacks.
    }

    // Google Maps universal URL.
    final googleMaps = Uri.parse(
      'https://www.google.com/maps/dir/?api=1'
      '&destination=$latitude,$longitude'
      '&destination_place_id=$encodedLabel',
    );

    if (await canLaunchUrl(googleMaps)) {
      return launchUrl(
        googleMaps,
        mode: LaunchMode.externalApplication,
      );
    }

    // Generic geo/browser fallback.
    final fallback = Uri.parse(
      'geo:$latitude,$longitude?q=$latitude,$longitude($encodedLabel)',
    );

    if (await canLaunchUrl(fallback)) {
      return launchUrl(
        fallback,
        mode: LaunchMode.externalApplication,
      );
    }

    return false;
  }
}
