import 'package:eldcare/admin/blocs/users/users_bloc.dart';
import 'package:eldcare/elduser/models/user_profile.dart';
import 'package:eldcare/pharmacy/model/pharmacist.dart';
import 'package:eldcare/pharmacy/model/shop.dart';
import 'package:flutter/material.dart';
import 'package:eldcare/admin/presentation/adminstyles/adminstyles.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class UsersTableWidget extends StatefulWidget {
  final List<UserProfile> elderlyUsers;
  final List<PharmacistProfile> pharmacists;

  const UsersTableWidget({
    super.key,
    required this.elderlyUsers,
    required this.pharmacists,
  });

  @override
  UsersTableWidgetState createState() => UsersTableWidgetState();
}

class UsersTableWidgetState extends State<UsersTableWidget> {
  int _rowsPerPage = 5; // Set initial rows per page to 5
  int _rowsPerPagePharmacist = 5; // Set initial rows per page to 5

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Text('Elderly Users', style: AdminStyles.subHeaderStyle),
        Card(
          elevation: 4,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          child: PaginatedDataTable(
            header:
                const Text('Elderly Users', style: AdminStyles.subHeaderStyle),
            columns: const [
              DataColumn(
                  label: Text('Name', style: AdminStyles.subHeaderStyle)),
              DataColumn(
                  label: Text('Email', style: AdminStyles.subHeaderStyle)),
              DataColumn(
                  label: Text('Phone', style: AdminStyles.subHeaderStyle)),
              DataColumn(
                  label: Text('Address', style: AdminStyles.subHeaderStyle)),
              DataColumn(
                  label: Text('Verified', style: AdminStyles.subHeaderStyle)),
            ],
            source: UserDataTableSource(widget.elderlyUsers),
            rowsPerPage: _rowsPerPage,
            availableRowsPerPage: const [
              5,
              10,
              15,
              20
            ], // Add 5 to available rows per page
            onRowsPerPageChanged: (rowsPerPage) {
              setState(() {
                _rowsPerPage = rowsPerPage!;
              });
            },
          ),
        ),
        const SizedBox(height: 20),
        const Text('Pharmacists', style: AdminStyles.subHeaderStyle),
        Card(
          elevation: 4,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          child: PaginatedDataTable(
            header:
                const Text('Pharmacists', style: AdminStyles.subHeaderStyle),
            columns: const [
              DataColumn(
                  label: Text('Name', style: AdminStyles.subHeaderStyle)),
              DataColumn(
                  label: Text('Email', style: AdminStyles.subHeaderStyle)),
              DataColumn(
                  label: Text('Phone', style: AdminStyles.subHeaderStyle)),
              DataColumn(
                  label: Text('License Number',
                      style: AdminStyles.subHeaderStyle)),
              DataColumn(
                  label: Text('Verified', style: AdminStyles.subHeaderStyle)),
            ],
            source: PharmacistDataTableSource(widget.pharmacists),
            rowsPerPage: _rowsPerPagePharmacist,
            availableRowsPerPage: const [
              5,
              10,
              15,
              20
            ], // Add 5 to available rows per page
            onRowsPerPageChanged: (rowsPerPage) {
              setState(() {
                _rowsPerPagePharmacist = rowsPerPage!;
              });
            },
          ),
        ),
      ],
    );
  }
}

class UserDataTableSource extends DataTableSource {
  final List<UserProfile> users;

  UserDataTableSource(this.users);

  @override
  DataRow getRow(int index) {
    final user = users[index];
    return DataRow(cells: [
      DataCell(Text(user.name ?? '', style: AdminStyles.bodyStyle)),
      DataCell(Text(user.email ?? '', style: AdminStyles.bodyStyle)),
      DataCell(Text(user.phone ?? '', style: AdminStyles.bodyStyle)),
      DataCell(Text('${user.houseName ?? ''}, ${user.city ?? ''}',
          style: AdminStyles.bodyStyle)),
      DataCell(
          Text(user.isVerified ? 'Yes' : 'No', style: AdminStyles.bodyStyle)),
    ]);
  }

  @override
  bool get isRowCountApproximate => false;
  @override
  int get rowCount => users.length;
  @override
  int get selectedRowCount => 0;
}

class PharmacistDataTableSource extends DataTableSource {
  final List<PharmacistProfile> pharmacists;

  PharmacistDataTableSource(this.pharmacists);

  @override
  DataRow getRow(int index) {
    final pharmacist = pharmacists[index];
    return DataRow(cells: [
      DataCell(Text(pharmacist.name ?? '', style: AdminStyles.bodyStyle)),
      DataCell(Text(pharmacist.email ?? '', style: AdminStyles.bodyStyle)),
      DataCell(Text(pharmacist.phone ?? '', style: AdminStyles.bodyStyle)),
      DataCell(
          Text(pharmacist.licenseNumber ?? '', style: AdminStyles.bodyStyle)),
      DataCell(Text(pharmacist.isVerified ? 'Yes' : 'No',
          style: AdminStyles.bodyStyle)),
    ]);
  }

  @override
  bool get isRowCountApproximate => false;
  @override
  int get rowCount => pharmacists.length;
  @override
  int get selectedRowCount => 0;
}

class ShopDataTableSource extends DataTableSource {
  final List<Shop> shops;
  final BuildContext context;
  final UserBloc userBloc;

  ShopDataTableSource(this.shops, this.context)
      : userBloc = context.read<UserBloc>();

  @override
  DataRow? getRow(int index) {
    if (index >= shops.length) return null;
    final shop = shops[index];
    return DataRow(
      cells: [
        DataCell(Text(shop.name)),
        DataCell(
          FutureBuilder<UserProfile?>(
            future: userBloc.getUserDetails(shop.ownerId),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const CircularProgressIndicator();
              }
              if (snapshot.hasData && snapshot.data != null) {
                return Text(snapshot.data!.name ?? 'N/A');
              }
              return Text(shop.ownerId);
            },
          ),
        ),
        DataCell(Text(shop.address)),
        DataCell(Text(shop.phoneNumber)),
        DataCell(Text(shop.licenseNumber)),
      ],
    );
  }

  @override
  bool get isRowCountApproximate => false;

  @override
  int get rowCount => shops.length;

  @override
  int get selectedRowCount => 0;
}
