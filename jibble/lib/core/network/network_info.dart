// Stub interface for network connection checking.
// Typically implemented using internet_connection_checker or connectivity_plus package.
abstract class NetworkInfo {
  Future<bool> get isConnected;
}

class NetworkInfoImpl implements NetworkInfo {
  @override
  Future<bool> get isConnected async => true; // implement actual check
}
