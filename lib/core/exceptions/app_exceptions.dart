class AppException implements Exception {
  final String message;
  final String? code;
  final dynamic originalError;

  const AppException(
    this.message, {
    this.code,
    this.originalError,
  });

  @override
  String toString() => 'AppException: $message${code != null ? ' (Code: $code)' : ''}';
}

class UserDataException extends AppException {
  const UserDataException(super.message, {super.code, super.originalError});
}

class AdLoadException extends AppException {
  const AdLoadException(super.message, {super.code, super.originalError});
}

class PremiumSubscriptionException extends AppException {
  const PremiumSubscriptionException(super.message, {super.code, super.originalError});
}

class GameException extends AppException {
  const GameException(super.message, {super.code, super.originalError});
}