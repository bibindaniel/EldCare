import 'package:eldcare/pharmacy/blocs/category/category_bloc.dart';
import 'package:eldcare/pharmacy/blocs/category/category_state.dart';
import 'package:eldcare/pharmacy/blocs/medicine_name/medicine_name_bloc.dart';
import 'package:eldcare/pharmacy/blocs/medicine_name/medicine_name_event.dart';
import 'package:eldcare/pharmacy/blocs/medicine_name/medicine_name_state.dart';
import 'package:eldcare/pharmacy/model/medicine.dart';
import 'package:eldcare/pharmacy/model/category.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:eldcare/core/theme/colors.dart';
import 'package:eldcare/core/theme/font.dart';

class AddMedicinePage extends StatefulWidget {
  const AddMedicinePage({super.key});

  @override
  State<AddMedicinePage> createState() => _AddMedicinePageState();
}

class _AddMedicinePageState extends State<AddMedicinePage> {
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _medicineNameController = TextEditingController();
  final TextEditingController _dosageController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  Category? _selectedCategory;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    _medicineNameController.dispose();
    _dosageController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    final query = _searchController.text;
    context.read<MedicineNameBloc>().add(SearchMedicines(query));
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MedicineNameBloc, MedicineNameState>(
      builder: (context, state) {
        return BlocListener<MedicineNameBloc, MedicineNameState>(
          listener: (context, state) {
            if (state is MedicineOperationSuccess) {
              _showSnackBar(context, state.message);
              context.read<MedicineNameBloc>().add(LoadMedicines());
            } else if (state is MedicineError) {
              _showSnackBar(context, state.message, isError: true);
            }
          },
          child: Scaffold(
            appBar: AppBar(
              title: const Text('Manage Medicines', style: AppFonts.headline3),
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
          ),
        );
      },
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
          onPressed: () => _showAddMedicineDialog(context),
          child: const Text('Add Medicine', style: TextStyle(fontSize: 18)),
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
          BlocBuilder<MedicineNameBloc, MedicineNameState>(
            builder: (context, state) {
              if (state is MedicineLoading) {
                return const Center(child: CircularProgressIndicator());
              } else if (state is MedicineLoaded) {
                return _buildExistingMedicinesSection(context, state.medicines);
              } else if (state is MedicineError) {
                return Text('Error: ${state.message}');
              }
              return const SizedBox();
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
          hintText: 'Search medicines',
          prefixIcon: const Icon(Icons.search),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        ),
      ),
    );
  }

  Widget _buildExistingMedicinesSection(
      BuildContext context, List<Medicine> medicines) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Existing Medicines', style: AppFonts.headline3Dark),
          const SizedBox(height: 20),
          if (medicines.isEmpty)
            const Text('No medicines found', style: AppFonts.bodyText1Dark)
          else
            ...medicines
                .map((medicine) => _buildMedicineTile(medicine, context))
                .toList(),
        ],
      ),
    );
  }

  Widget _buildMedicineTile(Medicine medicine, BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      decoration: BoxDecoration(
        color: kPrimaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: kPrimaryColor),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(medicine.name,
                  style: AppFonts.bodyText1Dark.copyWith(fontSize: 18)),
              Text('Dosage: ${medicine.dosage}',
                  style: AppFonts.bodyText1Dark.copyWith(fontSize: 14)),
            ],
          ),
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.edit, color: kPrimaryColor),
                onPressed: () => _showUpdateMedicineDialog(context, medicine),
              ),
              IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: () =>
                    _showDeleteConfirmationDialog(context, medicine),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showAddMedicineDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Add New Medicine', style: AppFonts.headline3Dark),
          content: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _medicineNameController,
                  decoration:
                      const InputDecoration(hintText: 'Enter medicine name'),
                  validator: _medicineNameValidator,
                ),
                const SizedBox(height: 10),
                _buildCategoryDropdown(),
                const SizedBox(height: 10),
                TextFormField(
                  controller: _dosageController,
                  decoration: const InputDecoration(hintText: 'Enter dosage'),
                  validator: _dosageValidator,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel', style: TextStyle(color: Colors.red)),
            ),
            TextButton(
              onPressed: () => _addMedicine(context),
              child: const Text('Add', style: TextStyle(color: kPrimaryColor)),
            ),
          ],
        );
      },
    );
  }

  Widget _buildCategoryDropdown() {
    return BlocBuilder<CategoryBloc, CategoryState>(
      builder: (context, state) {
        if (state is CategoryLoading) {
          return const CircularProgressIndicator();
        } else if (state is CategoryLoaded) {
          return DropdownButtonFormField<Category>(
            value: _selectedCategory,
            hint: const Text('Select category'),
            onChanged: (Category? newValue) {
              setState(() {
                _selectedCategory = newValue!;
              });
            },
            items: state.categories.map((Category category) {
              return DropdownMenuItem<Category>(
                value: category,
                child: Text(category.name),
              );
            }).toList(),
            validator: (value) =>
                value == null ? 'Please select a category' : null,
          );
        } else if (state is CategoryError) {
          return Text('Error: ${state.message}');
        }
        return const Text('No categories available');
      },
    );
  }

  void _showUpdateMedicineDialog(BuildContext context, Medicine medicine) {
    final TextEditingController updateController =
        TextEditingController(text: medicine.name);
    final TextEditingController updateDosageController =
        TextEditingController(text: medicine.dosage);
    final GlobalKey<FormState> updateFormKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Update Medicine', style: AppFonts.headline3Dark),
          content: Form(
            key: updateFormKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: updateController,
                  decoration:
                      const InputDecoration(hintText: 'Enter medicine name'),
                  validator: _medicineNameValidator,
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: updateDosageController,
                  decoration: const InputDecoration(hintText: 'Enter dosage'),
                  validator: _dosageValidator,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel', style: TextStyle(color: Colors.red)),
            ),
            TextButton(
              onPressed: () {
                if (updateFormKey.currentState?.validate() ?? false) {
                  context.read<MedicineNameBloc>().add(UpdateMedicine(
                        Medicine(
                          id: medicine.id,
                          name: updateController.text,
                          categoryId: medicine.categoryId,
                          dosage: updateDosageController.text,
                        ),
                      ));
                  Navigator.of(context).pop();
                  _searchController.clear(); // Clear the search field
                  _showSnackBar(context, 'Medicine updated successfully');
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

  void _showDeleteConfirmationDialog(BuildContext context, Medicine medicine) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Medicine'),
          content: Text('Are you sure you want to delete ${medicine.name}?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                context
                    .read<MedicineNameBloc>()
                    .add(DeleteMedicine(medicine.id));
                Navigator.of(context).pop();
                _searchController.clear(); // Clear the search field
                _showSnackBar(context, 'Medicine deleted successfully');
              },
              child: const Text('Delete', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  void _showSnackBar(BuildContext context, String message,
      {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
      ),
    );
  }

  String? _medicineNameValidator(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter a medicine name';
    }
    return null;
  }

  String? _dosageValidator(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter the dosage';
    }
    return null;
  }

  void _addMedicine(BuildContext context) {
    if (_formKey.currentState?.validate() ?? false) {
      final Medicine medicine = Medicine(
        id: '', // Firestore will generate this ID.
        name: _medicineNameController.text,
        categoryId: _selectedCategory!.id,
        dosage: _dosageController.text,
      );
      context.read<MedicineNameBloc>().add(AddMedicine(medicine));
      Navigator.of(context).pop();
      _medicineNameController.clear();
      _dosageController.clear();
      _selectedCategory = null;
      _searchController.clear(); // Clear the search field
      _showSnackBar(context, 'Medicine added successfully');
    }
  }
}
