import 'package:oremusapp/app/commons/enums.dart';

class FlavorSettings {
  final OremusFlavor oremusFlavor;

  //------------------------------------+
  //      For development section       |
  //------------------------------------+
  FlavorSettings.dev()
    : oremusFlavor = OremusFlavor(
        apiBaseUrl: 'https://api-dev.oremus.ci',
        customBaseUrl: 'https://report-dev.oremus.ci',
        //apiBaseUrl: 'https://api.oremus.ci',
        //customBaseUrl: 'https://report.oremus.ci',
        endpoint: '',
        shareAppLink: 'https://download-dev.oremus.ci/store-link',
        moreInfo: 'https://linktr.ee/oremusci',
        byPassAuth: false,
        canCheckConectivity: true,
        envCredentials: EnvCredentials.dev,
        oneSignalAppID: 'cee3817e-bb25-46db-b96d-e46d070991f9',
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
        moreInfo: 'https://linktr.ee/oremusci',
        byPassAuth: true,
        envCredentials: EnvCredentials.prod,
        oneSignalAppID: '654fdc09-64bd-44a5-b4a3-8aefb05f546c',
        showAppLogs: false,
      );
}

class OremusFlavor {
  final String? apiBaseUrl;
  final String? customBaseUrl;
  final String? endpoint;
  final String? shareAppLink;
  final String? moreInfo;
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
    this.moreInfo,
    this.oneSignalAppID,
    this.byPassAuth = false,
    this.canCheckConectivity = true,
    this.showAppLogs = true,
    this.bypassCert = true,
    this.envCredentials = EnvCredentials.dev,
  });
}
