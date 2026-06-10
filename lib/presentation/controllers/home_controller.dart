import 'package:get/get.dart';
import '../../domain/models/user_model.dart';
import '../../domain/repositories/user_repository.dart';

class HomeController extends GetxController {
  final UserRepository _userRepository;

  HomeController(this._userRepository);

  final Rxn<UserModel> user = Rxn<UserModel>();
  final RxBool isLoading = false.obs;
  final RxnString errorMessage = RxnString();

  @override
  void onInit() {
    super.onInit();
    // Simulate fetching profile on initial load
    fetchUserProfile();
  }

  Future<void> fetchUserProfile() async {
    isLoading.value = true;
    errorMessage.value = null;
    try {
      final fetchedUser = await _userRepository.getUserProfile('123');
      user.value = fetchedUser;
    } catch (e) {
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }
}
