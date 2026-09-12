import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stylclick/core/services/api_service.dart';
import 'package:stylclick/shared/endpoint.dart';
import 'package:stylclick/shared/models/api_model.dart';
import 'package:nb_utils/nb_utils.dart';

class VendorService {
  static VendorService? _instance;
  VendorService._();
  static VendorService get instance {
    _instance ??= VendorService._();
    return _instance!;
  }

  final _api = ApiService.instance;

  // In-memory cache
  static dynamic _memoryCachedProducts;

  Future<dynamic> getCachedProducts() async {
    if (_memoryCachedProducts != null) {
      return _memoryCachedProducts;
    }
    try {
      final prefs = await SharedPreferences.getInstance();
      final cachedJson = prefs.getString('cached_public_products');
      if (cachedJson != null) {
        _memoryCachedProducts = json.decode(cachedJson);
        return _memoryCachedProducts;
      }
    } catch (e) {
      log('[VendorService] Error reading cached products: $e');
    }
    return null;
  }

  Future<void> cacheProducts(dynamic data) async {
    _memoryCachedProducts = data;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('cached_public_products', json.encode(data));
    } catch (e) {
      log('[VendorService] Error saving cached products: $e');
    }
  }

  // ── Become a Vendor / Designer ────────────────────────────────────────

  Future<ApiResponse<Map<String, dynamic>>> applyAsVendor({
    required String shopName,
    required String email,
    required String phone,
    required String address,
    required List<String> specializations,
    String? certificate,
  }) =>
      _api.post<Map<String, dynamic>>(
        becomeVendor,
        body: <String, dynamic>{
          "shop_name": shopName,
          "name": shopName,
          "business_name": shopName,
          "email": email,
          "phone": phone,
          "phone_number": phone,
          "address": address,
          "shop_address": address,
          "location": address,
          "specialization": specializations.join(','),
          "specializations": specializations.join(','),
          "type": "designer",
          "certificate": certificate ?? "https://placeholder.com/certificate.png",
          "cac": certificate ?? "https://placeholder.com/certificate.png",
          "cac_certificate": certificate ?? "https://placeholder.com/certificate.png",
          "documents": <String, dynamic>{
            "certificate": certificate ?? "https://placeholder.com/certificate.png",
          },
        },
        authenticated: true,
        transform: (r) => Map<String, dynamic>.from(r as Map),
      );

  // ── Become a Seller (Fabric Store) ────────────────────────────────────

  Future<ApiResponse<Map<String, dynamic>>> applyAsSeller({
    required String shopName,
    required String email,
    required String phone,
    required String address,
    required List<String> fabricTypes,
    String? certificate,
  }) =>
      _api.post<Map<String, dynamic>>(
        becomeSeller,
        body: <String, dynamic>{
          "shop_name": shopName,
          "name": shopName,
          "business_name": shopName,
          "email": email,
          "phone": phone,
          "phone_number": phone,
          "address": address,
          "shop_address": address,
          "location": address,
          "fabric_type": fabricTypes.join(','),
          "fabric_types": fabricTypes.join(','),
          "type": "seller",
          "certificate": certificate ?? "https://placeholder.com/certificate.png",
          "cac": certificate ?? "https://placeholder.com/certificate.png",
          "documents": <String, dynamic>{
            "certificate": certificate ?? "https://placeholder.com/certificate.png",
          },
        },
        authenticated: true,
        transform: (r) => Map<String, dynamic>.from(r as Map),
      );

  // ── Become a Rider ────────────────────────────────────────────────────

  Future<ApiResponse<Map<String, dynamic>>> applyAsRider({
    required String fullName,
    required String email,
    required String phone,
    required String address,
    required String vehicleType,
    required String vehicleMake,
    required String plateNumber,
    String? certificate,
  }) =>
      _api.post<Map<String, dynamic>>(
        becomeRider,
        body: <String, dynamic>{
          "full_name": fullName,
          "name": fullName,
          "email": email,
          "phone": phone,
          "phone_number": phone,
          "address": address,
          "shop_address": address,
          "location": address,
          "vehicle_type": vehicleType,
          "vehicle_make": vehicleMake,
          "plate_number": plateNumber,
          "vehicle_plate_number": plateNumber,
          "type": "rider",
          "certificate": certificate ?? "https://placeholder.com/certificate.png",
          "cac": certificate ?? "https://placeholder.com/certificate.png",
          "documents": <String, dynamic>{
            "certificate": certificate ?? "https://placeholder.com/certificate.png",
          },
        },
        authenticated: true,
        transform: (r) => Map<String, dynamic>.from(r as Map),
      );

  // ── Vendor Profile Management ──────────────────────────────────────────

  Future<ApiResponse<Map<String, dynamic>>> getProfile() =>
      _api.get<Map<String, dynamic>>(
        vendorProfile,
        authenticated: true,
        transform: (r) => Map<String, dynamic>.from(r as Map),
      );

  Future<ApiResponse<Map<String, dynamic>>> updateProfile(Map<String, dynamic> data) =>
      _api.patch<Map<String, dynamic>>(
        vendorProfile,
        body: data,
        authenticated: true,
        transform: (r) => Map<String, dynamic>.from(r as Map),
      );

  Future<ApiResponse<Map<String, dynamic>>> uploadMedia(Map<String, dynamic> data) =>
      _api.post<Map<String, dynamic>>(
        vendorUpload,
        body: data,
        authenticated: true,
        transform: (r) => Map<String, dynamic>.from(r as Map),
      );

  Future<ApiResponse<Map<String, dynamic>>> updateBusinessHours(Map<String, dynamic> data) =>
      _api.patch<Map<String, dynamic>>(
        vendorBusinessHours,
        body: data,
        authenticated: true,
        transform: (r) => Map<String, dynamic>.from(r as Map),
      );

  Future<ApiResponse<Map<String, dynamic>>> updatePolicies(Map<String, dynamic> data) =>
      _api.patch<Map<String, dynamic>>(
        vendorPolicies,
        body: data,
        authenticated: true,
        transform: (r) => Map<String, dynamic>.from(r as Map),
      );

  // ── Vendor Products Management ─────────────────────────────────────────

  Future<ApiResponse<Map<String, dynamic>>> createProduct(Map<String, dynamic> productData) =>
      _api.post<Map<String, dynamic>>(
        vendorProducts,
        body: productData,
        authenticated: true,
        transform: (r) => Map<String, dynamic>.from(r as Map),
      );

  Future<ApiResponse<dynamic>> getVendorProducts() =>
      _api.get<dynamic>(
        vendorProducts,
        authenticated: true,
      );

  Future<ApiResponse<Map<String, dynamic>>> updateProduct(String id, Map<String, dynamic> productData) =>
      _api.patch<Map<String, dynamic>>(
        "$vendorProducts/$id",
        body: productData,
        authenticated: true,
        transform: (r) => Map<String, dynamic>.from(r as Map),
      );

  Future<ApiResponse<dynamic>> deleteProduct(String id) =>
      _api.delete<dynamic>(
        "$vendorProducts/$id",
        authenticated: true,
      );

  Future<ApiResponse<Map<String, dynamic>>> uploadProductImage(Map<String, dynamic> data) =>
      _api.post<Map<String, dynamic>>(
        vendorUploadImage,
        body: data,
        authenticated: true,
        transform: (r) => Map<String, dynamic>.from(r as Map),
      );

  /// Upload multiple local image files for a product. Returns a list of public URL strings.
  Future<List<String>> uploadProductImages(List<String> localPaths) async {
    if (localPaths.isEmpty) return [];
    final res = await _api.postMultipart(
      vendorUploadImage,
      filePaths: localPaths,
      fileField: 'images',
    );
    if (res.status == true) {
      final d = res.data;
      if (d is List) {
        return d.map((e) => e.toString()).toList();
      } else if (d is Map) {
        final dataField = d['data'];
        final urlsField = d['urls'] ?? d['image_urls'] ?? d['images'];
        if (dataField is List) {
          return dataField.map((e) => e.toString()).toList();
        } else if (dataField is Map && dataField['urls'] is List) {
          return (dataField['urls'] as List).map((e) => e.toString()).toList();
        } else if (urlsField is List) {
          return urlsField.map((e) => e.toString()).toList();
        } else {
          final url = d['url']?.toString() ?? d['image_url']?.toString() ?? d['data']?.toString();
          if (url != null) return [url];
        }
      }
    }
    return [];
  }

  // ── Public Catalogue (No Auth Required) ──────────────────────────────────

  Future<ApiResponse<dynamic>> getPublicProducts() async {
    final res = await _api.get<dynamic>(
      publicProducts,
      authenticated: false,
    );
    if (res.status == true && res.data != null) {
      await cacheProducts(res.data);
    }
    return res;
  }

  Future<ApiResponse<dynamic>> getPublicVendorProfile(String vendorId) =>
      _api.get<dynamic>(
        "$publicVendorProfile/$vendorId",
        authenticated: false,
      );

  Future<ApiResponse<dynamic>> getPublicProductDetail(String id) =>
      _api.get<dynamic>(
        "$publicProducts/$id",
        authenticated: false,
      );
}

