import 'package:json_annotation/json_annotation.dart';

part 'register_models.g.dart';

/// Request model for user registration
class RegisterRequest {
  final String name;
  final String email;
  final String phoneNumber;
  final String password;
  final String confirmPassword;
  final String role;
  final String? shopName;
  final String? address;
  final String? gst;

  RegisterRequest({
    required this.name,
    required this.email,
    required this.phoneNumber,
    required this.password,
    required this.confirmPassword,
    required this.role,
    this.shopName,
    this.address,
    this.gst,
  });

  Map<String, dynamic> toJson() {
    final json = {
      'Name': name,
      'Email': email,
      'PhoneNumber': phoneNumber,
      'Password': password,
      'ConfirmPassword': confirmPassword,
      'Role': role,
    };
    
    // Only include optional fields if they are not null and not empty
    if (shopName != null && shopName!.isNotEmpty) {
      json['ShopName'] = shopName!;
    }
    if (address != null && address!.isNotEmpty) {
      json['Address'] = address!;
    }
    if (gst != null && gst!.isNotEmpty) {
      json['GST'] = gst!;
    }
    
    return json;
  }
}

/// Response model for registration API
@JsonSerializable()
class RegisterResponse {
  @JsonKey(name: 'Data')
  final RegisterData? data;
  @JsonKey(name: 'Success')
  final bool success;
  @JsonKey(name: 'Message')
  final String message;
  @JsonKey(name: 'StatusCode')
  final int statusCode;

  RegisterResponse({
    this.data,
    required this.success,
    required this.message,
    required this.statusCode,
  });

  factory RegisterResponse.fromJson(Map<String, dynamic> json) =>
      _$RegisterResponseFromJson(json);
  Map<String, dynamic> toJson() => _$RegisterResponseToJson(this);
}

/// Data object containing registration details
@JsonSerializable()
class RegisterData {
  @JsonKey(name: 'Success')
  final bool success;
  @JsonKey(name: 'Message')
  final String message;
  @JsonKey(name: 'Token')
  final String? token;
  @JsonKey(name: 'RefreshToken')
  final String? refreshToken;
  @JsonKey(name: 'ExpiresAt')
  final String? expiresAt;
  @JsonKey(name: 'User')
  final RegisteredUser? user;

  RegisterData({
    required this.success,
    required this.message,
    this.token,
    this.refreshToken,
    this.expiresAt,
    this.user,
  });

  factory RegisterData.fromJson(Map<String, dynamic> json) =>
      _$RegisterDataFromJson(json);
  Map<String, dynamic> toJson() => _$RegisterDataToJson(this);
}

/// Registered user details
@JsonSerializable()
class RegisteredUser {
  @JsonKey(name: 'Id')
  final String id;
  @JsonKey(name: 'Email')
  final String email;
  @JsonKey(name: 'UserName')
  final String userName;
  @JsonKey(name: 'UserId')
  final int userId;
  @JsonKey(name: 'Name')
  final String name;
  @JsonKey(name: 'PhoneNumber')
  final String phoneNumber;
  @JsonKey(name: 'CreatedAt')
  final String createdAt;

  RegisteredUser({
    required this.id,
    required this.email,
    required this.userName,
    required this.userId,
    required this.name,
    required this.phoneNumber,
    required this.createdAt,
  });

  factory RegisteredUser.fromJson(Map<String, dynamic> json) =>
      _$RegisteredUserFromJson(json);
  Map<String, dynamic> toJson() => _$RegisteredUserToJson(this);
}
