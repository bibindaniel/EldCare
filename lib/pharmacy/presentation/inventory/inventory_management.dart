import 'package:eldcare/pharmacy/blocs/category/category_bloc.dart';
import 'package:eldcare/pharmacy/model/medicine.dart';
import 'package:eldcare/pharmacy/presentation/inventory/add_categery.dart';
import 'package:eldcare/pharmacy/presentation/inventory/add_medicine_name.dart';
import 'package:eldcare/pharmacy/repository/medicine_repositry.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:eldcare/core/theme/colors.dart';
import 'package:eldcare/core/theme/font.dart';
import 'package:eldcare/pharmacy/blocs/inventory/inventory_bloc.dart';
import 'package:eldcare/pharmacy/model/inventory_batch.dart';
import 'package:eldcare/pharmacy/model/shop.dart';
import 'package:eldcare/pharmacy/blocs/medicine_name/medicine_name_bloc.dart';
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
    context.read<InventoryBloc>().add(LoadInventory(widget.shop.id));
    context.read<CategoryBloc>().add(LoadCategories(widget.shop.id));
    context.read<MedicineNameBloc>().add(LoadMedicines(widget.shop.id));
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<InventoryBloc, InventoryState>(
      listener: (context, state) {
        if (state is InventoryOperationSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: kSuccessColor,
            ),
          );
          // Reload inventory after successful operation
          context.read<InventoryBloc>().add(LoadInventory(widget.shop.id));
        } else if (state is InventoryError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: kErrorColor,
            ),
          );
        }
      },
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(
            title: Text('Manage ${widget.shop.name}',
                style: AppFonts.headline3Light),
            backgroundColor: kPrimaryColor,
          ),
          body: Column(
            children: [
              _buildTopSection(),
              _buildSearchBar(),
              Expanded(child: _buildInventorySection(state)),
            ],
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () => _showAddInventoryBatchDialog(context),
            backgroundColor: kPrimaryColor,
            child: const Icon(Icons.add),
          ),
        );
      },
    );
  }

  Widget _buildTopSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: kPrimaryColor,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          ElevatedButton.icon(
            icon: const Icon(Icons.category),
            label: const Text('Add Category', style: TextStyle(fontSize: 16)),
            style: ElevatedButton.styleFrom(
              foregroundColor: kPrimaryColor,
              backgroundColor: kWhiteColor,
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30)),
            ),
            onPressed: () => _navigateToAddCategory(context),
          ),
          ElevatedButton.icon(
            icon: const Icon(Icons.medical_services),
            label: const Text('Add Medicine', style: TextStyle(fontSize: 16)),
            style: ElevatedButton.styleFrom(
              foregroundColor: kPrimaryColor,
              backgroundColor: kWhiteColor,
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30)),
            ),
            onPressed: () => _navigateToAddMedicine(context),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Search inventory...',
          prefixIcon: const Icon(Icons.search),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
          ),
        ),
        onChanged: (query) {
          context
              .read<InventoryBloc>()
              .add(SearchInventory(query, widget.shop.id));
        },
      ),
    );
  }

  Widget _buildInventorySection(InventoryState state) {
    if (state is InventoryLoading) {
      return const Center(child: CircularProgressIndicator());
    } else if (state is InventoryLoaded) {
      return _buildInventoryList(state.batches);
    } else if (state is InventoryError) {
      return Center(child: Text(state.message));
    } else {
      return const Center(child: Text('No inventory data available'));
    }
  }

  Widget _buildInventoryList(List<InventoryBatch> batches) {
    return ListView.builder(
      itemCount: batches.length,
      itemBuilder: (context, index) {
        final batch = batches[index];
        return Card(
          elevation: 2,
          margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
          child: ListTile(
            title: Text(batch.medicineName ?? 'Unknown Medicine',
                style: AppFonts.cardTitle),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Quantity: ${batch.quantity}', style: AppFonts.bodyText2),
                Text(
                    'Expiry: ${DateFormat('yyyy-MM-dd').format(batch.expiryDate)}',
                    style: AppFonts.bodyText2),
                Text('Price: \$${batch.price.toStringAsFixed(2)}',
                    style: AppFonts.bodyText2),
              ],
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.info_outline, color: kPrimaryColor),
                  onPressed: () => _showInventoryDetailsDialog(context, batch),
                ),
                IconButton(
                  icon: const Icon(Icons.edit, color: kPrimaryColor),
                  onPressed: () =>
                      _showEditInventoryBatchDialog(context, batch),
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () =>
                      _showDeleteConfirmationDialog(context, batch),
                ),
              ],
            ),
            onTap: () => _showInventoryDetailsDialog(context, batch),
          ),
        );
      },
    );
  }

  void _showInventoryDetailsDialog(BuildContext context, InventoryBatch batch) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return _InventoryDetailsDialog(batch: batch);
      },
    );
  }

  void _navigateToAddCategory(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddCategoryPage(shopId: widget.shop.id),
      ),
    );
  }

  void _navigateToAddMedicine(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddMedicinePage(shopId: widget.shop.id),
      ),
    );
  }

  void _showAddInventoryBatchDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return BlocProvider(
          create: (context) => MedicineNameBloc(
            medicineRepository: RepositoryProvider.of(context),
            repository: MedicineRepository(),
          )..add(LoadMedicines(widget.shop.id)),
          child: _InventoryBatchDialog(
            shopId: widget.shop.id,
            onSave: (InventoryBatch batch) {
              context.read<InventoryBloc>().add(AddInventoryBatch(batch));
              Navigator.of(context).pop();
            },
          ),
        );
      },
    );
  }

  void _showEditInventoryBatchDialog(
      BuildContext context, InventoryBatch batch) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return BlocProvider(
          create: (context) => MedicineNameBloc(
            medicineRepository: RepositoryProvider.of(context),
            repository: MedicineRepository(),
          )..add(LoadMedicines(widget.shop.id)),
          child: _InventoryBatchDialog(
            shopId: widget.shop.id,
            initialBatch: batch,
            onSave: (InventoryBatch updatedBatch) {
              context
                  .read<InventoryBloc>()
                  .add(UpdateInventoryBatch(updatedBatch));
              Navigator.of(context).pop();
            },
          ),
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
          title: const Text('Delete Inventory Batch'),
          content:
              Text('Are you sure you want to delete ${batch.medicineName}?'),
          actions: [
            TextButton(
              child: const Text('Cancel'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            ElevatedButton(
              onPressed: () {
                context
                    .read<InventoryBloc>()
                    .add(DeleteInventoryBatch(batch.id, widget.shop.id));
                Navigator.of(context).pop();
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }
}

class _InventoryDetailsDialog extends StatelessWidget {
  final InventoryBatch batch;

  const _InventoryDetailsDialog({required this.batch});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(batch.medicineName ?? 'Unknown Medicine',
          style: AppFonts.headline4),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildDetailRow('Quantity', batch.quantity.toString()),
            _buildDetailRow('Price', '\$${batch.price.toStringAsFixed(2)}'),
            _buildDetailRow('Expiry Date',
                DateFormat('yyyy-MM-dd').format(batch.expiryDate)),
            _buildDetailRow('Supplier', batch.supplier),
            _buildDetailRow('Lot Number', batch.lotNumber),
          ],
        ),
      ),
      actions: [
        TextButton(
          child: const Text('Close'),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ],
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: AppFonts.cardTitle,
            ),
          ),
          Expanded(
            child: Text(value, style: AppFonts.bodyText2),
          ),
        ],
      ),
    );
  }
}

class _InventoryBatchDialog extends StatefulWidget {
  final String shopId;
  final InventoryBatch? initialBatch;
  final Function(InventoryBatch) onSave;

  const _InventoryBatchDialog({
    required this.shopId,
    this.initialBatch,
    required this.onSave,
  });

  @override
  __InventoryBatchDialogState createState() => __InventoryBatchDialogState();
}

class __InventoryBatchDialogState extends State<_InventoryBatchDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _quantityController;
  late TextEditingController _priceController;
  late TextEditingController _supplierController;
  late TextEditingController _lotNumberController;
  DateTime? _expiryDate;
  Medicine? _selectedMedicine;

  @override
  void initState() {
    super.initState();
    _quantityController = TextEditingController(
        text: widget.initialBatch?.quantity.toString() ?? '');
    _priceController = TextEditingController(
        text: widget.initialBatch?.price.toString() ?? '');
    _supplierController =
        TextEditingController(text: widget.initialBatch?.supplier ?? '');
    _lotNumberController =
        TextEditingController(text: widget.initialBatch?.lotNumber ?? '');
    _expiryDate = widget.initialBatch?.expiryDate;
  }

  @override
  void dispose() {
    _quantityController.dispose();
    _priceController.dispose();
    _supplierController.dispose();
    _lotNumberController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.initialBatch == null
          ? 'Add Inventory Batch'
          : 'Edit Inventory Batch'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildMedicineDropdown(),
              TextFormField(
                controller: _quantityController,
                decoration: const InputDecoration(labelText: 'Quantity'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a quantity';
                  }
                  if (int.tryParse(value) == null) {
                    return 'Please enter a valid number';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _priceController,
                decoration: const InputDecoration(labelText: 'Price'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a price';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Please enter a valid number';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _supplierController,
                decoration: const InputDecoration(labelText: 'Supplier'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a supplier';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _lotNumberController,
                decoration: const InputDecoration(labelText: 'Lot Number'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a lot number';
                  }
                  return null;
                },
              ),
              _buildDatePicker(context),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          child: const Text('Cancel'),
          onPressed: () => Navigator.of(context).pop(),
        ),
        ElevatedButton(
          onPressed: _saveInventoryBatch,
          child: const Text('Save'),
        ),
      ],
    );
  }

  Widget _buildMedicineDropdown() {
    return BlocBuilder<MedicineNameBloc, MedicineNameState>(
      builder: (context, state) {
        if (state is MedicineNameLoaded) {
          return DropdownButtonFormField<Medicine>(
            value: _selectedMedicine,
            hint: const Text('Select Medicine'),
            items: state.medicines.map((Medicine medicine) {
              return DropdownMenuItem(
                value: medicine,
                child: Text(medicine.name),
              );
            }).toList(),
            onChanged: (Medicine? newValue) {
              setState(() {
                _selectedMedicine = newValue;
              });
            },
            validator: (value) {
              if (value == null) {
                return 'Please select a medicine';
              }
              return null;
            },
          );
        }
        return const CircularProgressIndicator();
      },
    );
  }

  Widget _buildDatePicker(BuildContext context) {
    return InkWell(
      onTap: () async {
        final DateTime? picked = await showDatePicker(
          context: context,
          initialDate: _expiryDate ?? DateTime.now(),
          firstDate: DateTime.now(),
          lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
        );
        if (picked != null && picked != _expiryDate) {
          setState(() {
            _expiryDate = picked;
          });
        }
      },
      child: InputDecorator(
        decoration: const InputDecoration(
          labelText: 'Expiry Date',
        ),
        child: Text(
          _expiryDate == null
              ? 'Select Date'
              : DateFormat('yyyy-MM-dd').format(_expiryDate!),
        ),
      ),
    );
  }

  void _saveInventoryBatch() {
    if (_formKey.currentState!.validate() &&
        _selectedMedicine != null &&
        _expiryDate != null) {
      final batch = InventoryBatch(
        id: widget.initialBatch?.id ?? '',
        shopId: widget.shopId,
        medicineId: _selectedMedicine!.id,
        quantity: int.parse(_quantityController.text),
        expiryDate: _expiryDate!,
        supplier: _supplierController.text,
        lotNumber: _lotNumberController.text,
        price: double.parse(_priceController.text),
        medicineName: _selectedMedicine!.name,
      );
      widget.onSave(batch);
    }
  }
}
