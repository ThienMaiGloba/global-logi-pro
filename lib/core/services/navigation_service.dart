import 'package:url_launcher/url_launcher.dart';

class NavigationService {
  static Future<void> openMap({required double latitude, required double longitude, String? address}) async {
    final uri = Uri.parse('https://www.google.com/maps/search/?api=1&query=$latitude,$longitude');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      throw 'Không thể mở ứng dụng bản đồ.';
    }
  }
}
