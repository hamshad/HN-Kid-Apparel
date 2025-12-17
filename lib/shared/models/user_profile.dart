
class UserProfile {
  final int userId;
  final String? mobile;
  final String? email;
  final String? fullName;
  final String createdAt;
  // Fields from PUT request that might be in GET or just local state
  final String? shopName;
  final String? address;
  final String? gst;
  final bool? isActive;

  UserProfile({
    required this.userId,
    this.mobile,
    this.email,
    this.fullName,
    required this.createdAt,
    this.shopName,
    this.address,
    this.gst,
    this.isActive,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      userId: json['UserId'],
      mobile: json['Mobile'],
      email: json['Email'],
      fullName: json['FullName'],
      createdAt: json['CreatedAt'],
      shopName: json['ShopName'],
      address: json['Address'],
      gst: json['GST'],
      isActive: json['IsActive'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'UserId': userId,
      'Mobile': mobile,
      'Email': email,
      'FullName': fullName,
      'CreatedAt': createdAt,
      'ShopName': shopName,
      'Address': address,
      'GST': gst,
      'IsActive': isActive,
    };
  }
}

class UpdateProfileRequest {
  final String? mobile;
  final String? email;
  final String? fullName;
  final String? shopName;
  final String? address;
  final String? gst;
  final bool? isActive;

  UpdateProfileRequest({
    this.mobile,
    this.email,
    this.fullName,
    this.shopName,
    this.address,
    this.gst,
    this.isActive,
  });

  Map<String, dynamic> toJson() {
    return {
      if (mobile != null) 'Mobile': mobile,
      if (email != null) 'Email': email,
      if (fullName != null) 'FullName': fullName,
      if (shopName != null) 'ShopName': shopName,
      if (address != null) 'Address': address,
      if (gst != null) 'GST': gst,
      if (isActive != null) 'IsActive': isActive,
    };
  }
}

class UserProfileResponse {
  final UserProfile? data;
  final bool success;
  final String? message;
  final int statusCode;

  UserProfileResponse({
    this.data,
    required this.success,
    this.message,
    required this.statusCode,
  });

  factory UserProfileResponse.fromJson(Map<String, dynamic> json) {
    return UserProfileResponse(
      data: json['Data'] != null ? UserProfile.fromJson(json['Data']) : null,
      success: json['Success'],
      message: json['Message'],
      statusCode: json['StatusCode'],
    );
  }
}
