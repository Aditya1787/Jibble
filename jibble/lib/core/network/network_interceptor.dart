import '../utils/logger.dart';

class NetworkInterceptor {
  static void logRequest(String url, Map<String, dynamic>? params) {
    AppLogger.log('REQ: $url | Params: $params', tag: 'NETWORK');
  }

  static void logResponse(String url, dynamic response) {
    AppLogger.log('RES: $url | Data: $response', tag: 'NETWORK');
  }
}
