import '../../domain/models/user_model.dart';
import '../../domain/repositories/auth_repository.dart';
import '../services/api_service.dart';
import '../services/storage_service.dart';

class AuthRepositoryImpl implements AuthRepository {
  final ApiService _apiService;
  final StorageService _storageService;

  AuthRepositoryImpl(this._apiService, this._storageService);

  @override
  Future<UserModel> login(String username, String password) async {
    final response = await _apiService.login(username, password);
    final responseData = response.data;
    if (responseData != null && responseData['success'] == true) {
      final data = responseData['data'] as Map<String, dynamic>;
      final token = data['token'] as String;
      final userJson = data['user'] as Map<String, dynamic>;
      
      // Save to local storage
      await _storageService.saveToken(token);
      await _storageService.saveUserData(userJson);

      return UserModel.fromJson(userJson);
    } else {
      throw Exception(responseData?['message'] ?? 'Login failed');
    }
  }

  @override
  Future<void> logout() async {
    await _storageService.clearAuth();
  }

  @override
  Future<UserModel?> getCachedUser() async {
    final userJson = _storageService.getUserData();
    if (userJson != null) {
      return UserModel.fromJson(userJson);
    }
    return null;
  }
}
