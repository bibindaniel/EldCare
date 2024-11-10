import 'package:flutter/material.dart';
import 'package:eldcare/admin/presentation/adminstyles/adminstyles.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

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
          _buildNotifications(),
        ],
      ),
    );
  }

  Widget _buildOverviewCards() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('users').snapshots(),
      builder: (context, userSnapshot) {
        int totalUsers =
            userSnapshot.hasData ? userSnapshot.data!.docs.length : 0;

        return StreamBuilder<QuerySnapshot>(
          stream:
              FirebaseFirestore.instance.collection('medicines').snapshots(),
          builder: (context, medicineSnapshot) {
            int totalMedicines = medicineSnapshot.hasData
                ? medicineSnapshot.data!.docs.length
                : 0;

            return StreamBuilder<QuerySnapshot>(
              stream:
                  FirebaseFirestore.instance.collection('orders').snapshots(),
              builder: (context, orderSnapshot) {
                int totalOrders =
                    orderSnapshot.hasData ? orderSnapshot.data!.docs.length : 0;

                int pendingOrders = orderSnapshot.hasData
                    ? orderSnapshot.data!.docs
                        .where((doc) => doc['status'] == 'pending')
                        .length
                    : 0;

                return GridView.count(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  children: [
                    _buildOverviewCard('Total Users', totalUsers.toString(),
                        Icons.people, Colors.blue),
                    _buildOverviewCard(
                        'Total Medicines',
                        totalMedicines.toString(),
                        Icons.medication,
                        Colors.green),
                    _buildOverviewCard('Total Orders', totalOrders.toString(),
                        Icons.shopping_cart, Colors.orange),
                    _buildOverviewCard('Pending Orders',
                        pendingOrders.toString(), Icons.pending, Colors.red),
                  ],
                );
              },
            );
          },
        );
      },
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
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('orders')
                  .orderBy('createdAt', descending: false)
                  .limitToLast(30)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                if (snapshot.data!.docs.isEmpty) {
                  return const Center(
                    child: Text('No order data available'),
                  );
                }

                Map<DateTime, double> revenueByDate = {};
                for (var doc in snapshot.data!.docs) {
                  final date = (doc['createdAt'] as Timestamp).toDate();
                  final dateOnly = DateTime(date.year, date.month, date.day);
                  final totalAmount = doc['totalAmount'] as double;
                  revenueByDate[dateOnly] =
                      (revenueByDate[dateOnly] ?? 0) + totalAmount;
                }

                List<BarChartGroupData> barGroups =
                    revenueByDate.entries.map((entry) {
                  final date = entry.key;
                  final revenue = entry.value;
                  return BarChartGroupData(
                    x: date.day,
                    barRods: [
                      BarChartRodData(
                        toY: revenue,
                        color: AdminStyles.primaryColor,
                        width: 16,
                      ),
                    ],
                  );
                }).toList();

                return SizedBox(
                  height: 300,
                  child: BarChart(
                    BarChartData(
                      barGroups: barGroups,
                      titlesData: FlTitlesData(
                        show: true,
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (value, meta) {
                              final date = DateTime.now()
                                  .subtract(Duration(days: 30 - value.toInt()));
                              return Text(
                                '${date.day}/${date.month}',
                                style: const TextStyle(fontSize: 10),
                              );
                            },
                          ),
                        ),
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (value, meta) {
                              return Text(
                                NumberFormat.compactCurrency(
                                  locale: 'en_IN',
                                  symbol: '₹',
                                  decimalDigits: 0,
                                ).format(value),
                                style: const TextStyle(fontSize: 10),
                              );
                            },
                          ),
                        ),
                      ),
                      gridData: const FlGridData(show: true),
                      borderData: FlBorderData(show: true),
                    ),
                  ),
                );
              },
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
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('orders')
                  .orderBy('createdAt', descending: true)
                  .limit(5)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                return Column(
                  children: snapshot.data!.docs.map((doc) {
                    double totalAmount = doc['totalAmount'];
                    DateTime createdAt =
                        (doc['createdAt'] as Timestamp).toDate();
                    String formattedTime =
                        DateFormat.yMd().add_jm().format(createdAt);

                    // Format the amount with Indian Rupee symbol
                    String formattedAmount = NumberFormat.currency(
                      locale: 'en_IN',
                      symbol: '₹',
                      decimalDigits: 2,
                    ).format(totalAmount);

                    return _buildActivityItem(
                      Icons.shopping_cart,
                      'Order Total: $formattedAmount',
                      formattedTime,
                    );
                  }).toList(),
                );
              },
            ),
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
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('notifications')
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                return Column(
                  children: snapshot.data!.docs.map((doc) {
                    return _buildNotificationItem(
                      doc['message'],
                      Icons.notifications,
                    );
                  }).toList(),
                );
              },
            ),
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
