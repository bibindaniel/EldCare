import 'package:cloud_firestore/cloud_firestore.dart';

enum AppointmentStatus {
  pending,
  confirmed,
  scheduled,
  completed,
  cancelled,
  pendingPayment,
  inProgress,
}

class Appointment {
  final String id;
  final String userId;
  final String userName;
  final String? userPhotoUrl;
  final String doctorId;
  final String doctorName;
  final String? doctorPhotoUrl;
  final DateTime appointmentTime;
  final int durationMinutes;
  final String reason;
  final AppointmentStatus status;
  final DateTime createdAt;
  final String? notes;
  final String? paymentId;
  final bool isPaid;
  final double? consultationFee;

  // Convenience getters for different naming conventions
  String get patientId => userId;
  DateTime get startTime => appointmentTime;
  DateTime get appointmentDate => DateTime(
        appointmentTime.year,
        appointmentTime.month,
        appointmentTime.day,
      );
  DateTime get endTime =>
      appointmentTime.add(Duration(minutes: durationMinutes));

  Appointment({
    required this.id,
    required this.userId,
    required this.userName,
    this.userPhotoUrl,
    required this.doctorId,
    required this.doctorName,
    this.doctorPhotoUrl,
    required this.appointmentTime,
    required this.durationMinutes,
    required this.reason,
    required this.status,
    required this.createdAt,
    this.notes,
    this.paymentId,
    this.isPaid = false,
    this.consultationFee,
  });

  factory Appointment.fromMap(Map<String, dynamic> map, String id) {
    return Appointment(
      id: id,
      userId: map['userId'] ?? '',
      userName: map['userName'] ?? '',
      userPhotoUrl: map['userPhotoUrl'],
      doctorId: map['doctorId'] ?? '',
      doctorName: map['doctorName'] ?? '',
      doctorPhotoUrl: map['doctorPhotoUrl'],
      appointmentTime: (map['appointmentTime'] as Timestamp).toDate(),
      durationMinutes: map['durationMinutes'] ?? 30,
      reason: map['reason'] ?? '',
      status: AppointmentStatus.values.firstWhere(
        (e) =>
            e.toString() == 'AppointmentStatus.${map['status'] ?? 'pending'}',
        orElse: () => AppointmentStatus.pending,
      ),
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      notes: map['notes'],
      paymentId: map['paymentId'],
      isPaid: map['isPaid'] ?? false,
      consultationFee: map['consultationFee'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'userName': userName,
      'userPhotoUrl': userPhotoUrl,
      'doctorId': doctorId,
      'doctorName': doctorName,
      'doctorPhotoUrl': doctorPhotoUrl,
      'appointmentTime': Timestamp.fromDate(appointmentTime),
      'durationMinutes': durationMinutes,
      'reason': reason,
      'status': status.toString().split('.').last,
      'createdAt': Timestamp.fromDate(createdAt),
      'notes': notes,
      'paymentId': paymentId,
      'isPaid': isPaid,
      'consultationFee': consultationFee,
    };
  }

  Appointment copyWith({
    String? id,
    String? userId,
    String? userName,
    String? userPhotoUrl,
    String? doctorId,
    String? doctorName,
    String? doctorPhotoUrl,
    DateTime? appointmentTime,
    int? durationMinutes,
    String? reason,
    AppointmentStatus? status,
    DateTime? createdAt,
    String? notes,
    String? paymentId,
    bool? isPaid,
    double? consultationFee,
  }) {
    return Appointment(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      userPhotoUrl: userPhotoUrl ?? this.userPhotoUrl,
      doctorId: doctorId ?? this.doctorId,
      doctorName: doctorName ?? this.doctorName,
      doctorPhotoUrl: doctorPhotoUrl ?? this.doctorPhotoUrl,
      appointmentTime: appointmentTime ?? this.appointmentTime,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      reason: reason ?? this.reason,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      notes: notes ?? this.notes,
      paymentId: paymentId ?? this.paymentId,
      isPaid: isPaid ?? this.isPaid,
      consultationFee: consultationFee ?? this.consultationFee,
    );
  }
}
