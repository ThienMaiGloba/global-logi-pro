enum UserRole {
  customer,
  driverBike,
  driverCar,
  driverTruck,
  fleetManager,
  dispatcher,
  admin,
  superAdmin,
}

enum OrderStatus {
  draft,
  quoted,
  confirmed,
  searchingDriver,
  driverOffer,
  driverAccepted,
  driverArriving,
  arrivedPickup,
  loading,
  inTransit,
  arrivedStop,
  delivering,
  delivered,
  completed,
  cancelled,
}

class OrderStop {
  final String? id;
  final int sequence;
  final double latitude;
  final double longitude;
  final String address;
  final String type;

  const OrderStop({
    this.id,
    required this.sequence,
    required this.latitude,
    required this.longitude,
    required this.address,
    required this.type,
  });

  factory OrderStop.fromJson(Map<String, dynamic> json) {
    return OrderStop(
      id: json['id']?.toString(),
      sequence: (json['sequence'] as num?)?.toInt() ?? 0,
      latitude: (json['latitude'] as num?)?.toDouble() ?? 0,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 0,
      address: json['address']?.toString() ?? '',
      type: json['type']?.toString() ?? 'PICKUP',
    );
  }

  Map<String, dynamic> toJson() => {
        'sequence': sequence,
        'latitude': latitude,
        'longitude': longitude,
        'address': address,
        'type': type,
      };
}

class Order {
  final String id;
  final String customerId;
  final String? driverId;
  final OrderStatus status;
  final int price;
  final List<OrderStop> stops;

  const Order({
    required this.id,
    required this.customerId,
    this.driverId,
    required this.status,
    required this.price,
    required this.stops,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    final statusName = json['status']?.toString() ?? 'DRAFT';
    final status = OrderStatus.values.firstWhere(
      (s) => s.name.toUpperCase() == statusName,
      orElse: () => OrderStatus.draft,
    );

    final rawStops = json['stops'];
    final stops = rawStops is List
        ? rawStops
            .whereType<Map>()
            .map((e) => OrderStop.fromJson(Map<String, dynamic>.from(e)))
            .toList()
        : <OrderStop>[];

    return Order(
      id: json['id'].toString(),
      customerId: json['customerId'].toString(),
      driverId: json['driverId']?.toString(),
      status: status,
      price: (json['price'] as num?)?.toInt() ?? 0,
      stops: stops,
    );
  }
}
