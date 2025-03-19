import 'package:eldcare/elduser/blocs/appointment/appointment_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:eldcare/core/theme/colors.dart';
import 'package:eldcare/core/theme/font.dart';
import 'package:eldcare/doctor/models/doctor.dart';
import 'package:eldcare/doctor/repositories/doctor_repository.dart';
import 'package:eldcare/elduser/presentation/screens/appointments/appointment_booking_screen.dart';
import 'package:eldcare/elduser/blocs/appointment/appointment_provider.dart';

class DoctorSelectionScreen extends StatefulWidget {
  final String userId;
  final String userName;

  const DoctorSelectionScreen({
    Key? key,
    required this.userId,
    required this.userName,
  }) : super(key: key);

  @override
  State<DoctorSelectionScreen> createState() => _DoctorSelectionScreenState();
}

class _DoctorSelectionScreenState extends State<DoctorSelectionScreen> {
  final DoctorRepository _doctorRepository = DoctorRepository();
  final TextEditingController _searchController = TextEditingController();
  List<Doctor> _doctors = [];
  List<Doctor> _filteredDoctors = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadDoctors();
  }

  Future<void> _loadDoctors() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final doctors = await _doctorRepository.getAllApprovedDoctors();
      setState(() {
        _doctors = doctors;
        _filteredDoctors = doctors;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Failed to load doctors: $e';
        _isLoading = false;
      });
    }
  }

  void _filterDoctors(String query) {
    setState(() {
      _filteredDoctors = _doctors.where((doctor) {
        final nameMatches =
            doctor.fullName.toLowerCase().contains(query.toLowerCase());
        final specializationMatches =
            doctor.specialization.toLowerCase().contains(query.toLowerCase());
        return nameMatches || specializationMatches;
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Select Doctor', style: AppFonts.headline2),
        backgroundColor: kPrimaryColor,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search by name or specialization',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onChanged: _filterDoctors,
            ),
          ),
          Expanded(
            child: _buildDoctorsList(),
          ),
        ],
      ),
    );
  }

  Widget _buildDoctorsList() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(_error!,
                style: AppFonts.bodyText1.copyWith(color: Colors.red)),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadDoctors,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_filteredDoctors.isEmpty) {
      return Center(
        child: Text(
          'No doctors found',
          style: AppFonts.headline3,
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(8.0),
      itemCount: _filteredDoctors.length,
      itemBuilder: (context, index) {
        final doctor = _filteredDoctors[index];
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
          child: ListTile(
            contentPadding: const EdgeInsets.all(16),
            leading: CircleAvatar(
              radius: 30,
              backgroundColor: kLightPrimaryColor,
              backgroundImage: doctor.profileImageUrl != null
                  ? NetworkImage(doctor.profileImageUrl!)
                  : null,
              child: doctor.profileImageUrl == null
                  ? const Icon(Icons.person, size: 30, color: kPrimaryColor)
                  : null,
            ),
            title: Text(
              doctor.fullName,
              style: AppFonts.headline4,
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Text(
                  doctor.specialization,
                  style: AppFonts.bodyText1.copyWith(
                    color: kPrimaryColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Experience: ${doctor.experience} years',
                  style: AppFonts.bodyText2,
                ),
                const SizedBox(height: 4),
                Text(
                  doctor.hospitalName,
                  style: AppFonts.bodyText2,
                ),
              ],
            ),
            trailing: IconButton(
              icon: const Icon(Icons.arrow_forward_ios, color: kPrimaryColor),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AppointmentProvider(
                      child: AppointmentBookingScreen(
                        userId: widget.userId,
                        userName: widget.userName,
                        doctor: doctor,
                      ),
                    ),
                  ),
                );
              },
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AppointmentProvider(
                    child: AppointmentBookingScreen(
                      userId: widget.userId,
                      userName: widget.userName,
                      doctor: doctor,
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
