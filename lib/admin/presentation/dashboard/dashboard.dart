import 'package:flutter/material.dart';
import 'package:eldcare/admin/presentation/adminstyles/adminstyles.dart';

class Dashboard extends StatelessWidget {
  const Dashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Dashboard', style: AdminStyles.headerStyle),
          const SizedBox(height: 20),
          _buildOverviewCards(),
          const SizedBox(height: 20),
          _buildCharts(),
          const SizedBox(height: 20),
          _buildRecentActivity(),
          const SizedBox(height: 20),
          _buildQuickActions(),
          const SizedBox(height: 20),
          _buildNotifications(),
        ],
      ),
    );
  }

  Widget _buildOverviewCards() {
    return GridView.count(
      crossAxisCount: 2,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: [
        _buildOverviewCard('Total Users', '1,234', Icons.people, Colors.blue),
        _buildOverviewCard(
            'Total Medicines', '567', Icons.medication, Colors.green),
        _buildOverviewCard(
            'Schedules', '89', Icons.calendar_today, Colors.orange),
        _buildOverviewCard('Reminders', '45', Icons.alarm, Colors.red),
      ],
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

  Widget _buildCharts() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Analytics', style: AdminStyles.subHeaderStyle),
            const SizedBox(height: 16),
            AspectRatio(
              aspectRatio: 16 / 9,
              child: Container(
                color: Colors.grey[200],
                child: const Center(
                    child: Text('User Growth Chart',
                        style: AdminStyles.bodyStyle)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentActivity() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Recent Activity', style: AdminStyles.subHeaderStyle),
            const SizedBox(height: 16),
            _buildActivityItem(Icons.login, 'John Doe logged in', '2m ago'),
            _buildActivityItem(
                Icons.medication_liquid, 'New medicine: Aspirin', '15m ago'),
            _buildActivityItem(
                Icons.edit_calendar, 'Schedule updated for Jane', '1h ago'),
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

  Widget _buildQuickActions() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Quick Actions', style: AdminStyles.subHeaderStyle),
            const SizedBox(height: 16),
            _buildActionButton('Add New User', Icons.person_add),
            const SizedBox(height: 8),
            _buildActionButton('Add New Medicine', Icons.medical_services),
            const SizedBox(height: 8),
            _buildActionButton('Create New Schedule', Icons.schedule),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton(String label, IconData icon) {
    return ElevatedButton.icon(
      onPressed: () {},
      icon: Icon(icon),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        foregroundColor: Colors.white,
        backgroundColor: AdminStyles.primaryColor,
        minimumSize: const Size(double.infinity, 40),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  Widget _buildNotifications() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Notifications', style: AdminStyles.subHeaderStyle),
            const SizedBox(height: 16),
            _buildNotificationItem(
                '3 pending user approvals', Icons.person_add),
            _buildNotificationItem('5 unread messages', Icons.mail),
            _buildNotificationItem(
                'System update available', Icons.system_update),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationItem(String text, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 24, color: AdminStyles.primaryColor),
          const SizedBox(width: 12),
          Expanded(child: Text(text, style: AdminStyles.bodyStyle)),
        ],
      ),
    );
  }
}
