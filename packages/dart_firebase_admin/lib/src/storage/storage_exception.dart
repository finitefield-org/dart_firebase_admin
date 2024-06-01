part of 'storage.dart';

/// A generic guard wrapper for API calls to handle exceptions.
R _storageGuard<R>(R Function() cb) {
  try {
    final value = cb();

    if (value is Future) {
      return value.catchError(_handleException) as R;
    }

    return value;
  } catch (error, stackTrace) {
    _handleException(error, stackTrace);
  }
}

/// Converts a Exception to a FirebaseAdminException.
Never _handleException(Object exception, StackTrace stackTrace) {
  if (exception is storage1.DetailedApiRequestError) {
    Error.throwWithStackTrace(
      FirebaseStorageAdminException.fromServerError(exception),
      stackTrace,
    );
  }

  Error.throwWithStackTrace(exception, stackTrace);
}

class FirebaseStorageAdminException extends FirebaseAdminException {
  FirebaseStorageAdminException.fromServerError(
    this.serverError,
  ) : super('storage', 'unknown', serverError.message);

  /// The error thrown by the http/grpc client.
  ///
  /// This is exposed temporarily as a workaround until proper status codes
  /// are exposed officially.
  @experimental
  final storage1.DetailedApiRequestError serverError;

  @override
  String toString() =>
      'FirebaseStorageAdminException: $code: $message ${serverError.jsonResponse} ';
}
