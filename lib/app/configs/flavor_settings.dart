class FlavorSettings {
  final String apiBaseUrl;

  FlavorSettings.dev() : apiBaseUrl = 'https://api-dev.oremus.ci';

  FlavorSettings.prod() : apiBaseUrl = 'https://api.oremus.ci';
}
