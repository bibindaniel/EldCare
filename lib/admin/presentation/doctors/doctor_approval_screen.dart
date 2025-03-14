import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:eldcare/admin/blocs/doctor_approval/doctor_approval_bloc.dart';
import 'package:eldcare/admin/presentation/adminstyles/adminstyles.dart';
import 'package:eldcare/doctor/models/doctor.dart';
import 'package:eldcare/admin/presentation/doctors/document_viewer_screen.dart';
import 'package:url_launcher/url_launcher.dart';

class DoctorApprovalScreen extends StatefulWidget {
  const DoctorApprovalScreen({Key? key}) : super(key: key);

  @override
  State<DoctorApprovalScreen> createState() => _DoctorApprovalScreenState();
}

class _DoctorApprovalScreenState extends State<DoctorApprovalScreen> {
  @override
  void initState() {
    super.initState();
    context.read<DoctorApprovalBloc>().add(LoadPendingDoctors());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () async {
          context.read<DoctorApprovalBloc>().add(LoadPendingDoctors());
        },
        child: BlocBuilder<DoctorApprovalBloc, DoctorApprovalState>(
          builder: (context, state) {
            if (state is DoctorApprovalLoading) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            } else if (state is DoctorApprovalError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline, size: 48, color: Colors.red[300]),
                    const SizedBox(height: 16),
                    Text(
                      'Error: ${state.message}',
                      style: const TextStyle(color: Colors.red),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: () {
                        context
                            .read<DoctorApprovalBloc>()
                            .add(LoadPendingDoctors());
                      },
                      icon: const Icon(Icons.refresh),
                      label: const Text('Retry'),
                    ),
                  ],
                ),
              );
            } else if (state is DoctorApprovalLoaded) {
              if (state.doctors.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.check_circle_outline,
                          size: 64, color: Colors.green[300]),
                      const SizedBox(height: 16),
                      const Text(
                        'No pending requests',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'All doctor registration requests have been processed',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                );
              }
              return CustomScrollView(
                slivers: [
                  SliverAppBar(
                    floating: true,
                    snap: true,
                    title: Text(
                      'Doctor Registration Requests (${state.doctors.length})',
                      style: const TextStyle(color: Colors.black87),
                    ),
                    backgroundColor: Colors.white,
                    elevation: 2,
                  ),
                  SliverPadding(
                    padding: const EdgeInsets.all(16),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) => _DoctorRequestCard(
                          doctor: state.doctors[index],
                        ),
                        childCount: state.doctors.length,
                      ),
                    ),
                  ),
                ],
              );
            }
            return const SizedBox();
          },
        ),
      ),
    );
  }
}

class _DoctorRequestCard extends StatelessWidget {
  final Doctor doctor;

  const _DoctorRequestCard({required this.doctor});

  void _viewDocument(BuildContext context, String type, String url) {
    try {
      print('Document URL: $url'); // Debug print

      if (url.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Invalid document URL'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      // For Firebase Storage URLs, we'll assume the file type based on the document type
      // or check for content-type in the metadata
      final String documentType = type.toLowerCase();
      bool isValidType = false;

      if (documentType.contains('image') ||
          documentType.contains('photo') ||
          documentType.contains('picture')) {
        isValidType = true; // Assume it's an image
      } else if (documentType.contains('pdf') ||
          documentType.contains('certificate') ||
          documentType.contains('degree') ||
          documentType.contains('license')) {
        isValidType = true; // Assume it's a PDF
      }

      if (!isValidType) {
        print('Document type: $documentType'); // Debug print
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Unsupported document type'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => DocumentViewerScreen(
            url: url,
            title: _formatDocumentType(type),
            documentType: documentType, // Pass the document type
          ),
        ),
      );
    } catch (e) {
      print('Error viewing document: $e'); // For debugging
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error viewing document: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showDocuments(BuildContext context, Doctor doctor) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Documents', style: AdminStyles.subHeaderStyle),
              const SizedBox(height: 16),
              ...doctor.documents.entries.map(
                (doc) => ListTile(
                  title: Text(_formatDocumentType(doc.key)),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.visibility),
                        onPressed: () {
                          Navigator.pop(context); // Close dialog
                          _viewDocument(context, doc.key, doc.value);
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.download),
                        onPressed: () => _downloadDocument(context, doc.value),
                      ),
                    ],
                  ),
                ),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Close'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _downloadDocument(BuildContext context, String url) async {
    try {
      final Uri uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      } else {
        throw 'Could not launch $url';
      }
    } catch (e) {
      print('Error downloading document: $e'); // For debugging
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error downloading document: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  String _formatDocumentType(String key) {
    return key
        .split('_')
        .map((word) => word[0].toUpperCase() + word.substring(1))
        .join(' ');
  }

  void _viewProfileImage(BuildContext context) {
    if (doctor.profileImageUrl != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => DocumentViewerScreen(
            url: doctor.profileImageUrl!,
            title: 'Profile Image',
            documentType: 'image',
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        children: [
          _buildHeader(context),
          const Divider(),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildInfoSection(),
                const SizedBox(height: 16),
                _buildDocumentsSection(context),
                const SizedBox(height: 16),
                _buildActionButtons(context),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => _viewProfileImage(context),
            child: Hero(
              tag: 'profile_${doctor.userId}',
              child: CircleAvatar(
                radius: 30,
                backgroundImage: doctor.profileImageUrl != null
                    ? NetworkImage(doctor.profileImageUrl!)
                    : null,
                child: doctor.profileImageUrl == null
                    ? const Icon(Icons.person, size: 30)
                    : null,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  doctor.fullName,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  doctor.workEmail,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          _buildInfoRow(
              Icons.medical_services, 'Specialization', doctor.specialization),
          const SizedBox(height: 8),
          _buildInfoRow(Icons.badge, 'Registration', doctor.registrationNumber),
          const SizedBox(height: 8),
          _buildInfoRow(Icons.work, 'Experience', '${doctor.experience} years'),
          const SizedBox(height: 8),
          _buildInfoRow(Icons.local_hospital, 'Hospital', doctor.hospitalName),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.blue[700]),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: const TextStyle(
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(color: Colors.black87),
          ),
        ),
      ],
    );
  }

  Widget _buildDocumentsSection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Required Documents',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: doctor.documents.entries.map((doc) {
              return ActionChip(
                avatar: const Icon(Icons.description, size: 18),
                label: Text(_formatDocumentType(doc.key)),
                onPressed: () => _viewDocument(context, doc.key, doc.value),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      alignment: WrapAlignment.end,
      children: [
        SizedBox(
          width: 150, // Fixed width for consistent layout
          child: OutlinedButton(
            onPressed: () => _showDocuments(context, doctor),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.blue,
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.folder_open, size: 20),
                SizedBox(width: 4),
                Text('Documents'),
              ],
            ),
          ),
        ),
        SizedBox(
          width: 120, // Fixed width for consistent layout
          child: ElevatedButton.icon(
            onPressed: () => _approveDoctor(context, doctor),
            icon: const Icon(Icons.check, size: 20),
            label: const Text('Approve'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
            ),
          ),
        ),
        SizedBox(
          width: 120, // Fixed width for consistent layout
          child: ElevatedButton.icon(
            onPressed: () => _rejectDoctor(context, doctor),
            icon: const Icon(Icons.close, size: 20),
            label: const Text('Reject'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
            ),
          ),
        ),
      ],
    );
  }

  void _approveDoctor(BuildContext context, Doctor doctor) {
    context
        .read<DoctorApprovalBloc>()
        .add(ApproveDoctor(doctor.userId, doctor));
  }

  void _rejectDoctor(BuildContext context, Doctor doctor) {
    context.read<DoctorApprovalBloc>().add(RejectDoctor(doctor.userId, doctor));
  }
}
