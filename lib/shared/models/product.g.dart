// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'product.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Product _$ProductFromJson(Map<String, dynamic> json) => Product(
  id: json['id'] as String,
  sku: json['sku'] as String,
  title: json['title'] as String,
  category: json['category'] as String,
  description: json['description'] as String,
  images: (json['images'] as List<dynamic>).map((e) => e as String).toList(),
  variants: (json['variants'] as List<dynamic>)
      .map((e) => ProductVariant.fromJson(e as Map<String, dynamic>))
      .toList(),
  tags: (json['tags'] as List<dynamic>).map((e) => e as String).toList(),
  createdAt: DateTime.parse(json['created_at'] as String),
  isNew: json['is_new'] as bool? ?? false,
);

Map<String, dynamic> _$ProductToJson(Product instance) => <String, dynamic>{
  'id': instance.id,
  'sku': instance.sku,
  'title': instance.title,
  'category': instance.category,
  'description': instance.description,
  'images': instance.images,
  'variants': instance.variants,
  'tags': instance.tags,
  'created_at': instance.createdAt.toIso8601String(),
  'is_new': instance.isNew,
};

ProductVariant _$ProductVariantFromJson(Map<String, dynamic> json) =>
    ProductVariant(
      sizeId: (json['size_id'] as num?)?.toInt() ?? 0,
      size: json['size'] as String,
      mrp: (json['mrp'] as num).toDouble(),
      availableQty: (json['available_qty'] as num).toInt(),
    );

Map<String, dynamic> _$ProductVariantToJson(ProductVariant instance) =>
    <String, dynamic>{
      'size_id': instance.sizeId,
      'size': instance.size,
      'mrp': instance.mrp,
      'available_qty': instance.availableQty,
    };
