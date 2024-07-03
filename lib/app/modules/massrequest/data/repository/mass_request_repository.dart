import 'package:oremusapp/app/modules/massrequest/data/repository/interface_mass_request_repository.dart';
import 'package:oremusapp/app/remote/api_client.dart';

class MassRequestRepository implements IMassRequestRepository {
  final ApiClient _apiClient;

  MassRequestRepository(this._apiClient);

}
