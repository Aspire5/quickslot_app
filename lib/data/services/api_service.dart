import 'package:dio/dio.dart';
import '../../core/network/dio_client.dart';
import '../../core/constants/api_endpoints.dart';

class ApiService {
  final DioClient _dioClient;

  ApiService(this._dioClient);

  Future<Response> getUserProfile(String userId) async {
    return await _dioClient.get('${ApiEndpoints.users}/$userId');
  }
}
