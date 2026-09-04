abstract class RoutingProvider {
  Future<RouteResult> getRoute({
    required double startLat,
    required double startLng,
    required double endLat,
    required double endLng,
    List<Waypoint> waypoints = const [],
  });
}

class Waypoint {
  final double lat;
  final double lng;
  Waypoint({required this.lat, required this.lng});
}

class RouteResult {
  final double distanceMeters;
  final int durationSeconds;
  final List<List<double>> polylinePoints;
  RouteResult({
    required this.distanceMeters,
    required this.durationSeconds,
    required this.polylinePoints,
  });
}

class OSRMRoutingProvider implements RoutingProvider {
  @override
  Future<RouteResult> getRoute({
    required double startLat,
    required double startLng,
    required double endLat,
    required double endLng,
    List<Waypoint> waypoints = const [],
  }) async {
    return RouteResult(
      distanceMeters: 5200.0,
      durationSeconds: 780,
      polylinePoints: [[startLat, startLng], [endLat, endLng]],
    );
  }
}
