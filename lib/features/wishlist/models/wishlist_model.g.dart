// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'wishlist_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

WishlistListResponse _$WishlistListResponseFromJson(
  Map<String, dynamic> json,
) => WishlistListResponse(
  data: (json['Data'] as List<dynamic>)
      .map((e) => WishlistItem.fromJson(e as Map<String, dynamic>))
      .toList(),
  success: json['Success'] as bool,
  message: json['Message'] as String,
  statusCode: (json['StatusCode'] as num).toInt(),
);

Map<String, dynamic> _$WishlistListResponseToJson(
  WishlistListResponse instance,
) => <String, dynamic>{
  'Data': instance.data,
  'Success': instance.success,
  'Message': instance.message,
  'StatusCode': instance.statusCode,
};

WishlistItemResponse _$WishlistItemResponseFromJson(
  Map<String, dynamic> json,
) => WishlistItemResponse(
  data: WishlistItem.fromJson(json['Data'] as Map<String, dynamic>),
  success: json['Success'] as bool,
  message: json['Message'] as String,
  statusCode: (json['StatusCode'] as num).toInt(),
);

Map<String, dynamic> _$WishlistItemResponseToJson(
  WishlistItemResponse instance,
) => <String, dynamic>{
  'Data': instance.data,
  'Success': instance.success,
  'Message': instance.message,
  'StatusCode': instance.statusCode,
};

WishlistItem _$WishlistItemFromJson(Map<String, dynamic> json) => WishlistItem(
  wishlistId: (json['WishlistId'] as num).toInt(),
  userId: (json['UserId'] as num).toInt(),
  designId: (json['DesignId'] as num).toInt(),
  designName: json['DesignName'] as String,
  designImageUrl: json['DesignImageUrl'] as String,
  basePrice: (json['BasePrice'] as num?)?.toDouble(),
  addedAt: DateTime.parse(json['AddedAt'] as String),
);

Map<String, dynamic> _$WishlistItemToJson(WishlistItem instance) =>
    <String, dynamic>{
      'WishlistId': instance.wishlistId,
      'UserId': instance.userId,
      'DesignId': instance.designId,
      'DesignName': instance.designName,
      'DesignImageUrl': instance.designImageUrl,
      'BasePrice': instance.basePrice,
      'AddedAt': instance.addedAt.toIso8601String(),
    };
