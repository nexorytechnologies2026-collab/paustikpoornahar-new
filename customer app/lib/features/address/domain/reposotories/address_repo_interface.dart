import 'package:paustik_poornahar/common/enums/data_source_enum.dart';
import 'package:paustik_poornahar/common/models/response_model.dart';
import 'package:paustik_poornahar/features/address/domain/models/address_model.dart';
import 'package:paustik_poornahar/interface/repository_interface.dart';

abstract class AddressRepoInterface<T> implements RepositoryInterface<AddressModel> {
  @override
  Future<List<AddressModel>?> getList({int? offset, bool isLocal = false, DataSourceEnum? source});
  Future<ResponseModel> markDefault(int id);
}