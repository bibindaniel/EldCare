class PharmacistProfile {
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
  final String? licenseNumber;
  final String? profileImageUrl;
  final bool isVerified;
  final bool isProfileComplete;

  PharmacistProfile({
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
    this.licenseNumber,
    this.profileImageUrl,
    this.isVerified = false,
    this.isProfileComplete = false,
  });

  PharmacistProfile copyWith({
    String? id,
    String? name,
    String? email,
    String? age,
    String? phone,
    String? houseName,
    String? street,
    String? city,
    String? state,
    String? postalCode,
    String? licenseNumber,
    String? profileImageUrl,
    bool? isVerified,
    bool? isProfileComplete,
  }) {
    return PharmacistProfile(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      age: age ?? this.age,
      phone: phone ?? this.phone,
      houseName: houseName ?? this.houseName,
      street: street ?? this.street,
      city: city ?? this.city,
      state: state ?? this.state,
      postalCode: postalCode ?? this.postalCode,
      licenseNumber: licenseNumber ?? this.licenseNumber,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      isVerified: isVerified ?? this.isVerified,
      isProfileComplete: isProfileComplete ?? this.isProfileComplete,
    );
  }

  factory PharmacistProfile.fromMap(Map<String, dynamic> map) {
    return PharmacistProfile(
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
      'licenseNumber': licenseNumber,
      'profileImageUrl': profileImageUrl,
      'isVerified': isVerified,
      'isProfileComplete': isProfileComplete,
    };
  }
}
