import 'package:flutter/material.dart';
import 'package:eldcare/core/theme/colors.dart';
import 'package:eldcare/core/theme/font.dart';

class ProfileView extends StatelessWidget {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            floating: true,
            pinned: true,
            expandedHeight: 180,
            collapsedHeight: 100,
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
                padding: const EdgeInsets.only(bottom: 18.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const CircleAvatar(
                            radius: 25,
                            backgroundColor: Colors.white,
                            child: Icon(Icons.person,
                                size: 25, color: kPrimaryColor),
                          ),
                          const SizedBox(height: 4),
                          FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              'Dr. Sarah Johnson',
                              style: AppFonts.bodyText1.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              'Cardiologist',
                              style: AppFonts.bodyText2
                                  .copyWith(color: Colors.white70),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              centerTitle: true,
              expandedTitleScale: 1.0,
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.edit, color: Colors.white),
                onPressed: () {},
              ),
              IconButton(
                icon: const Icon(Icons.settings, color: Colors.white),
                onPressed: () {},
              ),
            ],
          ),
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                _buildProfileStats(),
                const SizedBox(height: 16),
                _buildAvailabilitySection(),
                const SizedBox(height: 16),
                _buildConsultationSettings(),
                const SizedBox(height: 16),
                _buildProfessionalDetails(),
                const SizedBox(height: 16),
                _buildAccountSettings(),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileStats() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem('Patients', '1.2k'),
          _buildDivider(),
          _buildStatItem('Experience', '8 yrs'),
          _buildDivider(),
          _buildStatItem('Rating', '4.8'),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: AppFonts.headline3.copyWith(color: kPrimaryColor),
        ),
        Text(
          label,
          style: AppFonts.bodyText2,
        ),
      ],
    );
  }

  Widget _buildDivider() {
    return Container(
      height: 40,
      width: 1,
      color: Colors.grey.withOpacity(0.3),
    );
  }

  Widget _buildAvailabilitySection() {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Availability', style: AppFonts.headline4),
                Switch(
                  value: true,
                  onChanged: (value) {},
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildTimeSlot('Morning', '9:00 AM - 1:00 PM', true),
                _buildTimeSlot('Evening', '4:00 PM - 8:00 PM', true),
              ],
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.edit_calendar),
              label: const Text('Manage Schedule'),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 45),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeSlot(String title, String time, bool isActive) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: kPrimaryColor),
        borderRadius: BorderRadius.circular(8),
        color: isActive ? kPrimaryColor.withOpacity(0.1) : Colors.white,
      ),
      child: Column(
        children: [
          Text(title, style: AppFonts.bodyText2),
          Text(time,
              style: AppFonts.bodyText1.copyWith(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildConsultationSettings() {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Consultation Settings', style: AppFonts.headline4),
            const SizedBox(height: 16),
            _buildSettingItem(
              'Consultation Fee',
              '\$100',
              Icons.attach_money,
            ),
            _buildSettingItem(
              'Duration',
              '30 minutes',
              Icons.timer,
            ),
            _buildSettingItem(
              'Emergency Available',
              'Yes',
              Icons.emergency,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfessionalDetails() {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Professional Details', style: AppFonts.headline4),
            const SizedBox(height: 16),
            _buildDetailItem('Specialization', 'Cardiology'),
            _buildDetailItem('License No.', 'MD-12345'),
            _buildDetailItem('Hospital', 'City General Hospital'),
            _buildDetailItem('Languages', 'English, Spanish'),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.verified),
              label: const Text('View Credentials'),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(double.infinity, 45),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAccountSettings() {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        children: [
          _buildSettingTile(
            'Notifications',
            Icons.notifications_outlined,
            onTap: () {},
          ),
          _buildSettingTile(
            'Privacy & Security',
            Icons.security_outlined,
            onTap: () {},
          ),
          _buildSettingTile(
            'Help & Support',
            Icons.help_outline,
            onTap: () {},
          ),
          _buildSettingTile(
            'Terms & Conditions',
            Icons.description_outlined,
            onTap: () {},
          ),
          _buildSettingTile(
            'Logout',
            Icons.logout,
            isDestructive: true,
            onTap: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildSettingItem(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: kPrimaryColor),
          const SizedBox(width: 16),
          Expanded(
            child: Text(label, style: AppFonts.bodyText1),
          ),
          Text(value,
              style: AppFonts.bodyText1.copyWith(fontWeight: FontWeight.bold)),
          IconButton(
            icon: const Icon(Icons.edit, size: 20),
            onPressed: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildDetailItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: AppFonts.bodyText2),
          Text(value,
              style: AppFonts.bodyText1.copyWith(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildSettingTile(
    String title,
    IconData icon, {
    bool isDestructive = false,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: isDestructive ? Colors.red : null,
      ),
      title: Text(
        title,
        style: AppFonts.bodyText1.copyWith(
          color: isDestructive ? Colors.red : null,
        ),
      ),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }
}
