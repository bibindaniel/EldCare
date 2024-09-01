import 'package:cloud_firestore/cloud_firestore.dart';

class MedicineSchedule {
  final DateTime time;
  final String dosage;

  MedicineSchedule({required this.time, required this.dosage});

  Map<String, dynamic> toMap() {
    return {
      'time': Timestamp.fromDate(time),
      'dosage': dosage,
    };
  }

  factory MedicineSchedule.fromMap(Map<String, dynamic> map) {
    return MedicineSchedule(
      time: (map['time'] as Timestamp).toDate(),
      dosage: map['dosage'] ?? '',
    );
  }
}

class Medicine {
  final String id;
  final String name;
  final int quantity;
  final DateTime startDate;
  final DateTime endDate;
  final String shape;
  final String color;
  final List<MedicineSchedule> schedules;
  final bool isBeforeFood;
  final double? deliveryCharge;

  Medicine({
    this.id = '',
    required this.name,
    required this.quantity,
    required this.startDate,
    required this.endDate,
    required this.shape,
    required this.color,
    required this.schedules,
    required this.isBeforeFood,
    this.deliveryCharge,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'quantity': quantity,
      'startDate': Timestamp.fromDate(startDate),
      'endDate': Timestamp.fromDate(endDate),
      'shape': shape,
      'color': color,
      'schedules': schedules.map((s) => s.toMap()).toList(),
      'isBeforeFood': isBeforeFood,
      'deliveryCharge': deliveryCharge,
    };
  }

  factory Medicine.fromMap(Map<String, dynamic> map, String id) {
    return Medicine(
      id: id,
      name: map['name'] ?? '',
      quantity: map['quantity'] ?? 0,
      startDate: (map['startDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
      endDate: (map['endDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
      shape: map['shape'] ?? '',
      color: map['color'] ?? '',
      schedules: (map['schedules'] as List?)
              ?.map((s) => MedicineSchedule.fromMap(s))
              .toList() ??
          [],
      isBeforeFood: map['isBeforeFood'] ?? false,
      deliveryCharge: map['deliveryCharge'],
    );
  }

  bool isScheduledForDate(DateTime date) {
    final normalizedDate = DateTime.utc(date.year, date.month, date.day);
    final normalizedStartDate =
        DateTime.utc(startDate.year, startDate.month, startDate.day);
    final normalizedEndDate =
        DateTime.utc(endDate.year, endDate.month, endDate.day);

    bool isWithinDateRange =
        normalizedDate.isAtSameMomentAs(normalizedStartDate) ||
            normalizedDate.isAtSameMomentAs(normalizedEndDate) ||
            (normalizedDate.isAfter(normalizedStartDate) &&
                normalizedDate
                    .isBefore(normalizedEndDate.add(const Duration(days: 1))));

    if (!isWithinDateRange) return false;

    bool hasMatchingSchedule = schedules.any((schedule) {
      final normalizedScheduleDate = DateTime.utc(
          schedule.time.year, schedule.time.month, schedule.time.day);
      return normalizedScheduleDate.isAtSameMomentAs(normalizedDate);
    });

    return hasMatchingSchedule;
  }

  @override
  String toString() {
    return 'Medicine(id: $id, name: $name, startDate: $startDate, endDate: $endDate, schedules: ${schedules.length})';
  }
}
