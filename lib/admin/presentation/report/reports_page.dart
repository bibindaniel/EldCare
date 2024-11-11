import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class ReportsAnalyticsPage extends StatefulWidget {
  const ReportsAnalyticsPage({super.key});

  @override
  State<ReportsAnalyticsPage> createState() => _ReportsAnalyticsPageState();
}

class _ReportsAnalyticsPageState extends State<ReportsAnalyticsPage> {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Reports & Analytics'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Overview'),
              Tab(text: 'User Analytics'),
              Tab(text: 'Order Analytics'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            OverviewTab(),
            UserAnalyticsTab(),
            OrderAnalyticsTab(),
          ],
        ),
      ),
    );
  }
}

class OverviewTab extends StatelessWidget {
  const OverviewTab({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStatisticsCards(),
          const SizedBox(height: 20),
          _buildRecentOrders(),
        ],
      ),
    );
  }

  Widget _buildStatisticsCards() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('users').snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final users = snapshot.data!.docs;
        int elderlyCount = 0;
        int pharmacistCount = 0;
        int deliveryCount = 0;

        for (var user in users) {
          final data = user.data() as Map<String, dynamic>;
          switch (data['role']) {
            case 1:
              elderlyCount++;
              break;
            case 4:
              pharmacistCount++;
              break;
            case 5:
              deliveryCount++;
              break;
          }
        }

        return Wrap(
          spacing: 16,
          runSpacing: 16,
          children: [
            _StatCard(
              title: 'Elderly Users',
              value: elderlyCount.toString(),
              icon: Icons.elderly,
              color: Colors.blue,
            ),
            _StatCard(
              title: 'Pharmacists',
              value: pharmacistCount.toString(),
              icon: Icons.medical_services,
              color: Colors.green,
            ),
            _StatCard(
              title: 'Delivery Staff',
              value: deliveryCount.toString(),
              icon: Icons.delivery_dining,
              color: Colors.orange,
            ),
          ],
        );
      },
    );
  }

  Widget _buildRecentOrders() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Recent Orders',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 300,
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('orders')
                    .orderBy('timestamp', descending: true)
                    .limit(5)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final orders = snapshot.data!.docs;
                  return ListView.builder(
                    itemCount: orders.length,
                    itemBuilder: (context, index) {
                      final order =
                          orders[index].data() as Map<String, dynamic>;
                      return ListTile(
                        title:
                            Text('Order #${orders[index].id.substring(0, 8)}'),
                        subtitle: Text(
                          DateFormat('MMM dd, yyyy HH:mm')
                              .format(order['timestamp'].toDate()),
                        ),
                        trailing: Text(
                          'Rs.${order['totalAmount']?.toString() ?? '0'}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class UserAnalyticsTab extends StatelessWidget {
  const UserAnalyticsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildUserGrowthChart(),
          const SizedBox(height: 20),
          _buildUserDistributionPie(),
        ],
      ),
    );
  }

  Widget _buildUserGrowthChart() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'User Growth',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 300,
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('users')
                    .orderBy('createdAt')
                    .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final users = snapshot.data!.docs;
                  final List<FlSpot> spots = [];
                  int userCount = 0;

                  for (var i = 0; i < users.length; i++) {
                    userCount++;
                    spots.add(FlSpot(i.toDouble(), userCount.toDouble()));
                  }

                  return LineChart(
                    LineChartData(
                      gridData: const FlGridData(show: true),
                      titlesData: const FlTitlesData(show: true),
                      borderData: FlBorderData(show: true),
                      lineBarsData: [
                        LineChartBarData(
                          spots: spots,
                          isCurved: true,
                          color: Colors.blue,
                          barWidth: 3,
                          dotData: const FlDotData(show: false),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUserDistributionPie() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'User Distribution',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 300,
              child: StreamBuilder<QuerySnapshot>(
                stream:
                    FirebaseFirestore.instance.collection('users').snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final users = snapshot.data!.docs;
                  int elderlyCount = 0;
                  int pharmacistCount = 0;
                  int deliveryCount = 0;

                  for (var user in users) {
                    final data = user.data() as Map<String, dynamic>;
                    switch (data['role']) {
                      case 1:
                        elderlyCount++;
                        break;
                      case 4:
                        pharmacistCount++;
                        break;
                      case 5:
                        deliveryCount++;
                        break;
                    }
                  }

                  return PieChart(
                    PieChartData(
                      sections: [
                        PieChartSectionData(
                          value: elderlyCount.toDouble(),
                          title: 'Elderly\n$elderlyCount',
                          color: Colors.blue,
                          radius: 100,
                        ),
                        PieChartSectionData(
                          value: pharmacistCount.toDouble(),
                          title: 'Pharmacist\n$pharmacistCount',
                          color: Colors.green,
                          radius: 100,
                        ),
                        PieChartSectionData(
                          value: deliveryCount.toDouble(),
                          title: 'Delivery\n$deliveryCount',
                          color: Colors.orange,
                          radius: 100,
                        ),
                      ],
                      sectionsSpace: 2,
                      centerSpaceRadius: 0,
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class OrderAnalyticsTab extends StatelessWidget {
  const OrderAnalyticsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildOrderTrendsChart(),
          const SizedBox(height: 20),
          _buildTopMedicines(),
        ],
      ),
    );
  }

  Widget _buildOrderTrendsChart() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Order Trends',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 300,
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('orders')
                    .orderBy('timestamp')
                    .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final orders = snapshot.data!.docs;
                  final Map<String, double> dailyTotals = {};

                  for (var order in orders) {
                    final data = order.data() as Map<String, dynamic>;
                    final date = DateFormat('MMM dd')
                        .format((data['timestamp'] as Timestamp).toDate());
                    dailyTotals[date] = (dailyTotals[date] ?? 0) +
                        (data['totalAmount'] ?? 0).toDouble();
                  }

                  final List<FlSpot> spots = [];
                  var index = 0;
                  dailyTotals.forEach((_, value) {
                    spots.add(FlSpot(index.toDouble(), value));
                    index++;
                  });

                  return LineChart(
                    LineChartData(
                      gridData: const FlGridData(show: true),
                      titlesData: const FlTitlesData(show: true),
                      borderData: FlBorderData(show: true),
                      lineBarsData: [
                        LineChartBarData(
                          spots: spots,
                          isCurved: true,
                          color: Colors.green,
                          barWidth: 3,
                          dotData: const FlDotData(show: true),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopMedicines() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Top Ordered Medicines',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 300,
              child: StreamBuilder<QuerySnapshot>(
                stream:
                    FirebaseFirestore.instance.collection('orders').snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final orders = snapshot.data!.docs;
                  final Map<String, int> medicineCount = {};

                  for (var order in orders) {
                    final data = order.data() as Map<String, dynamic>;
                    if (data['items'] != null) {
                      for (var item in (data['items'] as List)) {
                        final medicineName = item['medicineName'] as String;
                        medicineCount[medicineName] =
                            (medicineCount[medicineName] ?? 0) + 1;
                      }
                    }
                  }

                  final sortedMedicines = medicineCount.entries.toList()
                    ..sort((a, b) => b.value.compareTo(a.value));

                  return ListView.builder(
                    itemCount: sortedMedicines.length.clamp(0, 5),
                    itemBuilder: (context, index) {
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Colors.blue,
                          child: Text('${index + 1}'),
                        ),
                        title: Text(sortedMedicines[index].key),
                        trailing: Text(
                          '${sortedMedicines[index].value} orders',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.blue,
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Container(
        width: 160,
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 48, color: color),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              title,
              style: TextStyle(
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
