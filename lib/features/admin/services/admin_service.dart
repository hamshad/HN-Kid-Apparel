import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../../../core/services/api_client.dart';
import '../../../core/constants/api_constants.dart';
import '../../../core/services/storage_service.dart';
import '../models/admin_models.dart';

class AdminService {
  final StorageService _storageService;
  final ApiClient _client = ApiClient();

  AdminService(this._storageService);

  Future<Map<String, String>> _getHeaders() async {
    final token = await _storageService.getToken();
    return {
      'Authorization': 'Bearer $token',
      // Content-Type is handled automatically for Multipart, manual for JSON if needed
    };
  }

  // --- Brands ---

  Future<List<Brand>> getBrands(int page, int pageSize) async {
    final headers = await _getHeaders();
    final uri = Uri.parse(
            '${ApiConstants.baseUrl}${ApiConstants.brandEndpoint}')
        .replace(queryParameters: {
      'page': page.toString(),
      'pageSize': pageSize.toString(),
    });

    final response = await http.get(uri, headers: headers);

    if (response.statusCode == 200) {
      final Map<String, dynamic> responseData = jsonDecode(response.body);
      final List<dynamic> data = responseData['Data'] ?? [];
      return data.map((json) => Brand.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load brands: ${response.statusCode}');
    }
  }

  Future<Map<String, dynamic>> addBrand(String name, File imageFile) async {
    final headers = await _getHeaders();
    var request = http.MultipartRequest(
      'POST',
      Uri.parse('${ApiConstants.baseUrl}${ApiConstants.brandEndpoint}'),
    );

    request.headers.addAll(headers);
    request.fields['Name'] = name;

    // Check if file exists to avoid errors
    if (await imageFile.exists()) {
      request.files.add(await http.MultipartFile.fromPath(
        'Logo',
        imageFile.path,
      ));
    }

    final streamResponse = await request.send();
    final response = await http.Response.fromStream(streamResponse);

    if (response.statusCode == 200 || response.statusCode == 201) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to add brand: ${response.body}');
    }
  }

  // --- Categories ---

  Future<List<Category>> getCategories(int page, int pageSize) async {
    final headers = await _getHeaders();
    final uri = Uri.parse(
            '${ApiConstants.baseUrl}${ApiConstants.categoryEndpoint}')
        .replace(queryParameters: {
      'page': page.toString(),
      'pageSize': pageSize.toString(),
    });

    final response = await http.get(uri, headers: headers);

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
    var request = http.MultipartRequest(
      'POST',
      Uri.parse('${ApiConstants.baseUrl}${ApiConstants.categoryEndpoint}'),
    );

    request.headers.addAll(headers);
    request.fields['Name'] = name;

    if (await imageFile.exists()) {
      request.files.add(await http.MultipartFile.fromPath(
        'Image', // Assuming 'Image' based on requirement "Image:{image}"
        imageFile.path,
      ));
    }

    final streamResponse = await request.send();
    final response = await http.Response.fromStream(streamResponse);

    if (response.statusCode == 200 || response.statusCode == 201) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to add category: ${response.body}');
    }
  }

  // --- Series ---

  Future<List<Series>> getSeries(int page, int pageSize) async {
    final headers = await _getHeaders();
    final uri = Uri.parse(
            '${ApiConstants.baseUrl}${ApiConstants.seriesEndpoint}')
        .replace(queryParameters: {
      'page': page.toString(),
      'pageSize': pageSize.toString(),
    });

    final response = await http.get(uri, headers: headers);

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

      final response = await _client.post(
        Uri.parse('${ApiConstants.baseUrl}${ApiConstants.seriesEndpoint}'),
        headers: headers,
        body: jsonEncode({
          'Name': name,
        }),
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

  // --- Designs ---

  Future<List<Design>> getDesigns(int page, int pageSize) async {
    final headers = await _getHeaders();
    final uri = Uri.parse(
            '${ApiConstants.baseUrl}${ApiConstants.designEndpoint}')
        .replace(queryParameters: {
      'page': page.toString(),
      'pageSize': pageSize.toString(),
    });

    final response = await http.get(uri, headers: headers);

    if (response.statusCode == 200) {
      final Map<String, dynamic> responseData = jsonDecode(response.body);
      final List<dynamic> data = responseData['Data'] ?? [];
      return data.map((json) => Design.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load designs: ${response.statusCode}');
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
    var request = http.MultipartRequest(
      'POST',
      Uri.parse('${ApiConstants.baseUrl}${ApiConstants.designEndpoint}'),
    );

    request.headers.addAll(headers);
    request.fields['Title'] = title;
    request.fields['DesignNumber'] = designNumber;
    request.fields['CategoryId'] = categoryId.toString();
    request.fields['SeriesId'] = seriesId.toString();
    request.fields['BrandId'] = brandId.toString();
    request.fields['IsNew'] = isNew.toString();

    final streamResponse = await request.send();
    final response = await http.Response.fromStream(streamResponse);

    if (response.statusCode == 200 || response.statusCode == 201) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to add design: ${response.body}');
    }
  }
}