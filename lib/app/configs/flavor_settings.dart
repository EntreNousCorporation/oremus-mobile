import 'package:oremusapp/app/commons/enums.dart';

class FlavorSettings {
  final OremusFlavor oremusFlavor;

  //------------------------------------+
  //      For development section       |
  //------------------------------------+
  FlavorSettings.dev()
    : oremusFlavor = OremusFlavor(
        //apiBaseUrl: 'https://api-dev.oremus.ci',
        //customBaseUrl: 'https://report-dev.oremus.ci',
        apiBaseUrl: 'https://api.oremus.ci',
        customBaseUrl: 'https://report.oremus.ci',
        endpoint: '',
        shareAppLink: 'https://download-dev.oremus.ci/store-link',
        byPassAuth: false,
        canCheckConectivity: true,
        envCredentials: EnvCredentials.dev,
        oneSignalAppID: '25d270d6-2c54-4adb-83ea-6004918f7c29',
      );

  //------------------------------------+
  //       For production section       |
  //------------------------------------+
  FlavorSettings.prod()
    : oremusFlavor = OremusFlavor(
        apiBaseUrl: 'https://api.oremus.ci',
        customBaseUrl: 'https://report.oremus.ci',
        endpoint: '',
        shareAppLink: 'https://download.oremus.ci/store-link',
        byPassAuth: true,
        envCredentials: EnvCredentials.prod,
        oneSignalAppID: '0d127e7e-a1dd-4275-b268-bb7cc626e0db',
        showAppLogs: false,
      );
}

class OremusFlavor {
  final String? apiBaseUrl;
  final String? customBaseUrl;
  final String? endpoint;
  final String? shareAppLink;
  final String? oneSignalAppID;
  final bool? showAppLogs;
  final bool? bypassCert;
  final bool?
  byPassAuth; // True or False, whether we want to bypass the auth or not
  final bool? canCheckConectivity;
  final EnvCredentials? envCredentials;

  OremusFlavor({
    this.apiBaseUrl,
    this.customBaseUrl,
    this.endpoint,
    this.shareAppLink,
    this.oneSignalAppID,
    this.byPassAuth = false,
    this.canCheckConectivity = true,
    this.showAppLogs = true,
    this.bypassCert = true,
    this.envCredentials = EnvCredentials.dev,
  });
}
