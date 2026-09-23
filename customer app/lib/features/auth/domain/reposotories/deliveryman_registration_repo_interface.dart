import 'package:paustik_poornahar/api/api_client.dart';
import 'package:paustik_poornahar/features/auth/domain/models/shift_model.dart';
import 'package:paustik_poornahar/features/auth/domain/models/vehicle_model.dart';
import 'package:paustik_poornahar/interface/repository_interface.dart';
import 'package:get/get_connect/http/src/response/response.dart';
import 'package:paustik_poornahar/features/auth/domain/models/zone_model.dart';

abstract class DeliverymanRegistrationRepoInterface extends RepositoryInterface{
  Future<List<VehicleModel>?> getVehicleList();
  Future<List<ShiftModel>?> getShiftList();
  Future<Response> registerDeliveryMan(Map<String, String> data, List<MultipartBody> multiParts, List<MultipartDocument> additionalDocument);
  @override
  Future<List<ZoneModel>?> getList({int? offset, bool? forDeliveryRegistration});
}