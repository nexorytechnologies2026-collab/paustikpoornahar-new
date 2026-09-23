import 'package:paustik_poornahar/common/enums/data_source_enum.dart';
import 'package:paustik_poornahar/common/models/response_model.dart';
import 'package:paustik_poornahar/features/address/domain/models/address_model.dart';

abstract class AddressServiceInterface{
  Future<List<AddressModel>?> getList({bool isLocal = false, DataSourceEnum? source});
  Future<ResponseModel> add(AddressModel addressModel, bool fromCheckout, int? restaurantZoneId);
  Future<ResponseModel> update(Map<String, dynamic> body, int? addressId);
  Future<ResponseModel> delete(int id);
  List<AddressModel> filterAddresses(List<AddressModel> addresses, String queryText);
  Future<ResponseModel> markDefault(int id);
}