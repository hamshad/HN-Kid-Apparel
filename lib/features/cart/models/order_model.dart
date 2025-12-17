class OrderResponse {
  final Order data;
  final bool success;
  final String message;
  final List<dynamic> validationErrors;
  final int statusCode;
  final String timestamp;

  OrderResponse({
    required this.data,
    required this.success,
    required this.message,
    required this.validationErrors,
    required this.statusCode,
    required this.timestamp,
  });

  factory OrderResponse.fromJson(Map<String, dynamic> json) {
    return OrderResponse(
      data: Order.fromJson(json['Data']),
      success: json['Success'],
      message: json['Message'],
      validationErrors: json['ValidationErrors'] ?? [],
      statusCode: json['StatusCode'],
      timestamp: json['Timestamp'],
    );
  }
}

class Order {
  final int orderId;
  final String orderNumber;
  final int userId;
  final String userName;
  final String userMobile;
  final String orderDate;
  final int totalQty;
  final String status;
  final List<OrderItem> orderItems;

  Order({
    required this.orderId,
    required this.orderNumber,
    required this.userId,
    required this.userName,
    required this.userMobile,
    required this.orderDate,
    required this.totalQty,
    required this.status,
    required this.orderItems,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      orderId: json['OrderId'],
      orderNumber: json['OrderNumber'],
      userId: json['UserId'],
      userName: json['UserName'],
      userMobile: json['UserMobile'],
      orderDate: json['OrderDate'],
      totalQty: json['TotalQty'],
      status: json['Status'],
      orderItems: (json['OrderItems'] as List)
          .map((item) => OrderItem.fromJson(item))
          .toList(),
    );
  }
}

class OrderItem {
  final int orderItemId;
  final int designId;
  final String designName;
  final String designImageUrl;
  final int totalQuantity;
  final List<SizeDetail> sizeDetails;

  OrderItem({
    required this.orderItemId,
    required this.designId,
    required this.designName,
    required this.designImageUrl,
    required this.totalQuantity,
    required this.sizeDetails,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      orderItemId: json['OrderItemId'],
      designId: json['DesignId'],
      designName: json['DesignName'],
      designImageUrl: json['DesignImageUrl'],
      totalQuantity: json['TotalQuantity'],
      sizeDetails: (json['SizeDetails'] as List)
          .map((size) => SizeDetail.fromJson(size))
          .toList(),
    );
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
      id: json['Id'],
      sizeId: json['SizeId'],
      sizeName: json['SizeName'],
      orderedQty: json['OrderedQty'],
      pendingQty: json['PendingQty'],
    );
  }
}
