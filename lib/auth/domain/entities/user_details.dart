import 'package:equatable/equatable.dart';

class PharmacyShop extends Equatable {
  final String name;
  final String address;
  final String licenseNumber;
  final String? phoneNumber;

  const PharmacyShop({
    required this.name,
    required this.address,
    required this.licenseNumber,
    this.phoneNumber,
  });

  @override
  List<Object?> get props => [name, address, licenseNumber, phoneNumber];
}

enum UserRole { elderly, caretaker, doctor, pharmacist, deliveryPersonnel }

extension UserRoleExtension on UserRole {
  String get name => toString().split('.').last;
}

class UserDetails extends Equatable {
  final String? role;
  final String? age;
  final String? phone;
  final String? houseName;
  final String? street;
  final String? city;
  final String? state;
  final String? postalCode;
  final String? bloodType;
  // Add any other fields that might be specific to certain roles
  final String? specialization; // For doctors
  final String? licenseNumber;
  final List<PharmacyShop>? pharmacyShops;

  const UserDetails({
    required this.role,
    this.age,
    this.phone,
    this.houseName,
    this.street,
    this.city,
    this.state,
    this.postalCode,
    this.bloodType,
    this.specialization,
    this.licenseNumber,
    this.pharmacyShops,
  });

  @override
  List<Object?> get props => [
        role,
        age,
        phone,
        houseName,
        street,
        city,
        state,
        postalCode,
        bloodType,
        specialization,
        licenseNumber,
        pharmacyShops
      ];
}
