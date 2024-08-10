import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eldcare/pharmacy/model/category.dart';

class CategoryRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<List<Category>> getCategoriesStream() {
    try {
      return _firestore.collection('categories').snapshots().map((snapshot) {
        return snapshot.docs.map((doc) => Category.fromSnapshot(doc)).toList();
      });
    } catch (e) {
      throw Exception('Failed to get categories: $e');
    }
  }

  Future<String> addCategory(String name) async {
    try {
      DocumentReference docRef =
          await _firestore.collection('categories').add({'name': name});
      return docRef.id;
    } catch (e) {
      throw Exception('Failed to add category: $e');
    }
  }

  Future<void> updateCategory(Category category) async {
    try {
      await _firestore
          .collection('categories')
          .doc(category.id)
          .update({'name': category.name});
    } catch (e) {
      throw Exception('Failed to update category: $e');
    }
  }

  Future<void> deleteCategory(String id) async {
    try {
      await _firestore.collection('categories').doc(id).delete();
    } catch (e) {
      throw Exception('Failed to delete category: $e');
    }
  }

  Future<List<Category>> searchCategories(String query) async {
    try {
      final snapshot = await _firestore
          .collection('categories')
          .where('name', isGreaterThanOrEqualTo: query)
          .where('name', isLessThanOrEqualTo: query + '\uf8ff')
          .get();
      return snapshot.docs.map((doc) => Category.fromSnapshot(doc)).toList();
    } catch (e) {
      throw Exception('Failed to search categories: $e');
    }
  }

  Future<bool> categoryExists(String name) async {
    try {
      final snapshot = await _firestore
          .collection('categories')
          .where('name', isEqualTo: name)
          .limit(1)
          .get();
      return snapshot.docs.isNotEmpty;
    } catch (e) {
      throw Exception('Failed to check if category exists: $e');
    }
  }
}
