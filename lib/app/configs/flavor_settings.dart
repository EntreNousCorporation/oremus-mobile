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
          oneSignalAppID: '25d270d6-2c54-4adb-83ea-6004918f7c29',
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
          oneSignalAppID: '0d127e7e-a1dd-4275-b268-bb7cc626e0db',
        );
}

class OremusFlavor {
  final String? apiBaseUrl;
  final String? endpoint;
  final String? shareAppLink;
  final String? oneSignalAppID;
  final bool? byPassAuth; // True or False, whether we want to bypass the auth or not
  final bool? canCheckConectivity;
  final EnvCredentials? envCredentials;

  OremusFlavor({
    this.apiBaseUrl,
    this.endpoint,
    this.shareAppLink,
    this.oneSignalAppID,
    this.byPassAuth = false,
    this.canCheckConectivity = true,
    this.envCredentials = EnvCredentials.dev,
  });
}
