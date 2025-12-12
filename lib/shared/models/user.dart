
class User {
  final String id;
  final String email;
  final String userName;
  final int userId;
  final String? name;
  final String? phoneNumber;
  final List<String> roles;
  final String createdAt;

  User({
    required this.id,
    required this.email,
    required this.userName,
    required this.userId,
    this.name,
    this.phoneNumber,
    required this.roles,
    required this.createdAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['Id'],
      email: json['Email'],
      userName: json['UserName'],
      userId: json['UserId'],
      name: json['Name'],
      phoneNumber: json['PhoneNumber'],
      roles: List<String>.from(json['Roles'] ?? []),
      createdAt: json['CreatedAt'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'Id': id,
      'Email': email,
      'UserName': userName,
      'UserId': userId,
      'Name': name,
      'PhoneNumber': phoneNumber,
      'Roles': roles,
      'CreatedAt': createdAt,
    };
  }
}

class AuthResponseData {
  final bool success;
  final String message;
  final String token;
  final String refreshToken;
  final String expiresAt;
  final User user;

  AuthResponseData({
    required this.success,
    required this.message,
    required this.token,
    required this.refreshToken,
    required this.expiresAt,
    required this.user,
  });

  factory AuthResponseData.fromJson(Map<String, dynamic> json) {
    return AuthResponseData(
      success: json['Success'],
      message: json['Message'],
      token: json['Token'],
      refreshToken: json['RefreshToken'],
      expiresAt: json['ExpiresAt'],
      user: User.fromJson(json['User']),
    );
  }
}

class AuthResponse {
  final AuthResponseData? data;
  final bool success;
  final String? message;
  final int statusCode;

  AuthResponse({
    this.data,
    required this.success,
    this.message,
    required this.statusCode,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      data: json['Data'] != null ? AuthResponseData.fromJson(json['Data']) : null,
      success: json['Success'],
      message: json['Message'],
      statusCode: json['StatusCode'],
    );
  }
}
