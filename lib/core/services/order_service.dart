class OrderService {
  static final OrderService _instance = OrderService._internal();
  factory OrderService() => _instance;
  OrderService._internal();

  String pickupLocation = '123 Nguyễn Huệ, Q.1, TP.HCM';
  String deliveryLocation = '45 Lê Duẩn, Q.1, TP.HCM';
  String orderWeight = '120 kg';
  String orderStatus = 'PICKUP_NAVIGATING'; // PICKUP_NAVIGATING, DELIVERY_NAVIGATING, COMPLETED
  String trackingId = '#VOGX-8892';
  bool hasActiveOrder = true;

  void createNewOrder({required String pickup, required String delivery, required String weight}) {
    pickupLocation = pickup;
    deliveryLocation = delivery;
    orderWeight = weight;
    orderStatus = 'PICKUP_NAVIGATING';
    trackingId = '#VOGX-${DateTime.now().millisecond}';
    hasActiveOrder = true;
  }
}
