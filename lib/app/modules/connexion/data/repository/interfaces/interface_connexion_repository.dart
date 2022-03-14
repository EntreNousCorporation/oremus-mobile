import 'package:oremusapp/app/modules/connexion/data/model/connection.dart';
import 'package:oremusapp/app/modules/connexion/data/model/connection_response.dart';

abstract class IConnexionRepository {
  Future<ConnectionResponse> loginUser(Connection request);
}