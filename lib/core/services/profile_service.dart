import 'package:stylclick/core/services/api_service.dart';
import 'package:stylclick/shared/endpoint.dart' as ep;
import 'package:stylclick/shared/models/api_model.dart';

class ProfileService {
  static ProfileService? _instance;
  ProfileService._();
  static ProfileService get instance {
    _instance ??= ProfileService._();
    return _instance!;
  }

  final _api = ApiService.instance;

  Future<ApiResponse<Map<String, dynamic>>> fetchProfile() =>
      _api.get<Map<String, dynamic>>(
        ep.getProfile,
        transform: (r) => Map<String, dynamic>.from(r as Map),
      );

  Future<ApiResponse<Map<String, dynamic>>> updateProfile({
    required String fullName,
    required String address,
    required String city,
    required String state,
    required String country,
  }) =>
      _api.patch<Map<String, dynamic>>(
        ep.updateProfile,
        body: {
          "full_name": fullName,
          "address": address,
          "city": city,
          "state": state,
          "country": country,
        },
        transform: (r) => Map<String, dynamic>.from(r as Map),
      );

  Future<ApiResponse<Map<String, dynamic>>> deleteAccount() =>
      _api.delete<Map<String, dynamic>>(
        ep.deleteAccount,
        transform: (r) => Map<String, dynamic>.from(r as Map),
      );
}
