import 'package:paustik_poornahar/common/enums/data_source_enum.dart';
import 'package:paustik_poornahar/common/models/product_model.dart';
import 'package:paustik_poornahar/common/models/response_model.dart';
import 'package:paustik_poornahar/common/models/review_model.dart';
import 'package:paustik_poornahar/features/product/domain/models/review_body_model.dart';
import 'package:paustik_poornahar/interface/repository_interface.dart';

abstract class ReviewRepositoryInterface extends RepositoryInterface {
  @override
  Future<List<Product>?> getList({int? offset, String type, DataSourceEnum? source});
  Future<ResponseModel> submitReview(ReviewBodyModel reviewBody, bool isProduct);
  Future<List<ReviewModel>?> getRestaurantReviewList(String? restaurantID);
}