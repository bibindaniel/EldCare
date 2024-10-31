part of 'category_bloc.dart';

abstract class CategoryState {}

class CategoryInitial extends CategoryState {}

class CategoryLoading extends CategoryState {}

class CategoryLoaded extends CategoryState {
  final List<Category> categories;
  CategoryLoaded(this.categories);
}

class CategoryOperationSuccess extends CategoryState {
  final String message;
  CategoryOperationSuccess(this.message);
}

class CategoryError extends CategoryState {
  final String message;
  CategoryError(this.message);
}
