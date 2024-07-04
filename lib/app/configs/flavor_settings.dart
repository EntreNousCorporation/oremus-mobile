import 'package:oremusapp/app/commons/enums.dart';

class FlavorSettings {
  final OremusFlavor oremusFlavor;

  //------------------------------------+
  //      For development section       |
  //------------------------------------+
  FlavorSettings.dev()
      : oremusFlavor = OremusFlavor(
          apiBaseUrl: 'https://api-dev.oremus.ci',
          endpoint: '',
          shareAppLink: 'https://download-dev.oremus.ci/store-link',
          byPassAuth: false,
          canCheckConectivity: false,
          envCredentials: EnvCredentials.dev,
        );

  //------------------------------------+
  //       For production section       |
  //------------------------------------+
  FlavorSettings.prod()
      : oremusFlavor = OremusFlavor(
          apiBaseUrl: 'https://api.oremus.ci',
          endpoint: '',
          shareAppLink: 'https://download.oremus.ci/store-link',
          byPassAuth: true,
          envCredentials: EnvCredentials.prod,
        );
}

class OremusFlavor {
  final String? apiBaseUrl;
  final String? endpoint;
  final String? shareAppLink;
  final bool?
      byPassAuth; // True or False, whether we want to bypass the auth or not
  final bool? canCheckConectivity;
  final EnvCredentials? envCredentials;

  OremusFlavor({
    this.apiBaseUrl,
    this.endpoint,
    this.shareAppLink,
    this.byPassAuth = false,
    this.canCheckConectivity = true,
    this.envCredentials = EnvCredentials.dev,
  });
}
