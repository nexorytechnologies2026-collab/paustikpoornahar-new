import 'package:get/get_connect/connect.dart';
import 'package:paustik_poornahar_restaurant/features/business/domain/models/business_plan_body.dart';
import 'package:paustik_poornahar_restaurant/interface/repository_interface.dart';

abstract class BusinessRepositoryInterface<T> implements RepositoryInterface<T> {
  Future<Response> setUpBusinessPlan(BusinessPlanBody businessPlanBody);
}