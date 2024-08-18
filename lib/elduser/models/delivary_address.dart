import 'address.dart';

class DeliveryAddress {
  final String id;
  final Address address;
  final String label;
  final bool isDefault;

  DeliveryAddress({
    required this.id,
    required this.address,
    required this.label,
    this.isDefault = false,
  });

  factory DeliveryAddress.fromMap(Map<String, dynamic> map, {String? id}) {
    return DeliveryAddress(
      id: id ?? map['id'] ?? '',
      address: Address.fromMap(map['address'] ?? {},
          id: map['address']?['id'] ?? ''),
      label: map['label'] ?? '',
      isDefault: map['isDefault'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'address': address.toMap(),
      'label': label,
      'isDefault': isDefault,
    };
  }
}
