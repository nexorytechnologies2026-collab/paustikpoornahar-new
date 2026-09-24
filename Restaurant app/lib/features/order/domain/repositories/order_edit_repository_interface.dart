import 'package:paustik_poornahar_restaurant/common/models/response_model.dart';
import 'package:paustik_poornahar_restaurant/features/order/domain/models/place_order_model.dart';
import 'package:paustik_poornahar_restaurant/interface/repository_interface.dart';
import 'package:paustik_poornahar_restaurant/features/order/domain/models/cart_model.dart';
import 'package:paustik_poornahar_restaurant/features/restaurant/domain/models/product_model.dart';

abstract class OrderEditRepositoryInterface implements RepositoryInterface {
  Future<ProductModel?> getSearchProduct({required int offset, required String productName});
  void addToSharedPrefCartList(List<CartModel> cartProductList);
  Future<ResponseModel> updateOrder(PlaceOrderModel placeOrderModel);
}