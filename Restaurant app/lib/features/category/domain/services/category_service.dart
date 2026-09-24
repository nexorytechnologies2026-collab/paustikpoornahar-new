import 'package:paustik_poornahar_restaurant/features/category/domain/models/category_model.dart';
import 'package:paustik_poornahar_restaurant/features/category/domain/repositories/category_repository_interface.dart';
import 'package:paustik_poornahar_restaurant/features/category/domain/services/categoty_service_interface.dart';
import 'package:paustik_poornahar_restaurant/features/restaurant/domain/models/product_model.dart';

class CategoryService implements CategoryServiceInterface {
  final CategoryRepositoryInterface categoryRepositoryInterface;
  CategoryService({required this.categoryRepositoryInterface});

  @override
  Future<List<CategoryModel>?> getCategoryList({bool isRestaurantWise = false, String? search}) async {
    return await categoryRepositoryInterface.getCategoryList(isRestaurantWise: isRestaurantWise, search: search);
  }

  @override
  Future<List<CategoryModel>?> getSubCategoryList(int? parentID, {bool isRestaurantWise = false}) async {
    return await categoryRepositoryInterface.getSubCategoryList(parentID, isRestaurantWise: isRestaurantWise);
  }

  @override
  Future<ProductModel?> getCategoryItemList({required String offset, required int id, required int isSubCategory}) async {
    return await categoryRepositoryInterface.getCategoryItemList(offset: offset, id: id, isSubCategory: isSubCategory);
  }

}