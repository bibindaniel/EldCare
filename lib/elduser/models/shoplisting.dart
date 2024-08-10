import 'package:eldcare/pharmacy/model/shop.dart';
import 'package:equatable/equatable.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class VerifiedShopListing extends Equatable {
  final String id;
  final String name;
  final String address;
  final String phoneNumber;
  final String email;
  final GeoPoint location;
  final DateTime createdAt;

  const VerifiedShopListing({
    required this.id,
    required this.name,
    required this.address,
    required this.location,
    required this.phoneNumber,
    required this.email,
    required this.createdAt,
  });

  @override
  List<Object?> get props =>
      [id, name, address, location, phoneNumber, email, createdAt];

  factory VerifiedShopListing.fromShop(Shop shop) {
    return VerifiedShopListing(
      id: shop.id,
      name: shop.name,
      address: shop.address,
      location: shop.location,
      phoneNumber: shop.phoneNumber,
      email: shop.email,
      createdAt: shop.createdAt,
    );
  }
}
