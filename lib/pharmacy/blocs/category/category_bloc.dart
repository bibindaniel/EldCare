import 'package:eldcare/pharmacy/blocs/category/category_event.dart';
import 'package:eldcare/pharmacy/blocs/category/category_state.dart';
import 'package:eldcare/pharmacy/model/category.dart';
import 'package:eldcare/pharmacy/repository/category_repo.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CategoryBloc extends Bloc<CategoryEvent, CategoryState> {
  final CategoryRepository repository;
  Stream<List<Category>>? _categoryStream;

  CategoryBloc({required this.repository}) : super(CategoryInitial()) {
    _startCategoryStream();
    on<LoadCategories>(_onLoadCategories);
    on<AddCategory>(_onAddCategory);
    on<UpdateCategory>(_onUpdateCategory);
    on<DeleteCategory>(_onDeleteCategory);
    on<SearchCategories>(_onSearchCategories);
    on<CheckCategoryExists>(_onCheckCategoryExists);
  }

  void _startCategoryStream() {
    _categoryStream = repository.getCategoriesStream();
    _categoryStream?.listen((categories) {
      add(LoadCategories(categories: categories));
    });
  }

  void _onLoadCategories(LoadCategories event, Emitter<CategoryState> emit) {
    emit(CategoryLoaded(event.categories));
  }

  Future<void> _onAddCategory(
      AddCategory event, Emitter<CategoryState> emit) async {
    try {
      await repository.addCategory(event.name);
    } catch (e) {
      emit(CategoryError(e.toString()));
    }
  }

  Future<void> _onUpdateCategory(
      UpdateCategory event, Emitter<CategoryState> emit) async {
    try {
      await repository.updateCategory(event.category);
    } catch (e) {
      emit(CategoryError(e.toString()));
    }
  }

  Future<void> _onDeleteCategory(
      DeleteCategory event, Emitter<CategoryState> emit) async {
    try {
      await repository.deleteCategory(event.id);
    } catch (e) {
      emit(CategoryError(e.toString()));
    }
  }

  Future<void> _onSearchCategories(
      SearchCategories event, Emitter<CategoryState> emit) async {
    try {
      final categories = await repository.searchCategories(event.query);
      emit(CategoryLoaded(categories));
    } catch (e) {
      emit(CategoryError(e.toString()));
    }
  }

  Future<void> _onCheckCategoryExists(
      CheckCategoryExists event, Emitter<CategoryState> emit) async {
    try {
      final exists = await repository.categoryExists(event.name);
      emit(CategoryExists(exists));
    } catch (e) {
      emit(CategoryError(e.toString()));
    }
  }
}
