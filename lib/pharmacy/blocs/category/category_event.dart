part of 'category_bloc.dart';

abstract class CategoryEvent {}

class LoadCategories extends CategoryEvent {
  final String shopId;
  LoadCategories(this.shopId);
}

class AddCategory extends CategoryEvent {
  final String name;
  final String shopId;
  AddCategory(this.name, this.shopId);
}

class UpdateCategory extends CategoryEvent {
  final Category category;
  UpdateCategory(this.category);
}

class DeleteCategory extends CategoryEvent {
  final String categoryId;
  final String shopId;
  DeleteCategory(this.categoryId, this.shopId);
}

class SearchCategories extends CategoryEvent {
  final String query;
  final String shopId;
  SearchCategories(this.query, this.shopId);
}
