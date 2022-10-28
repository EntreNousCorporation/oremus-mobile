part of internet_connection_checker;

/// Represents the status of the data connection.
/// Returned by [InternetConnectionChecker.connectionStatus]
enum InternetConnectionStatus {
  /// connected to internet
  connected,

  /// disconnected from internet
  disconnected,
}
