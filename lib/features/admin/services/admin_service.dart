import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../../../core/services/api_client.dart';
import '../../../core/constants/api_constants.dart';
import '../../../core/services/storage_service.dart';
import '../models/admin_models.dart';
import '../../../core/utils/fancy_logger.dart';

class AdminService {
  final StorageService _storageService;
  final ApiClient _client = ApiClient();

  AdminService(this._storageService);

  Future<Map<String, String>> _getHeaders() async {
    final token = await _storageService.getToken();
    return {'Authorization': 'Bearer $token'};
  }

  // --- Brands ---

  Future<List<Brand>> getBrands(int page, int pageSize) async {
    final headers = await _getHeaders();
    final uri =
        Uri.parse(
          '${ApiConstants.baseUrl}${ApiConstants.brandEndpoint}',
        ).replace(
          queryParameters: {
            'page': page.toString(),
            'pageSize': pageSize.toString(),
          },
        );

    FancyLogger.apiRequest('GET', uri.toString());
    final response = await http.get(uri, headers: headers);
    FancyLogger.apiResponse(
      'GET',
      uri.toString(),
      response.statusCode,
      response.body,
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> responseData = jsonDecode(response.body);
      // Optional: Check if responseData['Success'] == true
      final List<dynamic> data = responseData['Data'] ?? [];
      return data.map((json) => Brand.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load brands: ${response.statusCode}');
    }
  }

  Future<Map<String, dynamic>> addBrand(String name, File imageFile) async {
    final headers = await _getHeaders();
    final uri = Uri.parse(
      '${ApiConstants.baseUrl}${ApiConstants.brandEndpoint}',
    );

    FancyLogger.apiRequest('POST', uri.toString(), {
      'Name': name,
      'Logo': imageFile.path,
    });

    var request = http.MultipartRequest('POST', uri);

    request.headers.addAll(headers);
    request.fields['Name'] = name;

    if (await imageFile.exists()) {
      request.files.add(
        await http.MultipartFile.fromPath('Logo', imageFile.path),
      );
    }

    final streamResponse = await request.send();
    final response = await http.Response.fromStream(streamResponse);

    FancyLogger.apiResponse(
      'POST',
      uri.toString(),
      response.statusCode,
      response.body,
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to add brand: ${response.body}');
    }
  }

  Future<Map<String, dynamic>> updateBrand({
    required int id,
    required String name,
    File? imageFile,
    required bool isActive,
  }) async {
    final headers = await _getHeaders();
    final uri = Uri.parse(
      '${ApiConstants.baseUrl}${ApiConstants.brandEndpoint}/$id',
    );

    FancyLogger.apiRequest('PUT', uri.toString(), {
      'Name': name,
      'Logo': imageFile?.path,
      'IsActive': isActive,
    });

    var request = http.MultipartRequest('PUT', uri);

    request.headers.addAll(headers);
    request.fields['Name'] = name;
    request.fields['IsActive'] = isActive.toString();

    if (imageFile != null && await imageFile.exists()) {
      request.files.add(
        await http.MultipartFile.fromPath('Logo', imageFile.path),
      );
    }

    final streamResponse = await request.send();
    final response = await http.Response.fromStream(streamResponse);

    FancyLogger.apiResponse(
      'PUT',
      uri.toString(),
      response.statusCode,
      response.body,
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to update brand: ${response.body}');
    }
  }

  Future<void> deleteBrand(int id) async {
    final headers = await _getHeaders();
    final uri = Uri.parse(
      '${ApiConstants.baseUrl}${ApiConstants.brandEndpoint}/$id',
    );

    FancyLogger.apiRequest('DELETE', uri.toString());
    final response = await http.delete(uri, headers: headers);
    FancyLogger.apiResponse(
      'DELETE',
      uri.toString(),
      response.statusCode,
      response.body,
    );

    if (response.statusCode != 200 && response.statusCode != 204) {
      String errorMessage = 'Failed to delete brand';
      try {
        final body = jsonDecode(response.body);
        if (body is Map<String, dynamic> && body['Message'] != null) {
          errorMessage = body['Message'];
        }
      } catch (_) {
        // Fallback to default message if parsing fails
      }
      throw Exception(errorMessage);
    }
  }

  // --- Categories ---

  Future<List<Category>> getCategories(int page, int pageSize) async {
    final headers = await _getHeaders();
    final uri =
        Uri.parse(
          '${ApiConstants.baseUrl}${ApiConstants.categoryEndpoint}',
        ).replace(
          queryParameters: {
            'page': page.toString(),
            'pageSize': pageSize.toString(),
          },
        );

    FancyLogger.apiRequest('GET', uri.toString());
    final response = await http.get(uri, headers: headers);
    FancyLogger.apiResponse(
      'GET',
      uri.toString(),
      response.statusCode,
      response.body,
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> responseData = jsonDecode(response.body);
      final List<dynamic> data = responseData['Data'] ?? [];
      return data.map((json) => Category.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load categories: ${response.statusCode}');
    }
  }

  Future<Map<String, dynamic>> addCategory(String name, File imageFile) async {
    final headers = await _getHeaders();
    final uri = Uri.parse(
      '${ApiConstants.baseUrl}${ApiConstants.categoryEndpoint}',
    );

    FancyLogger.apiRequest('POST', uri.toString(), {
      'Name': name,
      'Image': imageFile.path,
    });

    var request = http.MultipartRequest('POST', uri);

    request.headers.addAll(headers);
    request.fields['Name'] = name;

    if (await imageFile.exists()) {
      request.files.add(
        await http.MultipartFile.fromPath('Image', imageFile.path),
      );
    }

    final streamResponse = await request.send();
    final response = await http.Response.fromStream(streamResponse);

    FancyLogger.apiResponse(
      'POST',
      uri.toString(),
      response.statusCode,
      response.body,
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to add category: ${response.body}');
    }
  }

  Future<Map<String, dynamic>> updateCategory({
    required int id,
    required String name,
    File? imageFile,
    required bool isActive,
  }) async {
    final headers = await _getHeaders();
    final uri = Uri.parse(
      '${ApiConstants.baseUrl}${ApiConstants.categoryEndpoint}/$id',
    );

    FancyLogger.apiRequest('PUT', uri.toString(), {
      'Name': name,
      'Image': imageFile?.path,
      'IsActive': isActive,
    });

    var request = http.MultipartRequest('PUT', uri);

    request.headers.addAll(headers);
    request.fields['Name'] = name;
    request.fields['IsActive'] = isActive.toString();

    if (imageFile != null && await imageFile.exists()) {
      request.files.add(
        await http.MultipartFile.fromPath('Image', imageFile.path),
      );
    }

    final streamResponse = await request.send();
    final response = await http.Response.fromStream(streamResponse);

    FancyLogger.apiResponse(
      'PUT',
      uri.toString(),
      response.statusCode,
      response.body,
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to update category: ${response.body}');
    }
  }

  Future<void> deleteCategory(int id) async {
    final headers = await _getHeaders();
    final uri = Uri.parse(
      '${ApiConstants.baseUrl}${ApiConstants.categoryEndpoint}/$id',
    );

    FancyLogger.apiRequest('DELETE', uri.toString());
    final response = await http.delete(uri, headers: headers);
    FancyLogger.apiResponse(
      'DELETE',
      uri.toString(),
      response.statusCode,
      response.body,
    );

    if (response.statusCode != 200 && response.statusCode != 204) {
      String errorMessage = 'Failed to delete category';
      try {
        final body = jsonDecode(response.body);
        if (body is Map<String, dynamic> && body['Message'] != null) {
          errorMessage = body['Message'];
        }
      } catch (_) {}
      throw Exception(errorMessage);
    }
  }

  // --- Series ---

  Future<List<Series>> getSeries(int page, int pageSize) async {
    final headers = await _getHeaders();
    final uri =
        Uri.parse(
          '${ApiConstants.baseUrl}${ApiConstants.seriesEndpoint}',
        ).replace(
          queryParameters: {
            'page': page.toString(),
            'pageSize': pageSize.toString(),
          },
        );

    FancyLogger.apiRequest('GET', uri.toString());
    final response = await http.get(uri, headers: headers);
    FancyLogger.apiResponse(
      'GET',
      uri.toString(),
      response.statusCode,
      response.body,
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> responseData = jsonDecode(response.body);
      final List<dynamic> data = responseData['Data'] ?? [];
      return data.map((json) => Series.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load series: ${response.statusCode}');
    }
  }

  Future<Map<String, dynamic>> addSeries(String name) async {
    try {
      final headers = await _getHeaders();
      headers['Content-Type'] = 'application/json';
      final uri = Uri.parse(
        '${ApiConstants.baseUrl}${ApiConstants.seriesEndpoint}',
      );

      final body = {'Name': name};
      FancyLogger.apiRequest('POST', uri.toString(), body);

      final response = await _client.post(
        uri,
        headers: headers,
        body: jsonEncode(body),
      );

      FancyLogger.apiResponse(
        'POST',
        uri.toString(),
        response.statusCode,
        response.body,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to add series: ${response.body}');
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> updateSeries({
    required int id,
    required String name,
    required bool isActive,
  }) async {
    final headers = await _getHeaders();
    headers['Content-Type'] = 'application/json';
    final uri = Uri.parse(
      '${ApiConstants.baseUrl}${ApiConstants.seriesEndpoint}/$id',
    );

    final body = {'Name': name, 'IsActive': isActive};
    FancyLogger.apiRequest('PUT', uri.toString(), body);

    final response = await http.put(
      uri,
      headers: headers,
      body: jsonEncode(body),
    );

    FancyLogger.apiResponse(
      'PUT',
      uri.toString(),
      response.statusCode,
      response.body,
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to update series: ${response.body}');
    }
  }

  Future<void> deleteSeries(int id) async {
    final headers = await _getHeaders();
    final uri = Uri.parse(
      '${ApiConstants.baseUrl}${ApiConstants.seriesEndpoint}/$id',
    );

    FancyLogger.apiRequest('DELETE', uri.toString());
    final response = await http.delete(uri, headers: headers);
    FancyLogger.apiResponse(
      'DELETE',
      uri.toString(),
      response.statusCode,
      response.body,
    );

    if (response.statusCode != 200 && response.statusCode != 204) {
      String errorMessage = 'Failed to delete series';
      try {
        final body = jsonDecode(response.body);
        if (body is Map<String, dynamic> && body['Message'] != null) {
          errorMessage = body['Message'];
        }
      } catch (_) {}
      throw Exception(errorMessage);
    }
  }

  // --- Designs ---

  Future<List<Design>> getDesigns(int page, int pageSize) async {
    final headers = await _getHeaders();
    final uri =
        Uri.parse(
          '${ApiConstants.baseUrl}${ApiConstants.designEndpoint}',
        ).replace(
          queryParameters: {
            'page': page.toString(),
            'pageSize': pageSize.toString(),
          },
        );

    FancyLogger.apiRequest('GET', uri.toString());
    final response = await http.get(uri, headers: headers);
    FancyLogger.apiResponse(
      'GET',
      uri.toString(),
      response.statusCode,
      response.body,
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> responseData = jsonDecode(response.body);
      final List<dynamic> data = responseData['Data'] ?? [];
      return data.map((json) => Design.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load product: ${response.statusCode}');
    }
  }

  Future<Map<String, dynamic>> addDesign({
    required String title,
    required String designNumber,
    required int categoryId,
    required int seriesId,
    required int brandId,
    required bool isNew,
  }) async {
    final headers = await _getHeaders();
    headers['Content-Type'] = 'application/json';
    final uri = Uri.parse(
      '${ApiConstants.baseUrl}${ApiConstants.designEndpoint}',
    );

    final body = {
      'Title': title,
      'DesignNumber': designNumber,
      'CategoryId': categoryId,
      'SeriesId': seriesId,
      'BrandId': brandId,
      'IsNew': isNew,
    };
    FancyLogger.apiRequest('POST', uri.toString(), body);

    final response = await http.post(
      uri,
      headers: headers,
      body: jsonEncode(body),
    );

    FancyLogger.apiResponse(
      'POST',
      uri.toString(),
      response.statusCode,
      response.body,
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to add product: ${response.body}');
    }
  }

  Future<Map<String, dynamic>> updateDesign({
    required int id,
    required String title,
    required String designNumber,
    required int categoryId,
    required int seriesId,
    required int brandId,
    required bool isNew,
    required bool isActive,
  }) async {
    final headers = await _getHeaders();
    headers['Content-Type'] = 'application/json';
    final uri = Uri.parse(
      '${ApiConstants.baseUrl}${ApiConstants.designEndpoint}/$id',
    );

    final body = {
      'Title': title,
      'DesignNumber': designNumber,
      'CategoryId': categoryId,
      'SeriesId': seriesId,
      'BrandId': brandId,
      'IsNew': isNew,
      'IsActive': isActive,
    };
    FancyLogger.apiRequest('PUT', uri.toString(), body);

    final response = await http.put(
      uri,
      headers: headers,
      body: jsonEncode(body),
    );

    FancyLogger.apiResponse(
      'PUT',
      uri.toString(),
      response.statusCode,
      response.body,
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to update product: ${response.body}');
    }
  }

  Future<void> deleteDesign(int id) async {
    final headers = await _getHeaders();
    final uri = Uri.parse(
      '${ApiConstants.baseUrl}${ApiConstants.designEndpoint}/$id',
    );

    FancyLogger.apiRequest('DELETE', uri.toString());
    final response = await http.delete(uri, headers: headers);
    FancyLogger.apiResponse(
      'DELETE',
      uri.toString(),
      response.statusCode,
      response.body,
    );

    if (response.statusCode != 200 && response.statusCode != 204) {
      String errorMessage = 'Failed to delete design';
      try {
        final body = jsonDecode(response.body);
        if (body is Map<String, dynamic> && body['Message'] != null) {
          errorMessage = body['Message'];
        }
      } catch (_) {}
      throw Exception(errorMessage);
    }
  }

  Future<Map<String, dynamic>> addDesignImage(
    int designId,
    File imageFile,
  ) async {
    final headers = await _getHeaders();
    final uri = Uri.parse(
      '${ApiConstants.baseUrl}${ApiConstants.designEndpoint}/$designId/images',
    );

    FancyLogger.apiRequest('POST', uri.toString(), {'Image': imageFile.path});

    var request = http.MultipartRequest('POST', uri);

    request.headers.addAll(headers);

    if (await imageFile.exists()) {
      request.files.add(
        await http.MultipartFile.fromPath(
          'Image', // API expects 'Image'
          imageFile.path,
        ),
      );
    }

    final streamResponse = await request.send();
    final response = await http.Response.fromStream(streamResponse);

    FancyLogger.apiResponse(
      'POST',
      uri.toString(),
      response.statusCode,
      response.body,
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to upload image: ${response.body}');
    }
  }

  Future<List<DesignImage>> getDesignImages(int designId) async {
    final headers = await _getHeaders();
    final uri = Uri.parse(
      '${ApiConstants.baseUrl}${ApiConstants.designEndpoint}/$designId/images',
    );

    FancyLogger.apiRequest('GET', uri.toString());
    final response = await http.get(uri, headers: headers);
    FancyLogger.apiResponse(
      'GET',
      uri.toString(),
      response.statusCode,
      response.body,
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> responseData = jsonDecode(response.body);
      final List<dynamic> data = responseData['Data'] ?? [];
      return data.map((json) => DesignImage.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load design images: ${response.statusCode}');
    }
  }

  // --- Sizes ---

  Future<List<Size>> getSizes(int page, int pageSize) async {
    final headers = await _getHeaders();
    final uri = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.sizeEndpoint}')
        .replace(
          queryParameters: {
            'page': page.toString(),
            'pageSize': pageSize.toString(),
          },
        );

    FancyLogger.apiRequest('GET', uri.toString());
    final response = await http.get(uri, headers: headers);
    FancyLogger.apiResponse(
      'GET',
      uri.toString(),
      response.statusCode,
      response.body,
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> responseData = jsonDecode(response.body);
      final List<dynamic> data = responseData['Data'] ?? [];
      return data.map((json) => Size.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load sizes: ${response.statusCode}');
    }
  }

  Future<Map<String, dynamic>> addSize(String sizeLabel) async {
    final headers = await _getHeaders();
    headers['Content-Type'] = 'application/json';
    final uri = Uri.parse(
      '${ApiConstants.baseUrl}${ApiConstants.sizeEndpoint}',
    );

    final body = {'SizeLabel': sizeLabel};
    FancyLogger.apiRequest('POST', uri.toString(), body);

    final response = await http.post(
      uri,
      headers: headers,
      body: jsonEncode(body),
    );

    FancyLogger.apiResponse(
      'POST',
      uri.toString(),
      response.statusCode,
      response.body,
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to add size: ${response.body}');
    }
  }

  Future<Map<String, dynamic>> updateSize(int id, String sizeLabel) async {
    final headers = await _getHeaders();
    headers['Content-Type'] = 'application/json';
    final uri = Uri.parse(
      '${ApiConstants.baseUrl}${ApiConstants.sizeEndpoint}/$id',
    );

    final body = {'SizeLabel': sizeLabel};
    FancyLogger.apiRequest('PUT', uri.toString(), body);

    final response = await http.put(
      uri,
      headers: headers,
      body: jsonEncode(body),
    );

    FancyLogger.apiResponse(
      'PUT',
      uri.toString(),
      response.statusCode,
      response.body,
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to update size: ${response.body}');
    }
  }

  Future<void> deleteSize(int id) async {
    final headers = await _getHeaders();
    final uri = Uri.parse(
      '${ApiConstants.baseUrl}${ApiConstants.sizeEndpoint}/$id',
    );

    FancyLogger.apiRequest('DELETE', uri.toString());
    final response = await http.delete(uri, headers: headers);
    FancyLogger.apiResponse(
      'DELETE',
      uri.toString(),
      response.statusCode,
      response.body,
    );

    if (response.statusCode != 200 && response.statusCode != 204) {
      String errorMessage = 'Failed to delete size';
      try {
        final body = jsonDecode(response.body);
        if (body is Map<String, dynamic> && body['Message'] != null) {
          errorMessage = body['Message'];
        }
      } catch (_) {}
      throw Exception(errorMessage);
    }
  }

  // --- Product Size Price ---

  Future<List<ProductSizePrice>> getProductSizePrices(
    int page,
    int pageSize,
  ) async {
    final headers = await _getHeaders();
    final uri =
        Uri.parse(
          '${ApiConstants.baseUrl}${ApiConstants.productSizePriceEndpoint}',
        ).replace(
          queryParameters: {
            'page': page.toString(),
            'pageSize': pageSize.toString(),
          },
        );

    FancyLogger.apiRequest('GET', uri.toString());
    final response = await http.get(uri, headers: headers);
    FancyLogger.apiResponse(
      'GET',
      uri.toString(),
      response.statusCode,
      response.body,
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> responseData = jsonDecode(response.body);
      final List<dynamic> data = responseData['Data'] ?? [];
      return data.map((json) => ProductSizePrice.fromJson(json)).toList();
    } else {
      throw Exception(
        'Failed to load product size prices: ${response.statusCode}',
      );
    }
  }

  Future<Map<String, dynamic>> addProductSizePrice(
    int designId,
    int sizeId,
    double price,
  ) async {
    final headers = await _getHeaders();
    headers['Content-Type'] = 'application/json';
    final uri = Uri.parse(
      '${ApiConstants.baseUrl}${ApiConstants.productSizePriceEndpoint}',
    );

    final body = {'DesignId': designId, 'SizeId': sizeId, 'Price': price};
    FancyLogger.apiRequest('POST', uri.toString(), body);

    final response = await http.post(
      uri,
      headers: headers,
      body: jsonEncode(body),
    );

    FancyLogger.apiResponse(
      'POST',
      uri.toString(),
      response.statusCode,
      response.body,
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to add product size price: ${response.body}');
    }
  }

  Future<Map<String, dynamic>> updateProductSizePrice(
    int id,
    int designId,
    int sizeId,
    double price,
    bool isActive,
  ) async {
    final headers = await _getHeaders();
    headers['Content-Type'] = 'application/json';
    final uri = Uri.parse(
      '${ApiConstants.baseUrl}${ApiConstants.productSizePriceEndpoint}/$id',
    );

    final body = {
      'DesignId': designId,
      'SizeId': sizeId,
      'Price': price,
      'IsActive': isActive,
    };
    FancyLogger.apiRequest('PUT', uri.toString(), body);

    final response = await http.put(
      uri,
      headers: headers,
      body: jsonEncode(body),
    );

    FancyLogger.apiResponse(
      'PUT',
      uri.toString(),
      response.statusCode,
      response.body,
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to update product size price: ${response.body}');
    }
  }

  Future<void> deleteProductSizePrice(int id) async {
    final headers = await _getHeaders();
    final uri = Uri.parse(
      '${ApiConstants.baseUrl}${ApiConstants.productSizePriceEndpoint}/$id',
    );

    FancyLogger.apiRequest('DELETE', uri.toString());
    final response = await http.delete(uri, headers: headers);
    FancyLogger.apiResponse(
      'DELETE',
      uri.toString(),
      response.statusCode,
      response.body,
    );

    if (response.statusCode != 200 && response.statusCode != 204) {
      String errorMessage = 'Failed to delete product size price';
      try {
        final body = jsonDecode(response.body);
        if (body is Map<String, dynamic> && body['Message'] != null) {
          errorMessage = body['Message'];
        }
      } catch (_) {}
      throw Exception(errorMessage);
    }
  }

  // --- Users ---

  Future<List<User>> getUsers(int page, int pageSize) async {
    final headers = await _getHeaders();
    final uri = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.userEndpoint}')
        .replace(
          queryParameters: {
            'page': page.toString(),
            'pageSize': pageSize.toString(),
          },
        );

    FancyLogger.apiRequest('GET', uri.toString());
    final response = await http.get(uri, headers: headers);
    FancyLogger.apiResponse(
      'GET',
      uri.toString(),
      response.statusCode,
      response.body,
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> responseData = jsonDecode(response.body);
      final List<dynamic> data = responseData['Data'] ?? [];
      return data.map((json) => User.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load users: ${response.statusCode}');
    }
  }

  Future<Map<String, dynamic>> updateUser({
    required int userId,
    required String mobile,
    required String email,
    required String fullName,
    required String shopName,
    required String address,
    required String gst,
    required bool isActive,
  }) async {
    final headers = await _getHeaders();
    headers['Content-Type'] = 'application/json';
    final uri = Uri.parse(
      '${ApiConstants.baseUrl}${ApiConstants.userEndpoint}/$userId',
    );

    final body = {
      'Mobile': mobile,
      'Email': email,
      'FullName': fullName,
      'ShopName': shopName,
      'Address': address,
      'GST': gst,
      'IsActive': isActive,
    };
    FancyLogger.apiRequest('PUT', uri.toString(), body);

    final response = await http.put(
      uri,
      headers: headers,
      body: jsonEncode(body),
    );

    FancyLogger.apiResponse(
      'PUT',
      uri.toString(),
      response.statusCode,
      response.body,
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to update user: ${response.body}');
    }
  }

  Future<void> deleteUser(int userId) async {
    final headers = await _getHeaders();
    final uri = Uri.parse(
      '${ApiConstants.baseUrl}${ApiConstants.userEndpoint}/$userId',
    );

    FancyLogger.apiRequest('DELETE', uri.toString());
    final response = await http.delete(uri, headers: headers);
    FancyLogger.apiResponse(
      'DELETE',
      uri.toString(),
      response.statusCode,
      response.body,
    );

    if (response.statusCode != 200 && response.statusCode != 204) {
      String errorMessage = 'Failed to delete user';
      try {
        final body = jsonDecode(response.body);
        if (body is Map<String, dynamic> && body['Message'] != null) {
          errorMessage = body['Message'];
        }
      } catch (_) {}
      throw Exception(errorMessage);
    }
  }

  // --- Orders ---

  Future<List<AdminOrder>> getAdminOrders({
    int page = 1,
    int pageSize = 10,
    String status = 'pending',
  }) async {
    final headers = await _getHeaders();
    final uri =
        Uri.parse(
          '${ApiConstants.baseUrl}${ApiConstants.orderEndpoint}/admin/all',
        ).replace(
          queryParameters: {
            'page': page.toString(),
            'pageSize': pageSize.toString(),
            'status': status,
          },
        );

    FancyLogger.apiRequest('GET', uri.toString());
    final response = await http.get(uri, headers: headers);
    FancyLogger.apiResponse(
      'GET',
      uri.toString(),
      response.statusCode,
      response.body,
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> responseData = jsonDecode(response.body);
      final List<dynamic> data = responseData['Data'] ?? [];
      return data.map((json) => AdminOrder.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load admin orders: ${response.statusCode}');
    }
  }

  Future<OrderStatistics> getOrderStatistics() async {
    final headers = await _getHeaders();
    final uri = Uri.parse(
      '${ApiConstants.baseUrl}${ApiConstants.orderEndpoint}/admin/statistics',
    );

    FancyLogger.apiRequest('GET', uri.toString());
    final response = await http.get(uri, headers: headers);
    FancyLogger.apiResponse(
      'GET',
      uri.toString(),
      response.statusCode,
      response.body,
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> responseData = jsonDecode(response.body);
      final Map<String, dynamic> data = responseData['Data'] ?? {};
      return OrderStatistics.fromJson(data);
    } else {
      throw Exception(
        'Failed to load order statistics: ${response.statusCode}',
      );
    }
  }

  Future<Map<String, dynamic>> approveOrder(int orderId) async {
    final headers = await _getHeaders();
    headers['Content-Type'] = 'application/json';
    final uri = Uri.parse(
      '${ApiConstants.baseUrl}${ApiConstants.orderEndpoint}/admin/$orderId/approve',
    );

    FancyLogger.apiRequest('POST', uri.toString());

    final response = await http.post(uri, headers: headers);

    FancyLogger.apiResponse(
      'POST',
      uri.toString(),
      response.statusCode,
      response.body,
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to approve order: ${response.body}');
    }
  }

  Future<Map<String, dynamic>> cancelOrder(int orderId, String reason) async {
    final headers = await _getHeaders();
    headers['Content-Type'] = 'application/json';
    final uri = Uri.parse(
      '${ApiConstants.baseUrl}${ApiConstants.orderEndpoint}/admin/$orderId/reject',
    );

    final body = {'Reason': reason};
    FancyLogger.apiRequest('POST', uri.toString(), body);

    final response = await http.post(
      uri,
      headers: headers,
      body: jsonEncode(body),
    );

    FancyLogger.apiResponse(
      'POST',
      uri.toString(),
      response.statusCode,
      response.body,
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to cancel order: ${response.body}');
    }
  }

  Future<Map<String, dynamic>> updateOrderStatus(
    int orderId,
    String status,
  ) async {
    final headers = await _getHeaders();
    headers['Content-Type'] = 'application/json';
    final uri = Uri.parse(
      '${ApiConstants.baseUrl}${ApiConstants.orderEndpoint}/admin/$orderId/status',
    );

    final body = {'Status': status};
    FancyLogger.apiRequest('PUT', uri.toString(), body);

    final response = await http.put(
      uri,
      headers: headers,
      body: jsonEncode(body),
    );

    FancyLogger.apiResponse(
      'PUT',
      uri.toString(),
      response.statusCode,
      response.body,
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to update order status: ${response.body}');
    }
  }
}
