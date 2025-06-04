import 'package:oremusapp/app/modules/lifeplan/data/model/create_life_plan_request.dart';
import 'package:oremusapp/app/modules/lifeplan/data/model/life_plan.dart';
import 'package:oremusapp/app/modules/lifeplan/data/model/user_life_plan.dart';
import 'package:oremusapp/app/remote/data_response.dart';

abstract class ILifePlanRepository {
  Future<DataResponse<LifePlan>> getAvailableLifePlans({int? page = 0, int? size = 50});
  Future<DataResponse<UserLifePlan>> getUserLifePlans({int? page = 0, int? size = 10});
  Future<UserLifePlan> createUserLifePlan({required CreateLifePlanRequest request});
  Future<UserLifePlan> updateUserLifePlan({required int id, required UpdateLifePlanRequest request});
  Future<void> deleteUserLifePlan({required int id});
}