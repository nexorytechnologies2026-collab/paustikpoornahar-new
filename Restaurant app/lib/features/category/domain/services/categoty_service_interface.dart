import 'package:paustik_poornahar_restaurant/features/restaurant/domain/models/product_model.dart';

abstract class CategoryServiceInterface {
  Future<dynamic> getCategoryList({bool isRestaurantWise = false, String? search});
  Future<dynamic> getSubCategoryList(int? parentID, {bool isRestaurantWise = false});
  Future<ProductModel?> getCategoryItemList({required String offset, required int id, required int isSubCategory});
}