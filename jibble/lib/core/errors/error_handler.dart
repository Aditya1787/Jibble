import 'exceptions.dart';
import 'failures.dart';
import 'error_messages.dart';

class ErrorHandler {
  static Failure handleException(Exception exception) {
    if (exception is ServerException) {
      return ServerFailure(exception.message);
    } else if (exception is AuthException) {
      return ServerFailure(exception.message);
    } else {
      return ServerFailure(ErrorMessages.unknown);
    }
  }
}
