import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../constants/app_constants.dart';
import '../errors/exceptions.dart';

class ApiClient {
  final http.Client client;
  final String baseUrl;

  ApiClient({
    http.Client? client,
    this.baseUrl = AppConstants.baseUrl,
  }) : client = client ?? http.Client();

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

  Future<dynamic> post(
    String endpoint, {
    Map<String, dynamic>? body,
    String? token,
  }) async {
    final url = Uri.parse('$baseUrl$endpoint');
    try {
      final response = await client
          .post(
            url,
            headers: _headers(token),
            body: body != null ? jsonEncode(body) : null,
          )
          .timeout(AppConstants.requestTimeout);

      return _handleResponse(response);
    } on SocketException {
      throw NetworkException();
    } on TimeoutException {
      throw NetworkException(message: 'Request timed out. Please try again.');
    }
  }

  dynamic _handleResponse(http.Response response) {
    final dynamic body = response.body.isNotEmpty ? jsonDecode(response.body) : {};

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
