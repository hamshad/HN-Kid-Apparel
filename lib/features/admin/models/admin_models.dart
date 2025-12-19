import '../../../core/constants/api_constants.dart';

class Brand {
  final int id;
  final String name;
  final String? logoUrl;
  final bool isActive;

  Brand({required this.id, required this.name, this.logoUrl, this.isActive = true});

  factory Brand.fromJson(Map<String, dynamic> json) {
    String? logo = json['LogoUrl'];
    if (logo != null && !logo.startsWith('http')) {
      logo = '${ApiConstants.baseUrl}$logo';
    }
    return Brand(
      id: json['BrandId'] ?? json['Id'] ?? 0,
      name: json['Name'] ?? '',
      logoUrl: logo,
      isActive: json['IsActive'] ?? true,
    );
  }
}

class Category {
  final int id;
  final String name;
  final String? imageUrl;
  final bool isActive;

  Category({required this.id, required this.name, this.imageUrl, this.isActive = true});

  factory Category.fromJson(Map<String, dynamic> json) {
    String? img = json['ImageUrl'];
    if (img != null && !img.startsWith('http')) {
      img = '${ApiConstants.baseUrl}$img';
    }
    return Category(
      id: json['CategoryId'] ?? json['Id'] ?? 0,
      name: json['Name'] ?? '',
      imageUrl: img,
      isActive: json['IsActive'] ?? true,
    );
  }
}

class Series {
  final int id;
  final String name;
  final bool isActive;

  Series({required this.id, required this.name, this.isActive = true});

  factory Series.fromJson(Map<String, dynamic> json) {
    return Series(
      id: json['SeriesId'] ?? json['Id'] ?? 0,
      name: json['Name'] ?? '',
      isActive: json['IsActive'] ?? true,
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
  final bool isActive;
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
    this.isActive = true,
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
      isActive: json['IsActive'] ?? true,
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

class ProductSizePrice {
  final int pspId;
  final int designId;
  final String designName;
  final int sizeId;
  final String sizeName;
  final double price;
  final bool isActive;

  ProductSizePrice({
    required this.pspId,
    required this.designId,
    required this.designName,
    required this.sizeId,
    required this.sizeName,
    required this.price,
    this.isActive = true,
  });

  factory ProductSizePrice.fromJson(Map<String, dynamic> json) {
    return ProductSizePrice(
      pspId: json['PSPId'] ?? 0,
      designId: json['DesignId'] ?? 0,
      designName: json['DesignName'] ?? '',
      sizeId: json['SizeId'] ?? 0,
      sizeName: json['SizeName'] ?? '',
      price: (json['Price'] ?? 0).toDouble(),
      isActive: json['IsActive'] ?? true,
    );
  }
}

class User {
  final int userId;
  final String mobile;
  final String email;
  final String fullName;
  final String shopName;
  final String address;
  final String gst;
  final bool isActive;
  final DateTime createdAt;

  User({
    required this.userId,
    required this.mobile,
    required this.email,
    required this.fullName,
    this.shopName = '',
    this.address = '',
    this.gst = '',
    this.isActive = true,
    required this.createdAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      userId: json['UserId'] ?? 0,
      mobile: json['Mobile'] ?? '',
      email: json['Email'] ?? '',
      fullName: json['FullName'] ?? '',
      shopName: json['ShopName'] ?? '',
      address: json['Address'] ?? '',
      gst: json['GST'] ?? '',
      isActive: json['IsActive'] ?? true,
      createdAt: DateTime.parse(json['CreatedAt'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'Mobile': mobile,
      'Email': email,
      'FullName': fullName,
      'ShopName': shopName,
      'Address': address,
      'GST': gst,
      'IsActive': isActive,
    };
  }
}

class SizeDetail {
  final int id;
  final int sizeId;
  final String sizeName;
  final int orderedQty;
  final int pendingQty;

  SizeDetail({
    required this.id,
    required this.sizeId,
    required this.sizeName,
    required this.orderedQty,
    required this.pendingQty,
  });

  factory SizeDetail.fromJson(Map<String, dynamic> json) {
    return SizeDetail(
      id: json['Id'] ?? 0,
      sizeId: json['SizeId'] ?? 0,
      sizeName: json['SizeName'] ?? '',
      orderedQty: json['OrderedQty'] ?? 0,
      pendingQty: json['PendingQty'] ?? 0,
    );
  }
}

class AdminOrderItem {
  final int orderItemId;
  final int designId;
  final String designName;
  final String designImageUrl;
  final int totalQuantity;
  final List<SizeDetail> sizeDetails;

  AdminOrderItem({
    required this.orderItemId,
    required this.designId,
    required this.designName,
    required this.designImageUrl,
    required this.totalQuantity,
    this.sizeDetails = const [],
  });

  factory AdminOrderItem.fromJson(Map<String, dynamic> json) {
    String img = json['DesignImageUrl'] ?? '';
    if (img.isNotEmpty && !img.startsWith('http')) {
      img = '${ApiConstants.baseUrl}$img';
    }

    var sizesList = <SizeDetail>[];
    if (json['SizeDetails'] != null) {
      sizesList = List<SizeDetail>.from(
          json['SizeDetails'].map((x) => SizeDetail.fromJson(x)));
    }

    return AdminOrderItem(
      orderItemId: json['OrderItemId'] ?? 0,
      designId: json['DesignId'] ?? 0,
      designName: json['DesignName'] ?? '',
      designImageUrl: img,
      totalQuantity: json['TotalQuantity'] ?? 0,
      sizeDetails: sizesList,
    );
  }
}

class AdminOrder {
  final int orderId;
  final String orderNumber;
  final int userId;
  final String userName;
  final String userMobile;
  final DateTime orderDate;
  final int totalQty;
  final String status;
  final List<AdminOrderItem> orderItems;

  AdminOrder({
    required this.orderId,
    required this.orderNumber,
    required this.userId,
    required this.userName,
    required this.userMobile,
    required this.orderDate,
    required this.totalQty,
    required this.status,
    this.orderItems = const [],
  });

  factory AdminOrder.fromJson(Map<String, dynamic> json) {
    var itemsList = <AdminOrderItem>[];
    if (json['OrderItems'] != null) {
      itemsList = List<AdminOrderItem>.from(
          json['OrderItems'].map((x) => AdminOrderItem.fromJson(x)));
    }

    return AdminOrder(
      orderId: json['OrderId'] ?? 0,
      orderNumber: json['OrderNumber'] ?? '',
      userId: json['UserId'] ?? 0,
      userName: json['UserName'] ?? '',
      userMobile: json['UserMobile'] ?? '',
      orderDate: DateTime.parse(
          json['OrderDate'] ?? DateTime.now().toIso8601String()),
      totalQty: json['TotalQty'] ?? 0,
      status: json['Status'] ?? 'Pending',
      orderItems: itemsList,
    );
  }
  }


class OrderStatistics {
  final int totalOrders;
  final int pendingOrders;
  final int processingOrders;
  final int shippedOrders;
  final int deliveredOrders;
  final int cancelledOrders;
  final double totalRevenue;
  final int totalItemsSold;

  OrderStatistics({
    required this.totalOrders,
    required this.pendingOrders,
    required this.processingOrders,
    required this.shippedOrders,
    required this.deliveredOrders,
    required this.cancelledOrders,
    required this.totalRevenue,
    required this.totalItemsSold,
  });

  factory OrderStatistics.fromJson(Map<String, dynamic> json) {
    return OrderStatistics(
      totalOrders: json['TotalOrders'] ?? 0,
      pendingOrders: json['PendingOrders'] ?? 0,
      processingOrders: json['ProcessingOrders'] ?? 0,
      shippedOrders: json['ShippedOrders'] ?? 0,
      deliveredOrders: json['DeliveredOrders'] ?? 0,
      cancelledOrders: json['CancelledOrders'] ?? 0,
      totalRevenue: (json['TotalRevenue'] ?? 0).toDouble(),
      totalItemsSold: json['TotalItemsSold'] ?? 0,
    );
  }
}

