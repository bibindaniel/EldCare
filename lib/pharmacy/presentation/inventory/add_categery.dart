import 'package:eldcare/pharmacy/blocs/category/category_bloc.dart';
import 'package:eldcare/pharmacy/blocs/category/category_event.dart';
import 'package:eldcare/pharmacy/blocs/category/category_state.dart';
import 'package:eldcare/pharmacy/model/category.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:eldcare/core/theme/colors.dart';
import 'package:eldcare/core/theme/font.dart';
import 'package:lottie/lottie.dart';

class AddCategoryPage extends StatefulWidget {
  const AddCategoryPage({super.key});

  @override
  State<AddCategoryPage> createState() => _AddCategoryPageState();
}

class _AddCategoryPageState extends State<AddCategoryPage> {
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _categoryController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    _categoryController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    final query = _searchController.text;
    context.read<CategoryBloc>().add(SearchCategories(query));
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<CategoryBloc, CategoryState>(
      listener: (context, state) {
        if (state is CategoryOperationSuccess) {
          _showSnackBar(context, state.message);
        } else if (state is CategoryError) {
          _showSnackBar(context, state.message, isError: true);
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Manage Categories', style: AppFonts.headline3),
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
          onPressed: () => _showAddCategoryDialog(context),
          child: const Text('Add Category', style: TextStyle(fontSize: 18)),
        ),
        Lottie.asset('assets/animations/pharmacy2.json',
            width: 150, height: 100),
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
          BlocBuilder<CategoryBloc, CategoryState>(
            builder: (context, state) {
              if (state is CategoryLoading) {
                return const Center(child: CircularProgressIndicator());
              } else if (state is CategoryLoaded) {
                return _buildExistingCategoriesSection(
                    context, state.categories);
              } else if (state is CategoryError) {
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

  Widget _buildExistingCategoriesSection(
      BuildContext context, List<Category> categories) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Existing Categories', style: AppFonts.headline3Dark),
          const SizedBox(height: 20),
          if (categories.isEmpty)
            const Text('No categories found', style: AppFonts.bodyText1Dark)
          else
            ...categories
                .map((category) => _buildCategoryTile(category, context))
                .toList(),
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
          hintText: 'Search categories',
          prefixIcon: const Icon(Icons.search),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        ),
      ),
    );
  }

  Widget _buildCategoryTile(Category category, BuildContext context) {
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
          Text(category.name,
              style: AppFonts.bodyText1Dark.copyWith(fontSize: 18)),
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.edit, color: kPrimaryColor),
                onPressed: () => _showUpdateCategoryDialog(context, category),
              ),
              IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: () =>
                    _showDeleteConfirmationDialog(context, category),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showAddCategoryDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Add New Category', style: AppFonts.headline3Dark),
          content: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _categoryController,
                  decoration:
                      const InputDecoration(hintText: 'Enter category name'),
                  validator: _categoryNameValidator,
                  onChanged: _onCategoryNameChanged,
                ),
                const SizedBox(height: 10),
                const Text(
                  'Please ensure the category name meets the following criteria:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const Text('- Only one word is allowed'),
                const Text('- Minimum of 3 letters'),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel', style: TextStyle(color: Colors.red)),
            ),
            TextButton(
              onPressed: () => _addCategory(context),
              child: const Text('Add', style: TextStyle(color: kPrimaryColor)),
            ),
          ],
        );
      },
    );
  }

  void _showUpdateCategoryDialog(BuildContext context, Category category) {
    final TextEditingController updateController =
        TextEditingController(text: category.name);
    final GlobalKey<FormState> updateFormKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Update Category', style: AppFonts.headline3Dark),
          content: Form(
            key: updateFormKey,
            child: TextFormField(
              controller: updateController,
              decoration:
                  const InputDecoration(hintText: 'Enter new category name'),
              validator: _categoryNameValidator,
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
                  context.read<CategoryBloc>().add(UpdateCategory(
                        Category(id: category.id, name: updateController.text),
                      ));
                  Navigator.of(context).pop();
                  _showSnackBar(context, 'Category updated successfully');
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

  void _showDeleteConfirmationDialog(BuildContext context, Category category) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Category'),
          content: Text('Are you sure you want to delete ${category.name}?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                context.read<CategoryBloc>().add(DeleteCategory(category.id));
                Navigator.of(context).pop();
                _showSnackBar(context, 'Category deleted successfully');
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

  String? _categoryNameValidator(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter a category name';
    }
    final capitalized = value[0].toUpperCase() + value.substring(1);
    if (!RegExp(r'^[A-Z][a-zA-Z]{2,}$').hasMatch(capitalized)) {
      return 'Invalid category name. Please follow the criteria.';
    }
    return null;
  }

  void _onCategoryNameChanged(String value) {
    if (value.isNotEmpty) {
      final capitalized = value[0].toUpperCase() + value.substring(1);
      _categoryController.value = _categoryController.value.copyWith(
        text: capitalized,
        selection: TextSelection.fromPosition(
          TextPosition(offset: capitalized.length),
        ),
      );
    }
  }

  void _addCategory(BuildContext context) {
    if (_formKey.currentState?.validate() ?? false) {
      final String categoryName = _categoryController.text;
      context.read<CategoryBloc>().add(AddCategory(categoryName));
      Navigator.of(context).pop();
      _categoryController.clear();
      _showSnackBar(context, 'Category added successfully');
    }
  }
}
