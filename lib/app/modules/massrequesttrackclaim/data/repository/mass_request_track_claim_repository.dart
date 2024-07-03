import 'package:oremusapp/app/modules/massrequesttrackclaim/data/repository/interface_mass_request_track_claim_repository.dart';
import 'package:oremusapp/app/remote/api_client.dart';

class MassRequestTrackClaimRepository implements IMassRequestTrackClaimRepository {
  final ApiClient _apiClient;

  MassRequestTrackClaimRepository(this._apiClient);
}
