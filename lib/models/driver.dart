class DriverModel {
  final String id;
  final String name;
  final String vehicleType;
  final String plateNumber;
  bool isOnline;
  double lat;
  double lng;
  double rating;
  double acceptRate;
  double cancelRate;
  DateTime lastGpsUpdate;

  DriverModel({
    required this.id,
    required this.name,
    required this.vehicleType,
    required this.plateNumber,
    this.isOnline = false,
    this.lat = 10.7769,
    this.lng = 106.7009,
    this.rating = 4.9,
    this.acceptRate = 0.95,
    this.cancelRate = 0.02,
    DateTime? lastGpsUpdate,
  }) : lastGpsUpdate = lastGpsUpdate ?? DateTime.now();

  bool get isGpsFresh => DateTime.now().difference(lastGpsUpdate).inSeconds < 30;
}
