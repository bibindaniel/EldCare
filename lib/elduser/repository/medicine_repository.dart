import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eldcare/elduser/models/medicine.dart';
import 'package:firebase_auth/firebase_auth.dart';

class MedicineRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> addMedicine(Medicine medicine) async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        await _firestore
            .collection('users')
            .doc(user.uid)
            .collection('medicines')
            .add(medicine.toMap());
        print('Medicine added successfully');
      } else {
        throw Exception('User not logged in');
      }
    } catch (e) {
      print('Error adding medicine in repository: $e');
      throw Exception('Failed to add medicine: ${e.toString()}');
    }
  }

  Future<List<Medicine>> getMedicinesForDate(DateTime date) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw Exception('User not logged in');
      }

      print('Fetching medicines for date: $date');

      final snapshot = await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('medicines')
          .get();

      print('Fetched ${snapshot.docs.length} documents');

      final medicines = snapshot.docs.map((doc) {
        final data = doc.data();
        print('Document data: $data');
        return Medicine.fromMap(data, doc.id);
      }).where((medicine) {
        // Check if the selected date falls within the medicine's date range
        bool isWithinDateRange =
            date.isAfter(medicine.startDate.subtract(Duration(days: 1))) &&
                date.isBefore(medicine.endDate.add(Duration(days: 1)));

        // Check if any scheduleTimes for this medicine match the time of day on the selected date
        bool hasMatchingScheduleTime =
            medicine.scheduleTimes.any((scheduleTime) {
          return scheduleTime.hour == date.hour &&
              scheduleTime.minute == date.minute;
        });

        return isWithinDateRange && hasMatchingScheduleTime;
      }).toList();

      print('Filtered ${medicines.length} medicines for the selected date');
      return medicines;
    } catch (e) {
      print('Error fetching medicines: $e');
      return [];
    }
  }

  Future<List<Medicine>> getCompletedMedicines() async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw Exception('User not logged in');
      }

      final snapshot = await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('medicines')
          .get();

      final now = DateTime.now();

      final completedMedicines = snapshot.docs
          .map((doc) => Medicine.fromMap(doc.data(), doc.id))
          .where((medicine) => medicine.endDate.isBefore(now))
          .toList();

      return completedMedicines;
    } catch (e) {
      print('Error fetching completed medicines: $e');
      return [];
    }
  }

  Future<List<Medicine>> getMedicinesForDateRange(
      DateTime start, DateTime end) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw Exception('User not logged in');
      }

      print('Fetching medicines for date range: $start to $end');

      final snapshot = await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('medicines')
          .get();

      print('Fetched ${snapshot.docs.length} documents');

      final medicines = snapshot.docs.map((doc) {
        final data = doc.data();
        print('Document data: $data');
        return Medicine.fromMap(data, doc.id);
      }).where((medicine) {
        // Check if the medicine's date range overlaps with the selected date range
        bool isWithinDateRange =
            medicine.startDate.isBefore(end) && medicine.endDate.isAfter(start);

        // Check if any scheduleTimes for this medicine fall within the selected date range
        bool hasMatchingScheduleTime =
            medicine.scheduleTimes.any((scheduleTime) {
          DateTime scheduleDateTime = DateTime(start.year, start.month,
              start.day, scheduleTime.hour, scheduleTime.minute);
          return scheduleDateTime.isAfter(start) &&
              scheduleDateTime.isBefore(end);
        });

        return isWithinDateRange && hasMatchingScheduleTime;
      }).toList();

      print(
          'Filtered ${medicines.length} medicines for the selected date range');
      return medicines;
    } catch (e) {
      print('Error fetching medicines: $e');
      return [];
    }
  }

  Future<List<Medicine>> getUpcomingMedicines() async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw Exception('User not logged in');
      }

      final snapshot = await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('medicines')
          .get();

      final now = DateTime.now();

      final upcomingMedicines = snapshot.docs
          .map((doc) => Medicine.fromMap(doc.data(), doc.id))
          .where((medicine) => medicine.endDate.isAfter(now))
          .toList();

      return upcomingMedicines;
    } catch (e) {
      print('Error fetching upcoming medicines: $e');
      return [];
    }
  }

  Future<void> updateMedicine(Medicine medicine) async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        await _firestore
            .collection('users')
            .doc(user.uid)
            .collection('medicines')
            .doc(medicine.id)
            .update(medicine.toMap());
        print('Medicine updated successfully');
      } else {
        throw Exception('User not logged in');
      }
    } catch (e) {
      print('Error updating medicine in repository: $e');
      throw Exception('Failed to update medicine: ${e.toString()}');
    }
  }

  Future<void> removeMedicine(String medicineId) async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        await _firestore
            .collection('users')
            .doc(user.uid)
            .collection('medicines')
            .doc(medicineId)
            .delete();
        print('Medicine removed successfully');
      } else {
        throw Exception('User not logged in');
      }
    } catch (e) {
      print('Error removing medicine in repository: $e');
      throw Exception('Failed to remove medicine: ${e.toString()}');
    }
  }
}
