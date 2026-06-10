import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../routes/app_routes.dart';

class AuthController extends GetxController {
  final AuthRepository _authRepository;

  AuthController(this._authRepository);

  final usernameController = TextEditingController();
  final passwordController = TextEditingController();

  final RxBool isLoading = false.obs;
  final RxnString errorMessage = RxnString();
  final RxBool isPasswordVisible = false.obs;

  @override
  void onClose() {
    usernameController.dispose();
    passwordController.dispose();
    super.onClose();
  }

  Future<void> login() async {
    final username = usernameController.text.trim();
    final password = passwordController.text;

    if (username.isEmpty || password.isEmpty) {
      errorMessage.value = 'Please enter both username and password';
      return;
    }

    isLoading.value = true;
    errorMessage.value = null;

    try {
      await _authRepository.login(username, password);
      Get.offAllNamed(Routes.dashboard);
    } catch (e) {
      errorMessage.value = e.toString().replaceAll('Exception: ', '');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loginWithSeeded(String username, String password) async {
    usernameController.text = username;
    passwordController.text = password;
    await login();
  }

  void togglePasswordVisibility() {
    isPasswordVisible.value = !isPasswordVisible.value;
  }
}
