import 'package:eldcare/auth/presentation/blocs/auth/auth_bloc.dart';
import 'package:eldcare/auth/presentation/blocs/auth/auth_state.dart';
import 'package:eldcare/core/theme/colors.dart';
import 'package:eldcare/core/theme/font.dart';
import 'package:eldcare/delivery/blocs/delivery_order/delivery_order_bloc.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  AnalyticsScreenState createState() => AnalyticsScreenState();
}

class AnalyticsScreenState extends State<AnalyticsScreen> {
  @override
  void initState() {
    super.initState();
    _fetchAnalytics();
  }

  void _fetchAnalytics() {
    final authState = context.read<AuthBloc>().state;
    if (authState is Authenticated) {
      context
          .read<DeliveryOrderBloc>()
          .add(FetchDeliverySummary(authState.user.uid));
      // Add more events to fetch other analytics data
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Analytics', style: AppFonts.headline4Light),
        backgroundColor: kPrimaryColor,
      ),
      body: RefreshIndicator(
        onRefresh: () async => _fetchAnalytics(),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildDeliverySummary(),
                const SizedBox(height: 24),
                _buildEarningsChart(),
                const SizedBox(height: 24),
                _buildDeliveryPerformance(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDeliverySummary() {
    return BlocBuilder<DeliveryOrderBloc, DeliveryOrderState>(
      builder: (context, state) {
        if (state is DeliveryOrderLoaded) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Delivery Summary', style: AppFonts.headline5),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildSummaryCard('Total', state.summary['total'].toString()),
                  _buildSummaryCard(
                      'Completed', state.summary['completed'].toString()),
                  _buildSummaryCard(
                      'Pending', state.summary['pending'].toString()),
                ],
              ),
            ],
          );
        } else if (state is DeliveryOrderLoading) {
          return const Center(child: CircularProgressIndicator());
        } else {
          return const Text('Unable to load summary');
        }
      },
    );
  }

  Widget _buildSummaryCard(String title, String value) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(title, style: AppFonts.bodyText2),
            const SizedBox(height: 8),
            Text(value,
                style: AppFonts.headline4.copyWith(color: kPrimaryColor)),
          ],
        ),
      ),
    );
  }

  Widget _buildEarningsChart() {
    // This is a placeholder. You'll need to implement actual data fetching and processing
    final List<FlSpot> spots = [
      FlSpot(0, 3),
      FlSpot(1, 1),
      FlSpot(2, 4),
      FlSpot(3, 2),
      FlSpot(4, 5),
      FlSpot(5, 3),
      FlSpot(6, 4),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Weekly Earnings', style: AppFonts.headline5),
        const SizedBox(height: 16),
        SizedBox(
          height: 200,
          child: LineChart(
            LineChartData(
              gridData: FlGridData(show: false),
              titlesData: FlTitlesData(show: false),
              borderData: FlBorderData(show: false),
              minX: 0,
              maxX: 6,
              minY: 0,
              maxY: 6,
              lineBarsData: [
                LineChartBarData(
                  spots: spots,
                  isCurved: true,
                  color: kPrimaryColor,
                  barWidth: 3,
                  isStrokeCapRound: true,
                  dotData: FlDotData(show: false),
                  belowBarData: BarAreaData(show: false),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDeliveryPerformance() {
    // This is a placeholder. You'll need to implement actual data fetching and processing
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Delivery Performance', style: AppFonts.headline5),
        const SizedBox(height: 16),
        ListTile(
          title: Text('On-Time Delivery Rate', style: AppFonts.bodyText1),
          trailing: Text('95%',
              style: AppFonts.bodyText1.copyWith(color: kSuccessColor)),
        ),
        ListTile(
          title: Text('Average Delivery Time', style: AppFonts.bodyText1),
          trailing: Text('28 mins', style: AppFonts.bodyText1),
        ),
        // ListTile(
        //   title: Text('Customer Rating', style: AppFonts.bodyText1),
        //   trailing: Row(
        //     mainAxisSize: MainAxisSize.min,
        //     children: [
        //       Icon(Icons.star, color: Colors.amber),
        //       Text('4.8', style: AppFonts.bodyText1),
        //     ],
        //   ),
        // ),
      ],
    );
  }
}
