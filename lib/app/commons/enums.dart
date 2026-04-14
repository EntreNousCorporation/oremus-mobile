enum HttpMethod {
  get,
  post,
  patch,
  put,
  delete,
}

enum EnvCredentials {
  dev,
  prod,
}

enum PaymentStatus {
  REFUSED,
  PENDING,
  INITIATED,
  INIT,
  ACCEPTED,
  FAILED,
  NONE,
}

enum TimeRange {
  morning, // 00h01-09h00 -> afficher à partir de 12h
  afternoon, // 09h01-15h00 -> afficher à partir de 18h
  evening // 15h01-00h00 -> afficher à partir de 12h le lendemain
}

enum RepetitionType {
  once,
  many,
  none,
}

enum EntityType {
  worship,
  oremus,
  none,
}

enum PaymentType {
  massRequest,
  donation,
  none,
}

enum SearchType {
  advanced,  // Recherche avancée avec filtres (utilise /places-of-worship)
  simple     // Recherche simple par texte/horaire (utilise /worship-places)
}