/// Lightweight Result type to model success/failure without throwing.
sealed class Result<T> {
  const Result();

  bool get isSuccess => this is Success<T>;
  bool get isFailure => this is Failure<T>;

  R fold<R>(R Function(T value) onSuccess, R Function(AppException error) onFailure) {
    final self = this;
    if (self is Success<T>) return onSuccess(self.value);
    if (self is Failure<T>) return onFailure(self.error);
    throw StateError('Unhandled Result state');
  }
}

class Success<T> extends Result<T> {
  const Success(this.value);
  final T value;
}

class Failure<T> extends Result<T> {
  const Failure(this.error);
  final AppException error;
}

/// Base class for domain-safe exceptions.
abstract class AppException implements Exception {
  AppException(this.message, {this.cause, this.stackTrace});
  final String message;
  final Object? cause;
  final StackTrace? stackTrace;

  @override
  String toString() => message;
}
