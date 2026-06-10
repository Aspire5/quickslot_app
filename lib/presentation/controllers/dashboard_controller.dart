import 'package:get/get.dart';
import '../../domain/models/venue_model.dart';
import '../../domain/models/booking_model.dart';
import '../../domain/models/user_model.dart';
import '../../domain/repositories/venue_repository.dart';
import '../../domain/repositories/booking_repository.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../routes/app_routes.dart';
import '../../shared/dialogs/custom_dialog.dart';
import '../../core/network/dio_client.dart';

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
      if (e is NoInternetException) {
        venuesError.value = e.message;
      } else {
        venuesError.value = e.toString().replaceAll('Exception: ', '');
      }
    } finally {
      isVenuesLoading.value = false;
    }
  }

  // Fetch Bookings from Network/Cache
  Future<void> fetchBookings({bool forceRefresh = false}) async {
    if (user.value == null) return;
    
    isBookingsLoading.value = bookings.isEmpty;
    bookingsError.value = null;

    // Load and show cached bookings immediately if they exist
    final cached = await _bookingRepository.getCachedBookings();
    if (cached != null) {
      bookings.assignAll(cached);
    }

    try {
      final list = await _bookingRepository.getUserBookings(
        user.value!.id,
        forceRefresh: forceRefresh || cached == null,
      );
      bookings.assignAll(list);
      isOfflineMode.value = false;
    } catch (e) {
      // Fetch failed, check if we can fall back to the cache
      final fallbackCached = await _bookingRepository.getCachedBookings();
      if (fallbackCached != null) {
        bookings.assignAll(fallbackCached);
        isOfflineMode.value = true;
        // If the user triggered a force refresh manually, show a helpful message
        if (forceRefresh) {
          CustomDialog.showSnackBar(
            title: 'Offline Mode',
            message: 'Could not refresh. Displaying cached bookings.',
            isError: true,
          );
        }
      } else {
        // No cache exists at all
        if (e is NoInternetException) {
          bookingsError.value = e.message;
        } else {
          bookingsError.value = e.toString().replaceAll('Exception: ', '');
        }
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
          String errorMsg;
          if (e is NoInternetException) {
            errorMsg = e.message;
          } else {
            errorMsg = e.toString().replaceAll('Exception: ', '');
          }
          CustomDialog.showSnackBar(
            title: 'Cancellation Failed',
            message: errorMsg,
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
