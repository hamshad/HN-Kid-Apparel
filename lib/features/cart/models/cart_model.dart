import 'package:json_annotation/json_annotation.dart';
import '../../../core/constants/api_constants.dart';

part 'cart_model.g.dart';

@JsonSerializable()
class CartResponse {
  @JsonKey(name: 'Data')
  final Cart data;
  @JsonKey(name: 'Success')
  final bool success;
  @JsonKey(name: 'Message')
  final String message;
  @JsonKey(name: 'StatusCode')
  final int statusCode;

  CartResponse({
    required this.data,
    required this.success,
    required this.message,
    required this.statusCode,
  });

  factory CartResponse.fromJson(Map<String, dynamic> json) => _$CartResponseFromJson(json);
  Map<String, dynamic> toJson() => _$CartResponseToJson(this);
}

@JsonSerializable()
class CartItemResponse {
  @JsonKey(name: 'Data')
  final CartItem data;
  @JsonKey(name: 'Success')
  final bool success;
  @JsonKey(name: 'Message')
  final String message;
  @JsonKey(name: 'StatusCode')
  final int statusCode;

  CartItemResponse({
    required this.data,
    required this.success,
    required this.message,
    required this.statusCode,
  });

  factory CartItemResponse.fromJson(Map<String, dynamic> json) => _$CartItemResponseFromJson(json);
  Map<String, dynamic> toJson() => _$CartItemResponseToJson(this);
}


@JsonSerializable()
class Cart {
  @JsonKey(name: 'CartId')
  final int cartId;
  @JsonKey(name: 'UserId')
  final int userId;
  @JsonKey(name: 'CreatedAt')
  final DateTime createdAt;
  @JsonKey(name: 'CartItems')
  final List<CartItem> cartItems;
  @JsonKey(name: 'TotalAmount')
  final double totalAmount;

  Cart({
    required this.cartId,
    required this.userId,
    required this.createdAt,
    required this.cartItems,
    required this.totalAmount,
  });

  factory Cart.fromJson(Map<String, dynamic> json) => _$CartFromJson(json);
  Map<String, dynamic> toJson() => _$CartToJson(this);
}

@JsonSerializable()
class CartItem {
  @JsonKey(name: 'CartItemId')
  final int cartItemId;
  @JsonKey(name: 'CartId')
  final int cartId;
  @JsonKey(name: 'DesignId')
  final int designId;
  @JsonKey(name: 'DesignName')
  final String designName;
  @JsonKey(name: 'DesignImageUrl')
  final String designImageUrl;
  @JsonKey(name: 'SizeId')
  final int sizeId;
  @JsonKey(name: 'SizeLabel')
  final String sizeLabel;
  @JsonKey(name: 'Quantity')
  final int quantity;

  CartItem({
    required this.cartItemId,
    required this.cartId,
    required this.designId,
    required this.designName,
    required this.designImageUrl,
    required this.sizeId,
    required this.sizeLabel,
    required this.quantity,
  });

  factory CartItem.fromJson(Map<String, dynamic> json) {
    String imgUrl = json['DesignImageUrl'] ?? '';
    if (imgUrl.isNotEmpty && !imgUrl.startsWith('http')) {
      imgUrl = '${ApiConstants.baseUrl}$imgUrl';
    }
    
    // We utilize the generated fromJson but modify the input map for the image url
    // OR we can manually map it. 
    // Usually easier to modify the map passed to generated code, but generated code expects the original map unless we call it manually.
    // Let's just do manual assignments or simple transformation.
    final modifiedJson = Map<String, dynamic>.from(json);
    modifiedJson['DesignImageUrl'] = imgUrl;

    return _$CartItemFromJson(modifiedJson);
  }
  
  Map<String, dynamic> toJson() => _$CartItemToJson(this);
  
  // CopyWith method for easier object manipulation
  CartItem copyWith({
    int? cartItemId,
    int? cartId,
    int? designId,
    String? designName,
    String? designImageUrl,
    int? sizeId,
    String? sizeLabel,
    int? quantity,
  }) {
    return CartItem(
      cartItemId: cartItemId ?? this.cartItemId,
      cartId: cartId ?? this.cartId,
      designId: designId ?? this.designId,
      designName: designName ?? this.designName,
      designImageUrl: designImageUrl ?? this.designImageUrl,
      sizeId: sizeId ?? this.sizeId,
      sizeLabel: sizeLabel ?? this.sizeLabel,
      quantity: quantity ?? this.quantity,
    );
  }
}
