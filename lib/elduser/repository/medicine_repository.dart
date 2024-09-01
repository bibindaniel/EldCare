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
        bool hasMatchingScheduleTime = medicine.schedules.any((schedule) {
          DateTime scheduleDateTime = DateTime(start.year, start.month,
              start.day, schedule.time.hour, schedule.time.minute);
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

  Future<List<Medicine>> getAllMedicines() async {
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

      return snapshot.docs
          .map((doc) => Medicine.fromMap(doc.data(), doc.id))
          .toList();
    } catch (e) {
      print('Error fetching all medicines: $e');
      return [];
    }
  }

  Future<List<Medicine>> getMedicinesForDate(DateTime date) async {
    try {
      final allMedicines = await getAllMedicines();
      return allMedicines
          .where((medicine) => medicine.isScheduledForDate(date))
          .toList();
    } catch (e) {
      print('Error fetching medicines for date: $e');
      return [];
    }
  }

  Future<List<Medicine>> getCompletedMedicines() async {
    try {
      final allMedicines = await getAllMedicines();
      final now = DateTime.now();
      return allMedicines
          .where((medicine) => medicine.endDate.isBefore(now))
          .toList();
    } catch (e) {
      print('Error fetching completed medicines: $e');
      return [];
    }
  }

  Future<List<Medicine>> getUpcomingMedicines() async {
    try {
      final allMedicines = await getAllMedicines();
      final now = DateTime.now();
      return allMedicines
          .where((medicine) => medicine.endDate.isAfter(now))
          .toList();
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
