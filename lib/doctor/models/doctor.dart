import 'package:cloud_firestore/cloud_firestore.dart';

class Doctor {
  final String userId;
  final String fullName;
  final String mobileNumber;
  final String address;
  final String registrationNumber;
  final String medicalCouncil;
  final String qualification;
  final String specialization;
  final int experience;
  final String hospitalName;
  final String hospitalAddress;
  final String workContact;
  final String workEmail;
  final Map<String, String> documents; // URLs of uploaded documents
  final bool isVerified;
  final DateTime registrationDate;
  final String? profileImageUrl;
  final int? consultationFee;
  final int? consultationDuration;
  final bool? emergencyAvailable;

  Doctor({
    required this.userId,
    required this.fullName,
    required this.mobileNumber,
    required this.address,
    required this.registrationNumber,
    required this.medicalCouncil,
    required this.qualification,
    required this.specialization,
    required this.experience,
    required this.hospitalName,
    required this.hospitalAddress,
    required this.workContact,
    required this.workEmail,
    required this.documents,
    this.isVerified = false,
    DateTime? registrationDate,
    this.profileImageUrl,
    this.consultationFee,
    this.consultationDuration,
    this.emergencyAvailable,
  }) : registrationDate = registrationDate ?? DateTime.now();

  Doctor copyWith({
    String? userId,
    String? fullName,
    String? mobileNumber,
    String? address,
    String? registrationNumber,
    String? medicalCouncil,
    String? qualification,
    String? specialization,
    int? experience,
    String? hospitalName,
    String? hospitalAddress,
    String? workContact,
    String? workEmail,
    Map<String, String>? documents,
    bool? isVerified,
    DateTime? registrationDate,
    String? profileImageUrl,
    int? consultationFee,
    int? consultationDuration,
    bool? emergencyAvailable,
  }) {
    return Doctor(
      userId: userId ?? this.userId,
      fullName: fullName ?? this.fullName,
      mobileNumber: mobileNumber ?? this.mobileNumber,
      address: address ?? this.address,
      registrationNumber: registrationNumber ?? this.registrationNumber,
      medicalCouncil: medicalCouncil ?? this.medicalCouncil,
      qualification: qualification ?? this.qualification,
      specialization: specialization ?? this.specialization,
      experience: experience ?? this.experience,
      hospitalName: hospitalName ?? this.hospitalName,
      hospitalAddress: hospitalAddress ?? this.hospitalAddress,
      workContact: workContact ?? this.workContact,
      workEmail: workEmail ?? this.workEmail,
      documents: documents ?? this.documents,
      isVerified: isVerified ?? this.isVerified,
      registrationDate: registrationDate ?? this.registrationDate,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      consultationFee: consultationFee ?? this.consultationFee,
      consultationDuration: consultationDuration ?? this.consultationDuration,
      emergencyAvailable: emergencyAvailable ?? this.emergencyAvailable,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'fullName': fullName,
      'mobileNumber': mobileNumber,
      'address': address,
      'registrationNumber': registrationNumber,
      'medicalCouncil': medicalCouncil,
      'qualification': qualification,
      'specialization': specialization,
      'experience': experience,
      'hospitalName': hospitalName,
      'hospitalAddress': hospitalAddress,
      'workContact': workContact,
      'workEmail': workEmail,
      'documents': documents,
      'isVerified': isVerified,
      'registrationDate': Timestamp.fromDate(registrationDate),
      'profileImageUrl': profileImageUrl,
      'consultationFee': consultationFee,
      'consultationDuration': consultationDuration,
      'emergencyAvailable': emergencyAvailable,
    };
  }

  factory Doctor.fromMap(Map<String, dynamic> map) {
    return Doctor(
      userId: map['userId'] ?? '',
      fullName: map['fullName'] ?? '',
      mobileNumber: map['mobileNumber'] ?? '',
      address: map['address'] ?? '',
      registrationNumber: map['registrationNumber'] ?? '',
      medicalCouncil: map['medicalCouncil'] ?? '',
      qualification: map['qualification'] ?? '',
      specialization: map['specialization'] ?? '',
      experience: map['experience'] ?? 0,
      hospitalName: map['hospitalName'] ?? '',
      hospitalAddress: map['hospitalAddress'] ?? '',
      workContact: map['workContact'] ?? '',
      workEmail: map['workEmail'] ?? '',
      documents: Map<String, String>.from(map['documents'] ?? {}),
      isVerified: map['isVerified'] ?? false,
      registrationDate: (map['registrationDate'] as Timestamp).toDate(),
      profileImageUrl: map['profileImageUrl'],
      consultationFee: map['consultationFee'],
      consultationDuration: map['consultationDuration'],
      emergencyAvailable: map['emergencyAvailable'],
    );
  }
}
