import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eldcare/shared/models/appointment.dart';

class AppointmentRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Collection reference
  CollectionReference get _appointments =>
      _firestore.collection('appointments');

  // Create a new appointment
  Future<String> createAppointment(Appointment appointment) async {
    try {
      final docRef = await _appointments.add(appointment.toMap());
      return docRef.id;
    } catch (e) {
      throw Exception('Failed to create appointment: $e');
    }
  }

  // Get appointments for a specific user
  Stream<List<Appointment>> getUserAppointments(String userId) {
    return _appointments
        .where('userId', isEqualTo: userId)
        .orderBy('appointmentTime', descending: false)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => Appointment.fromMap(
                doc.data() as Map<String, dynamic>,
                doc.id,
              ))
          .toList();
    });
  }

  // Get appointments for a specific doctor
  Stream<List<Appointment>> getDoctorAppointments(String doctorId) {
    return _appointments
        .where('doctorId', isEqualTo: doctorId)
        .orderBy('appointmentTime', descending: false)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => Appointment.fromMap(
                doc.data() as Map<String, dynamic>,
                doc.id,
              ))
          .toList();
    });
  }

  // Get a specific appointment
  Future<Appointment> getAppointment(String appointmentId) async {
    try {
      final docSnapshot = await _appointments.doc(appointmentId).get();
      if (!docSnapshot.exists) {
        throw Exception('Appointment not found');
      }
      return Appointment.fromMap(
        docSnapshot.data() as Map<String, dynamic>,
        docSnapshot.id,
      );
    } catch (e) {
      throw Exception('Failed to get appointment: $e');
    }
  }

  // Update appointment status
  Future<void> updateAppointmentStatus(
      String appointmentId, AppointmentStatus status) async {
    try {
      await _appointments.doc(appointmentId).update({
        'status': status.toString().split('.').last,
      });
    } catch (e) {
      throw Exception('Failed to update appointment status: $e');
    }
  }

  // Update appointment notes
  Future<void> updateAppointmentNotes(
      String appointmentId, String notes) async {
    try {
      await _appointments.doc(appointmentId).update({
        'notes': notes,
      });
    } catch (e) {
      throw Exception('Failed to update appointment notes: $e');
    }
  }

  // Cancel appointment
  Future<void> cancelAppointment(String appointmentId) async {
    try {
      await _appointments.doc(appointmentId).update({
        'status': AppointmentStatus.cancelled.toString().split('.').last,
      });
    } catch (e) {
      throw Exception('Failed to cancel appointment: $e');
    }
  }

  // Get available slots for a doctor on a specific day
  Future<List<DateTime>> getAvailableSlots(
      String doctorId, DateTime date) async {
    try {
      // Get doctor's schedule for the day of the week
      final dayOfWeek = date.weekday; // 1 for Monday, 7 for Sunday

      final scheduleDoc = await _firestore
          .collection('doctor_schedules')
          .where('doctorId', isEqualTo: doctorId)
          .get();

      if (scheduleDoc.docs.isEmpty) {
        return [];
      }

      final scheduleData = scheduleDoc.docs.first.data();
      final daySchedule = scheduleData['days']?[dayOfWeek.toString()];

      if (daySchedule == null || daySchedule['isWorkingDay'] == false) {
        return []; // Doctor doesn't work on this day
      }

      // Get the doctor's sessions for this day
      final sessions = daySchedule['sessions'] as List<dynamic>;

      // Convert sessions to available time slots (e.g., 30 min intervals)
      List<DateTime> availableSlots = [];

      for (var session in sessions) {
        final startTimeMap = session['startTime'] as Map<String, dynamic>;
        final endTimeMap = session['endTime'] as Map<String, dynamic>;

        final startHour = startTimeMap['hour'] as int;
        final startMinute = startTimeMap['minute'] as int;
        final endHour = endTimeMap['hour'] as int;
        final endMinute = endTimeMap['minute'] as int;

        DateTime startTime =
            DateTime(date.year, date.month, date.day, startHour, startMinute);

        final endTime =
            DateTime(date.year, date.month, date.day, endHour, endMinute);

        // Create 30-minute slots
        while (startTime.isBefore(endTime)) {
          availableSlots.add(startTime);
          startTime = startTime.add(const Duration(minutes: 30));
        }
      }

      // Filter out slots that are already booked
      final bookedAppointments = await _appointments
          .where('doctorId', isEqualTo: doctorId)
          .where('appointmentTime',
              isGreaterThanOrEqualTo:
                  Timestamp.fromDate(DateTime(date.year, date.month, date.day)))
          .where('appointmentTime',
              isLessThan: Timestamp.fromDate(
                  DateTime(date.year, date.month, date.day + 1)))
          .where('status', whereIn: [
        AppointmentStatus.pending.toString().split('.').last,
        AppointmentStatus.confirmed.toString().split('.').last,
      ]).get();

      final bookedTimes = bookedAppointments.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return (data['appointmentTime'] as Timestamp).toDate();
      }).toList();

      // Remove booked slots from available slots
      availableSlots.removeWhere((slot) {
        return bookedTimes.any((bookedTime) {
          return bookedTime.isAtSameMomentAs(slot);
        });
      });

      return availableSlots;
    } catch (e) {
      throw Exception('Failed to get available slots: $e');
    }
  }
}
