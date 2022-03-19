import 'package:oremusapp/app/modules/formation/data/repository/interface_formation_repository.dart';
import 'package:oremusapp/app/modules/service/data/repository/interface_service_repository.dart';
import 'package:oremusapp/app/remote/api_client.dart';

class ServiceRepository implements IServiceRepository {

  final ApiClient _apiClient;

  ServiceRepository(this._apiClient);
}
