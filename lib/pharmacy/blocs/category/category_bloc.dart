import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:eldcare/pharmacy/repository/category_repo.dart';
import 'package:eldcare/pharmacy/model/category.dart';

part 'category_event.dart';
part 'category_state.dart';

class CategoryBloc extends Bloc<CategoryEvent, CategoryState> {
  final CategoryRepository _categoryRepository;

  CategoryBloc(
      {required CategoryRepository categoryRepository,
      required CategoryRepository repository})
      : _categoryRepository = categoryRepository,
        super(CategoryInitial()) {
    on<LoadCategories>(_onLoadCategories);
    on<AddCategory>(_onAddCategory);
    on<UpdateCategory>(_onUpdateCategory);
    on<DeleteCategory>(_onDeleteCategory);
    on<SearchCategories>(_onSearchCategories);
  }

  void _onLoadCategories(
      LoadCategories event, Emitter<CategoryState> emit) async {
    emit(CategoryLoading());
    try {
      await emit.forEach(
        _categoryRepository.getCategoriesStream(event.shopId),
        onData: (List<Category> categories) => CategoryLoaded(categories),
        onError: (error, stackTrace) => CategoryError(error.toString()),
      );
    } catch (e) {
      emit(CategoryError(e.toString()));
    }
  }

  void _onAddCategory(AddCategory event, Emitter<CategoryState> emit) async {
    try {
      await _categoryRepository.addCategory(event.name, event.shopId);
      emit(CategoryOperationSuccess('Category added successfully'));
    } catch (e) {
      emit(CategoryError(e.toString()));
    }
  }

  void _onUpdateCategory(
      UpdateCategory event, Emitter<CategoryState> emit) async {
    try {
      await _categoryRepository.updateCategory(event.category);
      emit(CategoryOperationSuccess('Category updated successfully'));
    } catch (e) {
      emit(CategoryError(e.toString()));
    }
  }

  void _onDeleteCategory(
      DeleteCategory event, Emitter<CategoryState> emit) async {
    try {
      await _categoryRepository.deleteCategory(event.categoryId, event.shopId);
      emit(CategoryOperationSuccess('Category deleted successfully'));
    } catch (e) {
      emit(CategoryError(e.toString()));
    }
  }

  void _onSearchCategories(
      SearchCategories event, Emitter<CategoryState> emit) async {
    emit(CategoryLoading());
    try {
      final categories =
          await _categoryRepository.searchCategories(event.query, event.shopId);
      emit(CategoryLoaded(categories));
    } catch (e) {
      emit(CategoryError(e.toString()));
    }
  }
}
