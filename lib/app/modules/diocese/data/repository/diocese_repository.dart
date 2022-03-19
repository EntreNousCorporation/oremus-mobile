import 'package:oremusapp/app/modules/diocese/data/repository/interface_diocese_repository.dart';
import 'package:oremusapp/app/remote/api_client.dart';

class DioceseRepository implements IDioceseRepository {

  final ApiClient _apiClient;

  DioceseRepository(this._apiClient);
}
