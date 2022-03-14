import 'package:oremusapp/app/modules/splashscreen/data/repository/interface_splashscreen_repository.dart';
import 'package:oremusapp/app/remote/api_client.dart';

class SplashscreenRepository implements ISplashscreenRepository {

  final ApiClient _apiClient;

  SplashscreenRepository(this._apiClient);

}