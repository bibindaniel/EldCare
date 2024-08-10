import 'package:eldcare/pharmacy/blocs/inventory/inventory_bloc.dart';
import 'package:eldcare/pharmacy/blocs/inventory/inventory_event.dart';
import 'package:eldcare/pharmacy/blocs/inventory/inventory_state.dart';
import 'package:eldcare/pharmacy/blocs/medicine_name/medicine_name_bloc.dart';
import 'package:eldcare/pharmacy/blocs/medicine_name/medicine_name_state.dart';
import 'package:eldcare/pharmacy/model/inventory_batch.dart';
import 'package:eldcare/pharmacy/model/medicine.dart';
import 'package:eldcare/pharmacy/model/shop.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:eldcare/core/theme/colors.dart';
import 'package:eldcare/core/theme/font.dart';
import 'package:intl/intl.dart';

class InventoryManagementPage extends StatefulWidget {
  final Shop shop;

  const InventoryManagementPage({super.key, required this.shop});

  @override
  InventoryManagementPageState createState() => InventoryManagementPageState();
}

class InventoryManagementPageState extends State<InventoryManagementPage> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
    context.read<InventoryBloc>().add(LoadInventory(widget.shop.id));
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    final query = _searchController.text;
    context.read<InventoryBloc>().add(SearchInventory(query, widget.shop.id));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:
            Text('Inventory - ${widget.shop.name}', style: AppFonts.headline3),
        backgroundColor: kPrimaryColor,
      ),
      body: SingleChildScrollView(
        child: Container(
          color: kPrimaryColor,
          child: Column(
            children: [
              const SizedBox(height: 20),
              _buildTopSection(context),
              const SizedBox(height: 30),
              _buildBottomSection(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopSection(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            foregroundColor: kPrimaryColor,
            backgroundColor: kWhiteColor,
            padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
          ),
          onPressed: () => _showAddBatchDialog(context),
          child: const Text('Add Batch', style: TextStyle(fontSize: 18)),
        ),
      ],
    );
  }

  Widget _buildBottomSection(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: kWhiteColor,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            spreadRadius: 5,
            blurRadius: 7,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: Column(
        children: [
          const SizedBox(height: 20),
          _buildSearchField(),
          BlocBuilder<InventoryBloc, InventoryState>(
            builder: (context, state) {
              if (state is InventoryInitial) {
                return const Center(child: Text('Initializing...'));
              } else if (state is InventoryLoading) {
                return const Center(child: CircularProgressIndicator());
              } else if (state is InventoryLoaded) {
                return state.batches.isEmpty
                    ? const Center(child: Text('No inventory items found'))
                    : _buildInventoryList(context, state.batches);
              } else if (state is InventoryError) {
                return Center(child: Text('Error: ${state.message}'));
              } else {
                return const Center(child: Text('Unknown state'));
              }
            },
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildSearchField() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Search inventory',
          prefixIcon: const Icon(Icons.search),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        ),
        onChanged: (value) {
          if (value.isEmpty) {
            context.read<InventoryBloc>().add(LoadInventory(widget.shop.id));
          } else {
            context
                .read<InventoryBloc>()
                .add(SearchInventory(value, widget.shop.id));
          }
        },
      ),
    );
  }

  Widget _buildInventoryList(
      BuildContext context, List<InventoryBatch> batches) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: batches.length,
      itemBuilder: (context, index) {
        final batch = batches[index];
        return Card(
          elevation: 3,
          margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: ExpansionTile(
            tilePadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            childrenPadding: const EdgeInsets.all(16),
            leading: const CircleAvatar(
              backgroundColor: kPrimaryColor,
              child: Icon(Icons.medical_services, color: Colors.white),
            ),
            title: BlocBuilder<MedicineNameBloc, MedicineNameState>(
              builder: (context, state) {
                if (state is MedicineLoaded) {
                  final medicine = state.medicines.firstWhere(
                    (m) => m.id == batch.medicineId,
                    orElse: () => Medicine(
                      id: '',
                      name: 'Unknown Medicine',
                      categoryId: '',
                      dosage: 'Unknown',
                    ),
                  );
                  return Text(medicine.name, style: AppFonts.headline4Dark);
                }
                return const Text('Loading...', style: AppFonts.headline4Dark);
              },
            ),
            subtitle: Text(
              'Quantity: ${batch.quantity} • Expiry: ${DateFormat('MMM d, y').format(batch.expiryDate)}',
              style: AppFonts.bodyText2,
            ),
            trailing: Text(
              '₹${batch.price.toStringAsFixed(2)}',
              style: AppFonts.headline4Dark.copyWith(color: kPrimaryColor),
            ),
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildInfoRow('Supplier', batch.supplier),
                        _buildInfoRow('Lot Number', batch.lotNumber),
                      ],
                    ),
                  ),
                  Column(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: kPrimaryColor),
                        onPressed: () => _showEditBatchDialog(context, batch),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () =>
                            _showDeleteConfirmationDialog(context, batch),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: AppFonts.bodyText2.copyWith(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: AppFonts.bodyText2,
            ),
          ),
        ],
      ),
    );
  }

  void _showAddBatchDialog(BuildContext context) {
    final formKey = GlobalKey<FormState>();
    Medicine? selectedMedicine;
    int quantity = 0;
    DateTime expiryDate = DateTime.now();
    String supplier = '';
    String lotNumber = '';
    double price = 0.0;
    final TextEditingController dateController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Add New Batch', style: AppFonts.headline3Dark),
          content: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  BlocBuilder<MedicineNameBloc, MedicineNameState>(
                    builder: (context, state) {
                      if (state is MedicineLoaded) {
                        return DropdownButtonFormField<Medicine>(
                          value: selectedMedicine,
                          decoration:
                              const InputDecoration(labelText: 'Medicine'),
                          items: state.medicines.map((Medicine medicine) {
                            return DropdownMenuItem<Medicine>(
                              value: medicine,
                              child: Text(medicine.name),
                            );
                          }).toList(),
                          onChanged: (Medicine? newValue) {
                            selectedMedicine = newValue;
                          },
                          validator: (value) =>
                              value == null ? 'Please select a medicine' : null,
                        );
                      } else {
                        return const CircularProgressIndicator();
                      }
                    },
                  ),
                  TextFormField(
                    decoration: const InputDecoration(labelText: 'Quantity'),
                    keyboardType: TextInputType.number,
                    validator: (value) =>
                        value!.isEmpty ? 'Please enter quantity' : null,
                    onSaved: (value) => quantity = int.parse(value!),
                  ),
                  TextFormField(
                    controller: dateController,
                    decoration: const InputDecoration(labelText: 'Expiry Date'),
                    readOnly: true,
                    onTap: () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: expiryDate,
                        firstDate: DateTime.now(),
                        lastDate:
                            DateTime.now().add(const Duration(days: 365 * 5)),
                      );
                      if (date != null) {
                        expiryDate = date;
                        dateController.text =
                            DateFormat('yyyy-MM-dd').format(date);
                      }
                    },
                    validator: (value) =>
                        value!.isEmpty ? 'Please select expiry date' : null,
                  ),
                  TextFormField(
                    decoration: const InputDecoration(labelText: 'Supplier'),
                    validator: (value) =>
                        value!.isEmpty ? 'Please enter supplier' : null,
                    onSaved: (value) => supplier = value!,
                  ),
                  TextFormField(
                    decoration: const InputDecoration(labelText: 'Lot Number'),
                    validator: (value) =>
                        value!.isEmpty ? 'Please enter lot number' : null,
                    onSaved: (value) => lotNumber = value!,
                  ),
                  TextFormField(
                    decoration: const InputDecoration(labelText: 'Price'),
                    keyboardType: TextInputType.number,
                    validator: (value) =>
                        value!.isEmpty ? 'Please enter price' : null,
                    onSaved: (value) => price = double.parse(value!),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel', style: TextStyle(color: Colors.red)),
            ),
            TextButton(
              onPressed: () {
                if (formKey.currentState!.validate()) {
                  formKey.currentState!.save();
                  final newBatch = InventoryBatch(
                    id: '',
                    shopId: widget.shop.id,
                    medicineId: selectedMedicine!.id,
                    quantity: quantity,
                    expiryDate: expiryDate,
                    supplier: supplier,
                    lotNumber: lotNumber,
                    price: price,
                  );
                  context
                      .read<InventoryBloc>()
                      .add(AddInventoryBatch(newBatch));
                  Navigator.of(context).pop();
                }
              },
              child: const Text('Add', style: TextStyle(color: kPrimaryColor)),
            ),
          ],
        );
      },
    );
  }

  void _showEditBatchDialog(BuildContext context, InventoryBatch batch) {
    final formKey = GlobalKey<FormState>();
    Medicine? selectedMedicine;
    int quantity = batch.quantity;
    DateTime expiryDate = batch.expiryDate;
    String supplier = batch.supplier;
    String lotNumber = batch.lotNumber;
    double price = batch.price;
    final TextEditingController dateController = TextEditingController(
      text: DateFormat('yyyy-MM-dd').format(batch.expiryDate),
    );

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Edit Batch', style: AppFonts.headline3Dark),
          content: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  BlocBuilder<MedicineNameBloc, MedicineNameState>(
                    builder: (context, state) {
                      if (state is MedicineLoaded) {
                        selectedMedicine = state.medicines
                            .firstWhere((m) => m.id == batch.medicineId);
                        return DropdownButtonFormField<Medicine>(
                          value: selectedMedicine,
                          decoration:
                              const InputDecoration(labelText: 'Medicine'),
                          items: state.medicines.map((Medicine medicine) {
                            return DropdownMenuItem<Medicine>(
                              value: medicine,
                              child: Text(medicine.name),
                            );
                          }).toList(),
                          onChanged: (Medicine? newValue) {
                            selectedMedicine = newValue;
                          },
                          validator: (value) =>
                              value == null ? 'Please select a medicine' : null,
                        );
                      } else {
                        return const CircularProgressIndicator();
                      }
                    },
                  ),
                  TextFormField(
                    initialValue: batch.quantity.toString(),
                    decoration: const InputDecoration(labelText: 'Quantity'),
                    keyboardType: TextInputType.number,
                    validator: (value) =>
                        value!.isEmpty ? 'Please enter quantity' : null,
                    onSaved: (value) => quantity = int.parse(value!),
                  ),
                  TextFormField(
                    controller: dateController,
                    decoration: const InputDecoration(labelText: 'Expiry Date'),
                    readOnly: true,
                    onTap: () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: expiryDate,
                        firstDate: DateTime.now(),
                        lastDate:
                            DateTime.now().add(const Duration(days: 365 * 5)),
                      );
                      if (date != null) {
                        expiryDate = date;
                        dateController.text =
                            DateFormat('yyyy-MM-dd').format(date);
                      }
                    },
                    validator: (value) =>
                        value!.isEmpty ? 'Please select expiry date' : null,
                  ),
                  TextFormField(
                    initialValue: batch.supplier,
                    decoration: const InputDecoration(labelText: 'Supplier'),
                    validator: (value) =>
                        value!.isEmpty ? 'Please enter supplier' : null,
                    onSaved: (value) => supplier = value!,
                  ),
                  TextFormField(
                    initialValue: batch.lotNumber,
                    decoration: const InputDecoration(labelText: 'Lot Number'),
                    validator: (value) =>
                        value!.isEmpty ? 'Please enter lot number' : null,
                    onSaved: (value) => lotNumber = value!,
                  ),
                  TextFormField(
                    initialValue: batch.price.toString(),
                    decoration: const InputDecoration(labelText: 'Price'),
                    keyboardType: TextInputType.number,
                    validator: (value) =>
                        value!.isEmpty ? 'Please enter price' : null,
                    onSaved: (value) => price = double.parse(value!),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel', style: TextStyle(color: Colors.red)),
            ),
            TextButton(
              onPressed: () {
                if (formKey.currentState!.validate()) {
                  formKey.currentState!.save();
                  final updatedBatch = InventoryBatch(
                    id: batch.id,
                    shopId: batch.shopId,
                    medicineId: selectedMedicine!.id,
                    quantity: quantity,
                    expiryDate: expiryDate,
                    supplier: supplier,
                    lotNumber: lotNumber,
                    price: price,
                  );
                  context
                      .read<InventoryBloc>()
                      .add(UpdateInventoryBatch(updatedBatch));
                  Navigator.of(context).pop();
                }
              },
              child:
                  const Text('Update', style: TextStyle(color: kPrimaryColor)),
            ),
          ],
        );
      },
    );
  }

  void _showDeleteConfirmationDialog(
      BuildContext context, InventoryBatch batch) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Batch'),
          content: Text(
              'Are you sure you want to delete this batch of ${batch.medicineId}?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                context
                    .read<InventoryBloc>()
                    .add(DeleteInventoryBatch(batch.id));
                Navigator.of(context).pop();
              },
              child: const Text('Delete', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }
}
