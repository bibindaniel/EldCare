import 'package:equatable/equatable.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Shop extends Equatable {
  final String id;
  final String name;
  final String address;
  final String phoneNumber;
  final String email;
  final String ownerId;
  final String licenseNumber;
  final bool isVerified;
  final DateTime createdAt;
  final GeoPoint location;

  const Shop({
    required this.id,
    required this.name,
    required this.address,
    required this.location,
    required this.phoneNumber,
    required this.email,
    required this.ownerId,
    required this.licenseNumber,
    this.isVerified = false,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [
        id,
        name,
        address,
        location,
        phoneNumber,
        email,
        ownerId,
        licenseNumber,
        isVerified,
        createdAt
      ];

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'address': address,
      'location': location,
      'phoneNumber': phoneNumber,
      'email': email,
      'ownerId': ownerId,
      'licenseNumber': licenseNumber,
      'isVerified': isVerified,
      'createdAt': createdAt,
    };
  }

  factory Shop.fromMap(Map<String, dynamic> map) {
    return Shop(
      id: map['id'] as String,
      name: map['name'] as String,
      address: map['address'] as String,
      location: map['location'] as GeoPoint,
      phoneNumber: map['phoneNumber'] as String,
      email: map['email'] as String,
      ownerId: map['ownerId'] as String,
      licenseNumber: map['licenseNumber'] as String,
      isVerified: map['isVerified'] as bool,
      createdAt: (map['createdAt'] as Timestamp).toDate(),
    );
  }

  Shop copyWith({
    String? id,
    String? name,
    String? address,
    GeoPoint? location,
    String? phoneNumber,
    String? email,
    String? ownerId,
    String? licenseNumber,
    bool? isVerified,
    DateTime? createdAt,
  }) {
    return Shop(
      id: id ?? this.id,
      name: name ?? this.name,
      address: address ?? this.address,
      location: location ?? this.location,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      email: email ?? this.email,
      ownerId: ownerId ?? this.ownerId,
      licenseNumber: licenseNumber ?? this.licenseNumber,
      isVerified: isVerified ?? this.isVerified,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
