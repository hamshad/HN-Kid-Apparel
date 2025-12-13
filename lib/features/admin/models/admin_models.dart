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
  });

  factory Design.fromJson(Map<String, dynamic> json) {
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
    );
  }
}
