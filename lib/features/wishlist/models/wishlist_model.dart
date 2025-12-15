import 'package:json_annotation/json_annotation.dart';
import '../../../core/constants/api_constants.dart';

part 'wishlist_model.g.dart';

@JsonSerializable()
class WishlistListResponse {
  @JsonKey(name: 'Data')
  final List<WishlistItem> data;
  @JsonKey(name: 'Success')
  final bool success;
  @JsonKey(name: 'Message')
  final String message;
  @JsonKey(name: 'StatusCode')
  final int statusCode;

  WishlistListResponse({
    required this.data,
    required this.success,
    required this.message,
    required this.statusCode,
  });

  factory WishlistListResponse.fromJson(Map<String, dynamic> json) => _$WishlistListResponseFromJson(json);
  Map<String, dynamic> toJson() => _$WishlistListResponseToJson(this);
}

@JsonSerializable()
class WishlistItemResponse {
  @JsonKey(name: 'Data')
  final WishlistItem data;
  @JsonKey(name: 'Success')
  final bool success;
  @JsonKey(name: 'Message')
  final String message;
  @JsonKey(name: 'StatusCode')
  final int statusCode;

  WishlistItemResponse({
    required this.data,
    required this.success,
    required this.message,
    required this.statusCode,
  });

  factory WishlistItemResponse.fromJson(Map<String, dynamic> json) => _$WishlistItemResponseFromJson(json);
  Map<String, dynamic> toJson() => _$WishlistItemResponseToJson(this);
}

@JsonSerializable()
class WishlistItem {
  @JsonKey(name: 'WishlistId')
  final int wishlistId;
  @JsonKey(name: 'UserId')
  final int userId;
  @JsonKey(name: 'DesignId')
  final int designId;
  @JsonKey(name: 'DesignName')
  final String designName;
  @JsonKey(name: 'DesignImageUrl')
  final String designImageUrl;
  @JsonKey(name: 'BasePrice')
  final double? basePrice;
  @JsonKey(name: 'AddedAt')
  final DateTime addedAt;

  WishlistItem({
    required this.wishlistId,
    required this.userId,
    required this.designId,
    required this.designName,
    required this.designImageUrl,
    this.basePrice,
    required this.addedAt,
  });

  factory WishlistItem.fromJson(Map<String, dynamic> json) {
    String imgUrl = json['DesignImageUrl'] ?? '';
    if (imgUrl.isNotEmpty && !imgUrl.startsWith('http')) {
      imgUrl = '${ApiConstants.baseUrl}$imgUrl';
    }
    
    final modifiedJson = Map<String, dynamic>.from(json);
    modifiedJson['DesignImageUrl'] = imgUrl;

    return _$WishlistItemFromJson(modifiedJson);
  }
  
  Map<String, dynamic> toJson() => _$WishlistItemToJson(this);
}
