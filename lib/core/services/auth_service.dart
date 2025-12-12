import 'dart:convert';
import 'package:http/http.dart' as http;
import '../constants/api_constants.dart';
import '../../shared/models/user.dart';

class AuthService {
  Future<AuthResponse> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConstants.baseUrl}${ApiConstants.loginEndpoint}'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'Email': email,
          'Password': password,
        }),
      );

      // The API returns 200 even for some logical errors if we look at usage, 
      // but standard HTTP might return others.
      // Based on the request, we expect a JSON body.
      final Map<String, dynamic> body = jsonDecode(response.body);
      return AuthResponse.fromJson(body);
    } catch (e) {
      // Return a failure response in case of network error or parse error
      return AuthResponse(
        success: false,
        message: 'Network error: $e',
        statusCode: 500,
      );
    }
  }
}
