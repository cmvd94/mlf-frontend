import '../errors/exceptions.dart';

String cleanErrorMessage(dynamic error) {
  if (error == null) return 'An error occurred';
  if (error is ServerException) return _sanitize(error.message);
  if (error is AuthException) return _sanitize(error.message);
  if (error is NetworkException) return _sanitize(error.message);
  if (error is CacheException) return _sanitize(error.message);

  String msg = error.toString();
  // Strip any Exception prefix: e.g. "ServerException: ", "Exception: ", etc.
  msg = msg.replaceFirst(RegExp(r'^[A-Za-z]*Exception:\s*'), '');
  // Strip any trailing status code e.g. " (Status: 400)"
  msg = msg.replaceFirst(RegExp(r'\s*\(Status:\s*\d+\)$'), '');
  return _sanitize(msg.trim());
}

String _sanitize(String msg) {
  return msg
      .replaceAll('serverUser', 'user')
      .replaceAll('ServerUser', 'User')
      .replaceAll('server user', 'user')
      .replaceAll('Server user', 'User');
}
