abstract class Failure {
  final String message;
  const Failure(this.message);

  @override
  String toString() => message;
}

class ServerFailure extends Failure {
  final int? statusCode;
  const ServerFailure(String message, {this.statusCode}) : super(message);
}

class NetworkFailure extends Failure {
  const NetworkFailure([String message = 'Please check your internet connection'])
      : super(message);
}

class CacheFailure extends Failure {
  const CacheFailure([String message = 'Local storage failure']) : super(message);
}

class AuthFailure extends Failure {
  const AuthFailure(String message) : super(message);
}
