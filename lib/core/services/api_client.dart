import 'package:http/http.dart' as http;
import '../utils/fancy_logger.dart';

class ApiClient {
  final http.Client _client = http.Client();

  Future<http.Response> get(Uri url, {Map<String, String>? headers}) async {
    FancyLogger.apiRequest('GET', url.toString());
    try {
      final response = await _client.get(url, headers: headers);
      FancyLogger.apiResponse('GET', url.toString(), response.statusCode, response.body);
      return response;
    } catch (e) {
      FancyLogger.error('GET ${url.toString()} failed: $e');
      rethrow;
    }
  }

  Future<http.Response> post(Uri url, {Map<String, String>? headers, Object? body}) async {
    FancyLogger.apiRequest('POST', url.toString(), body);
    try {
      final response = await _client.post(url, headers: headers, body: body);
      FancyLogger.apiResponse('POST', url.toString(), response.statusCode, response.body);
      return response;
    } catch (e) {
      FancyLogger.error('POST ${url.toString()} failed: $e');
      rethrow;
    }
  }

  Future<http.Response> put(Uri url, {Map<String, String>? headers, Object? body}) async {
    FancyLogger.apiRequest('PUT', url.toString(), body);
    try {
      final response = await _client.put(url, headers: headers, body: body);
      FancyLogger.apiResponse('PUT', url.toString(), response.statusCode, response.body);
      return response;
    } catch (e) {
      FancyLogger.error('PUT ${url.toString()} failed: $e');
      rethrow;
    }
  }

    Future<http.Response> delete(Uri url, {Map<String, String>? headers, Object? body}) async {
    FancyLogger.apiRequest('DELETE', url.toString(), body);
    try {
      final response = await _client.delete(url, headers: headers, body: body);
      FancyLogger.apiResponse('DELETE', url.toString(), response.statusCode, response.body);
      return response;
    } catch (e) {
      FancyLogger.error('DELETE ${url.toString()} failed: $e');
      rethrow;
    }
  }
}
