import '../models/user_model.dart';

abstract class AuthRepository {
  Future<UserModel> login(String username, String password);
  Future<void> logout();
  Future<UserModel?> getCachedUser();
}
