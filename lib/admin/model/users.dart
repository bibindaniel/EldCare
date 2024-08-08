class DynamicUserProfile {
  final String id;
  final String? name;
  final String? email;
  final String? age;
  final String? phone;
  final String? houseName;
  final String? street;
  final String? city;
  final String? state;
  final String? postalCode;
  final String? bloodType; // Specific to UserProfile
  final String? licenseNumber; // Specific to PharmacistProfile
  final String? profileImageUrl;
  final bool isVerified;
  final bool isProfileComplete;

  DynamicUserProfile({
    required this.id,
    this.name,
    this.email,
    this.age,
    this.phone,
    this.houseName,
    this.street,
    this.city,
    this.state,
    this.postalCode,
    this.bloodType,
    this.licenseNumber,
    this.profileImageUrl,
    this.isVerified = false,
    this.isProfileComplete = false,
  });

  factory DynamicUserProfile.fromMap(Map<String, dynamic> map) {
    return DynamicUserProfile(
      id: map['id'] ?? '',
      name: map['name'],
      email: map['email'],
      age: map['age']?.toString(),
      phone: map['phone'],
      houseName: map['houseName'],
      street: map['street'],
      city: map['city'],
      state: map['state'],
      postalCode: map['postalCode'],
      bloodType: map['bloodType'],
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
      'age': age,
      'phone': phone,
      'houseName': houseName,
      'street': street,
      'city': city,
      'state': state,
      'postalCode': postalCode,
      'bloodType': bloodType,
      'licenseNumber': licenseNumber,
      'profileImageUrl': profileImageUrl,
      'isVerified': isVerified,
      'isProfileComplete': isProfileComplete,
    };
  }
}
