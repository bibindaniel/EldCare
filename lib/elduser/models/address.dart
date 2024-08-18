import 'package:cloud_firestore/cloud_firestore.dart';

class Address {
  final String id;
  final String houseName;
  final String street;
  final String city;
  final String state;
  final String postalCode;
  final GeoPoint? location;

  Address({
    required this.id,
    required this.houseName,
    required this.street,
    required this.city,
    required this.state,
    required this.postalCode,
    this.location,
  });

  factory Address.fromMap(Map<String, dynamic> map, {String? id}) {
    return Address(
      id: id ?? map['id'] ?? '',
      houseName: map['houseName'] ?? '',
      street: map['street'] ?? '',
      city: map['city'] ?? '',
      state: map['state'] ?? '',
      postalCode: map['postalCode'] ?? '',
      location: map['location'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'houseName': houseName,
      'street': street,
      'city': city,
      'state': state,
      'postalCode': postalCode,
      'location': location,
    };
  }
}
