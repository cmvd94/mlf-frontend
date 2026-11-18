import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/env_config.dart';
import '../constants/app_constants.dart';
import '../errors/exceptions.dart';
import '../logger/app_logger.dart';

class ApiClient {
  final http.Client client;
  final EnvConfig envConfig;

  ApiClient({
    http.Client? client,
    EnvConfig? envConfig,
  })  : client = client ?? http.Client(),
        envConfig = envConfig ?? EnvConfig();

  String get baseUrl => envConfig.baseUrl;

  Map<String, String> _headers([String? token]) {
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }

  Uri _buildUri(String endpoint, [Map<String, dynamic>? queryParams]) {
    final baseUri = Uri.parse('$baseUrl$endpoint');
    if (queryParams == null || queryParams.isEmpty) {
      return baseUri;
    }

    // Filter out null values and convert to string map
    final cleanParams = <String, String>{};
    queryParams.forEach((key, value) {
      if (value != null) {
        cleanParams[key] = value.toString();
      }
    });

    return baseUri.replace(queryParameters: cleanParams);
  }

  Future<dynamic> get(
    String endpoint, {
    Map<String, dynamic>? queryParams,
    String? token,
    Duration? timeout,
  }) async {
    final effectiveTimeout = timeout ?? AppConstants.requestTimeout;
    final url = _buildUri(endpoint, queryParams);
    AppLogger().i('HTTP GET $url', tag: 'ApiClient');
    try {
      final response = await client
          .get(url, headers: _headers(token))
          .timeout(effectiveTimeout);
      return _handleResponse(response, url.toString());
    } on TimeoutException catch (e, st) {
      AppLogger().e('HTTP GET Timeout: $url', tag: 'ApiClient', error: e, stackTrace: st);
      throw NetworkException(message: 'Request timed out. The server may be waking up, please try again.');
    } on http.ClientException catch (e, st) {
      AppLogger().e('HTTP GET ClientException: $url - ${e.message}', tag: 'ApiClient', error: e, stackTrace: st);
      throw NetworkException(message: 'Network error: ${e.message}');
    } catch (e, st) {
      if (e is! ServerException && e is! AuthException && e is! NetworkException) {
        AppLogger().e('HTTP GET Unexpected Error: $url - $e', tag: 'ApiClient', error: e, stackTrace: st);
      }
      if (e is ServerException || e is AuthException || e is NetworkException) {
        rethrow;
      }
      throw NetworkException(message: 'Unexpected network error: $e');
    }
  }

  Future<dynamic> post(
    String endpoint, {
    Map<String, dynamic>? body,
    String? token,
    Duration? timeout,
  }) async {
    final effectiveTimeout = timeout ?? AppConstants.requestTimeout;
    final url = _buildUri(endpoint);
    AppLogger().i('HTTP POST $url (body: ${body != null ? jsonEncode(body) : "none"})', tag: 'ApiClient');
    try {
      final response = await client
          .post(
            url,
            headers: _headers(token),
            body: body != null ? jsonEncode(body) : null,
          )
          .timeout(effectiveTimeout);
      return _handleResponse(response, url.toString());
    } on TimeoutException catch (e, st) {
      AppLogger().e('HTTP POST Timeout: $url', tag: 'ApiClient', error: e, stackTrace: st);
      throw NetworkException(message: 'Request timed out. The server may be waking up, please try again.');
    } on http.ClientException catch (e, st) {
      AppLogger().e('HTTP POST ClientException: $url - ${e.message}', tag: 'ApiClient', error: e, stackTrace: st);
      throw NetworkException(message: 'Network error: ${e.message}');
    } catch (e, st) {
      if (e is! ServerException && e is! AuthException && e is! NetworkException) {
        AppLogger().e('HTTP POST Unexpected Error: $url - $e', tag: 'ApiClient', error: e, stackTrace: st);
      }
      if (e is ServerException || e is AuthException || e is NetworkException) {
        rethrow;
      }
      throw NetworkException(message: 'Unexpected network error: $e');
    }
  }

  Future<dynamic> patch(
    String endpoint, {
    Map<String, dynamic>? body,
    String? token,
    Duration? timeout,
  }) async {
    final effectiveTimeout = timeout ?? AppConstants.requestTimeout;
    final url = _buildUri(endpoint);
    AppLogger().i('HTTP PATCH $url (body: ${body != null ? jsonEncode(body) : "none"})', tag: 'ApiClient');
    try {
      final response = await client
          .patch(
            url,
            headers: _headers(token),
            body: body != null ? jsonEncode(body) : null,
          )
          .timeout(effectiveTimeout);
      return _handleResponse(response, url.toString());
    } on TimeoutException catch (e, st) {
      AppLogger().e('HTTP PATCH Timeout: $url', tag: 'ApiClient', error: e, stackTrace: st);
      throw NetworkException(message: 'Request timed out. The server may be waking up, please try again.');
    } on http.ClientException catch (e, st) {
      AppLogger().e('HTTP PATCH ClientException: $url - ${e.message}', tag: 'ApiClient', error: e, stackTrace: st);
      throw NetworkException(message: 'Network error: ${e.message}');
    } catch (e, st) {
      if (e is! ServerException && e is! AuthException && e is! NetworkException) {
        AppLogger().e('HTTP PATCH Unexpected Error: $url - $e', tag: 'ApiClient', error: e, stackTrace: st);
      }
      if (e is ServerException || e is AuthException || e is NetworkException) {
        rethrow;
      }
      throw NetworkException(message: 'Unexpected network error: $e');
    }
  }

  Future<dynamic> delete(
    String endpoint, {
    Map<String, dynamic>? queryParams,
    String? token,
    Duration? timeout,
  }) async {
    final effectiveTimeout = timeout ?? AppConstants.requestTimeout;
    final url = _buildUri(endpoint, queryParams);
    AppLogger().i('HTTP DELETE $url', tag: 'ApiClient');
    try {
      final response = await client
          .delete(url, headers: _headers(token))
          .timeout(effectiveTimeout);
      return _handleResponse(response, url.toString());
    } on TimeoutException catch (e, st) {
      AppLogger().e('HTTP DELETE Timeout: $url', tag: 'ApiClient', error: e, stackTrace: st);
      throw NetworkException(message: 'Request timed out. The server may be waking up, please try again.');
    } on http.ClientException catch (e, st) {
      AppLogger().e('HTTP DELETE ClientException: $url - ${e.message}', tag: 'ApiClient', error: e, stackTrace: st);
      throw NetworkException(message: 'Network error: ${e.message}');
    } catch (e, st) {
      if (e is! ServerException && e is! AuthException && e is! NetworkException) {
        AppLogger().e('HTTP DELETE Unexpected Error: $url - $e', tag: 'ApiClient', error: e, stackTrace: st);
      }
      if (e is ServerException || e is AuthException || e is NetworkException) {
        rethrow;
      }
      throw NetworkException(message: 'Unexpected network error: $e');
    }
  }

  dynamic _handleResponse(http.Response response, String requestUrl) {
    dynamic body;
    try {
      body = response.body.isNotEmpty ? jsonDecode(response.body) : {};
    } catch (_) {
      body = {'message': response.body};
    }

    if (response.statusCode >= 200 && response.statusCode < 300) {
      AppLogger().i('HTTP SUCCESS ${response.statusCode} - $requestUrl', tag: 'ApiClient');
      return body;
    } else if (response.statusCode == 401 || response.statusCode == 403) {
      final message = body is Map && body['message'] != null
          ? body['message'].toString()
          : 'Authentication failed';
      AppLogger().w('HTTP AUTH ERROR ${response.statusCode} - $requestUrl: $message', tag: 'ApiClient');
      throw AuthException(message: message);
    } else {
      final message = body is Map && body['message'] != null
          ? body['message'].toString()
          : 'Server returned error ${response.statusCode}';
      AppLogger().e('HTTP SERVER ERROR ${response.statusCode} - $requestUrl: $message', tag: 'ApiClient');
      throw ServerException(message: message, statusCode: response.statusCode);
    }
  }
}
