class DeliveryChargesModel {
  final double baseCharge;
  final double perKmCharge;
  final double minimumOrderValue;

  DeliveryChargesModel({
    required this.baseCharge,
    required this.perKmCharge,
    required this.minimumOrderValue,
  });

  factory DeliveryChargesModel.fromJson(Map<String, dynamic> json) {
    return DeliveryChargesModel(
      baseCharge: json['baseCharge'].toDouble(),
      perKmCharge: json['perKmCharge'].toDouble(),
      minimumOrderValue: json['minimumOrderValue'].toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'baseCharge': baseCharge,
      'perKmCharge': perKmCharge,
      'minimumOrderValue': minimumOrderValue,
    };
  }
}
