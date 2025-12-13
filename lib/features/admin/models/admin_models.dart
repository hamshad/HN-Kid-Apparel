import '../../../core/constants/api_constants.dart';

class Brand {
  final int id;
  final String name;
  final String? logoUrl;

  Brand({required this.id, required this.name, this.logoUrl});

  factory Brand.fromJson(Map<String, dynamic> json) {
    String? logo = json['LogoUrl'];
    if (logo != null && !logo.startsWith('http')) {
      logo = '${ApiConstants.baseUrl}$logo';
    }
    return Brand(
      id: json['BrandId'] ?? json['Id'] ?? 0,
      name: json['Name'] ?? '',
      logoUrl: logo,
    );
  }
}

class Category {
  final int id;
  final String name;
  final String? imageUrl;

  Category({required this.id, required this.name, this.imageUrl});

  factory Category.fromJson(Map<String, dynamic> json) {
    String? img = json['ImageUrl'];
    if (img != null && !img.startsWith('http')) {
      img = '${ApiConstants.baseUrl}$img';
    }
    return Category(
      id: json['CategoryId'] ?? json['Id'] ?? 0,
      name: json['Name'] ?? '',
      imageUrl: img,
    );
  }
}

class Series {
  final int id;
  final String name;

  Series({required this.id, required this.name});

  factory Series.fromJson(Map<String, dynamic> json) {
    return Series(
      id: json['SeriesId'] ?? json['Id'] ?? 0,
      name: json['Name'] ?? '',
    );
  }
}

class Design {
  final int id;
  final String title;
  final String designNumber;
  final int categoryId;
  final String categoryName;
  final int seriesId;
  final String seriesName;
  final int brandId;
  final String brandName;
  final bool isNew;
  final DateTime? createdAt;
  final List<String> images;
  final List<dynamic> sizePrices;

  Design({
    required this.id,
    required this.title,
    required this.designNumber,
    required this.categoryId,
    required this.categoryName,
    required this.seriesId,
    required this.seriesName,
    required this.brandId,
    required this.brandName,
    required this.isNew,
    this.createdAt,
    this.images = const [],
    this.sizePrices = const [],
  });

  factory Design.fromJson(Map<String, dynamic> json) {
    var imgList = <String>[];
    if (json['Images'] != null) {
      imgList = List<String>.from(json['Images'].map((x) {
        if (x is Map) {
          String url = x['ImageUrl'] ?? '';
          if (url.isNotEmpty && !url.startsWith('http')) {
            return '${ApiConstants.baseUrl}$url';
          }
          return url;
        }
        if (x is String) {
          if (!x.startsWith('http') && x.isNotEmpty) {
            return '${ApiConstants.baseUrl}$x';
          }
          return x;
        }
        return '';
      }));
    }

    return Design(
      id: json['DesignId'] ?? 0,
      title: json['Title'] ?? '',
      designNumber: json['DesignNumber'] ?? '',
      categoryId: json['CategoryId'] ?? 0,
      categoryName: json['CategoryName'] ?? '',
      seriesId: json['SeriesId'] ?? 0,
      seriesName: json['SeriesName'] ?? '',
      brandId: json['BrandId'] ?? 0,
      brandName: json['BrandName'] ?? '',
      isNew: json['IsNew'] ?? false,
      createdAt: json['CreatedAt'] != null ? DateTime.tryParse(json['CreatedAt']) : null,
      images: imgList,
      sizePrices: json['SizePrices'] ?? [],
    );
  }
}

class DesignImage {
  final int imageId;
  final int designId;
  final String imageUrl;

  DesignImage({
    required this.imageId,
    required this.designId,
    required this.imageUrl,
  });


  factory DesignImage.fromJson(Map<String, dynamic> json) {
    String url = json['ImageUrl'] ?? '';
    if (url.isNotEmpty && !url.startsWith('http')) {
      url = '${ApiConstants.baseUrl}$url';
    }
    return DesignImage(
      imageId: json['ImageId'] ?? 0,
      designId: json['DesignId'] ?? 0,
      imageUrl: url,
    );
  }
}

class Size {
  final int id;
  final String sizeLabel;

  Size({required this.id, required this.sizeLabel});

  factory Size.fromJson(Map<String, dynamic> json) {
    return Size(
      id: json['SizeId'] ?? json['Id'] ?? 0,
      sizeLabel: json['SizeLabel'] ?? '',
    );
  }
}

