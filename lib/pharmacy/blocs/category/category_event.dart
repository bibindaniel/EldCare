import 'package:eldcare/pharmacy/model/category.dart';
import 'package:equatable/equatable.dart';

abstract class CategoryEvent extends Equatable {
  const CategoryEvent();

  @override
  List<Object> get props => [];
}

class LoadCategories extends CategoryEvent {
  final List<Category> categories;

  const LoadCategories({this.categories = const []});

  @override
  List<Object> get props => [categories];
}

class AddCategory extends CategoryEvent {
  final String name;

  const AddCategory(this.name);

  @override
  List<Object> get props => [name];
}

class UpdateCategory extends CategoryEvent {
  final Category category;

  const UpdateCategory(this.category);

  @override
  List<Object> get props => [category];
}

class DeleteCategory extends CategoryEvent {
  final String id;

  const DeleteCategory(this.id);

  @override
  List<Object> get props => [id];
}

class SearchCategories extends CategoryEvent {
  final String query;

  const SearchCategories(this.query);

  @override
  List<Object> get props => [query];
}

class CheckCategoryExists extends CategoryEvent {
  final String name;

  const CheckCategoryExists(this.name);

  @override
  List<Object> get props => [name];
}
