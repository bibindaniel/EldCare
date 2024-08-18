import 'package:eldcare/pharmacy/model/inventory_batch.dart';
import 'package:eldcare/pharmacy/model/medicine.dart';

class ShopMedicine {
  final String id;
  final String medicineId;
  final String medicineName;
  final String categoryId;
  final String? categoryName;
  final String dosage;
  final int quantity;
  final DateTime expiryDate;
  final String supplier;
  final String lotNumber;
  final double price;
  final String shopId;
  final bool requiresPrescription;

  ShopMedicine({
    required this.id,
    required this.medicineId,
    required this.medicineName,
    required this.categoryId,
    this.categoryName,
    required this.dosage,
    required this.quantity,
    required this.expiryDate,
    required this.supplier,
    required this.lotNumber,
    required this.price,
    required this.shopId,
    required this.requiresPrescription,
  });

  factory ShopMedicine.fromMedicineAndBatch(
      Medicine medicine, InventoryBatch batch) {
    return ShopMedicine(
      id: batch.id,
      medicineId: medicine.id,
      medicineName: medicine.name,
      categoryId: medicine.categoryId,
      dosage: medicine.dosage,
      quantity: batch.quantity,
      expiryDate: batch.expiryDate,
      supplier: batch.supplier,
      lotNumber: batch.lotNumber,
      price: batch.price,
      shopId: medicine.shopId,
      requiresPrescription: medicine.requiresPrescription,
    );
  }
}
