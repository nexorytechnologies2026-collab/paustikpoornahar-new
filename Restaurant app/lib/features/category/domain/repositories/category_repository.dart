import 'package:paustik_poornahar_restaurant/api/api_client.dart';
import 'package:paustik_poornahar_restaurant/features/category/domain/models/category_model.dart';
import 'package:paustik_poornahar_restaurant/features/category/domain/repositories/category_repository_interface.dart';
import 'package:paustik_poornahar_restaurant/features/restaurant/domain/models/product_model.dart';
import 'package:paustik_poornahar_restaurant/util/app_constants.dart';
import 'package:get/get.dart';

class CategoryRepository implements CategoryRepositoryInterface {
  final ApiClient apiClient;
  CategoryRepository({required this.apiClient});

  @override
  Future<List<CategoryModel>?> getCategoryList({bool isRestaurantWise = false, String? search}) async {
    List<CategoryModel>? categoryList;
    Response response = await apiClient.getData(isRestaurantWise ? '${AppConstants.restaurantWiseCategoryUri}?search=$search' : AppConstants.categoryUri);
    if(response.statusCode == 200) {
      categoryList = [];
      response.body.forEach((category) => categoryList!.add(CategoryModel.fromJson(category)));
    }
    return categoryList;
  }

  @override
  Future<List<CategoryModel>?> getSubCategoryList(int? parentID, {bool isRestaurantWise = false}) async {
    List<CategoryModel>? subCategoryList;
    Response response = await apiClient.getData('${isRestaurantWise ? AppConstants.restaurantWiseSubCategoryUri : AppConstants.subCategoryUri}$parentID');
    if(response.statusCode == 200) {
      subCategoryList = [];
      response.body.forEach((subCategory) => subCategoryList!.add(CategoryModel.fromJson(subCategory)));
    }
    return subCategoryList;
  }

  @override
  Future<ProductModel?> getCategoryItemList({required String offset, required int id, required int isSubCategory}) async {
    ProductModel? productModel;
    Response response = await apiClient.getData('${AppConstants.categoryWiseProducts}?offset=$offset&limit=10&category_id=$id&sub_category=$isSubCategory');
    if(response.statusCode == 200) {
      productModel = ProductModel.fromJson(response.body);
    }
    return productModel;
  }

  @override
  Future add(value) {
    throw UnimplementedError();
  }

  @override
  Future delete({int? id}) {
    throw UnimplementedError();
  }

  @override
  Future get(int id) {
    throw UnimplementedError();
  }

  @override
  Future update(Map<String, dynamic> body) {
    throw UnimplementedError();
  }

  @override
  Future<dynamic> getList() {
    throw UnimplementedError();
  }

}