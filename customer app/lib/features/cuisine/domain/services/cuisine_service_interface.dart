import 'package:paustik_poornahar/common/enums/data_source_enum.dart';
import 'package:paustik_poornahar/common/widgets/filter/domain/models/filter_data_model.dart';
import 'package:paustik_poornahar/features/cuisine/domain/models/cuisine_model.dart';
import 'package:paustik_poornahar/features/cuisine/domain/models/cuisine_restaurants_model.dart';

abstract class CuisineServiceInterface{
  Future<CuisineModel?> getCuisineList({DataSourceEnum? source, String? search});
  List<int?> generateCuisineIds(CuisineModel? cuisineModel);
  Future<CuisineRestaurantModel?> getRestaurantList(int cuisineId, {String? name, FilterDataModel? filterDataModel});
  Future<bool> saveSearchHistory(List<String> searchHistories);
  List<String> getSearchHistory();
  Future<bool> clearSearchHistory();
}