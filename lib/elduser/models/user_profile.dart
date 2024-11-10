class UserProfile {
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
  final String? bloodType;
  final String? profileImageUrl;
  final bool isVerified;
  final bool isProfileComplete;
  final bool isBlocked;

  UserProfile({
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
    this.profileImageUrl,
    this.isVerified = false,
    this.isProfileComplete = false,
    this.isBlocked = false,
  });

  factory UserProfile.fromMap(Map<String, dynamic> map, String documentId) {
    return UserProfile(
      id: documentId,
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
      profileImageUrl: map['profileImageUrl'],
      isVerified: map['isVerified'] ?? false,
      isProfileComplete: map['isProfileComplete'] ?? false,
      isBlocked: map['isBlocked'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
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
      'profileImageUrl': profileImageUrl,
      'isVerified': isVerified,
      'isProfileComplete': isProfileComplete,
      'isBlocked': isBlocked,
    };
  }

  UserProfile copyWith({
    String? name,
    String? email,
    String? age,
    String? phone,
    String? houseName,
    String? street,
    String? city,
    String? state,
    String? postalCode,
    String? bloodType,
    String? profileImageUrl,
    bool? isVerified,
    bool? isProfileComplete,
    bool? isBlocked,
  }) {
    return UserProfile(
      id: this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      age: age ?? this.age,
      phone: phone ?? this.phone,
      houseName: houseName ?? this.houseName,
      street: street ?? this.street,
      city: city ?? this.city,
      state: state ?? this.state,
      postalCode: postalCode ?? this.postalCode,
      bloodType: bloodType ?? this.bloodType,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      isVerified: isVerified ?? this.isVerified,
      isProfileComplete: isProfileComplete ?? this.isProfileComplete,
      isBlocked: isBlocked ?? this.isBlocked,
    );
  }
}
