enum OrderState {
  created,
  searching,
  offered,
  accepted,
  driverArriving,
  arrived,
  pickedUp,
  inTransit,
  delivered,
  completed,
  cancelled,
  expired,
  failed
}

class OrderModel {
  final String id;
  final String customerName;
  final String pickupAddress;
  final String dropoffAddress;
  final double pickupLat;
  final double pickupLng;
  final double dropoffLat;
  final double dropoffLng;
  final double price;
  final String vehicleType;
  OrderState state;
  String? assignedDriverId;
  final DateTime createdAt;

  OrderModel({
    required this.id,
    required this.customerName,
    required this.pickupAddress,
    required this.dropoffAddress,
    required this.pickupLat,
    required this.pickupLng,
    required this.dropoffLat,
    required this.dropoffLng,
    required this.price,
    required this.vehicleType,
    this.state = OrderState.created,
    this.assignedDriverId,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  bool canTransitionTo(OrderState nextState) {
    switch (state) {
      case OrderState.created:
        return nextState == OrderState.searching || nextState == OrderState.cancelled;
      case OrderState.searching:
        return nextState == OrderState.offered || nextState == OrderState.expired || nextState == OrderState.cancelled;
      case OrderState.offered:
        return nextState == OrderState.accepted || nextState == OrderState.searching || nextState == OrderState.cancelled;
      case OrderState.accepted:
        return nextState == OrderState.driverArriving || nextState == OrderState.cancelled;
      case OrderState.driverArriving:
        return nextState == OrderState.arrived || nextState == OrderState.cancelled;
      case OrderState.arrived:
        return nextState == OrderState.pickedUp || nextState == OrderState.cancelled;
      case OrderState.pickedUp:
        return nextState == OrderState.inTransit;
      case OrderState.inTransit:
        return nextState == OrderState.delivered;
      case OrderState.delivered:
        return nextState == OrderState.completed;
      default:
        return false;
    }
  }
}
