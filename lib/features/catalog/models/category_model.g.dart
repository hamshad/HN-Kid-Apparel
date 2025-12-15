// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'category_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CategoryResponse _$CategoryResponseFromJson(Map<String, dynamic> json) =>
    CategoryResponse(
      data: (json['Data'] as List<dynamic>)
          .map((e) => Category.fromJson(e as Map<String, dynamic>))
          .toList(),
      success: json['Success'] as bool,
      message: json['Message'] as String,
      statusCode: (json['StatusCode'] as num).toInt(),
    );

Map<String, dynamic> _$CategoryResponseToJson(CategoryResponse instance) =>
    <String, dynamic>{
      'Data': instance.data,
      'Success': instance.success,
      'Message': instance.message,
      'StatusCode': instance.statusCode,
    };

Category _$CategoryFromJson(Map<String, dynamic> json) => Category(
  categoryId: (json['CategoryId'] as num).toInt(),
  name: json['Name'] as String,
  imageUrl: json['ImageUrl'] as String,
  createdAt: DateTime.parse(json['CreatedAt'] as String),
);

Map<String, dynamic> _$CategoryToJson(Category instance) => <String, dynamic>{
  'CategoryId': instance.categoryId,
  'Name': instance.name,
  'ImageUrl': instance.imageUrl,
  'CreatedAt': instance.createdAt.toIso8601String(),
};
