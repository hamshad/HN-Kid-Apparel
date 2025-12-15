import 'package:json_annotation/json_annotation.dart';

part 'category_model.g.dart';

@JsonSerializable()
class CategoryResponse {
  @JsonKey(name: 'Data')
  final List<Category> data;
  @JsonKey(name: 'Success')
  final bool success;
  @JsonKey(name: 'Message')
  final String message;
  @JsonKey(name: 'StatusCode')
  final int statusCode;

  CategoryResponse({
    required this.data,
    required this.success,
    required this.message,
    required this.statusCode,
  });

  factory CategoryResponse.fromJson(Map<String, dynamic> json) => _$CategoryResponseFromJson(json);
  Map<String, dynamic> toJson() => _$CategoryResponseToJson(this);
}

@JsonSerializable()
class Category {
  @JsonKey(name: 'CategoryId')
  final int categoryId;
  @JsonKey(name: 'Name')
  final String name;
  @JsonKey(name: 'ImageUrl')
  final String imageUrl;
  @JsonKey(name: 'CreatedAt')
  final DateTime createdAt;

  Category({
    required this.categoryId,
    required this.name,
    required this.imageUrl,
    required this.createdAt,
  });

  factory Category.fromJson(Map<String, dynamic> json) => _$CategoryFromJson(json);
  Map<String, dynamic> toJson() => _$CategoryToJson(this);
}
