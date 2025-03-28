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
  Future<List<Appointment>> getUserAppointments(String userId) async {
    try {
      print("Fetching appointments for user: $userId");

      final querySnapshot = await _appointments
          .where('userId', isEqualTo: userId)
          // Make sure we're not filtering out any statuses accidentally
          // .where('status', isNotEqualTo: 'cancelled')  // Remove this line if it exists
          .orderBy('appointmentTime', descending: true)
          .get();

      print("Found ${querySnapshot.docs.length} appointments for user $userId");

      // Debug - print all appointments and their statuses
      for (var doc in querySnapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        print("Appointment: ${doc.id}, Status: ${data['status']}");
      }

      return querySnapshot.docs
          .map((doc) =>
              Appointment.fromMap(doc.data() as Map<String, dynamic>, doc.id))
          .toList();
    } catch (e) {
      print("Error fetching user appointments: $e");
      return [];
    }
  }

  // Get all appointments for a doctor
  Future<List<Appointment>> getDoctorAppointments(
    String doctorId,
    DateTime date,
  ) async {
    try {
      final startOfDay = DateTime(date.year, date.month, date.day);
      final endOfDay = startOfDay.add(const Duration(days: 1));

      final snapshot = await _firestore
          .collection('appointments')
          .where('doctorId', isEqualTo: doctorId)
          .where('appointmentTime',
              isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
          .where('appointmentTime', isLessThan: Timestamp.fromDate(endOfDay))
          .get();

      return snapshot.docs
          .map((doc) => Appointment.fromMap(doc.data(), doc.id))
          .toList();
    } catch (e) {
      print('Error getting doctor appointments: $e');
      throw Exception('Failed to load appointments');
    }
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

  // Get available slots for a specific doctor on a specific day
  Future<List<DateTime>> getAvailableSlots(
      String doctorId, DateTime date) async {
    try {
      print("Getting slots for doctor: $doctorId on date: $date");

      // Normalize date to start of day for comparison
      final startOfDay = DateTime(date.year, date.month, date.day);
      final endOfDay = startOfDay.add(const Duration(days: 1));

      // Get the doctor's schedule for this day of week (1-7)
      final dayOfWeek = date.weekday; // 1 for Monday, 7 for Sunday

      // Get schedule from the subcollection instead of a field in the doctor document
      final scheduleDoc = await _firestore
          .collection('doctors')
          .doc(doctorId)
          .collection('schedules')
          .doc(dayOfWeek.toString())
          .get();

      if (!scheduleDoc.exists) {
        print("No schedule for day ${dayOfWeek}");
        return [];
      }

      final scheduleData = scheduleDoc.data() as Map<String, dynamic>;
      if (!scheduleData.containsKey('isWorkingDay') ||
          scheduleData['isWorkingDay'] == false) {
        print("Not a working day");
        return [];
      }

      if (!scheduleData.containsKey('sessions') ||
          (scheduleData['sessions'] as List).isEmpty) {
        print("No sessions for this day");
        return [];
      }

      // Get the doctor's sessions for this day
      final sessions = scheduleData['sessions'] as List<dynamic>;
      print("Found ${sessions.length} sessions");

      // Convert sessions to available time slots
      List<DateTime> availableSlots = [];

      for (var session in sessions) {
        try {
          if (session['isActive'] != true) {
            continue; // Skip inactive sessions
          }

          final startTimeParts = (session['startTime'] as String).split(':');
          final endTimeParts = (session['endTime'] as String).split(':');

          final startHour = int.parse(startTimeParts[0]);
          final startMinute = int.parse(startTimeParts[1]);

          final endHour = int.parse(endTimeParts[0]);
          final endMinute = int.parse(endTimeParts[1]);

          final sessionStart = DateTime(
            date.year,
            date.month,
            date.day,
            startHour,
            startMinute,
          );

          final sessionEnd = DateTime(
            date.year,
            date.month,
            date.day,
            endHour,
            endMinute,
          );

          print(
              "Session: ${sessionStart.toIso8601String()} to ${sessionEnd.toIso8601String()}");

          // Create slots at specified duration intervals
          final slotDuration = Duration(minutes: session['slotDuration'] ?? 30);
          final bufferTime = Duration(minutes: session['bufferTime'] ?? 5);
          var currentSlot = sessionStart;

          while (currentSlot.add(slotDuration).isBefore(sessionEnd) ||
              currentSlot.add(slotDuration).isAtSameMomentAs(sessionEnd)) {
            availableSlots.add(currentSlot);
            currentSlot = currentSlot.add(slotDuration + bufferTime);
          }
        } catch (e) {
          print("Error processing session: $e");
        }
      }

      // Get already booked appointments for this doctor and date
      final bookedAppointments = await _appointments
          .where('doctorId', isEqualTo: doctorId)
          .where('appointmentTime',
              isGreaterThanOrEqualTo: startOfDay.millisecondsSinceEpoch)
          .where('appointmentTime', isLessThan: endOfDay.millisecondsSinceEpoch)
          .where('status', isNotEqualTo: 'cancelled')
          .get();

      // Filter out slots that are already booked
      final bookedSlots = bookedAppointments.docs.map((doc) {
        final appointmentData = doc.data() as Map<String, dynamic>;
        final timestamp = appointmentData['appointmentTime'] as int;
        return DateTime.fromMillisecondsSinceEpoch(timestamp);
      }).toList();

      print("Found ${bookedSlots.length} booked slots");

      final filteredSlots = availableSlots.where((slot) {
        return !bookedSlots.any((bookedSlot) {
          return slot.isAtSameMomentAs(bookedSlot);
        });
      }).toList();

      print("Returning ${filteredSlots.length} available slots");
      return filteredSlots;
    } catch (e) {
      print("Error getting available slots: $e");
      throw Exception('Failed to get available slots: $e');
    }
  }

  Future<String> createPendingAppointment(Appointment appointment) async {
    try {
      final appointmentRef = _firestore.collection('appointments').doc();
      final pendingAppointment = appointment.copyWith(
        id: appointmentRef.id,
        status: AppointmentStatus.pendingPayment,
        createdAt: DateTime.now(),
      );

      await appointmentRef.set(pendingAppointment.toMap());
      return appointmentRef.id;
    } catch (e) {
      throw Exception('Failed to create pending appointment: $e');
    }
  }

  Future<Map<String, dynamic>> getAppointmentPaymentDetails(
      String appointmentId) async {
    try {
      final appointmentDoc =
          await _firestore.collection('appointments').doc(appointmentId).get();
      if (!appointmentDoc.exists) {
        throw Exception('Appointment not found');
      }

      final appointmentData = appointmentDoc.data()!;

      // Get doctor details for payment description
      final doctorDoc = await _firestore
          .collection('doctors')
          .doc(appointmentData['doctorId'])
          .get();
      final doctorName =
          doctorDoc.exists ? doctorDoc.data()!['name'] : 'Doctor';

      // You can get these values from your system configuration
      final consultationFee = 500.0; // Example value

      return {
        'amount': consultationFee * 100, // Razorpay expects amount in paise
        'currency': 'INR',
        'receipt': appointmentId,
        'description': 'Consultation with Dr. $doctorName',
        'appointmentId': appointmentId,
      };
    } catch (e) {
      throw Exception('Failed to get payment details: $e');
    }
  }

  Future<void> confirmAppointmentPayment(
      String appointmentId, String paymentId) async {
    try {
      print(
          "Confirming payment for appointment: $appointmentId with payment ID: $paymentId");

      // First check if appointment exists
      final appointmentDoc =
          await _firestore.collection('appointments').doc(appointmentId).get();
      if (!appointmentDoc.exists) {
        print("ERROR: Appointment $appointmentId not found in database");
        throw Exception('Appointment not found');
      }

      // Update with scheduled status and payment info
      await _firestore.collection('appointments').doc(appointmentId).update({
        'status':
            'scheduled', // Use string directly - enum serialization can be tricky
        'paymentId': paymentId,
        'isPaid': true,
        'updatedAt': FieldValue.serverTimestamp(), // Add timestamp
      });

      print(
          "Successfully updated appointment $appointmentId to scheduled status");

      // Double-check update
      final updatedDoc =
          await _firestore.collection('appointments').doc(appointmentId).get();
      print("Updated appointment data: ${updatedDoc.data()}");
    } catch (e) {
      print("ERROR confirming payment: $e");
      throw Exception('Failed to confirm appointment payment: $e');
    }
  }

  Future<Appointment?> getAppointmentById(String appointmentId) async {
    try {
      final appointmentDoc =
          await _firestore.collection('appointments').doc(appointmentId).get();

      if (!appointmentDoc.exists) {
        return null;
      }

      return Appointment.fromMap(appointmentDoc.data()!, appointmentDoc.id);
    } catch (e) {
      print("Error getting appointment by ID: $e");
      return null;
    }
  }

  // Reschedule appointment
  Future<void> rescheduleAppointment(
      String appointmentId, DateTime newTime, int durationMinutes) async {
    try {
      await _appointments.doc(appointmentId).update({
        'appointmentTime': Timestamp.fromDate(newTime),
        'durationMinutes': durationMinutes,
        'status': AppointmentStatus.scheduled.toString().split('.').last,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to reschedule appointment: $e');
    }
  }

  // Get doctor appointments within a time range
  Future<List<Appointment>> getDoctorAppointmentsByTimeRange(
    String doctorId,
    DateTime startTime,
    DateTime endTime,
  ) async {
    try {
      final snapshot = await _firestore
          .collection('appointments')
          .where('doctorId', isEqualTo: doctorId)
          .where('appointmentTime', isGreaterThanOrEqualTo: startTime)
          .where('appointmentTime', isLessThan: endTime)
          .get();

      return snapshot.docs
          .map((doc) => Appointment.fromMap(doc.data(), doc.id))
          .toList();
    } catch (e) {
      print('Error getting doctor appointments by time range: $e');
      throw Exception('Failed to load appointments');
    }
  }

  // Update appointment with consultation details and status
  Future<void> updateAppointmentWithConsultation(
    String appointmentId,
    Map<String, dynamic> consultationDetails,
    AppointmentStatus status,
  ) async {
    try {
      await _firestore.collection('appointments').doc(appointmentId).update({
        'status': status.toString().split('.').last,
        'consultationDetails': consultationDetails,
      });
    } catch (e) {
      print('Error updating appointment with consultation: $e');
      throw Exception('Failed to update appointment');
    }
  }
}
