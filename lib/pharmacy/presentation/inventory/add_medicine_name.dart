import 'package:eldcare/pharmacy/presentation/inventory/capitakletter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:eldcare/core/theme/colors.dart';
import 'package:eldcare/core/theme/font.dart';
import 'package:eldcare/pharmacy/blocs/category/category_bloc.dart';
import 'package:eldcare/pharmacy/blocs/medicine_name/medicine_name_bloc.dart';
import 'package:eldcare/pharmacy/model/category.dart';
import 'package:eldcare/pharmacy/model/medicine.dart';
import 'package:lottie/lottie.dart';

class AddMedicinePage extends StatefulWidget {
  final String shopId;

  const AddMedicinePage({super.key, required this.shopId});

  @override
  State<AddMedicinePage> createState() => _AddMedicinePageState();
}

class _AddMedicinePageState extends State<AddMedicinePage> {
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _medicineNameController = TextEditingController();
  final TextEditingController _dosageController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  Category? _selectedCategory;
  bool _requiresPrescription = false;
  static const int maxMedicineNameLength = 50;
  static const int maxDosageLength = 20;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
    context.read<MedicineNameBloc>().add(LoadMedicines(widget.shopId));
    context.read<CategoryBloc>().add(LoadCategories(widget.shopId));
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
    context.read<MedicineNameBloc>().add(SearchMedicines(query, widget.shopId));
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<MedicineNameBloc, MedicineNameState>(
      listener: (context, state) {
        if (state is MedicineOperationSuccess) {
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text(state.message)));
          context.read<MedicineNameBloc>().add(LoadMedicines(widget.shopId));
        } else if (state is MedicineNameError) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text(state.message), backgroundColor: Colors.red));
        }
      },
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(
            title: Text('Manage Medicines', style: AppFonts.headline3Light),
            backgroundColor: kPrimaryColor,
          ),
          body: Column(
            children: [
              _buildTopSection(context),
              Expanded(child: _buildBottomSection(context, state)),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTopSection(BuildContext context) {
    return Container(
      color: kPrimaryColor,
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              foregroundColor: kPrimaryColor,
              backgroundColor: kWhiteColor,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30)),
            ),
            onPressed: () => _showAddMedicineDialog(context),
            child: const Text('Add Medicine', style: TextStyle(fontSize: 16)),
          ),
          Lottie.asset('assets/animations/pharmacy2.json',
              width: 100, height: 100),
        ],
      ),
    );
  }

  Widget _buildBottomSection(BuildContext context, MedicineNameState state) {
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
          _buildSearchField(),
          Expanded(
            child: state is MedicineNameLoading
                ? const Center(child: CircularProgressIndicator())
                : state is MedicineNameLoaded
                    ? _buildMedicineList(state.medicines)
                    : state is MedicineNameError
                        ? Center(child: Text(state.message))
                        : const Center(child: Text('No medicines available')),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchField() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Search medicines...',
          prefixIcon: const Icon(Icons.search),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
          ),
        ),
      ),
    );
  }

  Widget _buildMedicineList(List<Medicine> medicines) {
    return ListView.separated(
      itemCount: medicines.length,
      separatorBuilder: (context, index) => const Divider(),
      itemBuilder: (context, index) {
        final medicine = medicines[index];
        return ListTile(
          title: Text(medicine.name, style: AppFonts.cardSubtitle),
          subtitle: Text(medicine.dosage, style: AppFonts.bodyText2),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(Icons.edit, color: kPrimaryColor),
                onPressed: () => _showEditMedicineDialog(context, medicine),
              ),
              IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: () =>
                    _showDeleteConfirmationDialog(context, medicine),
              ),
            ],
          ),
          onTap: () => _showEditMedicineDialog(context, medicine),
        );
      },
    );
  }

  void _showAddMedicineDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return AlertDialog(
              title: const Text('Add New Medicine'),
              content: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      controller: _medicineNameController,
                      decoration: const InputDecoration(
                          hintText: "Enter medicine name"),
                      validator: _validateMedicineName,
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      textCapitalization: TextCapitalization.words,
                      maxLength: maxMedicineNameLength,
                      inputFormatters: [
                        FirstLetterUppercaseFormatter(),
                      ],
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      controller: _dosageController,
                      decoration:
                          const InputDecoration(hintText: "Enter dosage"),
                      validator: _validateDosage,
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      maxLength: maxDosageLength,
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(
                            RegExp(r'[a-zA-Z0-9\s]')),
                      ],
                    ),
                    const SizedBox(height: 10),
                    BlocBuilder<CategoryBloc, CategoryState>(
                      builder: (context, state) {
                        if (state is CategoryLoaded) {
                          return DropdownButtonFormField<Category>(
                            value: _selectedCategory,
                            hint: const Text('Select a category'),
                            items: state.categories.map((Category category) {
                              return DropdownMenuItem(
                                value: category,
                                child: Text(category.name),
                              );
                            }).toList(),
                            onChanged: (Category? newValue) {
                              setState(() {
                                _selectedCategory = newValue;
                              });
                            },
                            validator: (value) {
                              if (value == null) {
                                return 'Please select a category';
                              }
                              return null;
                            },
                          );
                        }
                        return const CircularProgressIndicator();
                      },
                    ),
                    const SizedBox(height: 10),
                    CheckboxListTile(
                      title: const Text("Requires Prescription"),
                      value: _requiresPrescription,
                      onChanged: (bool? value) {
                        setState(() {
                          _requiresPrescription = value ?? false;
                        });
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  child: const Text('Cancel'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                ElevatedButton(
                  child: const Text('Add'),
                  onPressed: () {
                    if (_formKey.currentState!.validate() &&
                        _selectedCategory != null) {
                      context.read<MedicineNameBloc>().add(AddMedicine(
                            Medicine(
                              id: '',
                              name: _medicineNameController.text,
                              dosage: _dosageController.text,
                              categoryId: _selectedCategory!.id,
                              shopId: widget.shopId,
                              requiresPrescription: _requiresPrescription,
                            ),
                          ));
                      Navigator.of(context).pop();
                      _medicineNameController.clear();
                      _dosageController.clear();
                      _selectedCategory = null;
                      _requiresPrescription = false;
                    }
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showEditMedicineDialog(BuildContext context, Medicine medicine) {
    _medicineNameController.text = medicine.name;
    _dosageController.text = medicine.dosage;
    _selectedCategory =
        null; // You might want to fetch the actual category here
    _requiresPrescription = medicine.requiresPrescription;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return AlertDialog(
              title: const Text('Edit Medicine'),
              content: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      controller: _medicineNameController,
                      decoration: const InputDecoration(
                          hintText: "Enter medicine name"),
                      validator: _validateMedicineName,
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      textCapitalization: TextCapitalization.words,
                      maxLength: maxMedicineNameLength,
                      inputFormatters: [
                        FirstLetterUppercaseFormatter(),
                      ],
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      controller: _dosageController,
                      decoration:
                          const InputDecoration(hintText: "Enter dosage"),
                      validator: _validateDosage,
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      maxLength: maxDosageLength,
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(
                            RegExp(r'[a-zA-Z0-9\s]')),
                      ],
                    ),
                    const SizedBox(height: 10),
                    BlocBuilder<CategoryBloc, CategoryState>(
                      builder: (context, state) {
                        if (state is CategoryLoaded) {
                          return DropdownButtonFormField<Category>(
                            value: _selectedCategory,
                            hint: const Text('Select a category'),
                            items: state.categories.map((Category category) {
                              return DropdownMenuItem(
                                value: category,
                                child: Text(category.name),
                              );
                            }).toList(),
                            onChanged: (Category? newValue) {
                              setState(() {
                                _selectedCategory = newValue;
                              });
                            },
                            validator: (value) {
                              if (value == null) {
                                return 'Please select a category';
                              }
                              return null;
                            },
                          );
                        }
                        return const CircularProgressIndicator();
                      },
                    ),
                    const SizedBox(height: 10),
                    CheckboxListTile(
                      title: const Text("Requires Prescription"),
                      value: _requiresPrescription,
                      onChanged: (bool? value) {
                        setState(() {
                          _requiresPrescription = value ?? false;
                        });
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  child: const Text('Cancel'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                ElevatedButton(
                  child: const Text('Update'),
                  onPressed: () {
                    if (_formKey.currentState!.validate() &&
                        _selectedCategory != null) {
                      context.read<MedicineNameBloc>().add(UpdateMedicine(
                            medicine.copyWith(
                              name: _medicineNameController.text,
                              dosage: _dosageController.text,
                              categoryId: _selectedCategory!.id,
                              requiresPrescription: _requiresPrescription,
                            ),
                          ));
                      Navigator.of(context).pop();
                      _medicineNameController.clear();
                      _dosageController.clear();
                      _selectedCategory = null;
                      _requiresPrescription = false;
                    }
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  String? _validateMedicineName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter a medicine name';
    }
    if (value.length > maxMedicineNameLength) {
      return 'Medicine name must be $maxMedicineNameLength characters or less';
    }
    if (!RegExp(r'^[A-Z][a-zA-Z\s]*$').hasMatch(value)) {
      return 'Medicine name should  contain only letters and spaces';
    }
    return null;
  }

  String? _validateDosage(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter a dosage';
    }
    if (value.length > maxDosageLength) {
      return 'Dosage must be $maxDosageLength characters or less';
    }
    if (!RegExp(r'^[a-zA-Z0-9\s]+$').hasMatch(value)) {
      return 'Dosage should contain only letters, numbers, and spaces';
    }
    return null;
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
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            ElevatedButton(
              child: const Text('Delete'),
              onPressed: () {
                context
                    .read<MedicineNameBloc>()
                    .add(DeleteMedicine(medicine.id, widget.shopId));
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
