import 'package:get/get.dart';
import '../../domain/models/venue_model.dart';
import '../../domain/models/booking_model.dart';
import '../../domain/models/user_model.dart';
import '../../domain/repositories/venue_repository.dart';
import '../../domain/repositories/booking_repository.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../routes/app_routes.dart';
import '../../shared/dialogs/custom_dialog.dart';

class DashboardController extends GetxController {
  final VenueRepository _venueRepository;
  final BookingRepository _bookingRepository;
  final AuthRepository _authRepository;

  DashboardController(
    this._venueRepository,
    this._bookingRepository,
    this._authRepository,
  );

  // Tab Indexing
  final RxInt currentIndex = 0.obs;

  // Active User Profile
  final Rxn<UserModel> user = Rxn<UserModel>();

  // Venues State
  final RxList<VenueModel> venues = <VenueModel>[].obs;
  final RxBool isVenuesLoading = false.obs;
  final RxnString venuesError = RxnString();

  // Bookings State
  final RxList<BookingModel> bookings = <BookingModel>[].obs;
  final RxBool isBookingsLoading = false.obs;
  final RxnString bookingsError = RxnString();
  final RxBool isOfflineMode = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadUserProfile();
    fetchVenues();
    fetchBookings();
  }

  // Load User Profile from storage
  Future<void> loadUserProfile() async {
    final cachedUser = await _authRepository.getCachedUser();
    if (cachedUser != null) {
      user.value = cachedUser;
    } else {
      // Session expired, redirect to login
      logout();
    }
  }

  // Fetch Venues from Network
  Future<void> fetchVenues() async {
    isVenuesLoading.value = true;
    venuesError.value = null;
    try {
      final list = await _venueRepository.getVenues();
      venues.assignAll(list);
    } catch (e) {
      venuesError.value = e.toString().replaceAll('Exception: ', '');
    } finally {
      isVenuesLoading.value = false;
    }
  }

  // Fetch Bookings from Network/Cache
  Future<void> fetchBookings({bool forceRefresh = false}) async {
    if (user.value == null) return;
    
    isBookingsLoading.value = true;
    bookingsError.value = null;
    isOfflineMode.value = false;

    try {
      // Check cached bookings first to see if offline mode fallback occurred
      final list = await _bookingRepository.getUserBookings(
        user.value!.id,
        forceRefresh: forceRefresh,
      );
      bookings.assignAll(list);

      // Verify if loaded cache only due to network failure
      final cachedOnly = await _bookingRepository.getCachedBookings();
      if (list.length == cachedOnly.length && forceRefresh == false) {
        // If we loaded cached bookings, check if server is unreachable
        // to show offline indicator banner
        isOfflineMode.value = true;
      }
    } catch (e) {
      // Fetch failed, try to load offline cache
      final cached = await _bookingRepository.getCachedBookings();
      if (cached.isNotEmpty) {
        bookings.assignAll(cached);
        isOfflineMode.value = true;
        CustomDialog.showSnackBar(
          title: 'Offline Mode',
          message: 'Displaying cached bookings. Some changes may not sync.',
          isError: true,
        );
      } else {
        bookingsError.value = e.toString().replaceAll('Exception: ', '');
      }
    } finally {
      isBookingsLoading.value = false;
    }
  }

  // Cancel Booking
  Future<void> cancelBooking(String bookingId) async {
    CustomDialog.showConfirmDialog(
      title: 'Cancel Booking',
      message: 'Are you sure you want to cancel this booking? This action cannot be undone.',
      confirmText: 'Yes, Cancel',
      onConfirm: () async {
        isBookingsLoading.value = true;
        try {
          await _bookingRepository.cancelBooking(bookingId);
          CustomDialog.showSnackBar(
            title: 'Booking Cancelled',
            message: 'Your slot reservation was successfully cancelled.',
          );
          // Refresh bookings list forcing network reload
          await fetchBookings(forceRefresh: true);
        } catch (e) {
          CustomDialog.showSnackBar(
            title: 'Cancellation Failed',
            message: e.toString().replaceAll('Exception: ', ''),
            isError: true,
          );
        } finally {
          isBookingsLoading.value = false;
        }
      },
    );
  }

  // Change Navigation Tab
  void changeTab(int index) {
    currentIndex.value = index;
    if (index == 0) {
      fetchVenues();
    } else if (index == 1) {
      fetchBookings();
    }
  }

  // Logout Session
  Future<void> logout() async {
    await _authRepository.logout();
    Get.offAllNamed(Routes.login);
  }
}
