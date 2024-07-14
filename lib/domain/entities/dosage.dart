class Medicine {
  final String name;
  final String dosage;
  final String time;

  Medicine({required this.name, required this.dosage, required this.time});
}

final List<Medicine> medicines = [
  Medicine(name: "Aspirin", dosage: "100mg", time: "08:00 AM"),
  Medicine(name: "Lisinopril", dosage: "10mg", time: "09:00 AM"),
  Medicine(name: "Metformin", dosage: "500mg", time: "01:00 PM"),
  Medicine(name: "Simvastatin", dosage: "20mg", time: "08:00 PM"),
  Medicine(name: "Omeprazole", dosage: "20mg", time: "10:00 PM"),
];
