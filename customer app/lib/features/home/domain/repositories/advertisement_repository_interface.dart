import 'package:paustik_poornahar/common/enums/data_source_enum.dart';
import 'package:paustik_poornahar/features/home/domain/models/advertisement_model.dart';
import 'package:paustik_poornahar/interface/repository_interface.dart';

abstract class AdvertisementRepositoryInterface extends RepositoryInterface{
  @override
  Future<List<AdvertisementModel>?> getList({int? offset, DataSourceEnum? source});
}