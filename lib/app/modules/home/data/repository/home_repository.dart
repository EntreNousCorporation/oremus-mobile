import 'package:oremusapp/app/modules/home/data/repository/interface_home_repository.dart';
import 'package:oremusapp/app/remote/api_client.dart';

class HomeRepository implements IHomeRepository {

  final ApiClient _apiClient;

  HomeRepository(this._apiClient);
}
