import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/doctor_schedule.dart';

class DoctorScheduleRepository {
  final FirebaseFirestore _firestore;

  DoctorScheduleRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  Future<WeeklySchedule> getWeeklySchedule(String doctorId) async {
    try {
      final snapshot = await _firestore
          .collection('doctors')
          .doc(doctorId)
          .collection('schedules')
          .get();

      List<DaySchedule> days = List.generate(7, (index) {
        final dayDocs = snapshot.docs.where(
          (doc) => doc.id == (index + 1).toString(),
        );

        if (dayDocs.isNotEmpty) {
          return DaySchedule.fromJson({
            ...dayDocs.first.data(),
            'dayOfWeek': index + 1,
          });
        } else {
          return DaySchedule(
            dayOfWeek: index + 1,
            sessions: [],
            isWorkingDay: true,
          );
        }
      });

      return WeeklySchedule(
        doctorId: doctorId,
        days: days,
      );
    } catch (e) {
      throw Exception('Failed to load weekly schedule: $e');
    }
  }

  Future<WeeklySchedule> addSession(
    String doctorId,
    int dayOfWeek,
    DoctorSession session,
  ) async {
    try {
      await _firestore
          .collection('doctors')
          .doc(doctorId)
          .collection('schedules')
          .doc(dayOfWeek.toString())
          .set({
        'sessions': FieldValue.arrayUnion([
          {
            'id': session.id,
            'label': session.label,
            'startTime':
                '${session.startTime.hour}:${session.startTime.minute}',
            'endTime': '${session.endTime.hour}:${session.endTime.minute}',
            'slotDuration': session.slotDuration,
            'bufferTime': session.bufferTime,
            'isActive': session.isActive,
          }
        ]),
        'isWorkingDay': true,
      }, SetOptions(merge: true));

      return getWeeklySchedule(doctorId);
    } catch (e) {
      throw Exception('Failed to add session: $e');
    }
  }

  Future<WeeklySchedule> updateSession(
    String doctorId,
    int dayOfWeek,
    DoctorSession session,
  ) async {
    try {
      final scheduleRef = _firestore
          .collection('doctors')
          .doc(doctorId)
          .collection('schedules')
          .doc(dayOfWeek.toString());

      await _firestore.runTransaction((transaction) async {
        final scheduleDoc = await transaction.get(scheduleRef);
        final List<dynamic> sessions = scheduleDoc.data()?['sessions'] ?? [];

        final updatedSessions = sessions.map((existingSession) {
          if (existingSession['id'] == session.id) {
            return {
              'id': session.id,
              'label': session.label,
              'startTime':
                  '${session.startTime.hour}:${session.startTime.minute}',
              'endTime': '${session.endTime.hour}:${session.endTime.minute}',
              'slotDuration': session.slotDuration,
              'bufferTime': session.bufferTime,
              'isActive': session.isActive,
            };
          }
          return existingSession;
        }).toList();

        transaction.set(
          scheduleRef,
          {'sessions': updatedSessions},
          SetOptions(merge: true),
        );
      });

      return getWeeklySchedule(doctorId);
    } catch (e) {
      throw Exception('Failed to update session: $e');
    }
  }

  Future<WeeklySchedule> deleteSession(
    String doctorId,
    int dayOfWeek,
    String sessionId,
  ) async {
    try {
      final scheduleRef = _firestore
          .collection('doctors')
          .doc(doctorId)
          .collection('schedules')
          .doc(dayOfWeek.toString());

      await _firestore.runTransaction((transaction) async {
        final scheduleDoc = await transaction.get(scheduleRef);
        final List<dynamic> sessions = scheduleDoc.data()?['sessions'] ?? [];

        final updatedSessions =
            sessions.where((session) => session['id'] != sessionId).toList();

        transaction.set(
          scheduleRef,
          {'sessions': updatedSessions},
          SetOptions(merge: true),
        );
      });

      return getWeeklySchedule(doctorId);
    } catch (e) {
      throw Exception('Failed to delete session: $e');
    }
  }

  Future<WeeklySchedule> updateDayWorkingStatus(
    String doctorId,
    int dayOfWeek,
    bool isWorkingDay,
  ) async {
    try {
      final docRef = _firestore
          .collection('doctors')
          .doc(doctorId)
          .collection('schedules')
          .doc(dayOfWeek.toString());

      // First check if the document exists
      final docSnapshot = await docRef.get();

      if (docSnapshot.exists) {
        // Update existing document
        await docRef.update({
          'isWorkingDay': isWorkingDay,
        });
      } else {
        // Create new document with initial data
        await docRef.set({
          'isWorkingDay': isWorkingDay,
          'sessions': [],
        });
      }

      return getWeeklySchedule(doctorId);
    } catch (e) {
      throw Exception('Failed to update working status: $e');
    }
  }

  Future<WeeklySchedule> copyScheduleToDay(
    String doctorId,
    int fromDayOfWeek,
    int toDayOfWeek,
  ) async {
    try {
      final fromDayDoc = await _firestore
          .collection('doctors')
          .doc(doctorId)
          .collection('schedules')
          .doc(fromDayOfWeek.toString())
          .get();

      if (fromDayDoc.exists) {
        await _firestore
            .collection('doctors')
            .doc(doctorId)
            .collection('schedules')
            .doc(toDayOfWeek.toString())
            .set(fromDayDoc.data()!, SetOptions(merge: true));
      }

      return getWeeklySchedule(doctorId);
    } catch (e) {
      throw Exception('Failed to copy schedule: $e');
    }
  }
}
