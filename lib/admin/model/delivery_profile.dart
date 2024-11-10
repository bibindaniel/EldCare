class DeliveryProfile {
  final String id;
  final String? name;
  final String? email;
  final String? phone;
  final String? vehicleType;
  final String? vehicleNumber;
  final String? licenseNumber;
  final String? profileImageUrl;
  final bool isVerified;
  final bool isProfileComplete;

  DeliveryProfile({
    required this.id,
    this.name,
    this.email,
    this.phone,
    this.vehicleType,
    this.vehicleNumber,
    this.licenseNumber,
    this.profileImageUrl,
    this.isVerified = false,
    this.isProfileComplete = false,
  });

  factory DeliveryProfile.fromMap(Map<String, dynamic> map) {
    return DeliveryProfile(
      id: map['id'] ?? '',
      name: map['name'],
      email: map['email'],
      phone: map['phone'],
      vehicleType: map['vehicleType'],
      vehicleNumber: map['vehicleNumber'],
      licenseNumber: map['licenseNumber'],
      profileImageUrl: map['profileImageUrl'],
      isVerified: map['isVerified'] ?? false,
      isProfileComplete: map['isProfileComplete'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'vehicleType': vehicleType,
      'vehicleNumber': vehicleNumber,
      'licenseNumber': licenseNumber,
      'profileImageUrl': profileImageUrl,
      'isVerified': isVerified,
      'isProfileComplete': isProfileComplete,
    };
  }
}
