import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:eldcare/core/theme/colors.dart';
import 'package:eldcare/core/theme/font.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:eldcare/doctor/blocs/dashboard/dashboard_bloc.dart';
import 'package:intl/intl.dart';

class DoctorDashboardView extends StatefulWidget {
  final String doctorId;
  const DoctorDashboardView({super.key, required this.doctorId});

  @override
  State<DoctorDashboardView> createState() => _DoctorDashboardViewState();
}

class _DoctorDashboardViewState extends State<DoctorDashboardView> {
  @override
  void initState() {
    super.initState();
    context.read<DashboardBloc>().add(LoadDashboardData(widget.doctorId));
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DashboardBloc, DashboardState>(
      builder: (context, state) {
        if (state is DashboardLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state is DashboardError) {
          return Center(child: Text('Error: ${state.message}'));
        }

        if (state is DashboardLoaded) {
          return Scaffold(
            body: CustomScrollView(
              slivers: [
                SliverAppBar(
                  floating: true,
                  pinned: true,
                  expandedHeight: 120,
                  backgroundColor: kPrimaryColor,
                  flexibleSpace: FlexibleSpaceBar(
                    background: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            kPrimaryColor,
                            kPrimaryColor.withOpacity(0.8),
                          ],
                        ),
                      ),
                    ),
                    title: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Welcome back,',
                                style: AppFonts.bodyText2.copyWith(
                                  color: Colors.white70,
                                ),
                              ),
                              Text(
                                state.doctorName.isNotEmpty
                                    ? 'Dr. ${state.doctorName}'
                                    : 'Loading...',
                                style: AppFonts.headline3
                                    .copyWith(color: Colors.white),
                              )
                            ],
                          ),
                          IconButton(
                            icon: const Badge(
                              label: Text('3'),
                              child: Icon(Icons.notifications_outlined,
                                  color: Colors.white),
                            ),
                            onPressed: () {},
                          ),
                        ],
                      ),
                    ),
                    titlePadding: const EdgeInsets.only(left: 16, bottom: 16),
                    expandedTitleScale: 1.0,
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        _buildStatsSection(state),
                        _buildRecentPatientsSection(state),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        }

        return Container();
      },
    );
  }

  Widget _buildStatsSection(DashboardLoaded state) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [kPrimaryColor, kPrimaryColor.withOpacity(0.8)],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Today\'s Overview',
            style: AppFonts.headline4.copyWith(color: Colors.white),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildOverviewItem(
                icon: Icons.people,
                count: state.patientCount.toString(),
                label: 'Patients',
              ),
              _buildOverviewItem(
                icon: Icons.calendar_today,
                count: state.appointmentCount.toString(),
                label: 'Appointments',
              ),
              _buildOverviewItem(
                icon: Icons.medical_services,
                count: state.prescriptionCount.toString(),
                label: 'Prescriptions',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOverviewItem({
    required IconData icon,
    required String count,
    required String label,
  }) {
    return Column(
      children: [
        Icon(icon, color: Colors.white, size: 24),
        const SizedBox(height: 8),
        Text(count, style: AppFonts.headline3.copyWith(color: Colors.white)),
        Text(label, style: AppFonts.bodyText2.copyWith(color: Colors.white70)),
      ],
    );
  }

  Widget _buildRecentPatientsSection(DashboardLoaded state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Recent Patients', style: AppFonts.headline4),
            TextButton(
              onPressed: () => context
                  .read<DashboardBloc>()
                  .add(LoadDashboardData(widget.doctorId)),
              child: const Text('Refresh'),
            ),
          ],
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 100,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: state.latestPatients.length,
            itemBuilder: (context, index) {
              final patient = state.latestPatients[index];
              final userData = patient['user'] as Map<String, dynamic>;

              final patientName = userData['displayName'] ??
                  userData['name'] ??
                  'Unknown Patient';

              return Card(
                margin: const EdgeInsets.only(right: 16),
                child: Container(
                  width: 200,
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 24,
                        backgroundImage: userData['profileImageUrl'] != null
                            ? NetworkImage(
                                userData['profileImageUrl'] as String)
                            : null,
                        child: userData['profileImageUrl'] == null
                            ? const Icon(Icons.person)
                            : null,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(patientName, style: AppFonts.bodyText1),
                            Text(
                              patient['record']['createdAt'] != null
                                  ? DateFormat('MMM dd, yyyy').format(
                                      (patient['record']['createdAt']
                                              as Timestamp)
                                          .toDate(),
                                    )
                                  : 'N/A',
                              style: AppFonts.caption,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
