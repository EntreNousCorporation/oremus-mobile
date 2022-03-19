import 'package:oremusapp/app/modules/paroisse/data/repository/interface_paroisse_repository.dart';
import 'package:oremusapp/app/remote/api_client.dart';

class ParoisseRepository implements IParoisseRepository {

  final ApiClient _apiClient;

  ParoisseRepository(this._apiClient);
}
