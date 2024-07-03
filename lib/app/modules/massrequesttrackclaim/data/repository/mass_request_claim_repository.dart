import 'package:oremusapp/app/modules/massrequesttrackclaim/data/repository/interface_mass_request_claim_repository.dart';
import 'package:oremusapp/app/remote/api_client.dart';

class MassRequestClaimRepository implements IMassRequestClaimRepository {
  final ApiClient _apiClient;

  MassRequestClaimRepository(this._apiClient);

}
