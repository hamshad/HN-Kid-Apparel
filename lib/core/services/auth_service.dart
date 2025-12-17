import 'dart:convert';
import 'api_client.dart';
import 'storage_service.dart';
import '../constants/api_constants.dart';
import '../../shared/models/user.dart';
import '../../shared/models/user_profile.dart'; // import was already there
import '../../features/auth/models/register_models.dart';

class AuthService {
  final ApiClient _client = ApiClient();
  final StorageService _storage = StorageService();

  Future<AuthResponse> login(String email, String password) async {
    try {
      final response = await _client.post(
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

  Future<RegisterResponse> registerSeller(RegisterRequest request) async {
    try {
      final response = await _client.post(
        Uri.parse('${ApiConstants.baseUrl}${ApiConstants.registerEndpoint}'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(request.toJson()),
      );

      final Map<String, dynamic> body = jsonDecode(response.body);
      return RegisterResponse.fromJson(body);
    } catch (e) {
      // Return a failure response in case of network error or parse error
      return RegisterResponse(
        success: false,
        message: 'Network error: $e',
        statusCode: 500,
      );
    }
  }

  Future<void> logout() async {
    try {
      final token = await _storage.getToken();
      await _client.post(
        Uri.parse('${ApiConstants.baseUrl}${ApiConstants.logoutEndpoint}'),
         headers: {
           'Content-Type': 'application/json',
           if (token != null) 'Authorization': 'Bearer $token',
         },
      );
    } catch (e) {
      // Logout error can be ignored locally, but logging it is good practice
      // ApiClient logs errors, so we might just let it be or do extra handling
    }
  }

  Future<UserProfileResponse> getProfile() async {
    try {
      final token = await _storage.getToken();
      final response = await _client.get(
        Uri.parse('${ApiConstants.baseUrl}/api/User/profile'),
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );
      
      final Map<String, dynamic> body = jsonDecode(response.body);
      return UserProfileResponse.fromJson(body);
    } catch (e) {
      return UserProfileResponse(
        success: false,
        message: 'Network error: $e',
        statusCode: 500,
      );
    }
  }

  Future<UserProfileResponse> updateProfile(UpdateProfileRequest request) async {
    try {
      final token = await _storage.getToken();
      final response = await _client.put(
        Uri.parse('${ApiConstants.baseUrl}/api/User/profile'),
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
        body: jsonEncode(request.toJson()),
      );

      final Map<String, dynamic> body = jsonDecode(response.body);
      return UserProfileResponse.fromJson(body); 
    } catch (e) {
      return UserProfileResponse(
        success: false,
        message: 'Network error: $e',
        statusCode: 500,
      );
    }
  }

}

