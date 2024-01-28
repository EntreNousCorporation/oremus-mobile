import 'package:oremusapp/app/commons/enums.dart';

class FlavorSettings {
  final OremusFlavor oremusFlavor;

  //------------------------------------+
  //      For development section       |
  //------------------------------------+
  FlavorSettings.dev()
      : oremusFlavor = OremusFlavor(
          //apiBaseUrl: 'https://api-dev.oremus.ci',
          apiBaseUrl: 'https://api.oremus.ci',
          endpoint: '',
          byPassAuth: false,
          envCredentials: EnvCredentials.dev,
        );

  //------------------------------------+
  //       For production section       |
  //------------------------------------+
  FlavorSettings.prod()
      : oremusFlavor = OremusFlavor(
          apiBaseUrl: 'https://api.oremus.ci',
          endpoint: '',
          byPassAuth: true,
          envCredentials: EnvCredentials.prod,
        );
}

class OremusFlavor {
  final String? apiBaseUrl;
  final String? endpoint;
  final bool?
      byPassAuth; // True or False, whether we want to bypass the auth or not
  final EnvCredentials? envCredentials;

  OremusFlavor({
    this.apiBaseUrl,
    this.endpoint,
    this.byPassAuth = false,
    this.envCredentials = EnvCredentials.dev,
  });
}
