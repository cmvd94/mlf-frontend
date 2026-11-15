import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/env_config.dart';
import '../constants/app_constants.dart';
import '../errors/exceptions.dart';

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
  }) async {
    final url = _buildUri(endpoint, queryParams);
    try {
      final response = await client
          .get(url, headers: _headers(token))
          .timeout(AppConstants.requestTimeout);
      return _handleResponse(response);
    } on TimeoutException {
      throw NetworkException(message: 'Request timed out. Please check your connection.');
    } on http.ClientException catch (e) {
      throw NetworkException(message: 'Network error: ${e.message}');
    } catch (e) {
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
  }) async {
    final url = _buildUri(endpoint);
    try {
      final response = await client
          .post(
            url,
            headers: _headers(token),
            body: body != null ? jsonEncode(body) : null,
          )
          .timeout(AppConstants.requestTimeout);
      return _handleResponse(response);
    } on TimeoutException {
      throw NetworkException(message: 'Request timed out. Please check your connection.');
    } on http.ClientException catch (e) {
      throw NetworkException(message: 'Network error: ${e.message}');
    } catch (e) {
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
  }) async {
    final url = _buildUri(endpoint);
    try {
      final response = await client
          .patch(
            url,
            headers: _headers(token),
            body: body != null ? jsonEncode(body) : null,
          )
          .timeout(AppConstants.requestTimeout);
      return _handleResponse(response);
    } on TimeoutException {
      throw NetworkException(message: 'Request timed out. Please check your connection.');
    } on http.ClientException catch (e) {
      throw NetworkException(message: 'Network error: ${e.message}');
    } catch (e) {
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
  }) async {
    final url = _buildUri(endpoint, queryParams);
    try {
      final response = await client
          .delete(url, headers: _headers(token))
          .timeout(AppConstants.requestTimeout);
      return _handleResponse(response);
    } on TimeoutException {
      throw NetworkException(message: 'Request timed out. Please check your connection.');
    } on http.ClientException catch (e) {
      throw NetworkException(message: 'Network error: ${e.message}');
    } catch (e) {
      if (e is ServerException || e is AuthException || e is NetworkException) {
        rethrow;
      }
      throw NetworkException(message: 'Unexpected network error: $e');
    }
  }

  dynamic _handleResponse(http.Response response) {
    dynamic body;
    try {
      body = response.body.isNotEmpty ? jsonDecode(response.body) : {};
    } catch (_) {
      body = {'message': response.body};
    }

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return body;
    } else if (response.statusCode == 401 || response.statusCode == 403) {
      final message = body is Map && body['message'] != null
          ? body['message'].toString()
          : 'Authentication failed';
      throw AuthException(message: message);
    } else {
      final message = body is Map && body['message'] != null
          ? body['message'].toString()
          : 'Server returned error ${response.statusCode}';
      throw ServerException(message: message, statusCode: response.statusCode);
    }
  }
}
