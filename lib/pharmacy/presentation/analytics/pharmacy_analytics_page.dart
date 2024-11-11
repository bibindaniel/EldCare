import 'package:eldcare/pharmacy/model/pharmacist_order.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eldcare/core/theme/colors.dart';
import 'package:eldcare/core/theme/font.dart';
import 'package:intl/intl.dart';

class PharmacyAnalyticsPage extends StatefulWidget {
  final String shopId;

  const PharmacyAnalyticsPage({super.key, required this.shopId});

  @override
  State<PharmacyAnalyticsPage> createState() => _PharmacyAnalyticsPageState();
}

class _PharmacyAnalyticsPageState extends State<PharmacyAnalyticsPage> {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.transparent,
          title: const Text(
            'Analytics Dashboard',
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
          bottom: TabBar(
            labelColor: kPrimaryColor,
            unselectedLabelColor: Colors.grey,
            indicatorColor: kPrimaryColor,
            indicatorWeight: 3,
            tabs: const [
              Tab(
                icon: Icon(Icons.dashboard_outlined),
                text: 'Overview',
              ),
              Tab(
                icon: Icon(Icons.trending_up_outlined),
                text: 'Sales',
              ),
              Tab(
                icon: Icon(Icons.inventory_2_outlined),
                text: 'Inventory',
              ),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _OverviewTab(shopId: widget.shopId),
            _SalesAnalyticsTab(shopId: widget.shopId),
            _InventoryAnalyticsTab(shopId: widget.shopId),
          ],
        ),
      ),
    );
  }
}

class _OverviewTab extends StatelessWidget {
  final String shopId;

  const _OverviewTab({required this.shopId});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildRevenueCard(),
          const SizedBox(height: 20),
          _buildOrdersStats(),
          const SizedBox(height: 20),
          _buildTopSellingMedicines(),
        ],
      ),
    );
  }

  Widget _buildRevenueCard() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('orders')
          .where('status',
              isEqualTo: OrderStatus.completed.toString().split('.').last)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        double totalRevenue = 0;
        for (var doc in snapshot.data!.docs) {
          final order = PharmacistOrderModel.fromFirestore(doc);
          totalRevenue += order.totalAmount;
        }

        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [kPrimaryColor, kPrimaryColor.withOpacity(0.8)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: kPrimaryColor.withOpacity(0.3),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.account_balance_wallet_outlined,
                      color: Colors.white, size: 28),
                  const SizedBox(width: 12),
                  Text('Total Revenue',
                      style: AppFonts.headline4.copyWith(color: Colors.white)),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                '₹${totalRevenue.toStringAsFixed(2)}',
                style: AppFonts.headline2.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildOrdersStats() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('orders').snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final orders = snapshot.data!.docs
            .map((doc) => PharmacistOrderModel.fromFirestore(doc))
            .toList();

        final completed =
            orders.where((o) => o.status == OrderStatus.completed).length;
        final pending =
            orders.where((o) => o.status == OrderStatus.pending).length;
        final cancelled =
            orders.where((o) => o.status == OrderStatus.cancelled).length;

        return Card(
          elevation: 4,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Orders Overview', style: AppFonts.headline4),
                const SizedBox(height: 16),
                Column(
                  children: [
                    _buildStatRow('Completed Orders', completed, kSuccessColor),
                    _buildStatRow('Pending Orders', pending, kWarningColor),
                    _buildStatRow('Cancelled Orders', cancelled, kErrorColor),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatRow(String title, int value, Color color) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.1),
            spreadRadius: 2,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(_getIconForStatus(title), color: color),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppFonts.bodyText1.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    value.toString(),
                    style: AppFonts.headline4.copyWith(
                      color: color,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getIconForStatus(String title) {
    switch (title) {
      case 'Completed Orders':
        return Icons.check_circle_outline;
      case 'Pending Orders':
        return Icons.pending_outlined;
      case 'Cancelled Orders':
        return Icons.cancel_outlined;
      default:
        return Icons.info_outline;
    }
  }

  Widget _buildTopSellingMedicines() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('orders')
          .where('status',
              isEqualTo: OrderStatus.completed.toString().split('.').last)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        // Create a map to store medicine sales data
        Map<String, MedicineSalesData> medicineStats = {};

        // Process all orders
        for (var doc in snapshot.data!.docs) {
          final order = PharmacistOrderModel.fromFirestore(doc);
          for (var item in order.items) {
            if (!medicineStats.containsKey(item.medicineId)) {
              medicineStats[item.medicineId] = MedicineSalesData(
                name: item.medicineName,
                totalQuantity: 0,
                totalRevenue: 0,
              );
            }
            medicineStats[item.medicineId]!.totalQuantity += item.quantity;
            medicineStats[item.medicineId]!.totalRevenue +=
                item.price * item.quantity;
          }
        }

        // Sort by revenue
        final sortedMedicines = medicineStats.values.toList()
          ..sort((a, b) => b.totalRevenue.compareTo(a.totalRevenue));

        // Take top 5
        final topMedicines = sortedMedicines.take(5).toList();

        return Card(
          elevation: 4,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Top Selling Medicines', style: AppFonts.headline4),
                const SizedBox(height: 16),
                ...topMedicines.map((medicine) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(medicine.name, style: AppFonts.bodyText1),
                                Text(
                                  'Sold: ${medicine.totalQuantity} units',
                                  style: AppFonts.caption,
                                ),
                              ],
                            ),
                          ),
                          Text(
                            '₹${medicine.totalRevenue.toStringAsFixed(2)}',
                            style: AppFonts.bodyText2.copyWith(
                              color: kPrimaryColor,
                            ),
                          ),
                        ],
                      ),
                    )),
              ],
            ),
          ),
        );
      },
    );
  }
}

// Helper class for medicine sales statistics
class MedicineSalesData {
  final String name;
  int totalQuantity;
  double totalRevenue;

  MedicineSalesData({
    required this.name,
    required this.totalQuantity,
    required this.totalRevenue,
  });
}

class _SalesAnalyticsTab extends StatelessWidget {
  final String shopId;

  const _SalesAnalyticsTab({required this.shopId});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildSalesChart(),
          const SizedBox(height: 20),
          _buildRevenueByCategory(),
        ],
      ),
    );
  }

  Widget _buildSalesChart() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('orders')
          .where('status', isEqualTo: 'completed')
          .orderBy('createdAt', descending: true)
          .limit(30)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        Map<String, double> dailySales = {};
        for (var doc in snapshot.data!.docs) {
          final data = doc.data() as Map<String, dynamic>;
          final date = DateFormat('MMM d')
              .format((data['createdAt'] as Timestamp).toDate());

          double orderTotal = 0;
          final items = List<Map<String, dynamic>>.from(data['items'] ?? []);
          for (var item in items) {
            final price = (item['price'] as num?)?.toDouble() ?? 0.0;
            final quantity = (item['quantity'] as num?)?.toInt() ?? 0;
            orderTotal += price * quantity;
          }

          dailySales[date] = (dailySales[date] ?? 0) + orderTotal;
        }

        if (dailySales.isEmpty) {
          return const Center(child: Text('No sales data available'));
        }

        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                spreadRadius: 2,
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Sales Trend', style: AppFonts.headline4),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: kPrimaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'Last 30 Days',
                      style: AppFonts.caption.copyWith(color: kPrimaryColor),
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: 200,
                child: LineChart(
                  LineChartData(
                    gridData: const FlGridData(show: false),
                    titlesData: FlTitlesData(
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 40,
                          getTitlesWidget: (value, meta) {
                            return Text('₹${value.toInt()}',
                                style: AppFonts.caption);
                          },
                        ),
                      ),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          getTitlesWidget: (value, meta) {
                            if (value.toInt() >= 0 &&
                                value.toInt() < dailySales.length) {
                              return Padding(
                                padding: const EdgeInsets.only(top: 8.0),
                                child: Text(
                                  dailySales.keys.elementAt(value.toInt()),
                                  style: AppFonts.caption,
                                ),
                              );
                            }
                            return const Text('');
                          },
                        ),
                      ),
                      rightTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      topTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                    ),
                    borderData: FlBorderData(show: true),
                    lineBarsData: [
                      LineChartBarData(
                        spots: dailySales.entries
                            .map((e) => FlSpot(
                                dailySales.keys
                                    .toList()
                                    .indexOf(e.key)
                                    .toDouble(),
                                e.value))
                            .toList(),
                        isCurved: true,
                        color: kPrimaryColor,
                        barWidth: 3,
                        dotData: const FlDotData(show: true),
                        belowBarData: BarAreaData(
                          show: true,
                          color: kPrimaryColor.withOpacity(0.1),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildRevenueByCategory() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('orders')
          .where('status', isEqualTo: 'completed')
          .orderBy('createdAt', descending: true)
          .limit(100)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        // Process orders to get revenue by category
        Map<String, double> categoryRevenue = {};
        double totalRevenue = 0;

        for (var doc in snapshot.data!.docs) {
          final order = PharmacistOrderModel.fromFirestore(doc);

          // Process each item in the order
          for (var item in order.items) {
            final itemRevenue = item.price * item.quantity;

            // Use a default category if none exists
            const category = 'Medicines'; // You can modify this as needed

            categoryRevenue[category] =
                (categoryRevenue[category] ?? 0) + itemRevenue;
            totalRevenue += itemRevenue;
          }
        }

        // Sort categories by revenue
        final sortedCategories = categoryRevenue.entries.toList()
          ..sort((a, b) => b.value.compareTo(a.value));

        if (sortedCategories.isEmpty) {
          return const Card(
            child: Padding(
              padding: EdgeInsets.all(16),
              child:
                  Text('No revenue data available', style: AppFonts.bodyText1),
            ),
          );
        }

        // Calculate percentages and prepare pie chart data
        final pieChartData = sortedCategories.map((entry) {
          final percentage = (entry.value / totalRevenue) * 100;
          return PieChartSectionData(
            value: entry.value,
            title: '${percentage.toStringAsFixed(1)}%',
            color: _getCategoryColor(sortedCategories.indexOf(entry)),
            radius: 100,
            titleStyle: AppFonts.caption.copyWith(color: Colors.white),
          );
        }).toList();

        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Revenue by Category', style: AppFonts.headline4),
                const SizedBox(height: 20),
                if (pieChartData.isNotEmpty) ...[
                  SizedBox(
                    height: 300,
                    child: PieChart(
                      PieChartData(
                        sections: pieChartData,
                        sectionsSpace: 2,
                        centerSpaceRadius: 40,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Category legend
                  ...sortedCategories.map((entry) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Row(
                          children: [
                            Container(
                              width: 16,
                              height: 16,
                              decoration: BoxDecoration(
                                color: _getCategoryColor(
                                    sortedCategories.indexOf(entry)),
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(entry.key, style: AppFonts.bodyText1),
                            ),
                            Text(
                              '₹${entry.value.toStringAsFixed(2)}',
                              style: AppFonts.bodyText2
                                  .copyWith(color: kPrimaryColor),
                            ),
                          ],
                        ),
                      )),
                ] else
                  const Center(
                    child: Text('No revenue data to display',
                        style: AppFonts.bodyText1),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Color _getCategoryColor(int index) {
    // Predefined colors for categories
    final colors = [
      const Color(0xFF2196F3), // Blue
      const Color(0xFF4CAF50), // Green
      const Color(0xFFFFC107), // Yellow
      const Color(0xFFE91E63), // Pink
      const Color(0xFF9C27B0), // Purple
      const Color(0xFF00BCD4), // Cyan
      const Color(0xFFFF5722), // Deep Orange
      const Color(0xFF795548), // Brown
      const Color(0xFF607D8B), // Blue Grey
      const Color(0xFF3F51B5), // Indigo
    ];

    return colors[index % colors.length];
  }
}

class _InventoryAnalyticsTab extends StatelessWidget {
  final String shopId;

  const _InventoryAnalyticsTab({required this.shopId});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildInventoryValue(),
          const SizedBox(height: 20),
          _buildLowStockAlert(),
          const SizedBox(height: 20),
          _buildExpiryAlert(),
        ],
      ),
    );
  }

  Widget _buildInventoryValue() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('inventory_batches')
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        double totalValue = 0;
        Map<String, double> categoryValues = {
          'General Medicines': 0.0, // Default category
        };

        for (var doc in snapshot.data!.docs) {
          try {
            final data = doc.data() as Map<String, dynamic>;
            final quantity = (data['quantity'] as num?)?.toInt() ?? 0;
            final price = (data['price'] as num?)?.toDouble() ?? 0.0;
            final value = quantity * price;

            totalValue += value;
            categoryValues['General Medicines'] =
                (categoryValues['General Medicines'] ?? 0) + value;
          } catch (e) {
            debugPrint('Error processing inventory item: $e');
            continue;
          }
        }

        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [kPrimaryColor, kPrimaryColor.withOpacity(0.8)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: kPrimaryColor.withOpacity(0.3),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.inventory, color: Colors.white, size: 28),
                  const SizedBox(width: 12),
                  Text('Total Inventory Value',
                      style: AppFonts.headline4.copyWith(color: Colors.white)),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                '₹${totalValue.toStringAsFixed(2)}',
                style: AppFonts.headline2.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (categoryValues.isNotEmpty) ...[
                const SizedBox(height: 24),
                const Divider(color: Colors.white24, thickness: 1),
                const SizedBox(height: 16),
                ...categoryValues.entries
                    .where((entry) => entry.value > 0)
                    .map((entry) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(entry.key,
                                  style: AppFonts.bodyText1
                                      .copyWith(color: Colors.white70)),
                              Text(
                                '₹${entry.value.toStringAsFixed(2)}',
                                style: AppFonts.bodyText1
                                    .copyWith(color: Colors.white),
                              ),
                            ],
                          ),
                        )),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildLowStockAlert() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('inventory_batches')
          .where('quantity', isLessThan: 10)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final lowStockItems = snapshot.data!.docs;

        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                spreadRadius: 2,
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: kWarningColor.withOpacity(0.1),
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(16)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.warning_amber_rounded,
                        color: kWarningColor, size: 24),
                    const SizedBox(width: 12),
                    Text('Low Stock Alert',
                        style:
                            AppFonts.headline4.copyWith(color: kWarningColor)),
                  ],
                ),
              ),
              if (lowStockItems.isEmpty)
                const Padding(
                  padding: EdgeInsets.all(16),
                  child: Text('No items running low on stock',
                      style: AppFonts.bodyText1),
                )
              else
                ...lowStockItems.map((item) => Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        border: Border(
                          bottom:
                              BorderSide(color: Colors.grey.withOpacity(0.1)),
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: kWarningColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              '${item['quantity']}',
                              style: AppFonts.bodyText1.copyWith(
                                color: kWarningColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(item['medicineName'] ?? '',
                                    style: AppFonts.bodyText1),
                                const SizedBox(height: 4),
                                Text('Batch: ${item['lotNumber'] ?? 'N/A'}',
                                    style: AppFonts.caption),
                              ],
                            ),
                          ),
                        ],
                      ),
                    )),
            ],
          ),
        );
      },
    );
  }

  Widget _buildExpiryAlert() {
    final now = DateTime.now();
    final threeMonthsFromNow = now.add(const Duration(days: 90));

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('inventory_batches')
          .where('expiryDate',
              isLessThan: Timestamp.fromDate(threeMonthsFromNow))
          .orderBy('expiryDate')
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final expiringItems = snapshot.data!.docs.where((doc) {
          final expiryDate = (doc['expiryDate'] as Timestamp).toDate();
          return expiryDate.isAfter(now);
        }).toList();

        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                spreadRadius: 2,
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: kErrorColor.withOpacity(0.1),
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(16)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.event_busy, color: kErrorColor, size: 24),
                    const SizedBox(width: 12),
                    Text('Expiring Soon',
                        style: AppFonts.headline4.copyWith(color: kErrorColor)),
                  ],
                ),
              ),
              if (expiringItems.isEmpty)
                const Padding(
                  padding: EdgeInsets.all(16),
                  child:
                      Text('No items expiring soon', style: AppFonts.bodyText1),
                )
              else
                ...expiringItems.map((item) {
                  final expiryDate = (item['expiryDate'] as Timestamp).toDate();
                  final daysUntilExpiry = expiryDate.difference(now).inDays;
                  final isUrgent = daysUntilExpiry < 30;
                  final statusColor = isUrgent ? kErrorColor : kWarningColor;

                  return Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(color: Colors.grey.withOpacity(0.1)),
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: statusColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Text(
                            '$daysUntilExpiry days',
                            style: AppFonts.caption.copyWith(
                              color: statusColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(item['medicineName'] ?? '',
                                  style: AppFonts.bodyText1),
                              const SizedBox(height: 4),
                              Text('Batch: ${item['lotNumber'] ?? 'N/A'}',
                                  style: AppFonts.caption),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                }),
            ],
          ),
        );
      },
    );
  }
}
