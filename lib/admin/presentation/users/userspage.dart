import 'package:eldcare/admin/blocs/users/users_bloc.dart';
import 'package:eldcare/admin/presentation/users/datatables.dart';
import 'package:flutter/material.dart';
import 'package:eldcare/admin/presentation/adminstyles/adminstyles.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class UsersPage extends StatelessWidget {
  const UsersPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<UserBloc, UserState>(
      builder: (context, state) {
        if (state is UserLoading) {
          return const Center(child: CircularProgressIndicator());
        } else if (state is UserError) {
          return Center(child: Text('Error: ${state.message}'));
        } else if (state is UserLoaded) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Users Management', style: AdminStyles.headerStyle),
                const SizedBox(height: 20),
                // _buildSearchAndFilter(),
                const SizedBox(height: 20),
                UsersTableWidget(
                  elderlyUsers: state.elderlyUsers,
                  pharmacists: state.pharmacists,
                ),
                const SizedBox(height: 20),
                _buildPendingApprovals(),
                const SizedBox(height: 20),
                _buildUserStatistics(),
                const SizedBox(height: 20),
                _buildRecentUserActivity(),
              ],
            ),
          );
        } else {
          return const Center(child: Text('No data available'));
        }
      },
    );
  }

//   Widget _buildUsersTable(
//     List<UserProfile> elderlyUsers, List<PharmacistProfile> pharmacists) {
//   return Column(
//     children: [
//       const Text('Elderly Users', style: AdminStyles.subHeaderStyle),
//       Card(
//         elevation: 4,
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
//         child: PaginatedDataTable(
//           header: const Text('Elderly Users', style: AdminStyles.subHeaderStyle),
//           columns: const [
//             DataColumn(label: Text('Name', style: AdminStyles.subHeaderStyle)),
//             DataColumn(label: Text('Email', style: AdminStyles.subHeaderStyle)),
//             DataColumn(label: Text('Phone', style: AdminStyles.subHeaderStyle)),
//             DataColumn(label: Text('Address', style: AdminStyles.subHeaderStyle)),
//             DataColumn(label: Text('Verified', style: AdminStyles.subHeaderStyle)),
//           ],
//           source: UserDataTableSource(elderlyUsers),
//           rowsPerPage: PaginatedDataTable.defaultRowsPerPage,
//           onRowsPerPageChanged: (rowsPerPage) {
//             setState(() {
//               _rowsPerPage = rowsPerPage!;
//             });
//           },
//         ),
//       ),
//       const SizedBox(height: 20),
//       const Text('Pharmacists', style: AdminStyles.subHeaderStyle),
//       Card(
//         elevation: 4,
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
//         child: PaginatedDataTable(
//           header: const Text('Pharmacists', style: AdminStyles.subHeaderStyle),
//           columns: const [
//             DataColumn(label: Text('Name', style: AdminStyles.subHeaderStyle)),
//             DataColumn(label: Text('Email', style: AdminStyles.subHeaderStyle)),
//             DataColumn(label: Text('Phone', style: AdminStyles.subHeaderStyle)),
//             DataColumn(label: Text('License Number', style: AdminStyles.subHeaderStyle)),
//             DataColumn(label: Text('Verified', style: AdminStyles.subHeaderStyle)),
//           ],
//           source: PharmacistDataTableSource(pharmacists),
//           rowsPerPage: PaginatedDataTable.defaultRowsPerPage,
//           onRowsPerPageChanged: (rowsPerPage) {
//             setState(() {
//               _rowsPerPagePharmacist = rowsPerPage!;
//             });
//           },
//         ),
//       ),
//     ],
//   );
// }

  DataRow _buildDataRow(
      String name, String contact, String address, String caregiver) {
    return DataRow(
      cells: [
        DataCell(Text(name, style: AdminStyles.bodyStyle)),
        DataCell(Text(contact, style: AdminStyles.bodyStyle)),
        DataCell(Text(address, style: AdminStyles.bodyStyle)),
        DataCell(Text(caregiver, style: AdminStyles.bodyStyle)),
        DataCell(Row(
          children: [
            IconButton(
              icon: const Icon(Icons.visibility, color: Colors.blue),
              onPressed: () {},
              tooltip: 'View',
            ),
            IconButton(
              icon: const Icon(Icons.edit, color: Colors.green),
              onPressed: () {},
              tooltip: 'Edit',
            ),
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () {},
              tooltip: 'Delete',
            ),
          ],
        )),
      ],
    );
  }

  Widget _buildUserStatistics() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('User Statistics', style: AdminStyles.subHeaderStyle),
            const SizedBox(height: 16),
            GridView.count(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _buildOverviewCard(
                    'Total Users', '1,234', Icons.people, Colors.blue),
                _buildOverviewCard(
                    'Active Users', '567', Icons.check_circle, Colors.green),
                _buildOverviewCard(
                    'Inactive Users', '89', Icons.cancel, Colors.orange),
                _buildOverviewCard(
                    'New Users', '45', Icons.person_add, Colors.red),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOverviewCard(
      String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40, color: color),
            const SizedBox(height: 8),
            Text(value,
                style: AdminStyles.subHeaderStyle.copyWith(color: color)),
            const SizedBox(height: 4),
            Text(title, style: AdminStyles.captionStyle),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentUserActivity() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Recent User Activity',
                style: AdminStyles.subHeaderStyle),
            const SizedBox(height: 16),
            _buildActivityItem(Icons.login, 'John Doe logged in', '2m ago'),
            _buildActivityItem(
                Icons.person_add, 'Alice Johnson registered', '15m ago'),
            _buildActivityItem(
                Icons.edit, 'David Lee updated profile', '1h ago'),
          ],
        ),
      ),
    );
  }

  Widget _buildActivityItem(IconData icon, String title, String time) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 24, color: AdminStyles.primaryColor),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AdminStyles.bodyStyle),
                Text(time, style: AdminStyles.captionStyle),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPendingApprovals() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Pending Approvals', style: AdminStyles.subHeaderStyle),
            const SizedBox(height: 16),
            _buildApprovalItem('John Doe', 'john.doe@example.com', 'Admin'),
            _buildApprovalItem(
                'Alice Johnson', 'alice.johnson@example.com', 'Caregiver'),
            _buildApprovalItem('David Lee', 'david.lee@example.com', 'Elderly'),
          ],
        ),
      ),
    );
  }

  Widget _buildApprovalItem(String name, String email, String role) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: AdminStyles.bodyStyle),
                Text(email, style: AdminStyles.captionStyle),
                Text('Role: $role', style: AdminStyles.captionStyle),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.check_circle, color: Colors.green),
            onPressed: () {
              // Approve user logic
            },
            tooltip: 'Approve',
          ),
          IconButton(
            icon: const Icon(Icons.cancel, color: Colors.red),
            onPressed: () {
              // Reject user logic
            },
            tooltip: 'Reject',
          ),
        ],
      ),
    );
  }
}
