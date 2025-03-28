import 'package:flutter/material.dart';
import 'package:eldcare/core/theme/font.dart';
import 'package:eldcare/core/theme/colors.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eldcare/shared/blockchain/blockchain_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:eldcare/doctor/presentation/screens/patients/patient_detail_screen.dart';
import 'package:eldcare/shared/repositories/medical_record_repository.dart';
import 'package:eldcare/shared/utils/user_helper.dart';

class PatientsView extends StatefulWidget {
  const PatientsView({super.key});

  @override
  State<PatientsView> createState() => _PatientsViewState();
}

class _PatientsViewState extends State<PatientsView> {
  final TextEditingController _searchController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _doctorId = FirebaseAuth.instance.currentUser?.uid ?? '';

  List<Map<String, dynamic>> _allPatients = [];
  List<Map<String, dynamic>> _filteredPatients = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchPatients();
  }

  Future<void> _fetchPatients() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      // Get current doctor ID consistently
      final doctorId = UserHelper.getCurrentUserId();

      // Try to get patients from both blockchain and direct Firebase
      final blockchainService = BlockchainService(_firestore);
      final recordRepo = MedicalRecordRepository();

      // Get patient IDs from both sources
      List<String> blockchainPatientIds = [];
      List<String> firestorePatientIds = [];

      try {
        blockchainPatientIds =
            await blockchainService.getDoctorPatients(doctorId);
      } catch (e) {
        print('Error fetching blockchain patients: $e');
      }

      try {
        firestorePatientIds = await recordRepo.getDoctorPatients();
      } catch (e) {
        print('Error fetching Firestore patients: $e');
      }

      // Combine unique patient IDs from both sources
      final Set<String> patientIds = {
        ...blockchainPatientIds,
        ...firestorePatientIds
      };

      if (patientIds.isEmpty) {
        // Also check appointments as a last resort
        final appointmentsSnapshot = await _firestore
            .collection('appointments')
            .where('doctorId', isEqualTo: doctorId)
            .where('status', isEqualTo: 'completed')
            .get();

        for (final doc in appointmentsSnapshot.docs) {
          final patientId = doc.data()['patientId'] as String?;
          if (patientId != null) {
            patientIds.add(patientId);
          }
        }
      }

      // Fetch patient details
      final List<Map<String, dynamic>> patients = [];
      for (final patientId in patientIds) {
        try {
          final userDoc =
              await _firestore.collection('users').doc(patientId).get();
          if (userDoc.exists) {
            final data = userDoc.data() ?? {};
            patients.add({
              'id': patientId,
              'name': data['displayName'] ?? 'Unknown',
              'age': data['age'] ?? 'N/A',
              'gender': data['gender'] ?? 'N/A',
              'phone': data['phone'] ?? 'N/A',
              'lastVisit': await _getLastVisitDate(patientId),
              'status': await _getPatientStatus(patientId),
              'imageUrl': data['profilePicture'],
            });
          }
        } catch (e) {
          print('Error fetching details for patient $patientId: $e');
        }
      }

      // Update UI
      setState(() {
        _allPatients = patients;
        _filteredPatients = patients;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Failed to load patients: $e';
        _isLoading = false;
      });
    }
  }

  Future<String> _getLastVisitDate(String patientId) async {
    try {
      // Query appointments collection for the last appointment with this patient
      final appointments = await _firestore
          .collection('appointments')
          .where('patientId', isEqualTo: patientId)
          .where('doctorId', isEqualTo: _doctorId)
          .where('status', isEqualTo: 'completed')
          .orderBy('appointmentDate', descending: true)
          .limit(1)
          .get();

      if (appointments.docs.isNotEmpty) {
        final lastAppointment = appointments.docs.first.data();
        final appointmentDate =
            (lastAppointment['appointmentDate'] as Timestamp).toDate();

        // Calculate days ago
        final now = DateTime.now();
        final difference = now.difference(appointmentDate).inDays;

        if (difference == 0) {
          return 'Today';
        } else if (difference == 1) {
          return 'Yesterday';
        } else {
          return '$difference days ago';
        }
      }

      return 'No visits';
    } catch (e) {
      debugPrint('Error getting last visit date: $e');
      return 'Unknown';
    }
  }

  Future<String> _getPatientStatus(String patientId) async {
    try {
      // Check if there are any active appointments
      final activeAppointments = await _firestore
          .collection('appointments')
          .where('patientId', isEqualTo: patientId)
          .where('doctorId', isEqualTo: _doctorId)
          .where('status', whereIn: ['scheduled', 'confirmed'])
          .limit(1)
          .get();

      if (activeAppointments.docs.isNotEmpty) {
        return 'Active';
      }

      // Check for completed appointments in last 30 days
      final recentAppointments = await _firestore
          .collection('appointments')
          .where('patientId', isEqualTo: patientId)
          .where('doctorId', isEqualTo: _doctorId)
          .where('status', isEqualTo: 'completed')
          .orderBy('appointmentDate', descending: true)
          .limit(1)
          .get();

      if (recentAppointments.docs.isNotEmpty) {
        final lastAppointment = recentAppointments.docs.first.data();
        final appointmentDate =
            (lastAppointment['appointmentDate'] as Timestamp).toDate();
        final daysSinceLastAppointment =
            DateTime.now().difference(appointmentDate).inDays;

        if (daysSinceLastAppointment <= 30) {
          return 'Recent';
        }
      }

      return 'Inactive';
    } catch (e) {
      debugPrint('Error getting patient status: $e');
      return 'Unknown';
    }
  }

  void _filterPatients(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredPatients = _allPatients;
      } else {
        _filteredPatients = _allPatients
            .where((patient) =>
                patient['name']
                    .toString()
                    .toLowerCase()
                    .contains(query.toLowerCase()) ||
                patient['phone']
                    .toString()
                    .toLowerCase()
                    .contains(query.toLowerCase()))
            .toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            floating: true,
            pinned: true,
            collapsedHeight: 60,
            title: Text('My Patients', style: AppFonts.headline2),
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(60),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: SearchBar(
                  controller: _searchController,
                  hintText: 'Search patients...',
                  leading: const Icon(Icons.search),
                  onChanged: _filterPatients,
                  trailing: [
                    IconButton(
                      icon: const Icon(Icons.filter_list),
                      onPressed: () {
                        // Show filter options
                        showModalBottomSheet(
                          context: context,
                          builder: (context) => _buildFilterOptions(),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
          if (_isLoading)
            const SliverFillRemaining(
              child: Center(child: CircularProgressIndicator()),
            )
          else if (_error != null)
            SliverFillRemaining(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline,
                        size: 48, color: Colors.red),
                    const SizedBox(height: 16),
                    Text(_error!, style: const TextStyle(color: Colors.red)),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _fetchPatients,
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            )
          else ...[
            SliverPadding(
              padding: const EdgeInsets.all(16),
              sliver: SliverToBoxAdapter(
                child: _buildPatientStats(),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              sliver: SliverToBoxAdapter(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Patient List (${_filteredPatients.length})',
                        style: AppFonts.headline4),
                    TextButton.icon(
                      onPressed: () {
                        // Show sort options
                        showModalBottomSheet(
                          context: context,
                          builder: (context) => _buildSortOptions(),
                        );
                      },
                      icon: const Icon(Icons.sort),
                      label: const Text('Sort'),
                    ),
                  ],
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.all(16),
              sliver: _filteredPatients.isEmpty
                  ? const SliverFillRemaining(
                      hasScrollBody: false,
                      child: Center(
                        child: Text('No patients found'),
                      ),
                    )
                  : SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) =>
                            _buildPatientCard(_filteredPatients[index]),
                        childCount: _filteredPatients.length,
                      ),
                    ),
            ),
          ],
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Navigate to add patient screen or show patient search dialog
        },
        backgroundColor: kAccentColor,
        child: const Icon(Icons.person_add),
      ),
    );
  }

  Widget _buildPatientStats() {
    // Calculate stats from patient data
    final totalPatients = _allPatients.length;

    // Count new patients (added in the last 30 days)
    final now = DateTime.now();
    final thirtyDaysAgo = now.subtract(const Duration(days: 30));

    // Since we don't have a "dateAdded" in our model, we'll use this as a placeholder
    // In a real app, you would store this information in Firestore
    final newPatients = 8; // Placeholder

    // Count active patients
    final activePatients =
        _allPatients.where((patient) => patient['status'] == 'Active').length;

    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            'Total',
            totalPatients.toString(),
            'Patients',
            Colors.blue,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            'New',
            newPatients.toString(),
            'This Month',
            Colors.green,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            'Active',
            activePatients.toString(),
            'Cases',
            Colors.orange,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(
      String title, String count, String subtitle, Color color) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            Text(title, style: AppFonts.bodyText2.copyWith(color: color)),
            Text(count, style: AppFonts.headline3.copyWith(color: color)),
            Text(subtitle,
                style: AppFonts.bodyText2, textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }

  Widget _buildPatientCard(Map<String, dynamic> patient) {
    final Color statusColor = patient['status'] == 'Active'
        ? Colors.green
        : patient['status'] == 'Recent'
            ? Colors.orange
            : Colors.grey;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: patient['imageUrl'] != null
            ? CircleAvatar(
                radius: 30,
                backgroundImage: NetworkImage(patient['imageUrl']),
              )
            : const CircleAvatar(
                radius: 30,
                child: Icon(Icons.person, size: 30),
              ),
        title: Row(
          children: [
            Text(patient['name'],
                style:
                    AppFonts.bodyText1.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                patient['status'],
                style: AppFonts.bodyText2.copyWith(color: statusColor),
              ),
            ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            Text('Age: ${patient['age']} • ${patient['gender']}',
                style: AppFonts.bodyText2),
            Text('Last Visit: ${patient['lastVisit']}',
                style: AppFonts.bodyText2),
          ],
        ),
        trailing: PopupMenuButton(
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'view',
              child: Text('View Profile'),
            ),
            const PopupMenuItem(
              value: 'history',
              child: Text('Medical History'),
            ),
            const PopupMenuItem(
              value: 'prescribe',
              child: Text('Write Prescription'),
            ),
          ],
          onSelected: (value) {
            if (value == 'history') {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => PatientDetailScreen(
                    doctorId: _doctorId,
                    patientId: patient['id'],
                    patientName: patient['name'],
                  ),
                ),
              );
            }
            // Handle other menu options
          },
        ),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PatientDetailScreen(
                doctorId: _doctorId,
                patientId: patient['id'],
                patientName: patient['name'],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildFilterOptions() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Filter Patients', style: AppFonts.headline3),
          const SizedBox(height: 16),
          Text('Status', style: AppFonts.cardSubtitle),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: [
              FilterChip(
                label: const Text('All'),
                selected: true,
                onSelected: (selected) {
                  setState(() {
                    _filteredPatients = _allPatients;
                  });
                  Navigator.pop(context);
                },
              ),
              FilterChip(
                label: const Text('Active'),
                selected: false,
                onSelected: (selected) {
                  setState(() {
                    _filteredPatients = _allPatients
                        .where((patient) => patient['status'] == 'Active')
                        .toList();
                  });
                  Navigator.pop(context);
                },
              ),
              FilterChip(
                label: const Text('Recent'),
                selected: false,
                onSelected: (selected) {
                  setState(() {
                    _filteredPatients = _allPatients
                        .where((patient) => patient['status'] == 'Recent')
                        .toList();
                  });
                  Navigator.pop(context);
                },
              ),
              FilterChip(
                label: const Text('Inactive'),
                selected: false,
                onSelected: (selected) {
                  setState(() {
                    _filteredPatients = _allPatients
                        .where((patient) => patient['status'] == 'Inactive')
                        .toList();
                  });
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSortOptions() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Sort Patients', style: AppFonts.headline3),
          const SizedBox(height: 16),
          ListTile(
            title: const Text('Name (A-Z)'),
            onTap: () {
              setState(() {
                _filteredPatients
                    .sort((a, b) => a['name'].compareTo(b['name']));
              });
              Navigator.pop(context);
            },
          ),
          ListTile(
            title: const Text('Name (Z-A)'),
            onTap: () {
              setState(() {
                _filteredPatients
                    .sort((a, b) => b['name'].compareTo(a['name']));
              });
              Navigator.pop(context);
            },
          ),
          ListTile(
            title: const Text('Last Visit (Recent first)'),
            onTap: () {
              setState(() {
                // This is a simplified approach since we don't have the actual date
                // In a real app you would sort by the actual timestamp
                _filteredPatients.sort((a, b) {
                  if (a['lastVisit'] == 'Today') return -1;
                  if (b['lastVisit'] == 'Today') return 1;
                  if (a['lastVisit'] == 'Yesterday') return -1;
                  if (b['lastVisit'] == 'Yesterday') return 1;

                  final aDays =
                      int.tryParse(a['lastVisit'].toString().split(' ')[0]) ??
                          999;
                  final bDays =
                      int.tryParse(b['lastVisit'].toString().split(' ')[0]) ??
                          999;
                  return aDays.compareTo(bDays);
                });
              });
              Navigator.pop(context);
            },
          ),
          ListTile(
            title: const Text('Status'),
            onTap: () {
              setState(() {
                _filteredPatients.sort((a, b) {
                  // Active first, then Recent, then Inactive
                  final aValue = a['status'] == 'Active'
                      ? 0
                      : a['status'] == 'Recent'
                          ? 1
                          : 2;
                  final bValue = b['status'] == 'Active'
                      ? 0
                      : b['status'] == 'Recent'
                          ? 1
                          : 2;
                  return aValue.compareTo(bValue);
                });
              });
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
