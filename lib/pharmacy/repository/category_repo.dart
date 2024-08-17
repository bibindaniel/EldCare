import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eldcare/pharmacy/model/category.dart';

class CategoryRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<List<Category>> getCategoriesStream(String shopId) {
    try {
      return _firestore
          .collection('shops')
          .doc(shopId)
          .collection('categories')
          .snapshots()
          .map((snapshot) {
        return snapshot.docs.map((doc) => Category.fromSnapshot(doc)).toList();
      });
    } catch (e) {
      throw Exception('Failed to get categories: $e');
    }
  }

  Future<String> addCategory(String name, String shopId) async {
    try {
      DocumentReference docRef = await _firestore
          .collection('shops')
          .doc(shopId)
          .collection('categories')
          .add({'name': name, 'shopId': shopId});
      return docRef.id;
    } catch (e) {
      throw Exception('Failed to add category: $e');
    }
  }

  Future<void> updateCategory(Category category) async {
    try {
      await _firestore
          .collection('shops')
          .doc(category.shopId)
          .collection('categories')
          .doc(category.id)
          .update(category.toMap());
    } catch (e) {
      throw Exception('Failed to update category: $e');
    }
  }

  Future<void> deleteCategory(String id, String shopId) async {
    try {
      await _firestore
          .collection('shops')
          .doc(shopId)
          .collection('categories')
          .doc(id)
          .delete();
    } catch (e) {
      throw Exception('Failed to delete category: $e');
    }
  }

  Future<List<Category>> searchCategories(String query, String shopId) async {
    try {
      final snapshot = await _firestore
          .collection('shops')
          .doc(shopId)
          .collection('categories')
          .where('name', isGreaterThanOrEqualTo: query)
          .where('name', isLessThanOrEqualTo: query + '\uf8ff')
          .get();
      return snapshot.docs.map((doc) => Category.fromSnapshot(doc)).toList();
    } catch (e) {
      throw Exception('Failed to search categories: $e');
    }
  }

  Future<bool> categoryExists(String name, String shopId) async {
    try {
      final snapshot = await _firestore
          .collection('shops')
          .doc(shopId)
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
