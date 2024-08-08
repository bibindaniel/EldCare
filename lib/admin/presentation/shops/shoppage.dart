import 'package:eldcare/admin/presentation/shops/shop_details.dart';
import 'package:eldcare/admin/presentation/users/datatables.dart';
import 'package:eldcare/pharmacy/model/shop.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:eldcare/admin/blocs/shop/shop_bloc.dart';
import 'package:eldcare/admin/presentation/adminstyles/adminstyles.dart';

class ShopsPage extends StatelessWidget {
  const ShopsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AdminShopBloc, AdminShopState>(
      builder: (context, state) {
        if (state is AdminShopLoading) {
          return const Center(child: CircularProgressIndicator());
        } else if (state is AdminShopError) {
          return Center(child: Text('Error: ${state.message}'));
        } else if (state is AdminShopLoaded) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Shops Management', style: AdminStyles.headerStyle),
                const SizedBox(height: 20),
                _buildShopsTable(state.shops, context),
                const SizedBox(height: 20),
                _buildPendingApprovals(state.pendingShops, context),
                const SizedBox(height: 20),
                _buildShopStatistics(state.shops, state.pendingShops),
              ],
            ),
          );
        } else {
          return const Center(child: Text('No data available'));
        }
      },
    );
  }

  Widget _buildShopsTable(List<Shop> shops, BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: PaginatedDataTable(
        header: const Text('Verified Shops', style: AdminStyles.subHeaderStyle),
        columns: const [
          DataColumn(label: Text('Name', style: AdminStyles.subHeaderStyle)),
          DataColumn(label: Text('Owner', style: AdminStyles.subHeaderStyle)),
          DataColumn(label: Text('Address', style: AdminStyles.subHeaderStyle)),
          DataColumn(label: Text('Phone', style: AdminStyles.subHeaderStyle)),
          DataColumn(label: Text('License', style: AdminStyles.subHeaderStyle)),
        ],
        source: ShopDataTableSource(shops, context),
        rowsPerPage: 5,
      ),
    );
  }

  Widget _buildPendingApprovals(List<Shop> pendingShops, BuildContext context) {
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
            for (var shop in pendingShops) _buildApprovalItem(shop, context),
          ],
        ),
      ),
    );
  }

  Widget _buildApprovalItem(Shop shop, BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ShopDetailPage(shop: shop),
            ),
          );
        },
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(shop.name, style: AdminStyles.bodyStyle),
                  Text(shop.email, style: AdminStyles.captionStyle),
                  Text('License: ${shop.licenseNumber}',
                      style: AdminStyles.captionStyle),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.check_circle, color: Colors.green),
              onPressed: () {
                context
                    .read<AdminShopBloc>()
                    .add(AdminApproveShop(shop.id, shop));
              },
              tooltip: 'Approve',
            ),
            IconButton(
              icon: const Icon(Icons.cancel, color: Colors.red),
              onPressed: () {
                context
                    .read<AdminShopBloc>()
                    .add(AdminRejectShop(shop.id, shop));
              },
              tooltip: 'Reject',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildShopStatistics(List<Shop> shops, List<Shop> pendingShops) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Shop Statistics', style: AdminStyles.subHeaderStyle),
            const SizedBox(height: 16),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildStatCard(
                      'Total Shops',
                      '${shops.length + pendingShops.length}',
                      Icons.store,
                      Colors.blue),
                  _buildStatCard('Verified Shops', '${shops.length}',
                      Icons.verified, Colors.green),
                  _buildStatCard('Pending Shops', '${pendingShops.length}',
                      Icons.pending, Colors.orange),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(
      String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 32, color: color),
            const SizedBox(height: 8),
            Text(value,
                style: TextStyle(
                    fontSize: 24, fontWeight: FontWeight.bold, color: color)),
            Text(title, style: AdminStyles.captionStyle),
          ],
        ),
      ),
    );
  }
}
