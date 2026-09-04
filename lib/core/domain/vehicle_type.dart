class VehicleDomainConfig {
  final String vehicleTypeId;
  final String name;
  final double payloadKg;
  final double volumeM3;
  final double maxHeightM;
  final double maxWidthM;
  final double maxLengthM;
  final List<String> allowedZones;
  final double baseFare;
  final double perKmRate;
  final double codLimit;

  const VehicleDomainConfig({
    required this.vehicleTypeId,
    required this.name,
    required this.payloadKg,
    required this.volumeM3,
    required this.maxHeightM,
    required this.maxWidthM,
    required this.maxLengthM,
    required this.allowedZones,
    required this.baseFare,
    required this.perKmRate,
    required this.codLimit,
  });

  Map<String, dynamic> toJson() => {
    'vehicleTypeId': vehicleTypeId,
    'name': name,
    'payloadKg': payloadKg,
    'volumeM3': volumeM3,
    'maxHeightM': maxHeightM,
    'maxWidthM': maxWidthM,
    'maxLengthM': maxLengthM,
    'allowedZones': allowedZones,
    'baseFare': baseFare,
    'perKmRate': perKmRate,
    'codLimit': codLimit,
  };
}
