import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/foundation.dart';

class NavigationProvider {
  static Future<bool> openNavigation({
    required double lat,
    required double lng,
    String? label,
  }) async {
    final String encodedLabel = label != null ? Uri.encodeComponent(label) : '$lat,$lng';
    
    final Uri geoUri = Uri.parse('geo:$lat,$lng?q=$lat,$lng($encodedLabel)');
    final Uri googleMapsUri = Uri.parse('google.navigation:q=$lat,$lng');
    final Uri appleMapsUri = Uri.parse('https://maps.apple.com/?daddr=$lat,$lng&q=$encodedLabel');
    final Uri webMapsUri = Uri.parse('https://www.google.com/maps/search/?api=1&query=$lat,$lng');

    try {
      if (defaultTargetPlatform == TargetPlatform.android) {
        if (await canLaunchUrl(googleMapsUri)) {
          return await launchUrl(googleMapsUri, mode: LaunchMode.externalApplication);
        }
        if (await canLaunchUrl(geoUri)) {
          return await launchUrl(geoUri, mode: LaunchMode.externalApplication);
        }
      } else if (defaultTargetPlatform == TargetPlatform.iOS) {
        if (await canLaunchUrl(appleMapsUri)) {
          return await launchUrl(appleMapsUri, mode: LaunchMode.externalApplication);
        }
      }
      
      if (await canLaunchUrl(webMapsUri)) {
        return await launchUrl(webMapsUri, mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      debugPrint('Navigation exception: $e');
    }
    return false;
  }
}
