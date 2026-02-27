import '../utils/result.dart';

class AuthFailure extends AppException {
  AuthFailure(String message, {Object? cause, StackTrace? stackTrace})
      : super(message, cause: cause, stackTrace: stackTrace);
}

class FirestoreFailure extends AppException {
  FirestoreFailure(String message, {Object? cause, StackTrace? stackTrace})
      : super(message, cause: cause, stackTrace: stackTrace);
}

class NetworkFailure extends AppException {
  NetworkFailure(String message, {Object? cause, StackTrace? stackTrace})
      : super(message, cause: cause, stackTrace: stackTrace);
}

class ValidationFailure extends AppException {
  ValidationFailure(String message, {Object? cause, StackTrace? stackTrace})
      : super(message, cause: cause, stackTrace: stackTrace);
}
