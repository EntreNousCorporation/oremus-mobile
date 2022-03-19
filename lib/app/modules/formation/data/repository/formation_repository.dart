import 'package:oremusapp/app/modules/formation/data/repository/interface_formation_repository.dart';
import 'package:oremusapp/app/remote/api_client.dart';

class FormationRepository implements IFormationRepository {

  final ApiClient _apiClient;

  FormationRepository(this._apiClient);
}
