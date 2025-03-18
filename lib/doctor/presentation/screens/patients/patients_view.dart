import 'package:flutter/material.dart';
import 'package:eldcare/core/theme/font.dart';

class PatientsView extends StatefulWidget {
  const PatientsView({super.key});

  @override
  State<PatientsView> createState() => _PatientsViewState();
}

class _PatientsViewState extends State<PatientsView> {
  final TextEditingController _searchController = TextEditingController();

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
                  trailing: [
                    IconButton(
                      icon: const Icon(Icons.filter_list),
                      onPressed: () {},
                    ),
                  ],
                ),
              ),
            ),
          ),
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
                  Text('Patient List', style: AppFonts.headline4),
                  TextButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.sort),
                    label: const Text('Sort'),
                  ),
                ],
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) => _buildPatientCard(),
                childCount: 10,
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        child: const Icon(Icons.person_add),
      ),
    );
  }

  Widget _buildPatientStats() {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            'Total',
            '124',
            'Patients',
            Colors.blue,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            'New',
            '8',
            'This Month',
            Colors.green,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            'Active',
            '45',
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

  Widget _buildPatientCard() {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: const CircleAvatar(
          radius: 30,
          child: Icon(Icons.person, size: 30),
        ),
        title: Row(
          children: [
            Text('Sarah Johnson',
                style:
                    AppFonts.bodyText1.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                'Active',
                style: AppFonts.bodyText2.copyWith(color: Colors.green),
              ),
            ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            Text('Age: 45 • Female', style: AppFonts.bodyText2),
            Text('Last Visit: 2 days ago', style: AppFonts.bodyText2),
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
        ),
      ),
    );
  }
}
