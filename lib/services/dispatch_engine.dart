import 'dart:math';
import '../models/driver.dart';
import '../models/order.dart';

class DispatchEngine {
  static DriverModel? selectBestDriver(OrderModel order, List<DriverModel> availableDrivers) {
    List<DriverModel> eligible = availableDrivers.where((d) {
      if (!d.isOnline) return false;
      if (!d.isGpsFresh) return false;
      if (d.vehicleType != order.vehicleType) return false;
      return true;
    }).toList();

    if (eligible.isEmpty) return null;

    DriverModel? bestDriver;
    double bestScore = -1.0;

    for (var driver in eligible) {
      double distance = _calculateDistance(order.pickupLat, order.pickupLng, driver.lat, driver.lng);
      double etaMinutes = distance * 3.0;

      double score = (driver.rating * 10) + (driver.acceptRate * 20) - (etaMinutes * 2) - (driver.cancelRate * 10);

      if (score > bestScore) {
        bestScore = score;
        bestDriver = driver;
      }
    }

    return bestDriver;
  }

  static double _calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    const p = 0.017453292519943295;
    final c = cos;
    final a = 0.5 - c((lat2 - lat1) * p)/2 + 
              c(lat1 * p) * c(lat2 * p) * 
              (1 - c((lon2 - lon1) * p))/2;
    return 12742 * asin(sqrt(a));
  }
}
