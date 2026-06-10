import '../../domain/models/user_model.dart';
import '../../domain/repositories/user_repository.dart';
import '../services/api_service.dart';

class UserRepositoryImpl implements UserRepository {
  final ApiService _apiService;

  UserRepositoryImpl(this._apiService);

  @override
  Future<UserModel> getUserProfile(String userId) async {
    final response = await _apiService.getUserProfile(userId);
    if (response.data != null && response.data is Map<String, dynamic>) {
      return UserModel.fromJson(response.data as Map<String, dynamic>);
    } else {
      throw Exception('Invalid user data response');
    }
  }
}
