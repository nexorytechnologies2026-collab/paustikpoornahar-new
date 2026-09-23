import 'package:paustik_poornahar/common/enums/data_source_enum.dart';
import 'package:paustik_poornahar/common/models/product_model.dart';
import 'package:paustik_poornahar/common/models/restaurant_model.dart';
import 'package:paustik_poornahar/common/widgets/filter/domain/models/filter_data_model.dart';
import 'package:paustik_poornahar/features/category/domain/models/category_model.dart';
import 'package:get/get_connect/connect.dart';

abstract class CategoryServiceInterface{
  Future<List<CategoryModel>?> getCategoryList({DataSourceEnum? source, String? search});
  Future<List<CategoryModel>?> getSubCategoryList(String? parentID);
  Future<ProductModel?> getCategoryProductList(String? categoryID, FilterDataModel? filterDataModel);
  Future<RestaurantModel?> getCategoryRestaurantList(String? categoryID, FilterDataModel? filterDataModel);
  Future<Response> getSearchData(String? query, String? categoryID, bool isRestaurant, FilterDataModel? filterDataModel);
}