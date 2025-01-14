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
  ACCEPTED,
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
