import 'package:eldcare/pharmacy/presentation/inventory/capitakletter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:eldcare/core/theme/colors.dart';
import 'package:eldcare/core/theme/font.dart';
import 'package:eldcare/pharmacy/blocs/category/category_bloc.dart';
import 'package:eldcare/pharmacy/model/category.dart';
import 'package:lottie/lottie.dart';

class AddCategoryPage extends StatefulWidget {
  final String shopId;

  const AddCategoryPage({super.key, required this.shopId});

  @override
  State<AddCategoryPage> createState() => _AddCategoryPageState();
}

class _AddCategoryPageState extends State<AddCategoryPage> {
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _categoryController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  static const int maxCategoryLength = 20;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
    context.read<CategoryBloc>().add(LoadCategories(widget.shopId));
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
    context.read<CategoryBloc>().add(SearchCategories(query, widget.shopId));
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<CategoryBloc, CategoryState>(
      listener: (context, state) {
        if (state is CategoryOperationSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text(state.message), backgroundColor: kSuccessColor));
          context.read<CategoryBloc>().add(LoadCategories(widget.shopId));
        } else if (state is CategoryError) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text(state.message), backgroundColor: kErrorColor));
        }
      },
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(
            title: Text('Manage Categories', style: AppFonts.headline3Light),
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
            onPressed: () => _showAddCategoryDialog(context),
            child: const Text('Add Category', style: TextStyle(fontSize: 16)),
          ),
          Lottie.asset('assets/animations/pharmacy2.json',
              width: 100, height: 100),
        ],
      ),
    );
  }

  Widget _buildBottomSection(BuildContext context, CategoryState state) {
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
            child: state is CategoryLoading
                ? const Center(child: CircularProgressIndicator())
                : state is CategoryLoaded
                    ? _buildCategoryList(state.categories)
                    : state is CategoryError
                        ? Center(child: Text(state.message))
                        : const SizedBox.shrink(),
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
          hintText: 'Search categories...',
          prefixIcon: const Icon(Icons.search),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryList(List<Category> categories) {
    return ListView.separated(
      itemCount: categories.length,
      separatorBuilder: (context, index) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final category = categories[index];
        return ListTile(
          title: Text(category.name, style: AppFonts.cardSubtitle),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(Icons.edit, color: kPrimaryColor),
                onPressed: () => _showEditCategoryDialog(context, category),
              ),
              IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: () =>
                    _showDeleteConfirmationDialog(context, category),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showAddCategoryDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Add New Category'),
          content: Form(
            key: _formKey,
            child: TextFormField(
              controller: _categoryController,
              decoration:
                  const InputDecoration(hintText: "Enter category name"),
              validator: _validateCategory,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              textCapitalization: TextCapitalization.sentences,
              maxLength: maxCategoryLength,
              inputFormatters: [
                FirstLetterUppercaseFormatter(),
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
                if (_formKey.currentState!.validate()) {
                  context.read<CategoryBloc>().add(AddCategory(
                      _categoryController.text.trim(), widget.shopId));
                  Navigator.of(context).pop();
                  _categoryController.clear();
                }
              },
            ),
          ],
        );
      },
    );
  }

  void _showEditCategoryDialog(BuildContext context, Category category) {
    _categoryController.text = category.name;
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Edit Category'),
          content: Form(
            key: _formKey,
            child: TextFormField(
              controller: _categoryController,
              decoration:
                  const InputDecoration(hintText: "Enter category name"),
              validator: _validateCategory,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              textCapitalization: TextCapitalization.sentences,
              maxLength: maxCategoryLength,
              inputFormatters: [
                FirstLetterUppercaseFormatter(),
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
                if (_formKey.currentState!.validate()) {
                  context.read<CategoryBloc>().add(UpdateCategory(
                        Category(
                            id: category.id,
                            name: _categoryController.text.trim(),
                            shopId: widget.shopId),
                      ));
                  Navigator.of(context).pop();
                  _categoryController.clear();
                }
              },
            ),
          ],
        );
      },
    );
  }

  String? _validateCategory(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter a category name';
    }
    if (value.length > maxCategoryLength) {
      return 'Category name must be $maxCategoryLength characters or less';
    }
    if (value.trim().contains(' ')) {
      return 'Category name should be a single word';
    }
    if (!RegExp(r'^[A-Z][a-zA-Z]*$').hasMatch(value)) {
      return 'Category name should contain only letters';
    }
    return null;
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
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            ElevatedButton(
              child: const Text('Delete'),
              onPressed: () {
                context
                    .read<CategoryBloc>()
                    .add(DeleteCategory(category.id, widget.shopId));
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
